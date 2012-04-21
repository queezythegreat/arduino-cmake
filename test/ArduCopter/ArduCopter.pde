/// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

#define THISFIRMWARE "ArduCopter V2.5.3"
/*
ArduCopter Version 2.5
Lead author:	Jason Short
Based on code and ideas from the Arducopter team: Randy Mackay, Pat Hickey, Jose Julio, Jani Hirvinen, Andrew Tridgell, Justin Beech, Adam Rivera, Jean-Louis Naudin, Roberto Navoni
Thanks to:	Chris Anderson, Mike Smith, Jordi Munoz, Doug Weibel, James Goppert, Benjamin Pelletier, Robert Lefebvre, Marco Robustini

This firmware is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

Special Thanks for Contributors:

Hein Hollander 		:Octo Support
Dani Saez 			:V Ocoto Support
Max Levine			:Tri Support, Graphics
Jose Julio			:Stabilization Control laws
Randy MacKay		:Heli Support
Jani Hiriven		:Testing feedback
Andrew Tridgell		:Mavlink Support
James Goppert		:Mavlink Support
Doug Weibel			:Libraries
Mike Smith			:Libraries, Coding support
HappyKillmore		:Mavlink GCS
Michael Oborne		:Mavlink GCS
Jack Dunkle			:Alpha testing
Christof Schmid		:Alpha testing
Oliver				:Piezo support
Guntars				:Arming safety suggestion
Igor van Airde 		:Control Law optimization
Jean-Louis Naudin 	:Auto Landing
Sandro Benigno  	:Camera support
Olivier Adler 		:PPM Encoder
John Arne Birkeland	:PPM Encoder
Adam M Rivera		:Auto Compass Declination

And much more so PLEASE PM me on DIYDRONES to add your contribution to the List

Requires modified "mrelax" version of Arduino, which can be found here:
http://code.google.com/p/ardupilot-mega/downloads/list

*/

////////////////////////////////////////////////////////////////////////////////
// Header includes
////////////////////////////////////////////////////////////////////////////////

// AVR runtime
#include <avr/io.h>
#include <avr/eeprom.h>
#include <avr/pgmspace.h>
#include <math.h>

// Libraries
#include <FastSerial.h>
#include <AP_Common.h>
#include <Arduino_Mega_ISR_Registry.h>
#include <APM_RC.h>         // ArduPilot Mega RC Library
#include <AP_GPS.h>         // ArduPilot GPS library
#include <I2C.h>			// Arduino I2C lib
#include <SPI.h>			// Arduino SPI lib
#include <DataFlash.h>      // ArduPilot Mega Flash Memory Library
#include <AP_ADC.h>         // ArduPilot Mega Analog to Digital Converter Library
#include <AP_AnalogSource.h>
#include <AP_Baro.h>
#include <AP_Compass.h>     // ArduPilot Mega Magnetometer Library
#include <AP_Math.h>        // ArduPilot Mega Vector/Matrix math Library
#include <AP_InertialSensor.h> // ArduPilot Mega Inertial Sensor (accel & gyro) Library
#include <AP_IMU.h>         // ArduPilot Mega IMU Library
#include <AP_PeriodicProcess.h>         // Parent header of Timer
                                        // (only included for makefile libpath to work)
#include <AP_TimerProcess.h>            // TimerProcess is the scheduler for MPU6000 reads.
#include <AP_AHRS.h>
#include <APM_PI.h>            	// PI library
#include <AC_PID.h>            // PID library
#include <RC_Channel.h>     // RC Channel Library
#include <AP_Motors.h>		// AP Motors library
#include <AP_MotorsQuad.h>	// AP Motors library for Quad
#include <AP_MotorsTri.h>	// AP Motors library for Tri
#include <AP_MotorsHexa.h>	// AP Motors library for Hexa
#include <AP_MotorsY6.h>	// AP Motors library for Y6
#include <AP_MotorsOcta.h>	// AP Motors library for Octa
#include <AP_MotorsOctaQuad.h>	// AP Motors library for OctaQuad
#include <AP_MotorsHeli.h>	// AP Motors library for Heli
#include <AP_MotorsMatrix.h>	// AP Motors library for Heli
#include <AP_RangeFinder.h>	// Range finder library
#include <AP_OpticalFlow.h> // Optical Flow library
#include <Filter.h>			// Filter library
#include <ModeFilter.h>		// Mode Filter from Filter library
#include <AverageFilter.h>	// Mode Filter from Filter library
#include <AP_Relay.h>		// APM relay
#include <GCS_MAVLink.h>    // MAVLink GCS definitions
#include <memcheck.h>

// Configuration
#include "defines.h"
#include "config.h"
#include "config_channels.h"

// Local modules
#include "Parameters.h"
#include "GCS.h"

#include <AP_Declination.h> // ArduPilot Mega Declination Helper Library

////////////////////////////////////////////////////////////////////////////////
// Serial ports
////////////////////////////////////////////////////////////////////////////////
//
// Note that FastSerial port buffers are allocated at ::begin time,
// so there is not much of a penalty to defining ports that we don't
// use.
//
FastSerialPort0(Serial);        // FTDI/console
FastSerialPort1(Serial1);       // GPS port
FastSerialPort3(Serial3);       // Telemetry port

Arduino_Mega_ISR_Registry isr_registry;

////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
//
// Global parameters are all contained within the 'g' class.
//
static Parameters      g;


////////////////////////////////////////////////////////////////////////////////
// prototypes
static void update_events(void);

////////////////////////////////////////////////////////////////////////////////
// RC Hardware
////////////////////////////////////////////////////////////////////////////////
#if CONFIG_APM_HARDWARE == APM_HARDWARE_APM2
    APM_RC_APM2 APM_RC;
#else
    APM_RC_APM1 APM_RC;
#endif

////////////////////////////////////////////////////////////////////////////////
// Dataflash
////////////////////////////////////////////////////////////////////////////////
#if CONFIG_APM_HARDWARE == APM_HARDWARE_APM2
    DataFlash_APM2 DataFlash;
#else
    DataFlash_APM1   DataFlash;
#endif


////////////////////////////////////////////////////////////////////////////////
// Sensors
////////////////////////////////////////////////////////////////////////////////
//
// There are three basic options related to flight sensor selection.
//
// - Normal flight mode.  Real sensors are used.
// - HIL Attitude mode.  Most sensors are disabled, as the HIL
//   protocol supplies attitude information directly.
// - HIL Sensors mode.  Synthetic sensors are configured that
//   supply data from the simulation.
//

// All GPS access should be through this pointer.
static GPS         *g_gps;

// flight modes convenience array
static AP_Int8                *flight_modes = &g.flight_mode1;

#if HIL_MODE == HIL_MODE_DISABLED

// real sensors
#if CONFIG_ADC == ENABLED
	AP_ADC_ADS7844          adc;
#endif

#ifdef DESKTOP_BUILD
    AP_Baro_BMP085_HIL barometer;
    AP_Compass_HIL          compass;
#else

#if CONFIG_BARO == AP_BARO_BMP085
# if CONFIG_APM_HARDWARE == APM_HARDWARE_APM2
	AP_Baro_BMP085 barometer(true);
# else
	AP_Baro_BMP085 barometer(false);
# endif
#elif CONFIG_BARO == AP_BARO_MS5611
    AP_Baro_MS5611 barometer;
#endif

    AP_Compass_HMC5843      compass;
#endif

#ifdef OPTFLOW_ENABLED
	AP_OpticalFlow_ADNS3080 optflow(OPTFLOW_CS_PIN);
#else
    AP_OpticalFlow optflow;
#endif

// real GPS selection
#if   GPS_PROTOCOL == GPS_PROTOCOL_AUTO
	AP_GPS_Auto     g_gps_driver(&Serial1, &g_gps);

#elif GPS_PROTOCOL == GPS_PROTOCOL_NMEA
	AP_GPS_NMEA     g_gps_driver(&Serial1);

#elif GPS_PROTOCOL == GPS_PROTOCOL_SIRF
	AP_GPS_SIRF     g_gps_driver(&Serial1);

#elif GPS_PROTOCOL == GPS_PROTOCOL_UBLOX
	AP_GPS_UBLOX    g_gps_driver(&Serial1);

#elif GPS_PROTOCOL == GPS_PROTOCOL_MTK
	AP_GPS_MTK      g_gps_driver(&Serial1);

#elif GPS_PROTOCOL == GPS_PROTOCOL_MTK16
	AP_GPS_MTK16    g_gps_driver(&Serial1);

#elif GPS_PROTOCOL == GPS_PROTOCOL_NONE
	AP_GPS_None     g_gps_driver(NULL);

#else
	#error Unrecognised GPS_PROTOCOL setting.
#endif // GPS PROTOCOL

#if CONFIG_IMU_TYPE == CONFIG_IMU_MPU6000
AP_InertialSensor_MPU6000 ins( CONFIG_MPU6000_CHIP_SELECT_PIN );
#else
AP_InertialSensor_Oilpan ins(&adc);
#endif
AP_IMU_INS  imu(&ins);

// we don't want to use gps for yaw correction on ArduCopter, so pass
// a NULL GPS object pointer
static GPS         *g_gps_null;

#if QUATERNION_ENABLE == ENABLED
 AP_AHRS_Quaternion ahrs(&imu, g_gps_null);
#else
 AP_AHRS_DCM ahrs(&imu, g_gps_null);
#endif

