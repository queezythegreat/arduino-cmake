// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

/*
 * AP_Relay.h
 *
 *  Created on: Oct 2, 2011
 *      Author: Amilcar Lucas
 */

/// @file	AP_Relay.h
/// @brief	APM relay control class

#ifndef AP_RELAY_H_
#define AP_RELAY_H_

/// @class	AP_Relay
/// @brief	Class to manage the APM relay
class AP_Relay{
public:
	// activate the relay
	void on();

	// de-activate the relay
	void off();

	// toggle the relay status
	void toggle();

	// set the relay status (on/off)
	void set(bool status);

	// get the relay status (on/off)
	bool get();
};


#endif /* AP_RELAY_H_ */
