/*
	ADC.cpp - Analog Digital Converter Base Class for Ardupilot Mega
	Code by James Goppert. DIYDrones.com

	This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.
*/

#include "AP_OpticalFlow.h"

#define FORTYFIVE_DEGREES 0.78539816

AP_OpticalFlow* AP_OpticalFlow::_sensor = NULL;  // pointer to the last instantiated optical flow sensor.  Will be turned into a table if we ever add support for more than one sensor

// init - initCommAPI parameter controls whether I2C/SPI interface is initialised (set to false if other devices are on the I2C/SPI bus and have already initialised the interface)
bool
AP_OpticalFlow::init(bool initCommAPI)
{
	_orientation = ROTATION_NONE;
	update_conversion_factors();
	return true;  // just return true by default
}

// set_orientation - Rotation vector to transform sensor readings to the body frame.
void
AP_OpticalFlow::set_orientation(enum Rotation rotation)
{
    _orientation = rotation;
}

// read value from the sensor.  Should be overridden by derived class
bool
AP_OpticalFlow::update()
{
	return true;
}

// reads a value from the sensor (will be sensor specific)
byte
AP_OpticalFlow::read_register(byte address)
{
	return 0;
}

// writes a value to one of the sensor's register (will be sensor specific)
void
AP_OpticalFlow::write_register(byte address, byte value)
{
}

// rotate raw values to arrive at final x,y,dx and dy values
void
AP_OpticalFlow::apply_orientation_matrix()
{
	Vector3f rot_vector;
	rot_vector(raw_dx, raw_dy, 0);

	// next rotate dx and dy
	rot_vector.rotate(_orientation);

	dx = rot_vector.x;
	dy = rot_vector.y;

	// add rotated values to totals (perhaps this is pointless as we need to take into account yaw, roll, pitch)
	x += dx;
	y += dy;
}

// updatse conversion factors that are dependent upon field_of_view
void
AP_OpticalFlow::update_conversion_factors()
{
	conv_factor = (1.0 / (float)(num_pixels * scaler)) * 2.0 * tan(field_of_view / 2.0);	// multiply this number by altitude and pixel change to get horizontal move (in same units as altitude)
	// 0.00615
	radians_to_pixels = (num_pixels * scaler) / field_of_view;
	// 162.99
}

// updates internal lon and lat with estimation based on optical flow
void
AP_OpticalFlow::update_position(float roll, float pitch, float cos_yaw_x, float sin_yaw_y, float altitude)
{
    float diff_roll 	= roll  - _last_roll;
    float diff_pitch 	= pitch - _last_pitch;

	// only update position if surface quality is good and angle is not over 45 degrees
	if( surface_quality >= 10 && fabs(roll) <= FORTYFIVE_DEGREES && fabs(pitch) <= FORTYFIVE_DEGREES ) {
		altitude = max(altitude, 0);
		// calculate expected x,y diff due to roll and pitch change
		exp_change_x = diff_roll * radians_to_pixels;
		exp_change_y = -diff_pitch * radians_to_pixels;

		// real estimated raw change from mouse
		change_x = dx - exp_change_x;
		change_y = dy - exp_change_y;

		float avg_altitude = (altitude + _last_altitude)*0.5;

		// convert raw change to horizontal movement in cm
		x_cm = -change_x * avg_altitude * conv_factor;    // perhaps this altitude should actually be the distance to the ground?  i.e. if we are very rolled over it should be longer?
		y_cm = -change_y * avg_altitude * conv_factor;    // for example if you are leaned over at 45 deg the ground will appear farther away and motion from opt flow sensor will be less

		// convert x/y movements into lon/lat movement
		vlon = x_cm * sin_yaw_y + y_cm * cos_yaw_x;
		vlat = y_cm * sin_yaw_y - x_cm * cos_yaw_x;
	}

	_last_altitude = altitude;
	_last_roll = roll;
	_last_pitch = pitch;
}