AP_TimerProcess timer_scheduler;
#elif HIL_MODE == HIL_MODE_SENSORS
	// sensor emulators
	AP_ADC_HIL              adc;
	AP_Baro_BMP085_HIL      barometer;
	AP_Compass_HIL          compass;
	AP_GPS_HIL              g_gps_driver(NULL);
    AP_IMU_Shim imu;
    AP_AHRS_DCM  ahrs(&imu, g_gps);
    AP_PeriodicProcessStub timer_scheduler;
    AP_InertialSensor_Stub ins;

    static int32_t          gps_base_alt;

#elif HIL_MODE == HIL_MODE_ATTITUDE
	AP_ADC_HIL              adc;
	AP_IMU_Shim             imu; // never used
    AP_AHRS_HIL             ahrs(&imu, g_gps);
	AP_GPS_HIL              g_gps_driver(NULL);
	AP_Compass_HIL          compass; // never used
    AP_Baro_BMP085_HIL      barometer;
    AP_InertialSensor_Stub ins;
    AP_PeriodicProcessStub timer_scheduler;
	#ifdef OPTFLOW_ENABLED
		AP_OpticalFlow_ADNS3080 optflow(OPTFLOW_CS_PIN);
	#endif
    static int32_t          gps_base_alt;
#else
	#error Unrecognised HIL_MODE setting.
#endif // HIL MODE



////////////////////////////////////////////////////////////////////////////////
// GCS selection
////////////////////////////////////////////////////////////////////////////////
GCS_MAVLINK	gcs0;
GCS_MAVLINK	gcs3;

////////////////////////////////////////////////////////////////////////////////
// SONAR selection
////////////////////////////////////////////////////////////////////////////////
//
ModeFilterInt16_Size5 sonar_mode_filter(2);
#if CONFIG_SONAR == ENABLED
	#if CONFIG_SONAR_SOURCE == SONAR_SOURCE_ADC
	AP_AnalogSource_ADC sonar_analog_source( &adc, CONFIG_SONAR_SOURCE_ADC_CHANNEL, 0.25);
	#elif CONFIG_SONAR_SOURCE == SONAR_SOURCE_ANALOG_PIN
		AP_AnalogSource_Arduino sonar_analog_source(CONFIG_SONAR_SOURCE_ANALOG_PIN);
	#endif
	AP_RangeFinder_MaxsonarXL sonar(&sonar_analog_source, &sonar_mode_filter);
#endif

// agmatthews USERHOOKS
////////////////////////////////////////////////////////////////////////////////
// User variables
////////////////////////////////////////////////////////////////////////////////
#ifdef USERHOOK_VARIABLES
#include USERHOOK_VARIABLES
#endif

////////////////////////////////////////////////////////////////////////////////
// Global variables
////////////////////////////////////////////////////////////////////////////////

static const char* flight_mode_strings[] = {
	"STABILIZE",
	"ACRO",
	"ALT_HOLD",
	"AUTO",
	"GUIDED",
	"LOITER",
	"RTL",
	"CIRCLE",
	"POSITION",
	"LAND",
	"OF_LOITER"};

/* Radio values
		Channel assignments
			1	Ailerons (rudder if no ailerons)
			2	Elevator
			3	Throttle
			4	Rudder (if we have ailerons)
			5	Mode - 3 position switch
			6 	User assignable
			7	trainer switch - sets throttle nominal (toggle switch), sets accels to Level (hold > 1 second)
			8	TBD
*/

//Documentation of GLobals:

////////////////////////////////////////////////////////////////////////////////
// The GPS based velocity calculated by offsetting the Latitude and Longitude
// updated after GPS read - 5-10hz
static int16_t x_actual_speed;
static int16_t y_actual_speed;

static int16_t x_rate_d;
static int16_t y_rate_d;

// The difference between the desired rate of travel and the actual rate of travel
// updated after GPS read - 5-10hz
static int16_t x_rate_error;
static int16_t y_rate_error;

////////////////////////////////////////////////////////////////////////////////
// Radio
////////////////////////////////////////////////////////////////////////////////
// This is the state of the flight control system
// There are multiple states defined such as STABILIZE, ACRO,
static int8_t 	control_mode		= STABILIZE;
// This is the state of simple mode.
// Set in the control_mode.pde file when the control switch is read
static bool		do_simple 			= false;
// Used to maintain the state of the previous control switch position
// This is set to -1 when we need to re-read the switch
static byte 	oldSwitchPosition;
// This is used to look for change in the control switch
static byte 	old_control_mode = STABILIZE;


////////////////////////////////////////////////////////////////////////////////
// Motor Output
////////////////////////////////////////////////////////////////////////////////
// This is the array of PWM values being sent to the motors
//static int16_t  motor_out[11];
// This is the array of PWM values being sent to the motors that has been lightly filtered with a simple LPF
// This was added to try and deal with biger motors
//static int16_t  motor_filtered[11];

#if FRAME_CONFIG ==	QUAD_FRAME
	#define MOTOR_CLASS AP_MotorsQuad
#endif
#if FRAME_CONFIG ==	TRI_FRAME
	#define MOTOR_CLASS AP_MotorsTri
#endif
#if FRAME_CONFIG ==	HEXA_FRAME
	#define MOTOR_CLASS AP_MotorsHexa
#endif
#if FRAME_CONFIG ==	Y6_FRAME
	#define MOTOR_CLASS AP_MotorsY6
#endif
#if FRAME_CONFIG ==	OCTA_FRAME
	#define MOTOR_CLASS AP_MotorsOcta
#endif
#if FRAME_CONFIG ==	OCTA_QUAD_FRAME
	#define MOTOR_CLASS AP_MotorsOctaQuad
#endif
#if FRAME_CONFIG ==	HELI_FRAME
	#define MOTOR_CLASS AP_MotorsHeli
#endif

#if FRAME_CONFIG ==	HELI_FRAME  // helicopter constructor requires more arguments
	#if INSTANT_PWM == 1
		MOTOR_CLASS	motors(CONFIG_APM_HARDWARE, &APM_RC, &g.rc_1, &g.rc_2, &g.rc_3, &g.rc_4, &g.heli_servo_1, &g.heli_servo_2, &g.heli_servo_3, &g.heli_servo_4, AP_MOTORS_SPEED_INSTANT_PWM);   // this hardware definition is slightly bad because it assumes APM_HARDWARE_APM2 == AP_MOTORS_APM2
	#else
		MOTOR_CLASS	motors(CONFIG_APM_HARDWARE, &APM_RC, &g.rc_1, &g.rc_2, &g.rc_3, &g.rc_4, &g.heli_servo_1, &g.heli_servo_2, &g.heli_servo_3, &g.heli_servo_4);
	#endif
#else
	#if INSTANT_PWM == 1
		MOTOR_CLASS	motors(CONFIG_APM_HARDWARE, &APM_RC, &g.rc_1, &g.rc_2, &g.rc_3, &g.rc_4, AP_MOTORS_SPEED_INSTANT_PWM);   // this hardware definition is slightly bad because it assumes APM_HARDWARE_APM2 == AP_MOTORS_APM2
	#else
		MOTOR_CLASS	motors(CONFIG_APM_HARDWARE, &APM_RC, &g.rc_1, &g.rc_2, &g.rc_3, &g.rc_4);
	#endif
#endif

////////////////////////////////////////////////////////////////////////////////
// Mavlink/HIL control
////////////////////////////////////////////////////////////////////////////////
// Used to track the GCS based control input
// Allow override of RC channel values for HIL
static int16_t rc_override[8] = {0,0,0,0,0,0,0,0};
// Status flag that tracks whether we are under GCS control
static bool rc_override_active = false;
// Status flag that tracks whether we are under GCS control
static uint32_t rc_override_fs_timer = 0;

////////////////////////////////////////////////////////////////////////////////
// Failsafe
////////////////////////////////////////////////////////////////////////////////
// A status flag for the failsafe state
// did our throttle dip below the failsafe value?
static boolean 	failsafe;

////////////////////////////////////////////////////////////////////////////////
// PIDs
////////////////////////////////////////////////////////////////////////////////
// This is a convienience accessor for the IMU roll rates. It's currently the raw IMU rates
// and not the adjusted omega rates, but the name is stuck
static Vector3f omega;
// This is used to hold radio tuning values for in-flight CH6 tuning
float tuning_value;
// This will keep track of the percent of roll or pitch the user is applying
float roll_scale_d, pitch_scale_d;

////////////////////////////////////////////////////////////////////////////////
// LED output
////////////////////////////////////////////////////////////////////////////////
// status of LED based on the motor_armed variable
// Flashing indicates we are not armed
// Solid indicates Armed state
static boolean motor_light;
// Flashing indicates we are reading the GPS Strings
// Solid indicates we have full 3D lock and can navigate
static boolean GPS_light;
// This is current status for the LED lights state machine
// setting this value changes the output of the LEDs
static byte	led_mode = NORMAL_LEDS;

////////////////////////////////////////////////////////////////////////////////
// GPS variables
////////////////////////////////////////////////////////////////////////////////
// This is used to scale GPS values for EEPROM storage
// 10^7 times Decimal GPS means 1 == 1cm
// This approximation makes calculations integer and it's easy to read
static const 	float t7			= 10000000.0;
// We use atan2 and other trig techniques to calaculate angles
// We need to scale the longitude up to make these calcs work
// to account for decreasing distance between lines of longitude away from the equator
static float 	scaleLongUp			= 1;
// Sometimes we need to remove the scaling for distance calcs
static float 	scaleLongDown 		= 1;


////////////////////////////////////////////////////////////////////////////////
// Mavlink specific
////////////////////////////////////////////////////////////////////////////////
// Used by Mavlink for unknow reasons
static const float radius_of_earth 	= 6378100;		// meters
// Used by Mavlink for unknow reasons
static const float gravity 			= 9.81;			// meters/ sec^2


