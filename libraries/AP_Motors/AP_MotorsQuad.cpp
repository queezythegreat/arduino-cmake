/*
	AP_MotorsQuad.cpp - ArduCopter motors library
	Code by RandyMackay. DIYDrones.com

	This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.
*/

#include "AP_MotorsQuad.h"

// setup_motors - configures the motors for a quad
void AP_MotorsQuad::setup_motors()
{
	// call parent
	AP_MotorsMatrix::setup_motors();

	// hard coded config for supported frames
	if( _frame_orientation == AP_MOTORS_PLUS_FRAME ) {
		// plus frame set-up
		add_motor(AP_MOTORS_MOT_1,  90, AP_MOTORS_MATRIX_MOTOR_CCW, AP_MOTORS_MOT_2, 2);
		add_motor(AP_MOTORS_MOT_2, -90, AP_MOTORS_MATRIX_MOTOR_CCW, AP_MOTORS_MOT_1, 4);
		add_motor(AP_MOTORS_MOT_3,   0, AP_MOTORS_MATRIX_MOTOR_CW,  AP_MOTORS_MOT_4, 1);
		add_motor(AP_MOTORS_MOT_4, 180, AP_MOTORS_MATRIX_MOTOR_CW,  AP_MOTORS_MOT_3, 3);
	}else{
		// X frame set-up
		add_motor(AP_MOTORS_MOT_1,   45, AP_MOTORS_MATRIX_MOTOR_CCW, AP_MOTORS_MOT_2, 1);
		add_motor(AP_MOTORS_MOT_2, -135, AP_MOTORS_MATRIX_MOTOR_CCW, AP_MOTORS_MOT_1, 3);
		add_motor(AP_MOTORS_MOT_3,  -45, AP_MOTORS_MATRIX_MOTOR_CW,  AP_MOTORS_MOT_4, 4);
		add_motor(AP_MOTORS_MOT_4,  135, AP_MOTORS_MATRIX_MOTOR_CW,  AP_MOTORS_MOT_3, 2);
	}
}
