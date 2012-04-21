// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: t -*-

#include "GPS.h"
#if defined(ARDUINO) && ARDUINO >= 100
	#include "Arduino.h"
#else
	#include "WProgram.h"
#endif

void
GPS::update(void)
{
    bool	result;

    // call the GPS driver to process incoming data
    result = read();

    // if we did not get a message, and the idle timer has expired, re-init
    if (!result) {
        if ((millis() - _idleTimer) > idleTimeout) {
            _status = NO_GPS;

            init();
            // reset the idle timer
            _idleTimer = millis();
        }
    } else {
        // we got a message, update our status correspondingly
        _status = fix ? GPS_OK : NO_FIX;

        valid_read = true;
        new_data = true;

        // reset the idle timer
        _idleTimer = millis();

		if (_status == GPS_OK) {
			// update our acceleration
			float deltat = 1.0e-3 * (_idleTimer - last_fix_time);
			float deltav = 1.0e-2 * ((float)ground_speed - (float)_last_ground_speed);
			last_fix_time = _idleTimer;
			_last_ground_speed = ground_speed;

			if (deltat > 2.0 || deltat == 0) {
				// we didn't get a fix for 2 seconds - set
				// acceleration to zero, as the estimate will be too
				// far out
				_acceleration = 0;
			} else {
				// calculate a mildly smoothed acceleration value
				_acceleration = (0.7 * _acceleration) + (0.3 * (deltav/deltat));
			}
		}
    }
}

void
GPS::setHIL(long _time, float _latitude, float _longitude, float _altitude,
            float _ground_speed, float _ground_course, float _speed_3d, uint8_t _num_sats)
{
}

// XXX this is probably the wrong way to do it, too
void
GPS::_error(const char *msg)
{
    Serial.println(msg);
}
