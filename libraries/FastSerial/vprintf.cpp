// -*- Mode: C++; c-basic-offset: 8; indent-tabs-mode: nil -*-
/*
   Adapted from the avr-libc vfprintf:

   Copyright (c) 2002, Alexander Popov (sasho@vip.bg)
   Copyright (c) 2002,2004,2005 Joerg Wunsch
   Copyright (c) 2005, Helmut Wallner
   Copyright (c) 2007, Dmitry Xmelkov
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

   * Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the
   distribution.
   * Neither the name of the copyright holders nor the names of
   contributors may be used to endorse or promote products derived
   from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
*/

/* From: Id: printf_p_new.c,v 1.1.1.9 2002/10/15 20:10:28 joerg_wunsch Exp */
/* $Id: vfprintf.c,v 1.18.2.1 2009/04/01 23:12:06 arcanum Exp $ */

#include "BetterStream.h"

#include <avr/pgmspace.h>
#include <stdarg.h>
#include <string.h>
extern "C" {
#include "ftoa_engine.h"
#include "ntz.h"
#include "xtoa_fast.h"
}

// workaround for GCC bug c++/34734
#undef PROGMEM 
#define PROGMEM __attribute__(( section(".progmem.data") )) 
#undef PSTR 
#define PSTR(s) (__extension__({static prog_char __c[] PROGMEM = (s); &__c[0];})) 

#define GETBYTE(flag, mask, pnt)        ({                              \
                        unsigned char __c;                              \
                        asm (                                           \
                             "sbrc      %2,%3   \n\t"                   \
                             "lpm       %0,Z+   \n\t"                   \
                             "sbrs      %2,%3   \n\t"                   \
                             "ld        %0,Z+   "                       \
                             : "=r" (__c),                              \
                               "+z" (pnt)                               \
                             : "r" (flag),                              \
                               "I" (ntz(mask))                          \
                        );                                              \
                        __c;                                            \
                })

#define FL_ZFILL	0x01
#define FL_PLUS		0x02
#define FL_SPACE	0x04
#define FL_LPAD		0x08
#define FL_ALT		0x10
#define FL_WIDTH	0x20
#define FL_PREC		0x40
#define FL_LONG		0x80

#define FL_PGMSTRING	FL_LONG
#define FL_NEGATIVE	FL_LONG

#define FL_ALTUPP	FL_PLUS
#define FL_ALTHEX	FL_SPACE

#define	FL_FLTUPP	FL_ALT
#define FL_FLTEXP	FL_PREC
#define	FL_FLTFIX	FL_LONG

