// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: t -*-

#ifndef AP_GPS_None_h
#define AP_GPS_None_h

#include "GPS.h"

class AP_GPS_None : public GPS
{
public:
    AP_GPS_None(Stream *s) : GPS(s) {}
    virtual void init(void) {};
    virtual bool read(void) {
        return false;
    };
};
#endif