////////////////////////////////////////////////////////////////////////////////
// Location & Navigation
////////////////////////////////////////////////////////////////////////////////
// Status flag indicating we have data that can be used to navigate
// Set by a GPS read with 3D fix, or an optical flow read
static bool	nav_ok;
// This is the angle from the copter to the "next_WP" location in degrees * 100
static int32_t	target_bearing;
// This is the angle from the copter to the "next_WP" location
// with the addition of Crosstrack error in degrees * 100
static int32_t	nav_bearing;
// Status of the Waypoint tracking mode. Options include:
// NO_NAV_MODE, WP_MODE, LOITER_MODE, CIRCLE_MODE
static byte	wp_control;
// Register containing the index of the current navigation command in the mission script
static uint8_t	command_nav_index;
// Register containing the index of the previous navigation command in the mission script
// Used to manage the execution of conditional commands
static uint8_t	prev_nav_index;
// Register containing the index of the current conditional command in the mission script
static uint8_t	command_cond_index;
// Used to track the required WP navigation information
// options include
// NAV_ALTITUDE - have we reached the desired altitude?
// NAV_LOCATION - have we reached the desired location?
// NAV_DELAY 	- have we waited at the waypoint the desired time?
static uint8_t	wp_verify_byte;							// used for tracking state of navigating waypoints
// used to limit the speed ramp up of WP navigation
// Acceleration is limited to .5m/s/s
static int16_t waypoint_speed_gov;
// Used to track how many cm we are from the "next_WP" location
static int32_t	long_error, lat_error;
// Are we navigating while holding a positon? This is set to false once the speed drops below 1m/s
static boolean 	loiter_override;


////////////////////////////////////////////////////////////////////////////////
// Orientation
////////////////////////////////////////////////////////////////////////////////
// Convienience accessors for commonly used trig functions. These values are generated
// by the DCM through a few simple equations. They are used throughout the code where cos and sin
// would normally be used.
// The cos values are defaulted to 1 to get a decent initial value for a level state
static float cos_roll_x 	= 1;
static float cos_pitch_x 	= 1;
static float cos_yaw_x 		= 1;
static float sin_yaw_y;

////////////////////////////////////////////////////////////////////////////////
// SIMPLE Mode
////////////////////////////////////////////////////////////////////////////////
// Used to track the orientation of the copter for Simple mode. This value is reset at each arming
// or in SuperSimple mode when the copter leaves a 20m radius from home.
static int32_t initial_simple_bearing;

////////////////////////////////////////////////////////////////////////////////
// ACRO Mode
////////////////////////////////////////////////////////////////////////////////
// Used to control Axis lock
int32_t roll_axis;
int32_t pitch_axis;

// Filters
AverageFilterInt32_Size3 roll_rate_d_filter;	// filtered acceleration
AverageFilterInt32_Size3 pitch_rate_d_filter;	// filtered pitch acceleration

AverageFilterInt16_Size2 lat_rate_d_filter;		// for filtering D term
AverageFilterInt16_Size2 lon_rate_d_filter;		// for filtering D term

// Barometer filter
AverageFilterInt32_Size5 baro_filter;	// filtered pitch acceleration

////////////////////////////////////////////////////////////////////////////////
// Circle Mode / Loiter control
////////////////////////////////////////////////////////////////////////////////
// used to determin the desired location in Circle mode
// increments at circle_rate / second
static float circle_angle;
// used to control the speed of Circle mode
// units are in radians, default is 5° per second
static const float circle_rate = 0.0872664625;
// used to track the delat in Circle Mode
static int32_t 	old_target_bearing;
// deg : how many times to circle * 360 for Loiter/Circle Mission command
static int16_t	loiter_total;
// deg : how far we have turned around a waypoint
static int16_t	loiter_sum;
// How long we should stay in Loiter Mode for mission scripting
static uint16_t loiter_time_max;
// How long have we been loitering - The start time in millis
static uint32_t loiter_time;
// The synthetic location created to make the copter do circles around a WP
static struct 	Location circle_WP;


////////////////////////////////////////////////////////////////////////////////
// CH7 control
////////////////////////////////////////////////////////////////////////////////
// Used to enable Jose's flip code
// when true the Roll/Pitch/Throttle control is sent to the flip state machine
#if CH7_OPTION == CH7_FLIP
static bool do_flip = false;
#endif
// Used to track the CH7 toggle state.
// When CH7 goes LOW PWM from HIGH PWM, this value will have been set true
// This allows advanced functionality to know when to execute
static boolean trim_flag;
// This register tracks the current Mission Command index when writing
// a mission using CH7 in flight
static int8_t CH7_wp_index;


////////////////////////////////////////////////////////////////////////////////
// Battery Sensors
////////////////////////////////////////////////////////////////////////////////
// Battery Voltage of battery, initialized above threshold for filter
static float	battery_voltage1		= LOW_VOLTAGE * 1.05;
// refers to the instant amp draw – based on an Attopilot Current sensor
static float	current_amps1;
// refers to the total amps drawn – based on an Attopilot Current sensor
static float	current_total1;
// Used to track if the battery is low - LED output flashes when the batt is low
static bool		low_batt = false;


////////////////////////////////////////////////////////////////////////////////
// Altitude
////////////////////////////////////////////////////////////////////////////////
// The pressure at home location - calibrated at arming
static int32_t 	ground_pressure;
// The ground temperature at home location - calibrated at arming
static int16_t 	ground_temperature;
// The cm we are off in altitude from next_WP.alt – Positive value means we are below the WP
static int32_t		altitude_error;
// The cm/s we are moving up or down based on sensor data - Positive = UP
static int16_t		climb_rate_actual;
// Used to dither our climb_rate over 50hz
static int16_t		climb_rate_error;
// The cm/s we are moving up or down based on filtered data - Positive = UP
static int16_t		climb_rate;
// The altitude as reported by Sonar in cm – Values are 20 to 700 generally.
static int16_t		sonar_alt;
// The climb_rate as reported by sonar in cm/s
static int16_t		sonar_rate;
// The altitude as reported by Baro in cm – Values can be quite high
static int32_t		baro_alt;
// The climb_rate as reported by Baro in cm/s
static int16_t		baro_rate;
// used to switch out of Manual Boost
static boolean 		reset_throttle_flag;
// used to track when to read sensors vs estimate alt
static boolean 		alt_sensor_flag;


////////////////////////////////////////////////////////////////////////////////
// flight modes
////////////////////////////////////////////////////////////////////////////////
// Flight modes are combinations of Roll/Pitch, Yaw and Throttle control modes
// Each Flight mode is a unique combination of these modes
//
// The current desired control scheme for Yaw
static byte		yaw_mode;
// The current desired control scheme for roll and pitch / navigation
static byte		roll_pitch_mode;
// The current desired control scheme for altitude hold
static byte		throttle_mode;


////////////////////////////////////////////////////////////////////////////////
// flight specific
////////////////////////////////////////////////////////////////////////////////
// Flag for monitoring the status of flight
// We must be in the air with throttle for 5 seconds before this flag is true
// This flag is reset when we are in a manual throttle mode with 0 throttle or disarmed
static boolean	takeoff_complete;
// Used to record the most recent time since we enaged the throttle to take off
static uint32_t	takeoff_timer;
// Used to see if we have landed and if we should shut our engines - not fully implemented
static boolean	land_complete = true;
// used to manually override throttle in interactive Alt hold modes
static int16_t 	manual_boost;
// An additional throttle added to keep the copter at the same altitude when banking
static int16_t 	angle_boost;
// Push copter down for clean landing
static int16_t 	landing_boost;
// for controlling the landing throttle curve
//verifies landings
static int16_t ground_detector;


////////////////////////////////////////////////////////////////////////////////
// Navigation general
////////////////////////////////////////////////////////////////////////////////
// The location of the copter in relation to home, updated every GPS read
static int32_t	home_to_copter_bearing;
// distance between plane and home in cm
static int32_t	home_distance;
// distance between plane and next_WP in cm
static int32_t	wp_distance;

////////////////////////////////////////////////////////////////////////////////
// 3D Location vectors
////////////////////////////////////////////////////////////////////////////////
// home location is stored when we have a good GPS lock and arm the copter
// Can be reset each the copter is re-armed
static struct 	Location home;
// Flag for if we have g_gps lock and have set the home location
static boolean	home_is_set;
// Current location of the copter
static struct 	Location current_loc;
// Next WP is the desired location of the copter - the next waypoint or loiter location
static struct 	Location next_WP;
// Prev WP is used to get the optimum path from one WP to the next
static struct 	Location prev_WP;
// Holds the current loaded command from the EEPROM for navigation
static struct 	Location command_nav_queue;
// Holds the current loaded command from the EEPROM for conditional scripts
static struct 	Location command_cond_queue;
// Holds the current loaded command from the EEPROM for guided mode
static struct   Location guided_WP;

////////////////////////////////////////////////////////////////////////////////
// Crosstrack
////////////////////////////////////////////////////////////////////////////////
// deg * 100, The original angle to the next_WP when the next_WP was set
// Also used to check when we pass a WP
static int32_t 	original_target_bearing;
// The amount of angle correction applied to target_bearing to bring the copter back on its optimum path
static int16_t	crosstrack_error;


////////////////////////////////////////////////////////////////////////////////
// Navigation Roll/Pitch functions
////////////////////////////////////////////////////////////////////////////////
// all angles are deg * 100 : target yaw angle
// The Commanded ROll from the autopilot.
static int32_t	nav_roll;
// The Commanded pitch from the autopilot. negative Pitch means go forward.
static int32_t	nav_pitch;
// The desired bank towards North (Positive) or South (Negative)
static int32_t	auto_roll;
static int32_t	auto_pitch;

