// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: t -*-
//
//  Hardware in the loop gps class.
//  Code by James Goppert
//
//	This library is free software; you can redistribute it and / or
//	modify it under the terms of the GNU Lesser General Public
//	License as published by the Free Software Foundation; either
//	version 2.1 of the License, or (at your option) any later version.
//
//
#ifndef AP_GPS_HIL_h
#define AP_GPS_HIL_h

#include "GPS.h"

class AP_GPS_HIL : public GPS {
public:
    AP_GPS_HIL(Stream *s);
    virtual void init(void);
    virtual bool read(void);

    /**
     * Hardware in the loop set function
     * @param latitude  - latitude in deggrees
     * @param longitude - longitude in degrees
     * @param altitude - altitude in degrees
     * @param ground_speed - ground speed in meters/second
     * @param ground_course - ground course in degrees
     * @param speed_3d - ground speed in meters/second
     * @param altitude - altitude in meters
     */
    virtual void setHIL(long time, float latitude, float longitude, float altitude,
                        float ground_speed, float ground_course, float speed_3d, uint8_t num_sats);

private:
    bool	_updated;
};

#endif	// AP_GPS_HIL_H
