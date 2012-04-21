// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

// Example config file. Take a look at config.h. Any term define there can be overridden by defining it here.

// # define CONFIG_APM_HARDWARE APM_HARDWARE_APM2
// # define APM2_BETA_HARDWARE

// GPS is auto-selected

//#define MAG_ORIENTATION		AP_COMPASS_COMPONENTS_DOWN_PINS_FORWARD
//#define HIL_MODE				HIL_MODE_ATTITUDE

//#define FRAME_CONFIG QUAD_FRAME
	/*
	options:
	QUAD_FRAME
	TRI_FRAME
	HEXA_FRAME
	Y6_FRAME
	OCTA_FRAME
	OCTA_QUAD_FRAME
	HELI_FRAME
	*/

//#define FRAME_ORIENTATION X_FRAME
	/*
	PLUS_FRAME
	X_FRAME
	V_FRAME
	*/

//# define CH7_OPTION		CH7_SAVE_WP
	/*
	CH7_DO_NOTHING
	CH7_SET_HOVER
	CH7_FLIP
	CH7_SIMPLE_MODE
	CH7_RTL
	CH7_AUTO_TRIM
	CH7_ADC_FILTER (experimental)
	CH7_SAVE_WP
	*/

#define ACCEL_ALT_HOLD 0		// disabled by default, work in progress


//#define RATE_ROLL_I 	0.18
//#define RATE_PITCH_I	0.18
//#define MOTORS_JD880
//#define MOTORS_JD850


// agmatthews USERHOOKS
// the choice of function names is up to the user and does not have to match these
// uncomment these hooks and ensure there is a matching function un your "UserCode.pde" file
//#define USERHOOK_FASTLOOP userhook_FastLoop();
#define USERHOOK_50HZLOOP userhook_50Hz();
//#define USERHOOK_MEDIUMLOOP userhook_MediumLoop();
//#define USERHOOK_SLOWLOOP userhook_SlowLoop();
//#define USERHOOK_SUPERSLOWLOOP userhook_SuperSlowLoop();
#define USERHOOK_INIT userhook_init();

// the choice of includeed variables file (*.h) is up to the user and does not have to match this one
// Ensure the defined file exists and is in the arducopter directory
#define USERHOOK_VARIABLES "UserVariables.h"

// to enable, set to 1
// to disable, set to 0
#define AUTO_THROTTLE_HOLD 1

//# define LOGGING_ENABLED		DISABLED


// Custom channel config - Expert Use Only.
// this for defining your own MOT_n to CH_n mapping.
// Overrides defaults (for APM1 or APM2) found in config_channels.h
// MOT_n variables are used by the Frame mixing code. You must define
// MOT_1 through MOT_m where m is the number of motors on your frame.
// CH_n variables are used for RC output. These can be CH_1 through CH_8,
// and CH_10 or CH_12. 
// Sample channel config. Must define all MOT_ chanels used by
// your FRAME_TYPE.
// #define CONFIG_CHANNELS CHANNEL_CONFIG_CUSTOM
// #define MOT_1 CH_6
// #define MOT_2 CH_3
// #define MOT_3 CH_2
// #define MOT_4 CH_5
// #define MOT_5 CH_1
// #define MOT_6 CH_4
// #define MOT_7 CH_7
// #define MOT_8 CH_8