// Don't be fooled by the fact that Pitch is reversed from Roll in its sign!
static int16_t	nav_lat;
// The desired bank towards East (Positive) or West (Negative)
static int16_t	nav_lon;
// The Commanded ROll from the autopilot based on optical flow sensor.
static int32_t	of_roll;
// The Commanded pitch from the autopilot based on optical flow sensor. negative Pitch means go forward.
static int32_t	of_pitch;
static bool	slow_wp = false;


////////////////////////////////////////////////////////////////////////////////
// Navigation Throttle control
////////////////////////////////////////////////////////////////////////////////
// The Commanded Throttle from the autopilot.
static int16_t	nav_throttle;						// 0-1000 for throttle control
// This is a simple counter to track the amount of throttle used during flight
// This could be useful later in determining and debuging current usage and predicting battery life
static uint32_t throttle_integrator;

////////////////////////////////////////////////////////////////////////////////
// Climb rate control
////////////////////////////////////////////////////////////////////////////////
// Time when we intiated command in millis - used for controlling decent rate
// The orginal altitude used to base our new altitude during decent
static int32_t 	original_altitude;
// Used to track the altitude offset for climbrate control
static int32_t 	target_altitude;
static uint32_t alt_change_timer;
static int8_t 	alt_change_flag;
static uint32_t alt_change;

////////////////////////////////////////////////////////////////////////////////
// Navigation Yaw control
////////////////////////////////////////////////////////////////////////////////
// The Commanded Yaw from the autopilot.
static int32_t	nav_yaw;
// A speed governer for Yaw control - limits the rate the quad can be turned by the autopilot
static int32_t	auto_yaw;
// Used to manage the Yaw hold capabilities -
// Options include: no tracking, point at next wp, or at a target
static byte 	yaw_tracking = MAV_ROI_WPNEXT;
// In AP Mission scripting we have a fine level of control for Yaw
// This is our initial angle for relative Yaw movements
static int32_t 	command_yaw_start;
// Timer values used to control the speed of Yaw movements
static uint32_t command_yaw_start_time;
static uint16_t	command_yaw_time;					// how long we are turning
static int32_t 	command_yaw_end;					// what angle are we trying to be
// how many degrees will we turn
static int32_t 	command_yaw_delta;
// Deg/s we should turn
static int16_t	command_yaw_speed;
// Direction we will turn –  1 = CW, 0 or -1 = CCW
static byte		command_yaw_dir;
// Direction we will turn – 1 = relative, 0 = Absolute
static byte		command_yaw_relative;
// Yaw will point at this location if yaw_tracking is set to MAV_ROI_LOCATION
static struct 	Location target_WP;



////////////////////////////////////////////////////////////////////////////////
// Repeat Mission Scripting Command
////////////////////////////////////////////////////////////////////////////////
// The type of repeating event - Toggle a servo channel, Toggle the APM1 relay, etc
static byte    	event_id;
// Used to manage the timimng of repeating events
static uint32_t event_timer;
// How long to delay the next firing of event in millis
static uint16_t event_delay;
// how many times to fire : 0 = forever, 1 = do once, 2 = do twice
static int16_t 	event_repeat;
// per command value, such as PWM for servos
static int16_t 	event_value;
// the stored value used to undo commands - such as original PWM command
static int16_t 	event_undo_value;

////////////////////////////////////////////////////////////////////////////////
// Delay Mission Scripting Command
////////////////////////////////////////////////////////////////////////////////
static int32_t 	condition_value; // used in condition commands (eg delay, change alt, etc.)
static uint32_t condition_start;


////////////////////////////////////////////////////////////////////////////////
// IMU variables
////////////////////////////////////////////////////////////////////////////////
// Integration time for the gyros (DCM algorithm)
// Updated with th efast loop
static float G_Dt		= 0.02;
// The rotated accelerometer values
// Used by Z accel control, updated at 10hz
Vector3f accels_rot;

////////////////////////////////////////////////////////////////////////////////
// Performance monitoring
////////////////////////////////////////////////////////////////////////////////
// Used to manage the rate of performance logging messages
static int16_t 			perf_mon_counter;
// The number of GPS fixes we have had
static int16_t			gps_fix_count;
// gps_watchdog check for bad reads and if we miss 12 in a row, we stop navigating
// by lowering nav_lat and navlon to 0 gradually
static byte				gps_watchdog;

// System Timers
// --------------
// Time in microseconds of main control loop
static uint32_t 	    fast_loopTimer;
// Time in microseconds of 50hz control loop
static uint32_t	        fiftyhz_loopTimer;
// Counters for branching from 10 hz control loop
static byte 			medium_loopCounter;
// Counters for branching from 3 1/3hz control loop
static byte 			slow_loopCounter;
// Counters for branching at 1 hz
static byte				counter_one_herz;
// Stat machine counter for Simple Mode
static byte				simple_counter;
// used to track the elapsed time between GPS reads
static uint32_t         nav_loopTimer;
// Delta Time in milliseconds for navigation computations, updated with every good GPS read
static float 			dTnav;
// Counters for branching from 4 minute control loop used to save Compass offsets
static int16_t			superslow_loopCounter;
// RTL Autoland Timer
static uint32_t 		auto_land_timer;
// disarms the copter while in Acro or Stabilize mode after 30 seconds of no flight
static uint8_t 			auto_disarming_counter;


// Tracks if GPS is enabled based on statup routine
// If we do not detect GPS at startup, we stop trying and assume GPS is not connected
static bool				GPS_enabled 	= false;
// Set true if we have new PWM data to act on from the Radio
static bool				new_radio_frame;
// Used to auto exit the in-flight leveler
static int16_t 			auto_level_counter;

// Reference to the AP relay object - APM1 only
AP_Relay relay;

// APM2 only
#if USB_MUX_PIN > 0
	static bool usb_connected;
#endif


////////////////////////////////////////////////////////////////////////////////
// Top-level logic
////////////////////////////////////////////////////////////////////////////////

void setup() {
	memcheck_init();
	init_ardupilot();
}

void loop()
{
	uint32_t timer 			= micros();

	// We want this to execute fast
	// ----------------------------
	if ((timer - fast_loopTimer) >= 10000 && imu.new_data_available()) {
		//Log_Write_Data(13, (int32_t)(timer - fast_loopTimer));

		//PORTK |= B00010000;
		G_Dt 				= (float)(timer - fast_loopTimer) / 1000000.f;		// used by PI Loops
		fast_loopTimer 		= timer;

		// Execute the fast loop
		// ---------------------
		fast_loop();
	}

	// port manipulation for external timing of main loops
	//PORTK &= B11101111;

	if ((timer - fiftyhz_loopTimer) >= 20000) {
		// store the micros for the 50 hz timer
		fiftyhz_loopTimer		= timer;

		// port manipulation for external timing of main loops
		//PORTK |= B01000000;

		// reads all of the necessary trig functions for cameras, throttle, etc.
		// --------------------------------------------------------------------
		update_trig();

		// update our velocity estimate based on IMU at 50hz
		// -------------------------------------------------
		//estimate_velocity();

		// check for new GPS messages
		// --------------------------
		if(GPS_enabled){
			update_GPS();
		}

		// perform 10hz tasks
		// ------------------
		medium_loop();

		// Stuff to run at full 50hz, but after the med loops
		// --------------------------------------------------
		fifty_hz_loop();

		counter_one_herz++;

		// trgger our 1 hz loop
		if(counter_one_herz >= 50){
			super_slow_loop();
			counter_one_herz = 0;
		}
		perf_mon_counter++;
		if (perf_mon_counter > 600 ) {
			if (g.log_bitmask & MASK_LOG_PM)
				Log_Write_Performance();

			gps_fix_count 		= 0;
			perf_mon_counter 	= 0;
        }
		//PORTK &= B10111111;
	}
}
//  PORTK |= B01000000;
//	PORTK &= B10111111;

// Main loop
static void fast_loop()
{
    // try to send any deferred messages if the serial port now has
    // some space available
    gcs_send_message(MSG_RETRY_DEFERRED);

	// Read radio
	// ----------
	read_radio();

	// IMU DCM Algorithm
	read_AHRS();

	// custom code/exceptions for flight modes
	// ---------------------------------------
	update_yaw_mode();
	update_roll_pitch_mode();

	// write out the servo PWM values
	// ------------------------------
	set_servos_4();

	// agmatthews - USERHOOKS
	#ifdef USERHOOK_FASTLOOP
	   USERHOOK_FASTLOOP
	#endif

}