#ifdef DESKTOP_BUILD
void
BetterStream::_vprintf (unsigned char in_progmem, const char *fmt, va_list ap)
{
        char *str = NULL;
        int i;
        char *fmt2 = strdup(fmt);
        for (i=0; fmt2[i]; i++) {
                // cope with %S
                if (fmt2[i] == '%' && fmt2[i+1] == 'S') {
                        fmt2[i+1] = 's';
                }
        }
        vasprintf(&str, fmt2, ap);
        for (i=0; str[i]; i++) {
                write(str[i]);
        }
        free(str);
        free(fmt2);
}
#else
void
BetterStream::_vprintf (unsigned char in_progmem, const char *fmt, va_list ap)
{
        unsigned char c;        /* holds a char from the format string */
        unsigned char flags;
        unsigned char width;
        unsigned char prec;
        unsigned char buf[11];  /* size for -1 in octal, without '\0'   */

        for (;;) {

                /*
                 * Process non-format characters
                 */
                for (;;) {
                        c = GETBYTE (in_progmem, 1, fmt);
                        if (!c) return;
                        if (c == '%') {
                                c = GETBYTE (in_progmem, 1, fmt);
                                if (c != '%') break;
                        }
                        /* emit cr before lf to make most terminals happy */
                        if (c == '\n')
                                write('\r');
                        write(c);
                }

                flags = 0;
                width = 0;
                prec = 0;
                
                /*
                 * Process format adjustment characters, precision, width.
                 */
                do {
                        if (flags < FL_WIDTH) {
                                switch (c) {
                                case '0':
                                        flags |= FL_ZFILL;
                                        continue;
                                case '+':
                                        flags |= FL_PLUS;
                                        /* FALLTHROUGH */
                                case ' ':
                                        flags |= FL_SPACE;
                                        continue;
                                case '-':
                                        flags |= FL_LPAD;
                                        continue;
                                case '#':
                                        flags |= FL_ALT;
                                        continue;
                                }
                        }

                        if (flags < FL_LONG) {
                                if (c >= '0' && c <= '9') {
                                        c -= '0';
                                        if (flags & FL_PREC) {
                                                prec = 10*prec + c;
                                                continue;
                                        }
                                        width = 10*width + c;
                                        flags |= FL_WIDTH;
                                        continue;
                                }
                                if (c == '.') {
                                        if (flags & FL_PREC)
                                                return;
                                        flags |= FL_PREC;
                                        continue;
                                }
                                if (c == 'l') {
                                        flags |= FL_LONG;
                                        continue;
                                }
                                if (c == 'h')
                                        continue;
                        }
            
                        break;
                } while ( (c = GETBYTE (in_progmem, 1, fmt)) != 0);

                /*
                 * Handle floating-point formats E, F, G, e, f, g.
                 */
                if (c >= 'E' && c <= 'G') {
                        flags |= FL_FLTUPP;
                        c += 'e' - 'E';
                        goto flt_oper;

                } else if (c >= 'e' && c <= 'g') {

                        int exp;                /* exponent of master decimal digit     */
                        int n;
                        unsigned char vtype;    /* result of float value parse  */
                        unsigned char sign;     /* sign character (or 0)        */
                        unsigned char ndigs;

                        flags &= ~FL_FLTUPP;

                flt_oper:
                        if (!(flags & FL_PREC))
                                prec = 6;
                        flags &= ~(FL_FLTEXP | FL_FLTFIX);
                        if (c == 'e')
                                flags |= FL_FLTEXP;
                        else if (c == 'f')
                                flags |= FL_FLTFIX;
                        else if (prec > 0)
                                prec -= 1;

                        if (flags & FL_FLTFIX) {
                                vtype = 7;              /* 'prec' arg for 'ftoa_engine' */
                                ndigs = prec < 60 ? prec + 1 : 60;
                        } else {
                                if (prec > 7) prec = 7;
                                vtype = prec;
                                ndigs = 0;
                        }
                        exp = __ftoa_engine (va_arg(ap,double), (char *)buf, vtype, ndigs);
                        vtype = buf[0];
    
                        sign = 0;
                        if ((vtype & FTOA_MINUS) && !(vtype & FTOA_NAN))
                                sign = '-';
                        else if (flags & FL_PLUS)
                                sign = '+';
                        else if (flags & FL_SPACE)
                                sign = ' ';

                        if (vtype & (FTOA_NAN | FTOA_INF)) {
                                const char *p;
                                ndigs = sign ? 4 : 3;
                                if (width > ndigs) {
                                        width -= ndigs;
                                        if (!(flags & FL_LPAD)) {
                                                do {
                                                        write(' ');
                                                } while (--width);
                                        }
                                } else {
                                        width = 0;
                                }
                                if (sign)
                                        write(sign);
                                p = PSTR("inf");
                                if (vtype & FTOA_NAN)
                                        p = PSTR("nan");
                                while ( (ndigs = pgm_read_byte((const prog_char *)p)) != 0) {
                                        if (flags & FL_FLTUPP)
                                                ndigs += 'I' - 'i';
                                        write(ndigs);
                                        p++;
                                }
                                goto tail;
                        }

                        /* Output format adjustment, number of decimal digits in buf[] */
                        if (flags & FL_FLTFIX) {
                                ndigs += exp;
                                if ((vtype & FTOA_CARRY) && buf[1] == '1')
                                        ndigs -= 1;
                                if ((signed char)ndigs < 1)
                                        ndigs = 1;
                                else if (ndigs > 8)
                                        ndigs = 8;
                        } else if (!(flags & FL_FLTEXP)) {              /* 'g(G)' format */
                                if (exp <= prec && exp >= -4)
                                        flags |= FL_FLTFIX;
                                while (prec && buf[1+prec] == '0')
                                        prec--;
                                if (flags & FL_FLTFIX) {
                                        ndigs = prec + 1;               /* number of digits in buf */
                                        prec = prec > exp
                                                ? prec - exp : 0;       /* fractional part length  */
                                }
                        }
    
                        /* Conversion result length, width := free space length */
                        if (flags & FL_FLTFIX)
                                n = (exp>0 ? exp+1 : 1);
                        else
                                n = 5;          /* 1e+00 */
                        if (sign) n += 1;
                        if (prec) n += prec + 1;
                        width = width > n ? width - n : 0;
    
                        /* Output before first digit    */
                        if (!(flags & (FL_LPAD | FL_ZFILL))) {
                                while (width) {
                                        write(' ');
                                        width--;
                                }
                        }
                        if (sign) write(sign);
                        if (!(flags & FL_LPAD)) {
                                while (width) {
                                        write('0');
                                        width--;
                                }
                        }
    
                        if (flags & FL_FLTFIX) {                /* 'f' format           */

                                n = exp > 0 ? exp : 0;          /* exponent of left digit */
                                do {
                                        if (n == -1)
                                                write('.');
                                        flags = (n <= exp && n > exp - ndigs)
                                                ? buf[exp - n + 1] : '0';
                                        if (--n < -prec)
                                                break;
                                        write(flags);
                                } while (1);
                                if (n == exp
                                    && (buf[1] > '5'
                                        || (buf[1] == '5' && !(vtype & FTOA_CARRY))) )
                                        {
                                                flags = '1';
                                        }
                                write(flags);
        
                        } else {                                /* 'e(E)' format        */

                                /* mantissa     */
                                if (buf[1] != '1')
                                        vtype &= ~FTOA_CARRY;
                                write(buf[1]);
                                if (prec) {
                                        write('.');
                                        sign = 2;
                                        do {
                                                write(buf[sign++]);
                                        } while (--prec);
                                }

                                /* exponent     */
                                write(flags & FL_FLTUPP ? 'E' : 'e');
                                ndigs = '+';
                                if (exp < 0 || (exp == 0 && (vtype & FTOA_CARRY) != 0)) {
                                        exp = -exp;
                                        ndigs = '-';
                                }
                                write(ndigs);
                                for (ndigs = '0'; exp >= 10; exp -= 10)
                                        ndigs += 1;
                                write(ndigs);
                                write('0' + exp);
                        }

                        goto tail;
                }

                /*
                 * Handle string formats c, s, S.
                 */
                {
                        const char * pnt;
                        size_t size;

                        switch (c) {

                        case 'c':
                                buf[0] = va_arg (ap, int);
                                pnt = (char *)buf;
                                size = 1;
                                goto no_pgmstring;

                        case 's':
                                pnt = va_arg (ap, char *);
                                size = strnlen (pnt, (flags & FL_PREC) ? prec : ~0);
                        no_pgmstring:
                                flags &= ~FL_PGMSTRING;
                                goto str_lpad;

                        case 'S':
                        // pgmstring: // not yet used
                                pnt = va_arg (ap, char *);
                                size = strnlen_P (pnt, (flags & FL_PREC) ? prec : ~0);
                                flags |= FL_PGMSTRING;

                        str_lpad:
                                if (!(flags & FL_LPAD)) {
                                        while (size < width) {
                                                write(' ');
                                                width--;
                                        }
                                }
                                while (size) {
                                        write(GETBYTE (flags, FL_PGMSTRING, pnt));
                                        if (width) width -= 1;
                                        size -= 1;
                                }
                                goto tail;
                        }
                }

                /*
                 * Handle integer formats variations for d/i, u, o, p, x, X.
                 */
                if (c == 'd' || c == 'i') {
                        long x = (flags & FL_LONG) ? va_arg(ap,long) : va_arg(ap,int);
                        flags &= ~(FL_NEGATIVE | FL_ALT);
                        if (x < 0) {
                                x = -x;
                                flags |= FL_NEGATIVE;
                        }
                        c = __ultoa_invert (x, (char *)buf, 10) - (char *)buf;

                } else {
                        int base;

                        if (c == 'u') {
                                flags &= ~FL_ALT;
                                base = 10;
                                goto ultoa;
                        }

                        flags &= ~(FL_PLUS | FL_SPACE);

                        switch (c) {
                        case 'o':
                                base = 8;
                                goto ultoa;
                        case 'p':
                                flags |= FL_ALT;
                                /* no break */
                        case 'x':
                                if (flags & FL_ALT)
                                        flags |= FL_ALTHEX;
                                base = 16;
                                goto ultoa;
                        case 'X':
                                if (flags & FL_ALT)
                                        flags |= (FL_ALTHEX | FL_ALTUPP);
                                base = 16 | XTOA_UPPER;
                        ultoa:
                                c = __ultoa_invert ((flags & FL_LONG)
                                                    ? va_arg(ap, unsigned long)
                                                    : va_arg(ap, unsigned int),
                                                    (char *)buf, base)  -  (char *)buf;
                                flags &= ~FL_NEGATIVE;
                                break;

                        default:
                                return;
                        }
                }

                /*
                 * Format integers.
                 */
                {
                        unsigned char len;

                        len = c;
                        if (flags & FL_PREC) {
                                flags &= ~FL_ZFILL;
                                if (len < prec) {
                                        len = prec;
                                        if ((flags & FL_ALT) && !(flags & FL_ALTHEX))
                                                flags &= ~FL_ALT;
                                }
                        }
                        if (flags & FL_ALT) {
                                if (buf[c-1] == '0') {
                                        flags &= ~(FL_ALT | FL_ALTHEX | FL_ALTUPP);
                                } else {
                                        len += 1;
                                        if (flags & FL_ALTHEX)
                                                len += 1;
                                }
                        } else if (flags & (FL_NEGATIVE | FL_PLUS | FL_SPACE)) {
                                len += 1;
                        }

                        if (!(flags & FL_LPAD)) {
                                if (flags & FL_ZFILL) {
                                        prec = c;
                                        if (len < width) {
                                                prec += width - len;
                                                len = width;
                                        }
                                }
                                while (len < width) {
                                        write(' ');
                                        len++;
                                }
                        }
        
                        width =  (len < width) ? width - len : 0;

                        if (flags & FL_ALT) {
                                write('0');
                                if (flags & FL_ALTHEX)
                                        write(flags & FL_ALTUPP ? 'X' : 'x');
                        } else if (flags & (FL_NEGATIVE | FL_PLUS | FL_SPACE)) {
                                unsigned char z = ' ';
                                if (flags & FL_PLUS) z = '+';
                                if (flags & FL_NEGATIVE) z = '-';
                                write(z);
                        }
                
                        while (prec > c) {
                                write('0');
                                prec--;
                        }
        
                        do {
                                write(buf[--c]);
                        } while (c);
                }
        
        tail:
                /* Tail is possible.    */
                while (width) {
                        write(' ');
                        width--;
                }
        } /* for (;;) */
}
#endif // DESKTOP_BUILD
