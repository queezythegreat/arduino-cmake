
#ifndef __PERIODICPROCESS_H__
#define __PERIODICPROCESS_H__

#include <stdint.h>

// the callback type for periodic processes. They are passed the time
// in microseconds since boot 
typedef void (*ap_procedure)(uint32_t );

class AP_PeriodicProcess
{
    public:
        virtual void register_process(ap_procedure proc) = 0;
        virtual void set_failsafe(ap_procedure proc) = 0;
};

#endif // __PERIODICPROCESS_H__