static void medium_loop()
{
	// This is the start of the medium (10 Hz) loop pieces
	// -----------------------------------------
	switch(medium_loopCounter) {

		// This case deals with the GPS and Compass
		//-----------------------------------------
		case 0:
			medium_loopCounter++;

			//if(GPS_enabled){
			//	update_GPS();
			//}

			#if HIL_MODE != HIL_MODE_ATTITUDE					// don't execute in HIL mode
				if(g.compass_enabled){
					if (compass.read()) {
                        // Calculate heading
                        Matrix3f m = ahrs.get_dcm_matrix();
                        compass.calculate(m);
                        compass.null_offsets();
                    }
				}
			#endif

			// auto_trim, uses an auto_level algorithm
			auto_trim();

			// record throttle output
			// ------------------------------
			throttle_integrator += g.rc_3.servo_out;
			break;

		// This case performs some navigation computations
		//------------------------------------------------
		case 1:
			medium_loopCounter++;

			// Auto control modes:
			if(nav_ok){
				// clear nav flag
				nav_ok = false;

				// calculate the copter's desired bearing and WP distance
				// ------------------------------------------------------
				if(navigate()){

					// this calculates the velocity for Loiter
					// only called when there is new data
					// ----------------------------------
					calc_XY_velocity();

					// If we have optFlow enabled we can grab a more accurate speed
					// here and override the speed from the GPS
					// ----------------------------------------
					//#ifdef OPTFLOW_ENABLED
					//if(g.optflow_enabled && current_loc.alt < 500){
					//	// optflow wont be enabled on 1280's
					//	x_GPS_speed 	= optflow.x_cm;
					//	y_GPS_speed 	= optflow.y_cm;
					//}
					//#endif

					// control mode specific updates
					// -----------------------------
					update_navigation();

					if (g.log_bitmask & MASK_LOG_NTUN && motors.armed()){
						Log_Write_Nav_Tuning();
					}
				}
			}
			break;

		// command processing
		//-------------------
		case 2:
			medium_loopCounter++;

			// Read altitude from sensors
			// --------------------------
			//#if HIL_MODE != HIL_MODE_ATTITUDE					// don't execute in HIL mode
			//update_altitude();
			//#endif
			alt_sensor_flag = true;

			break;

		// This case deals with sending high rate telemetry
		//-------------------------------------------------
		case 3:
			medium_loopCounter++;

			// perform next command
			// --------------------
			if(control_mode == AUTO){
				if(home_is_set == true && g.command_total > 1){
					update_commands();
				}
			}

            if(motors.armed()){
                if (g.log_bitmask & MASK_LOG_ATTITUDE_MED)
                    Log_Write_Attitude();

				if (g.log_bitmask & MASK_LOG_MOTORS)
					Log_Write_Motors();
            }
			break;

		// This case controls the slow loop
		//---------------------------------
		case 4:
			medium_loopCounter = 0;

			if (g.battery_monitoring != 0){
				read_battery();
			}

			// Accel trims 		= hold > 2 seconds
			// Throttle cruise  = switch less than 1 second
			// --------------------------------------------
			read_trim_switch();

			// Check for engine arming
			// -----------------------
			arm_motors();

			// Do an extra baro read for Temp sensing
			// ---------------------------------------
			#if HIL_MODE != HIL_MODE_ATTITUDE
			barometer.read();
			#endif

			// agmatthews - USERHOOKS
			#ifdef USERHOOK_MEDIUMLOOP
			   USERHOOK_MEDIUMLOOP
			#endif

			slow_loop();
			break;

		default:
			// this is just a catch all
			// ------------------------
			medium_loopCounter = 0;
			break;
	}
}

// stuff that happens at 50 hz
// ---------------------------
static void fifty_hz_loop()
{
	// read altitude sensors or estimate altitude
	// ------------------------------------------
	update_altitude_est();

	// moved to slower loop
	// --------------------
	update_throttle_mode();

	// Read Sonar
	// ----------
    # if CONFIG_SONAR == ENABLED
	if(g.sonar_enabled){
		sonar_alt = sonar.read();
	}
    #endif

	// syncronise optical flow reads with altitude reads
	#ifdef OPTFLOW_ENABLED
	if(g.optflow_enabled){
		update_optical_flow();
	}
	#endif

	// agmatthews - USERHOOKS
	#ifdef USERHOOK_50HZLOOP
	  USERHOOK_50HZLOOP
	#endif

	#if HIL_MODE != HIL_MODE_DISABLED && FRAME_CONFIG != HELI_FRAME
		// HIL for a copter needs very fast update of the servo values
		gcs_send_message(MSG_RADIO_OUT);
	#endif

	camera_stabilization();

	# if HIL_MODE == HIL_MODE_DISABLED
		if (g.log_bitmask & MASK_LOG_ATTITUDE_FAST && motors.armed())
			Log_Write_Attitude();

		if (g.log_bitmask & MASK_LOG_RAW && motors.armed())
			Log_Write_Raw();
	#endif

	// kick the GCS to process uplink data
	gcs_update();
    gcs_data_stream_send();
}


static void slow_loop()
{
	// This is the slow (3 1/3 Hz) loop pieces
	//----------------------------------------
	switch (slow_loopCounter){
		case 0:
			slow_loopCounter++;
			superslow_loopCounter++;

			// update throttle hold every 20 seconds
			if(superslow_loopCounter > 60){
				update_throttle_cruise();
			}

			if(superslow_loopCounter > 1200){
				#if HIL_MODE != HIL_MODE_ATTITUDE
					if(g.rc_3.control_in == 0 && control_mode == STABILIZE && g.compass_enabled){
						compass.save_offsets();
						superslow_loopCounter = 0;
					}
				#endif
            }

			// check the user hasn't updated the frame orientation
			if( !motors.armed() ) {
				motors.set_frame_orientation(g.frame_orientation);
			}

			break;

		case 1:
			slow_loopCounter++;

			// Read 3-position switch on radio
			// -------------------------------
			read_control_switch();

			// agmatthews - USERHOOKS
			#ifdef USERHOOK_SLOWLOOP
			   USERHOOK_SLOWLOOP
			#endif

			break;

		case 2:
			slow_loopCounter = 0;
			update_events();

			// blink if we are armed
			update_lights();

			if(g.radio_tuning > 0)
				tuning();

			#if MOTOR_LEDS == 1
				update_motor_leds();
			#endif

			#if USB_MUX_PIN > 0
            check_usb_mux();
			#endif
			break;

		default:
			slow_loopCounter = 0;
			break;
	}
}

#define AUTO_ARMING_DELAY 60
// 1Hz loop
static void super_slow_loop()
{
	if (g.log_bitmask & MASK_LOG_CUR && motors.armed())
		Log_Write_Current();

	// this function disarms the copter if it has been sitting on the ground for any moment of time greater than 30s
	// but only of the control mode is manual
	if((control_mode <= ACRO) && (g.rc_3.control_in == 0)){
		auto_disarming_counter++;

		if(auto_disarming_counter == AUTO_ARMING_DELAY){
			init_disarm_motors();
		}else if (auto_disarming_counter > AUTO_ARMING_DELAY){
			auto_disarming_counter = AUTO_ARMING_DELAY + 1;
		}
	}else{
		auto_disarming_counter = 0;
	}

    gcs_send_message(MSG_HEARTBEAT);

	// agmatthews - USERHOOKS
	#ifdef USERHOOK_SUPERSLOWLOOP
	   USERHOOK_SUPERSLOWLOOP
	#endif

	/*
	Serial.printf("alt %d, next.alt %d, alt_err: %d, cruise: %d, Alt_I:%1.2f, wp_dist %d, tar_bear %d, home_d %d, homebear %d\n",
					current_loc.alt,
					next_WP.alt,
					altitude_error,
					g.throttle_cruise.get(),
					g.pi_alt_hold.get_integrator(),
					wp_distance,
					target_bearing,
					home_distance,
					home_to_copter_bearing);
	*/
}

// updated at 10 Hz
#ifdef OPTFLOW_ENABLED
static void update_optical_flow(void)
{
    static int log_counter = 0;

	optflow.update();
	optflow.update_position(ahrs.roll, ahrs.pitch, cos_yaw_x, sin_yaw_y, current_loc.alt);  // updates internal lon and lat with estimation based on optical flow

	// write to log
	log_counter++;
	if( log_counter >= 5 ) {
	    log_counter = 0;
		if (g.log_bitmask & MASK_LOG_OPTFLOW){
			Log_Write_Optflow();
		}
	}

	/*if(g.optflow_enabled && current_loc.alt < 500){
		if(GPS_enabled){
			// if we have a GPS, we add some detail to the GPS
			// XXX this may not ne right
			current_loc.lng += optflow.vlon;
			current_loc.lat += optflow.vlat;

			// some sort of error correction routine
			//current_loc.lng -= ERR_GAIN * (float)(current_loc.lng - x_GPS_speed); // error correction
			//current_loc.lng -= ERR_GAIN * (float)(current_loc.lng - x_GPS_speed); // error correction
		}else{
			// if we do not have a GPS, use relative from 0 for lat and lon
			current_loc.lng = optflow.vlon;
			current_loc.lat = optflow.vlat;
		}
		// OK to run the nav routines
		nav_ok = true;
	}*/
}
#endif

static void update_GPS(void)
{
	// A counter that is used to grab at least 10 reads before commiting the Home location
	static byte ground_start_count	= 10;

	g_gps->update();
	update_GPS_light();

	//current_loc.lng =   377697000;		// Lon * 10 * *7
	//current_loc.lat = -1224318000;		// Lat * 10 * *7
	//current_loc.alt = 100;				// alt * 10 * *7
	//return;
	if(gps_watchdog < 30){
		gps_watchdog++;
	}else{
		// after 12 reads we guess we may have lost GPS signal, stop navigating
		// we have lost GPS signal for a moment. Reduce our error to avoid flyaways
		auto_roll  >>= 1;
		auto_pitch >>= 1;
	}

    if (g_gps->new_data && g_gps->fix) {

		// clear new data flag
    	g_gps->new_data = false;

		gps_watchdog = 0;

		// OK to run the nav routines
		nav_ok = true;

		// for performance
		// ---------------
		gps_fix_count++;

		// used to calculate speed in X and Y, iterms
		// ------------------------------------------
		dTnav 				= (float)(millis() - nav_loopTimer)/ 1000.0;
		nav_loopTimer 		= millis();

		// prevent runup from bad GPS
		// --------------------------
		dTnav = min(dTnav, 1.0);

		if(ground_start_count > 1){
			ground_start_count--;

		} else if (ground_start_count == 1) {

			// We countdown N number of good GPS fixes
			// so that the altitude is more accurate
			// -------------------------------------
			if (current_loc.lat == 0) {
				ground_start_count = 5;

			}else{
				if (g.compass_enabled) {
					// Set compass declination automatically
					compass.set_initial_location(g_gps->latitude, g_gps->longitude);
				}
				// save home to eeprom (we must have a good fix to have reached this point)
				init_home();
				ground_start_count = 0;
			}
		}

		current_loc.lng = g_gps->longitude;	// Lon * 10 * *7
		current_loc.lat = g_gps->latitude;	// Lat * 10 * *7

		if (g.log_bitmask & MASK_LOG_GPS && motors.armed()){
			Log_Write_GPS();
		}

		#if HIL_MODE == HIL_MODE_ATTITUDE					// only execute in HIL mode
			//update_altitude();
			alt_sensor_flag = true;
		#endif
	}
}

