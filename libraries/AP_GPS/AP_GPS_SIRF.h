// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: t -*-
//
//  SiRF Binary GPS driver for ArduPilot and ArduPilotMega.
//	Code by Michael Smith.
//
//	This library is free software; you can redistribute it and / or
//	modify it under the terms of the GNU Lesser General Public
//	License as published by the Free Software Foundation; either
//	version 2.1 of the License, or (at your option) any later version.
//
#ifndef AP_GPS_SIRF_h
#define AP_GPS_SIRF_h

#include "GPS.h"

#define SIRF_SET_BINARY	"$PSRF100,0,38400,8,1,0*3C"

class AP_GPS_SIRF : public GPS {
public:
    AP_GPS_SIRF(Stream *s);

    virtual void   	init();
    virtual bool	read();

private:
// XXX this is being ignored by the compiler #pragma pack(1)
    struct sirf_geonav {
        uint16_t	fix_invalid;
        uint16_t	fix_type;
        uint16_t	week;
        uint32_t	time;
        uint16_t	year;
        uint8_t		month;
        uint8_t		day;
        uint8_t		hour;
        uint8_t		minute;
        uint16_t	second;
        uint32_t	satellites_used;
        int32_t		latitude;
        int32_t		longitude;
        int32_t		altitude_ellipsoid;
        int32_t		altitude_msl;
        int8_t		map_datum;
        int16_t		ground_speed;
        int16_t		ground_course;
        int16_t		res1;
        int16_t		climb_rate;
        uint16_t	heading_rate;
        uint32_t	horizontal_position_error;
        uint32_t	vertical_position_error;
        uint32_t	time_error;
        int16_t		horizontal_velocity_error;
        int32_t		clock_bias;
        uint32_t	clock_bias_error;
        int32_t		clock_drift;
        uint32_t	clock_drift_error;
        uint32_t	distance;
        uint16_t	distance_error;
        uint16_t	heading_error;
        uint8_t		satellites;
        uint8_t		hdop;
        uint8_t		mode_info;
    };
// #pragma pack(pop)
    enum sirf_protocol_bytes {
        PREAMBLE1 = 0xa0,
        PREAMBLE2 = 0xa2,
        POSTAMBLE1 = 0xb0,
        POSTAMBLE2 = 0xb3,
        MSG_GEONAV = 0x29
    };
    enum sirf_fix_type {
        FIX_3D = 0x6,
        FIX_MASK = 0x7
    };


    // State machine state
    uint8_t			_step;
    uint16_t		_checksum;
    bool			_gather;
    uint16_t		_payload_length;
    uint16_t		_payload_counter;
    uint8_t			_msg_id;

    // Message buffer
    union {
        sirf_geonav		nav;
        uint8_t			bytes[];
    } _buffer;

    bool			_parse_gps(void);
    void			_accumulate(uint8_t val);
};

#endif // AP_GPS_SIRF_h
