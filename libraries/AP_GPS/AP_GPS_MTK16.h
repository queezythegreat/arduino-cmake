// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: t -*-
//
//  DIYDrones Custom Mediatek GPS driver for ArduPilot and ArduPilotMega.
//	Code by Michael Smith, Jordi Munoz and Jose Julio, DIYDrones.com
//
//	This library is free software; you can redistribute it and / or
//	modify it under the terms of the GNU Lesser General Public
//	License as published by the Free Software Foundation; either
//	version 2.1 of the License, or (at your option) any later version.
//
//	GPS configuration : Custom protocol per "Customize Function Specification, 3D Robotics, v1.6"
//
#ifndef AP_GPS_MTK16_h
#define AP_GPS_MTK16_h

#include "GPS.h"
#include "AP_GPS_MTK_Common.h"

class AP_GPS_MTK16 : public GPS {
public:
    AP_GPS_MTK16(Stream *s);
    virtual void	init(void);
    virtual bool	read(void);

private:
// XXX this is being ignored by the compiler #pragma pack(1)
    struct diyd_mtk_msg {
        int32_t		latitude;
        int32_t		longitude;
        int32_t		altitude;
        int32_t		ground_speed;
        int32_t		ground_course;
        uint8_t		satellites;
        uint8_t		fix_type;
        uint32_t	utc_date;
        uint32_t	utc_time;
        uint16_t	hdop;
    };
// #pragma pack(pop)
    enum diyd_mtk_fix_type {
        FIX_NONE = 1,
        FIX_2D = 2,
        FIX_3D = 3
    };

    enum diyd_mtk_protocol_bytes {
        PREAMBLE1 = 0xd0,
        PREAMBLE2 = 0xdd,
    };

    // Packet checksum accumulators
    uint8_t 	_ck_a;
    uint8_t 	_ck_b;

    // State machine state
    uint8_t 	_step;
    uint8_t		_payload_counter;

    // Time from UNIX Epoch offset
    long		_time_offset;
    bool		_offset_calculated;

    // Receive buffer
    union {
        diyd_mtk_msg	msg;
        uint8_t			bytes[];
    } _buffer;
};

#endif	// AP_GPS_MTK16_H