void update_yaw_mode(void)
{
	switch(yaw_mode){
		case YAW_ACRO:
			g.rc_4.servo_out = get_acro_yaw(g.rc_4.control_in);
			return;
			break;

		case YAW_HOLD:
			// calcualte new nav_yaw offset
			if (control_mode <= STABILIZE){
				nav_yaw = get_nav_yaw_offset(g.rc_4.control_in, g.rc_3.control_in);
			}else{
				nav_yaw = get_nav_yaw_offset(g.rc_4.control_in, 1);
			}
			break;

		case YAW_LOOK_AT_HOME:
			//nav_yaw updated in update_navigation()
			break;

		case YAW_AUTO:
			nav_yaw += constrain(wrap_180(auto_yaw - nav_yaw), -20, 20); // 40 deg a second
			//Serial.printf("nav_yaw %d ", nav_yaw);
			nav_yaw  = wrap_360(nav_yaw);
			break;
	}

	// Yaw control
	g.rc_4.servo_out = get_stabilize_yaw(nav_yaw);

	//Serial.printf("4: %d\n",g.rc_4.servo_out);
}

void update_roll_pitch_mode(void)
{
	int control_roll, control_pitch;

	// hack to do auto_flip - need to remove, no one is using.
	#if CH7_OPTION == CH7_FLIP
	if (do_flip){
		roll_flip();
		return;
	}
	#endif

	switch(roll_pitch_mode){
		case ROLL_PITCH_ACRO:
			if(g.axis_enabled){
				roll_axis 	+= (float)g.rc_1.control_in * g.axis_lock_p;
				pitch_axis 	+= (float)g.rc_2.control_in * g.axis_lock_p;

				roll_axis = wrap_360(roll_axis);
				pitch_axis = wrap_360(pitch_axis);

				// in this mode, nav_roll and nav_pitch = the iterm
				g.rc_1.servo_out = get_stabilize_roll(roll_axis);
				g.rc_2.servo_out = get_stabilize_pitch(pitch_axis);

				if (g.rc_3.control_in == 0){
					roll_axis = 0;
					pitch_axis = 0;
				}

			}else{
				// ACRO does not get SIMPLE mode ability
				g.rc_1.servo_out = get_acro_roll(g.rc_1.control_in);
				g.rc_2.servo_out = get_acro_pitch(g.rc_2.control_in);
			}
			break;

		case ROLL_PITCH_STABLE:
			// apply SIMPLE mode transform
			if(do_simple && new_radio_frame){
				update_simple_mode();
			}

			// in this mode, nav_roll and nav_pitch = the iterm
			g.rc_1.servo_out = get_stabilize_roll(g.rc_1.control_in);
			g.rc_2.servo_out = get_stabilize_pitch(g.rc_2.control_in);
			break;

		case ROLL_PITCH_AUTO:
			// apply SIMPLE mode transform
			if(do_simple && new_radio_frame){
				update_simple_mode();
			}
			// mix in user control with Nav control
			nav_roll			+= constrain(wrap_180(auto_roll  - nav_roll),  -g.auto_slew_rate.get(), g.auto_slew_rate.get()); // 40 deg a second
			nav_pitch			+= constrain(wrap_180(auto_pitch - nav_pitch), -g.auto_slew_rate.get(), g.auto_slew_rate.get()); // 40 deg a second

			control_roll 		= g.rc_1.control_mix(nav_roll);
			control_pitch 		= g.rc_2.control_mix(nav_pitch);
			g.rc_1.servo_out 	= get_stabilize_roll(control_roll);
			g.rc_2.servo_out 	= get_stabilize_pitch(control_pitch);
			break;

		case ROLL_PITCH_STABLE_OF:
			// apply SIMPLE mode transform
			if(do_simple && new_radio_frame){
				update_simple_mode();
			}
			// mix in user control with optical flow
			g.rc_1.servo_out = get_stabilize_roll(get_of_roll(g.rc_1.control_in));
			g.rc_2.servo_out = get_stabilize_pitch(get_of_pitch(g.rc_2.control_in));
			break;
	}

	if(g.rc_3.control_in == 0 && roll_pitch_mode <= ROLL_PITCH_ACRO){
		reset_rate_I();
		reset_stability_I();
	}

	if(takeoff_complete == false){
		// reset these I terms to prevent awkward tipping on takeoff
		//reset_rate_I();
		//reset_stability_I();
	}

	if(new_radio_frame){
		// clear new radio frame info
		new_radio_frame = false;

		// These values can be used to scale the PID gains
		// This allows for a simple gain scheduling implementation
		roll_scale_d	= g.stabilize_d_schedule * (float)abs(g.rc_1.control_in);
		roll_scale_d 	= (1 - (roll_scale_d / 4500.0));
		roll_scale_d	= constrain(roll_scale_d, 0, 1) * g.stabilize_d;

		pitch_scale_d	= g.stabilize_d_schedule * (float)abs(g.rc_2.control_in);
		pitch_scale_d 	= (1 - (pitch_scale_d / 4500.0));
		pitch_scale_d 	= constrain(pitch_scale_d, 0, 1) * g.stabilize_d;
	}
}

// new radio frame is used to make sure we only call this at 50hz
void update_simple_mode(void)
{
	static float simple_sin_y=0, simple_cos_x=0;

	// used to manage state machine
	// which improves speed of function
	simple_counter++;

	int delta = wrap_360(ahrs.yaw_sensor - initial_simple_bearing)/100;

	if (simple_counter == 1){
		// roll
		simple_cos_x = sin(radians(90 - delta));

	}else if (simple_counter > 2){
		// pitch
		simple_sin_y = cos(radians(90 - delta));
		simple_counter = 0;
	}

	// Rotate input by the initial bearing
	int control_roll 	= g.rc_1.control_in * simple_cos_x + g.rc_2.control_in * simple_sin_y;
	int control_pitch 	= -(g.rc_1.control_in * simple_sin_y - g.rc_2.control_in * simple_cos_x);

	g.rc_1.control_in = control_roll;
	g.rc_2.control_in = control_pitch;
}

#define THROTTLE_FILTER_SIZE 2

// 50 hz update rate, not 250
// controls all throttle behavior
void update_throttle_mode(void)
{
	int16_t throttle_out;

	#if AUTO_THROTTLE_HOLD != 0
	static float throttle_avg = 0;  // this is initialised to g.throttle_cruise later
	#endif

	switch(throttle_mode){
		case THROTTLE_MANUAL:
			if (g.rc_3.control_in > 0){
			    #if FRAME_CONFIG == HELI_FRAME
				    g.rc_3.servo_out = heli_get_angle_boost(g.rc_3.control_in);
				#else
					if (control_mode == ACRO){
						g.rc_3.servo_out 	= g.rc_3.control_in;
					}else{
						angle_boost 		= get_angle_boost(g.rc_3.control_in);
						g.rc_3.servo_out 	= g.rc_3.control_in + angle_boost;
					}
				#endif

				#if AUTO_THROTTLE_HOLD != 0
				// ensure throttle_avg has been initialised
				if( throttle_avg == 0 ) {
				    throttle_avg = g.throttle_cruise;
				}
				// calc average throttle
				if ((g.rc_3.control_in > MINIMUM_THROTTLE) && abs(climb_rate) < 60){
					throttle_avg = throttle_avg * .98 + (float)g.rc_3.control_in * .02;
					g.throttle_cruise = throttle_avg;
				}
				#endif

				// Code to manage the Copter state
				if ((millis() - takeoff_timer) > 5000){
					// we must be in the air by now
					takeoff_complete 	= true;
				}
			}else{
				// we are on the ground
				takeoff_complete = false;

				// reset baro data if we are near home
				if(home_distance < 400  || GPS_enabled == false){ // 4m from home
					// causes Baro to do a quick recalibration
					// XXX commented until further testing
					// reset_baro();
				}

				// remember our time since takeoff
				// -------------------------------
				takeoff_timer = millis();

				// make sure we also request 0 throttle out
				// so the props stop ... properly
				// ----------------------------------------
				g.rc_3.servo_out = 0;
			}
			break;

		case THROTTLE_HOLD:
			// allow interactive changing of atitude
			adjust_altitude();

			// fall through

		case THROTTLE_AUTO:
			// calculate angle boost
			angle_boost = get_angle_boost(g.throttle_cruise);

			// manual command up or down?
			if(manual_boost != 0){
				#if FRAME_CONFIG == HELI_FRAME
					throttle_out = heli_get_angle_boost(g.throttle_cruise + manual_boost);
				#else
					throttle_out = g.throttle_cruise + angle_boost + manual_boost;
				#endif

				//force a reset of the altitude change
				clear_new_altitude();

				/*
				int16_t iterm = g.pi_alt_hold.get_integrator();

				Serial.printf("tar_alt: %d, actual_alt: %d \talt_err: %d, \t manb: %d, iterm %d\n",
									next_WP.alt,
									current_loc.alt,
									altitude_error,
									manual_boost,
									iterm);
				//*/
				// this lets us know we need to update the altitude after manual throttle control
				reset_throttle_flag = true;

			}else{
				// we are under automatic throttle control
				// ---------------------------------------
				if(reset_throttle_flag)	{
					force_new_altitude(max(current_loc.alt, 100));
					reset_throttle_flag = false;
					update_throttle_cruise();
				}

				// 10hz, 			don't run up i term
				if( motors.auto_armed() == true ){

					// how far off are we
					altitude_error = get_altitude_error();

					// get the AP throttle
					nav_throttle = get_nav_throttle(altitude_error);

					/*
					Serial.printf("tar_alt: %d, actual_alt: %d \talt_err: %d, \tnav_thr: %d, \talt Int: %d\n",
										next_WP.alt,
										current_loc.alt,
										altitude_error,
										nav_throttle,
										(int16_t)g.pi_alt_hold.get_integrator());
					//*/

				}

				// hack to remove the influence of the ground effect
				if(g.sonar_enabled && current_loc.alt < 100 && landing_boost != 0) {
					nav_throttle = min(nav_throttle, 0);
				}

				#if FRAME_CONFIG == HELI_FRAME
					throttle_out = heli_get_angle_boost(g.throttle_cruise + nav_throttle + get_z_damping() - landing_boost);
				#else
					throttle_out = g.throttle_cruise + nav_throttle + angle_boost + get_z_damping() - landing_boost;
				#endif
			}

			// light filter of output
			//g.rc_3.servo_out = (g.rc_3.servo_out * (THROTTLE_FILTER_SIZE - 1) + throttle_out) / THROTTLE_FILTER_SIZE;

			// no filter
			g.rc_3.servo_out = throttle_out;
			break;
	}
}

// called after a GPS read
static void update_navigation()
{
	// wp_distance is in CM
	// --------------------
	switch(control_mode){
		case AUTO:
			// note: wp_control is handled by commands_logic
			verify_commands();

			// calculates desired Yaw
			update_auto_yaw();

			// calculates the desired Roll and Pitch
			update_nav_wp();
			break;

		case GUIDED:
			wp_control = WP_MODE;
            // check if we are close to point > loiter
			wp_verify_byte = 0;
			verify_nav_wp();

			if (wp_control == WP_MODE) {
				update_auto_yaw();
			} else {
				set_mode(LOITER);
			}
			update_nav_wp();
			break;

		case RTL:
			// We have reached Home
			if((wp_distance <= g.waypoint_radius) || check_missed_wp()){
				// if auto_land_timer value > 0, we are set to trigger auto_land after 20 seconds
				set_mode(LOITER);
				if(g.rtl_land_enabled || failsafe)
					auto_land_timer = millis();
				else
					auto_land_timer = 0;
				break;
			}

			wp_control = WP_MODE;
			slow_wp = true;

			// calculates desired Yaw
			#if FRAME_CONFIG ==	HELI_FRAME
			update_auto_yaw();
			#endif

			// calculates the desired Roll and Pitch
			update_nav_wp();
			break;

			// switch passthrough to LOITER
		case LOITER:
		case POSITION:
			// This feature allows us to reposition the quad when the user lets
			// go of the sticks

			if((abs(g.rc_2.control_in) + abs(g.rc_1.control_in)) > 500){
				loiter_override 	= true;
			}

			// Allow the user to take control temporarily,
			if(loiter_override){
				// this sets the copter to not try and nav while we control it
				wp_control 	= NO_NAV_MODE;

				// reset LOITER to current position
				next_WP.lat = current_loc.lat;
				next_WP.lng = current_loc.lng;

				if( g.rc_2.control_in == 0 && g.rc_1.control_in == 0 ){
					loiter_override 	= false;
					wp_control 			= LOITER_MODE;
				}
			}else{
				wp_control = LOITER_MODE;
			}

			// Kick us out of loiter and begin landing if the auto_land_timer is set
			if(auto_land_timer != 0 && (millis() - auto_land_timer) > (uint32_t)g.auto_land_timeout.get()){
				// just to make sure we clear the timer
				auto_land_timer = 0;
				set_mode(LAND);
			}

			// calculates the desired Roll and Pitch
			update_nav_wp();
			break;

		case LAND:
			if(g.sonar_enabled)
				verify_land_sonar();
			else
				verify_land_baro();

			// calculates the desired Roll and Pitch
			update_nav_wp();
			break;

		case CIRCLE:
			yaw_tracking	= MAV_ROI_WPNEXT;
			wp_control 		= CIRCLE_MODE;

			// calculates desired Yaw
			update_auto_yaw();
			update_nav_wp();
			break;

		case STABILIZE:
			wp_control = NO_NAV_MODE;
			update_nav_wp();
			break;

	}

	// are we in SIMPLE mode?
	if(do_simple && g.super_simple){
		// get distance to home
		if(home_distance > 1000){ // 10m from home
			// we reset the angular offset to be a vector from home to the quad
			initial_simple_bearing = home_to_copter_bearing;
			//Serial.printf("ISB: %d\n", initial_simple_bearing);
		}
	}

	if(yaw_mode == YAW_LOOK_AT_HOME){
		if(home_is_set){
			//nav_yaw = point_at_home_yaw();
			nav_yaw = get_bearing(&current_loc, &home);
		} else {
			nav_yaw = 0;
		}
	}
}

static void read_AHRS(void)
{
	// Perform IMU calculations and get attitude info
	//-----------------------------------------------
	#if HIL_MODE != HIL_MODE_DISABLED
		// update hil before ahrs update
		gcs_update();
	#endif

	ahrs.update();
	omega = imu.get_gyro();
}

static void update_trig(void){
	Vector2f yawvector;
	Matrix3f temp 	= ahrs.get_dcm_matrix();

	yawvector.x 	= temp.a.x; // sin
	yawvector.y 	= temp.b.x;	// cos
	yawvector.normalize();

	cos_pitch_x 	= safe_sqrt(1 - (temp.c.x * temp.c.x));	// level = 1
    cos_roll_x 		= temp.c.z / cos_pitch_x;			// level = 1

    cos_pitch_x = constrain(cos_pitch_x, 0, 1.0);
    // this relies on constrain() of infinity doing the right thing,
    // which it does do in avr-libc
    cos_roll_x  = constrain(cos_roll_x, -1.0, 1.0);

	sin_yaw_y 		= yawvector.x;						// 1y = north
	cos_yaw_x 		= yawvector.y;						// 0x = north

	//flat:
	// 0 ° = cos_yaw:  0.00, sin_yaw:  1.00,
	// 90° = cos_yaw:  1.00, sin_yaw:  0.00,
	// 180 = cos_yaw:  0.00, sin_yaw: -1.00,
	// 270 = cos_yaw: -1.00, sin_yaw:  0.00,
}

// updated at 10hz
static void update_altitude()
{
	static int16_t 	old_sonar_alt 	= 0;
	static int32_t 	old_baro_alt 	= 0;

	#if HIL_MODE == HIL_MODE_ATTITUDE
		// we are in the SIM, fake out the baro and Sonar
		int fake_relative_alt = g_gps->altitude - gps_base_alt;
		baro_alt			= fake_relative_alt;
		sonar_alt			= fake_relative_alt;

		baro_rate 			= (baro_alt - old_baro_alt) * 5; // 5hz
		old_baro_alt		= baro_alt;

	#else
		// This is real life

		// read in Actual Baro Altitude
		baro_alt 			= read_barometer();
		//Serial.printf("baro_alt: %d \n", baro_alt);

		// calc the vertical accel rate
		int temp			= (baro_alt - old_baro_alt) * 10;
		baro_rate 			= (temp + baro_rate) >> 1;
		baro_rate			= constrain(baro_rate, -300, 300);
		old_baro_alt		= baro_alt;

		// Note: sonar_alt is calculated in a faster loop and filtered with a mode filter
	#endif

	if(g.sonar_enabled){
		// filter out offset
		float scale;

		// calc rate of change for Sonar
		#if HIL_MODE == HIL_MODE_ATTITUDE
			// we are in the SIM, fake outthe Sonar rate
			sonar_rate		= baro_rate;
		#else
			// This is real life
			// calc the vertical accel rate
			// positive = going up.
			sonar_rate 		= (sonar_alt - old_sonar_alt) * 10;
			sonar_rate		= constrain(sonar_rate, -150, 150);
			old_sonar_alt 	= sonar_alt;
		#endif

		if(baro_alt < 800){
			#if SONAR_TILT_CORRECTION == 1
				// correct alt for angle of the sonar
				float temp = cos_pitch_x * cos_roll_x;
				temp = max(temp, 0.707);
				sonar_alt = (float)sonar_alt * temp;
			#endif

			scale = (float)(sonar_alt - 400) / 200.0;
			scale = constrain(scale, 0.0, 1.0);
			// solve for a blended altitude
			current_loc.alt = ((float)sonar_alt * (1.0 - scale)) + ((float)baro_alt * scale) + home.alt;

			// solve for a blended climb_rate
			climb_rate_actual = ((float)sonar_rate * (1.0 - scale)) + (float)baro_rate * scale;

		}else{
			// we must be higher than sonar (>800), don't get tricked by bad sonar reads
			current_loc.alt = baro_alt + home.alt; // home alt = 0
			// dont blend, go straight baro
			climb_rate_actual 	= baro_rate;
		}

	}else{
		// NO Sonar case
		current_loc.alt = baro_alt + home.alt;
		climb_rate_actual = baro_rate;
	}

	// update the target altitude
	next_WP.alt = get_new_altitude();

	// calc error
	climb_rate_error = (climb_rate_actual - climb_rate) / 5;
}

static void update_altitude_est()
{
	if(alt_sensor_flag){
		update_altitude();
		alt_sensor_flag = false;

		if(g.log_bitmask & MASK_LOG_CTUN && motors.armed()){
			Log_Write_Control_Tuning();
		}

	}else{
		// simple dithering of climb rate
		climb_rate += climb_rate_error;
		current_loc.alt += (climb_rate / 50);
	}
	//Serial.printf(" %d, %d, %d, %d\n", climb_rate_actual, climb_rate_error, climb_rate, current_loc.alt);
}

#define THROTTLE_ADJUST 225
static void
adjust_altitude()
{
	if(g.rc_3.control_in <= (MINIMUM_THROTTLE + THROTTLE_ADJUST)){
		// we remove 0 to 100 PWM from hover
		manual_boost = (g.rc_3.control_in - MINIMUM_THROTTLE) - THROTTLE_ADJUST;
		manual_boost = max(-THROTTLE_ADJUST, manual_boost);

	}else if  (g.rc_3.control_in >= (MAXIMUM_THROTTLE - THROTTLE_ADJUST)){
		// we add 0 to 100 PWM to hover
		manual_boost = g.rc_3.control_in - (MAXIMUM_THROTTLE - THROTTLE_ADJUST);
		manual_boost = min(THROTTLE_ADJUST, manual_boost);

	}else {
		manual_boost = 0;
	}
}

static void tuning(){
	tuning_value = (float)g.rc_6.control_in / 1000.0;
	g.rc_6.set_range(g.radio_tuning_low,g.radio_tuning_high); 		// 0 to 1

	switch(g.radio_tuning){

		case CH6_DAMP:
			g.stabilize_d.set(tuning_value);
			break;

		case CH6_RATE_KD:
			g.pid_rate_roll.kD(tuning_value);
			g.pid_rate_pitch.kD(tuning_value);
			break;

		case CH6_STABILIZE_KP:
			g.pi_stabilize_roll.kP(tuning_value);
			g.pi_stabilize_pitch.kP(tuning_value);
			break;

		case CH6_STABILIZE_KI:
			g.pi_stabilize_roll.kI(tuning_value);
			g.pi_stabilize_pitch.kI(tuning_value);
			break;

		case CH6_STABILIZE_KD:
			g.stabilize_d = tuning_value;
			break;

		case CH6_ACRO_KP:
			g.acro_p = tuning_value;
			break;

		case CH6_RATE_KP:
			g.pid_rate_roll.kP(tuning_value);
			g.pid_rate_pitch.kP(tuning_value);
			break;

		case CH6_RATE_KI:
			g.pid_rate_roll.kI(tuning_value);
			g.pid_rate_pitch.kI(tuning_value);
			break;

		case CH6_YAW_KP:
			g.pi_stabilize_yaw.kP(tuning_value);
			break;

		case CH6_YAW_KI:
			g.pi_stabilize_yaw.kI(tuning_value);
			break;

		case CH6_YAW_RATE_KP:
			g.pid_rate_yaw.kP(tuning_value);
			break;

		case CH6_YAW_RATE_KD:
			g.pid_rate_yaw.kD(tuning_value);
			break;

		case CH6_THROTTLE_KP:
			g.pid_throttle.kP(tuning_value);
			break;

		case CH6_TOP_BOTTOM_RATIO:
			motors.top_bottom_ratio = tuning_value;
			break;

		case CH6_RELAY:
		  	if (g.rc_6.control_in > 525) relay.on();
		  	if (g.rc_6.control_in < 475) relay.off();
			break;

		case CH6_TRAVERSE_SPEED:
			g.waypoint_speed_max = g.rc_6.control_in;
			break;

		case CH6_LOITER_KP:
			g.pi_loiter_lat.kP(tuning_value);
			g.pi_loiter_lon.kP(tuning_value);
			break;

		case CH6_LOITER_KI:
			g.pi_loiter_lat.kI(tuning_value);
			g.pi_loiter_lon.kI(tuning_value);
			break;

		case CH6_NAV_KP:
			g.pid_nav_lat.kP(tuning_value);
			g.pid_nav_lon.kP(tuning_value);
			break;

		case CH6_LOITER_RATE_KP:
			g.pid_loiter_rate_lon.kP(tuning_value);
			g.pid_loiter_rate_lat.kP(tuning_value);
			break;

		case CH6_LOITER_RATE_KI:
			g.pid_loiter_rate_lon.kI(tuning_value);
			g.pid_loiter_rate_lat.kI(tuning_value);
			break;

		case CH6_LOITER_RATE_KD:
			g.pid_loiter_rate_lon.kD(tuning_value);
			g.pid_loiter_rate_lat.kD(tuning_value);
			break;

		case CH6_NAV_I:
			g.pid_nav_lat.kI(tuning_value);
			g.pid_nav_lon.kI(tuning_value);
			break;

		#if FRAME_CONFIG == HELI_FRAME
		case CH6_HELI_EXTERNAL_GYRO:
			motors.ext_gyro_gain = tuning_value;
			break;
		#endif

		case CH6_THR_HOLD_KP:
			g.pi_alt_hold.kP(tuning_value);
			break;

		case CH6_OPTFLOW_KP:
			g.pid_optflow_roll.kP(tuning_value);
			g.pid_optflow_pitch.kP(tuning_value);
			break;

		case CH6_OPTFLOW_KI:
			g.pid_optflow_roll.kI(tuning_value);
			g.pid_optflow_pitch.kI(tuning_value);
			break;

		case CH6_OPTFLOW_KD:
			g.pid_optflow_roll.kD(tuning_value);
			g.pid_optflow_pitch.kD(tuning_value);
			break;
	}
}

// Outputs Nav_Pitch and Nav_Roll
static void update_nav_wp()
{
	if(wp_control == LOITER_MODE){

		// calc error to target
		calc_location_error(&next_WP);

		// use error as the desired rate towards the target
		calc_loiter(long_error, lat_error);

		// rotate pitch and roll to the copter frame of reference
		calc_loiter_pitch_roll();

	}else if(wp_control == CIRCLE_MODE){

		// check if we have missed the WP
		int loiter_delta = (target_bearing - old_target_bearing)/100;

		// reset the old value
		old_target_bearing = target_bearing;

		// wrap values
		if (loiter_delta > 180) loiter_delta -= 360;
		if (loiter_delta < -180) loiter_delta += 360;

		// sum the angle around the WP
		loiter_sum += loiter_delta;

		// create a virtual waypoint that circles the next_WP
		// Count the degrees we have circulated the WP
		//int circle_angle = wrap_360(target_bearing + 3000 + 18000) / 100;

		circle_angle += (circle_rate * dTnav);
		//1° = 0.0174532925 radians

		// wrap
		if (circle_angle > 6.28318531)
			circle_angle -= 6.28318531;

		circle_WP.lng = next_WP.lng + (g.loiter_radius * 100 * cos(1.57 - circle_angle) * scaleLongUp);
		circle_WP.lat = next_WP.lat + (g.loiter_radius * 100 * sin(1.57 - circle_angle));

		// calc the lat and long error to the target
		calc_location_error(&circle_WP);

		// use error as the desired rate towards the target
		// nav_lon, nav_lat is calculated
		calc_loiter(long_error, lat_error);

		//CIRCLE: angle:29, dist:0, lat:400, lon:242

		// rotate pitch and roll to the copter frame of reference
		calc_loiter_pitch_roll();

		// debug
		//int angleTest = degrees(circle_angle);
		//int nroll = nav_roll;
		//int npitch = nav_pitch;
		//Serial.printf("CIRCLE: angle:%d, dist:%d, X:%d, Y:%d, P:%d, R:%d  \n", angleTest, (int)wp_distance , (int)long_error, (int)lat_error, npitch, nroll);

	}else if(wp_control == WP_MODE){
		// calc error to target
		calc_location_error(&next_WP);

		int16_t speed = calc_desired_speed(g.waypoint_speed_max, slow_wp);
		// use error as the desired rate towards the target
		calc_nav_rate(speed);
		// rotate pitch and roll to the copter frame of reference
		calc_loiter_pitch_roll();

	}else if(wp_control == NO_NAV_MODE){
		// clear out our nav so we can do things like land straight down
		// or change Loiter position

		// We bring copy over our Iterms for wind control, but we don't navigate
		nav_lon	= g.pid_loiter_rate_lon.get_integrator();
		nav_lat = g.pid_loiter_rate_lon.get_integrator();

		nav_lon			= constrain(nav_lon, -2000, 2000); 			// 20°
		nav_lat			= constrain(nav_lat, -2000, 2000); 			// 20°

		// rotate pitch and roll to the copter frame of reference
		calc_loiter_pitch_roll();
	}
}

static void update_auto_yaw()
{
	// If we Loiter, don't start Yawing, allow Yaw control
	if(wp_control == LOITER_MODE)
		return;

	// this tracks a location so the copter is always pointing towards it.
	if(yaw_tracking == MAV_ROI_LOCATION){
		auto_yaw = get_bearing(&current_loc, &target_WP);

	}else if(yaw_tracking == MAV_ROI_WPNEXT){
		// Point towards next WP
		auto_yaw = target_bearing;
	}
	//Serial.printf("auto_yaw %d ", auto_yaw);
	// MAV_ROI_NONE = basic Yaw hold
}
