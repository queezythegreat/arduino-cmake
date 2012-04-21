// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

// use this to prevent recursion during sensor init
static bool in_mavlink_delay;


// this costs us 51 bytes, but means that low priority
// messages don't block the CPU
static mavlink_statustext_t pending_status;

// true when we have received at least 1 MAVLink packet
static bool mavlink_active;


// check if a message will fit in the payload space available
#define CHECK_PAYLOAD_SIZE(id) if (payload_space < MAVLINK_MSG_ID_## id ##_LEN) return false

/*
  !!NOTE!!

  the use of NOINLINE separate functions for each message type avoids
  a compiler bug in gcc that would cause it to use far more stack
  space than is needed. Without the NOINLINE we use the sum of the
  stack needed for each message type. Please be careful to follow the
  pattern below when adding any new messages
 */

static NOINLINE void send_heartbeat(mavlink_channel_t chan)
{
    mavlink_msg_heartbeat_send(
        chan,
        2 /*mavlink_system.type*/,  //MAV_TYPE_QUADROTOR
        MAV_AUTOPILOT_ARDUPILOTMEGA);
}

static NOINLINE void send_attitude(mavlink_channel_t chan)
{
    mavlink_msg_attitude_send(
        chan,
        micros(),
        ahrs.roll,
        ahrs.pitch,
        ahrs.yaw,
        omega.x,
        omega.y,
        omega.z);
}

static NOINLINE void send_extended_status1(mavlink_channel_t chan, uint16_t packet_drops)
{
    uint8_t mode 	 = MAV_MODE_UNINIT;
    uint8_t nav_mode = MAV_NAV_VECTOR;

    switch(control_mode) {
    case LOITER:
        mode 		= MAV_MODE_AUTO;
        nav_mode 	= MAV_NAV_HOLD;
        break;
    case AUTO:
        mode 		= MAV_MODE_AUTO;
        nav_mode 	= MAV_NAV_WAYPOINT;
        break;
    case RTL:
        mode 		= MAV_MODE_AUTO;
        nav_mode 	= MAV_NAV_RETURNING;
        break;
    case GUIDED:
        mode 		= MAV_MODE_GUIDED;
        nav_mode 	= MAV_NAV_WAYPOINT;
        break;
    default:
        mode 		= control_mode + 100;
    }

    uint8_t status 		= MAV_STATE_ACTIVE;

    if (!motors.armed()) {
        status 		= MAV_STATE_STANDBY;
    }

    uint16_t battery_remaining = 1000.0 * (float)(g.pack_capacity - current_total1)/(float)g.pack_capacity;	//Mavlink scaling 100% = 1000

    mavlink_msg_sys_status_send(
        chan,
        mode,
        nav_mode,
        status,
        0,
        battery_voltage1 * 1000,
        battery_remaining,
        packet_drops);
}

static void NOINLINE send_meminfo(mavlink_channel_t chan)
{
    extern unsigned __brkval;
    mavlink_msg_meminfo_send(chan, __brkval, memcheck_available_memory());
}

static void NOINLINE send_location(mavlink_channel_t chan)
{
    Matrix3f rot = ahrs.get_dcm_matrix(); // neglecting angle of attack for now
    mavlink_msg_global_position_int_send(
        chan,
        current_loc.lat,
        current_loc.lng,
        current_loc.alt * 10,
        g_gps->ground_speed * rot.a.x,
        g_gps->ground_speed * rot.b.x,
        g_gps->ground_speed * rot.c.x);
}

static void NOINLINE send_nav_controller_output(mavlink_channel_t chan)
{
    mavlink_msg_nav_controller_output_send(
        chan,
        nav_roll / 1.0e2,
        nav_pitch / 1.0e2,
        nav_bearing / 1.0e2,
        target_bearing / 1.0e2,
        wp_distance / 1.0e2,
        altitude_error / 1.0e2,
        0,
        crosstrack_error);	// was 0
}

#if HIL_MODE != HIL_MODE_ATTITUDE
static void NOINLINE send_ahrs(mavlink_channel_t chan)
{
    Vector3f omega_I = ahrs.get_gyro_drift();
    mavlink_msg_ahrs_send(
        chan,
        omega_I.x,
        omega_I.y,
        omega_I.z,
        1,
        0,
        ahrs.get_error_rp(),
        ahrs.get_error_yaw());
}
#endif // HIL_MODE != HIL_MODE_ATTITUDE

#ifdef DESKTOP_BUILD
// report simulator state
static void NOINLINE send_simstate(mavlink_channel_t chan)
{
    extern void sitl_simstate_send(uint8_t chan);
    sitl_simstate_send((uint8_t)chan);
}
#endif

#ifndef DESKTOP_BUILD
static void NOINLINE send_hwstatus(mavlink_channel_t chan)
{
    mavlink_msg_hwstatus_send(
        chan,
        board_voltage(),
        I2c.lockup_count());
}
#endif


static void NOINLINE send_gps_raw(mavlink_channel_t chan)
{
    mavlink_msg_gps_raw_send(
        chan,
        micros(),
        g_gps->status(),
        g_gps->latitude / 1.0e7,
        g_gps->longitude / 1.0e7,
        g_gps->altitude / 100.0,
        g_gps->hdop,
        current_loc.alt / 100.0, // was 0
        g_gps->ground_speed / 100.0,
        g_gps->ground_course / 100.0);
}

static void NOINLINE send_servo_out(mavlink_channel_t chan)
{
    const uint8_t rssi = 1;
    // normalized values scaled to -10000 to 10000
    // This is used for HIL.  Do not change without discussing with HIL maintainers

    #if FRAME_CONFIG ==	HELI_FRAME

        mavlink_msg_rc_channels_scaled_send(
        chan,
        g.rc_1.servo_out,
        g.rc_2.servo_out,
        g.rc_3.radio_out,
        g.rc_4.servo_out,
        0,
        0,
        0,
        0,
        rssi);
    #else
		#if X_PLANE == ENABLED
			 /* update by JLN for X-Plane HIL */
			if(motors.armed() && motors.auto_armed()){
				mavlink_msg_rc_channels_scaled_send(
					chan,
					g.rc_1.servo_out,
					g.rc_2.servo_out,
					10000 * g.rc_3.norm_output(),
					g.rc_4.servo_out,
					10000 * g.rc_1.norm_output(),
					10000 * g.rc_2.norm_output(),
					10000 * g.rc_3.norm_output(),
					10000 * g.rc_4.norm_output(),
					rssi);
		   }else{
				mavlink_msg_rc_channels_scaled_send(
					chan,
					0,
					0,
					-10000,
					0,
					10000 * g.rc_1.norm_output(),
					10000 * g.rc_2.norm_output(),
					10000 * g.rc_3.norm_output(),
					10000 * g.rc_4.norm_output(),
					rssi);
		  }

		#else
			mavlink_msg_rc_channels_scaled_send(
				chan,
				g.rc_1.servo_out,
				g.rc_2.servo_out,
				g.rc_3.radio_out,
				g.rc_4.servo_out,
				10000 * g.rc_1.norm_output(),
				10000 * g.rc_2.norm_output(),
				10000 * g.rc_3.norm_output(),
				10000 * g.rc_4.norm_output(),
				rssi);
		 #endif
     #endif
}

static void NOINLINE send_radio_in(mavlink_channel_t chan)
{
    const uint8_t rssi = 1;
    mavlink_msg_rc_channels_raw_send(
        chan,
        g.rc_1.radio_in,
        g.rc_2.radio_in,
        g.rc_3.radio_in,
        g.rc_4.radio_in,
        g.rc_5.radio_in,
        g.rc_6.radio_in,
        g.rc_7.radio_in,
        g.rc_8.radio_in,
        rssi);
}

static void NOINLINE send_radio_out(mavlink_channel_t chan)
{
    mavlink_msg_servo_output_raw_send(
        chan,
        motors.motor_out[AP_MOTORS_MOT_1],
        motors.motor_out[AP_MOTORS_MOT_2],
        motors.motor_out[AP_MOTORS_MOT_3],
        motors.motor_out[AP_MOTORS_MOT_4],
        motors.motor_out[AP_MOTORS_MOT_5],
        motors.motor_out[AP_MOTORS_MOT_6],
        motors.motor_out[AP_MOTORS_MOT_7],
        motors.motor_out[AP_MOTORS_MOT_8]);
}

static void NOINLINE send_vfr_hud(mavlink_channel_t chan)
{
    mavlink_msg_vfr_hud_send(
        chan,
        (float)g_gps->ground_speed / 100.0,
        (float)g_gps->ground_speed / 100.0,
        (ahrs.yaw_sensor / 100) % 360,
        g.rc_3.servo_out/10,
        current_loc.alt / 100.0,
        climb_rate);
}

#if HIL_MODE != HIL_MODE_ATTITUDE
static void NOINLINE send_raw_imu1(mavlink_channel_t chan)
{
    Vector3f accel = imu.get_accel();
    Vector3f gyro = imu.get_gyro();
    mavlink_msg_raw_imu_send(
        chan,
        micros(),
        accel.x * 1000.0 / gravity,
        accel.y * 1000.0 / gravity,
        accel.z * 1000.0 / gravity,
        gyro.x * 1000.0,
        gyro.y * 1000.0,
        gyro.z * 1000.0,
        compass.mag_x,
        compass.mag_y,
        compass.mag_z);
}

static void NOINLINE send_raw_imu2(mavlink_channel_t chan)
{
    mavlink_msg_scaled_pressure_send(
        chan,
        micros(),
        (float)barometer.get_pressure()/100.0,
        (float)(barometer.get_pressure()-ground_pressure)/100.0,
        (int)(barometer.get_temperature()*10));
}

static void NOINLINE send_raw_imu3(mavlink_channel_t chan)
{
    Vector3f mag_offsets = compass.get_offsets();

    mavlink_msg_sensor_offsets_send(chan,
                                    mag_offsets.x,
                                    mag_offsets.y,
                                    mag_offsets.z,
                                    compass.get_declination(),
                                    barometer.get_raw_pressure(),
                                    barometer.get_raw_temp(),
                                    imu.gx(), imu.gy(), imu.gz(),
                                    imu.ax(), imu.ay(), imu.az());
}
#endif // HIL_MODE != HIL_MODE_ATTITUDE

static void NOINLINE send_gps_status(mavlink_channel_t chan)
{
    mavlink_msg_gps_status_send(
        chan,
        g_gps->num_sats,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL);
}

static void NOINLINE send_current_waypoint(mavlink_channel_t chan)
{
    mavlink_msg_waypoint_current_send(
        chan,
        (uint16_t)g.command_index);
}

static void NOINLINE send_statustext(mavlink_channel_t chan)
{
    mavlink_msg_statustext_send(
        chan,
        pending_status.severity,
        pending_status.text);
}


// try to send a message, return false if it won't fit in the serial tx buffer
static bool mavlink_try_send_message(mavlink_channel_t chan, enum ap_message id, uint16_t packet_drops)
{
    int payload_space = comm_get_txspace(chan) - MAVLINK_NUM_NON_PAYLOAD_BYTES;

    if (chan == MAVLINK_COMM_1 && millis() < MAVLINK_TELEMETRY_PORT_DELAY) {
        // defer any messages on the telemetry port for 1 second after
        // bootup, to try to prevent bricking of Xbees
        return false;
    }

	switch(id) {
    case MSG_HEARTBEAT:
        CHECK_PAYLOAD_SIZE(HEARTBEAT);
        send_heartbeat(chan);
        return true;

    case MSG_EXTENDED_STATUS1:
        CHECK_PAYLOAD_SIZE(SYS_STATUS);
        send_extended_status1(chan, packet_drops);
        break;

    case MSG_EXTENDED_STATUS2:
        CHECK_PAYLOAD_SIZE(MEMINFO);
        send_meminfo(chan);
        break;

    case MSG_ATTITUDE:
        CHECK_PAYLOAD_SIZE(ATTITUDE);
        send_attitude(chan);
        break;

    case MSG_LOCATION:
        CHECK_PAYLOAD_SIZE(GLOBAL_POSITION_INT);
        send_location(chan);
        break;

    case MSG_NAV_CONTROLLER_OUTPUT:
        CHECK_PAYLOAD_SIZE(NAV_CONTROLLER_OUTPUT);
        send_nav_controller_output(chan);
        break;

    case MSG_GPS_RAW:
        CHECK_PAYLOAD_SIZE(GPS_RAW);
        send_gps_raw(chan);
        break;

    case MSG_SERVO_OUT:
        CHECK_PAYLOAD_SIZE(RC_CHANNELS_SCALED);
        send_servo_out(chan);
        break;

    case MSG_RADIO_IN:
        CHECK_PAYLOAD_SIZE(RC_CHANNELS_RAW);
        send_radio_in(chan);
        break;

    case MSG_RADIO_OUT:
        CHECK_PAYLOAD_SIZE(SERVO_OUTPUT_RAW);
        send_radio_out(chan);
        break;

    case MSG_VFR_HUD:
        CHECK_PAYLOAD_SIZE(VFR_HUD);
        send_vfr_hud(chan);
        break;

#if HIL_MODE != HIL_MODE_ATTITUDE
    case MSG_RAW_IMU1:
        CHECK_PAYLOAD_SIZE(RAW_IMU);
        send_raw_imu1(chan);
        break;

    case MSG_RAW_IMU2:
        CHECK_PAYLOAD_SIZE(SCALED_PRESSURE);
        send_raw_imu2(chan);
        break;

    case MSG_RAW_IMU3:
        CHECK_PAYLOAD_SIZE(SENSOR_OFFSETS);
        send_raw_imu3(chan);
        break;
#endif // HIL_MODE != HIL_MODE_ATTITUDE

    case MSG_GPS_STATUS:
        CHECK_PAYLOAD_SIZE(GPS_STATUS);
        send_gps_status(chan);
        break;

    case MSG_CURRENT_WAYPOINT:
        CHECK_PAYLOAD_SIZE(WAYPOINT_CURRENT);
        send_current_waypoint(chan);
        break;

    case MSG_NEXT_PARAM:
        CHECK_PAYLOAD_SIZE(PARAM_VALUE);
        if (chan == MAVLINK_COMM_0) {
            gcs0.queued_param_send();
        } else if (gcs3.initialised) {
            gcs3.queued_param_send();
        }
        break;

    case MSG_NEXT_WAYPOINT:
        CHECK_PAYLOAD_SIZE(WAYPOINT_REQUEST);
        if (chan == MAVLINK_COMM_0) {
            gcs0.queued_waypoint_send();
        } else {
            gcs3.queued_waypoint_send();
        }
        break;

    case MSG_STATUSTEXT:
        CHECK_PAYLOAD_SIZE(STATUSTEXT);
        send_statustext(chan);
        break;

    case MSG_AHRS:
#if HIL_MODE != HIL_MODE_ATTITUDE
        CHECK_PAYLOAD_SIZE(AHRS);
        send_ahrs(chan);
#endif
        break;

    case MSG_SIMSTATE:
#ifdef DESKTOP_BUILD
        CHECK_PAYLOAD_SIZE(SIMSTATE);
        send_simstate(chan);
#endif
        break;

    case MSG_HWSTATUS:
#ifndef DESKTOP_BUILD
        CHECK_PAYLOAD_SIZE(HWSTATUS);
        send_hwstatus(chan);
#endif
        break;

    case MSG_RETRY_DEFERRED:
        break; // just here to prevent a warning
	}
    return true;
}


#define MAX_DEFERRED_MESSAGES MSG_RETRY_DEFERRED
static struct mavlink_queue {
    enum ap_message deferred_messages[MAX_DEFERRED_MESSAGES];
    uint8_t next_deferred_message;
    uint8_t num_deferred_messages;
} mavlink_queue[2];

// send a message using mavlink
static void mavlink_send_message(mavlink_channel_t chan, enum ap_message id, uint16_t packet_drops)
{
    uint8_t i, nextid;
    struct mavlink_queue *q = &mavlink_queue[(uint8_t)chan];

    // see if we can send the deferred messages, if any
    while (q->num_deferred_messages != 0) {
        if (!mavlink_try_send_message(chan,
                                      q->deferred_messages[q->next_deferred_message],
                                      packet_drops)) {
            break;
        }
        q->next_deferred_message++;
        if (q->next_deferred_message == MAX_DEFERRED_MESSAGES) {
            q->next_deferred_message = 0;
        }
        q->num_deferred_messages--;
    }

    if (id == MSG_RETRY_DEFERRED) {
        return;
    }

    // this message id might already be deferred
    for (i=0, nextid = q->next_deferred_message; i < q->num_deferred_messages; i++) {
        if (q->deferred_messages[nextid] == id) {
            // its already deferred, discard
            return;
        }
        nextid++;
        if (nextid == MAX_DEFERRED_MESSAGES) {
            nextid = 0;
        }
    }

    if (q->num_deferred_messages != 0 ||
        !mavlink_try_send_message(chan, id, packet_drops)) {
        // can't send it now, so defer it
        if (q->num_deferred_messages == MAX_DEFERRED_MESSAGES) {
            // the defer buffer is full, discard
            return;
        }
        nextid = q->next_deferred_message + q->num_deferred_messages;
        if (nextid >= MAX_DEFERRED_MESSAGES) {
            nextid -= MAX_DEFERRED_MESSAGES;
        }
        q->deferred_messages[nextid] = id;
        q->num_deferred_messages++;
    }
}

void mavlink_send_text(mavlink_channel_t chan, gcs_severity severity, const char *str)
{
    if (chan == MAVLINK_COMM_1 && millis() < MAVLINK_TELEMETRY_PORT_DELAY) {
        // don't send status MAVLink messages for 2 seconds after
        // bootup, to try to prevent Xbee bricking
        return;
    }

    if (severity == SEVERITY_LOW) {
        // send via the deferred queuing system
        pending_status.severity = (uint8_t)severity;
        strncpy((char *)pending_status.text, str, sizeof(pending_status.text));
        mavlink_send_message(chan, MSG_STATUSTEXT, 0);
    } else {
        // send immediately
	mavlink_msg_statustext_send(
				chan,
				severity,
				(const int8_t*) str);
}
}

const AP_Param::GroupInfo GCS_MAVLINK::var_info[] PROGMEM = {
    AP_GROUPINFO("RAW_SENS", 0, GCS_MAVLINK, streamRateRawSensors),
	AP_GROUPINFO("EXT_STAT", 1, GCS_MAVLINK, streamRateExtendedStatus),
    AP_GROUPINFO("RC_CHAN",  2, GCS_MAVLINK, streamRateRCChannels),
	AP_GROUPINFO("RAW_CTRL", 3, GCS_MAVLINK, streamRateRawController),
	AP_GROUPINFO("POSITION", 4, GCS_MAVLINK, streamRatePosition),
	AP_GROUPINFO("EXTRA1",   5, GCS_MAVLINK, streamRateExtra1),
	AP_GROUPINFO("EXTRA2",   6, GCS_MAVLINK, streamRateExtra2),
	AP_GROUPINFO("EXTRA3",   7, GCS_MAVLINK, streamRateExtra3),
	AP_GROUPINFO("PARAMS",   8, GCS_MAVLINK, streamRateParams),
    AP_GROUPEND
};


GCS_MAVLINK::GCS_MAVLINK() :
packet_drops(0),
waypoint_send_timeout(1000), // 1 second
waypoint_receive_timeout(1000) // 1 second
{

}

void
GCS_MAVLINK::init(FastSerial * port)
{
	GCS_Class::init(port);
    if (port == &Serial) {
		mavlink_comm_0_port = port;
		chan = MAVLINK_COMM_0;
	}else{
		mavlink_comm_1_port = port;
		chan = MAVLINK_COMM_1;
	}
	_queued_parameter = NULL;
}

void
GCS_MAVLINK::update(void)
{
	// receive new packets
	mavlink_message_t msg;
	mavlink_status_t status;
	status.packet_rx_drop_count = 0;

	// process received bytes
	while(comm_get_available(chan))
	{
		uint8_t c = comm_receive_ch(chan);

#if CLI_ENABLED == ENABLED
        /* allow CLI to be started by hitting enter 3 times, if no
           heartbeat packets have been received */
        if (mavlink_active == false) {
            if (c == '\n' || c == '\r') {
                crlf_count++;
            } else {
                crlf_count = 0;
            }
            if (crlf_count == 3) {
                run_cli();
            }
        }
#endif

		// Try to get a new message
        if (mavlink_parse_char(chan, c, &msg, &status)) {
            mavlink_active = true;
            handleMessage(&msg);
        }
	}

	// Update packet drops counter
	packet_drops += status.packet_rx_drop_count;

    if (!waypoint_receiving && !waypoint_sending) {
        return;
    }

    uint32_t tnow = millis();

    if (waypoint_receiving &&
        waypoint_request_i <= (unsigned)g.command_total &&
        tnow > waypoint_timelast_request + 500 + (stream_slowdown*20)) {
        waypoint_timelast_request = tnow;
        send_message(MSG_NEXT_WAYPOINT);
    }

    // stop waypoint sending if timeout
    if (waypoint_sending && (tnow - waypoint_timelast_send) > waypoint_send_timeout){
        waypoint_sending = false;
    }

    // stop waypoint receiving if timeout
    if (waypoint_receiving && (tnow - waypoint_timelast_receive) > waypoint_receive_timeout){
        waypoint_receiving = false;
    }
}

// see if we should send a stream now. Called at 50Hz
bool GCS_MAVLINK::stream_trigger(enum streams stream_num)
{
    AP_Int16 *stream_rates = &streamRateRawSensors;
    uint8_t rate = (uint8_t)stream_rates[stream_num].get();

    if (rate == 0) {
        return false;
    }

    if (stream_ticks[stream_num] == 0) {
        // we're triggering now, setup the next trigger point
        if (rate > 50) {
            rate = 50;
        }
        stream_ticks[stream_num] = (50 / rate) + stream_slowdown;
        return true;
    }

    // count down at 50Hz
    stream_ticks[stream_num]--;
    return false;
}

void
GCS_MAVLINK::data_stream_send(void)
{
    if (waypoint_receiving || waypoint_sending) {
        // don't interfere with mission transfer
        return;
    }

    if (_queued_parameter != NULL) {
        if (streamRateParams.get() <= 0) {
            streamRateParams.set(50);
        }
        if (stream_trigger(STREAM_PARAMS)) {
            send_message(MSG_NEXT_PARAM);
        }
        // don't send anything else at the same time as parameters
        return;
    }

    if (stream_trigger(STREAM_RAW_SENSORS)) {
			send_message(MSG_RAW_IMU1);
			send_message(MSG_RAW_IMU2);
			send_message(MSG_RAW_IMU3);
			//Serial.printf("mav1 %d\n", (int)streamRateRawSensors.get());
		}

    if (stream_trigger(STREAM_EXTENDED_STATUS)) {
			send_message(MSG_EXTENDED_STATUS1);
			send_message(MSG_EXTENDED_STATUS2);
			send_message(MSG_CURRENT_WAYPOINT);
			send_message(MSG_GPS_RAW);			// TODO - remove this message after location message is working
			send_message(MSG_NAV_CONTROLLER_OUTPUT);

            if (last_gps_satellites != g_gps->num_sats) {
                // this message is mostly a huge waste of bandwidth,
                // except it is the only message that gives the number
                // of visible satellites. So only send it when that
                // changes.
                send_message(MSG_GPS_STATUS);
                last_gps_satellites = g_gps->num_sats;
            }
		}

    if (stream_trigger(STREAM_POSITION)) {
			// sent with GPS read
#if HIL_MODE == HIL_MODE_ATTITUDE
			send_message(MSG_LOCATION);
#endif
			//Serial.printf("mav3 %d\n", (int)streamRatePosition.get());
		}

    if (stream_trigger(STREAM_RAW_CONTROLLER)) {
			send_message(MSG_SERVO_OUT);
			//Serial.printf("mav4 %d\n", (int)streamRateRawController.get());
		}

    if (stream_trigger(STREAM_RC_CHANNELS)) {
			send_message(MSG_RADIO_OUT);
			send_message(MSG_RADIO_IN);
			//Serial.printf("mav5 %d\n", (int)streamRateRCChannels.get());
		}

    if (stream_trigger(STREAM_EXTRA1)) {
			send_message(MSG_ATTITUDE);
			send_message(MSG_SIMSTATE);
			//Serial.printf("mav6 %d\n", (int)streamRateExtra1.get());
		}

    if (stream_trigger(STREAM_EXTRA2)) {
			send_message(MSG_VFR_HUD);
			//Serial.printf("mav7 %d\n", (int)streamRateExtra2.get());
		}

    if (stream_trigger(STREAM_EXTRA3)) {
			send_message(MSG_AHRS);
			send_message(MSG_HWSTATUS);
		}
	}



void
GCS_MAVLINK::send_message(enum ap_message id)
{
    mavlink_send_message(chan,id, packet_drops);
}

void
GCS_MAVLINK::send_text(gcs_severity severity, const char *str)
{
    mavlink_send_text(chan,severity,str);
}

void
GCS_MAVLINK::send_text(gcs_severity severity, const prog_char_t *str)
{
    mavlink_statustext_t m;
    uint8_t i;
    for (i=0; i<sizeof(m.text); i++) {
        m.text[i] = pgm_read_byte((const prog_char *)(str++));
    }
    if (i < sizeof(m.text)) m.text[i] = 0;
    mavlink_send_text(chan, severity, (const char *)m.text);
}

void GCS_MAVLINK::handleMessage(mavlink_message_t* msg)
{
	struct Location tell_command = {};				// command for telemetry
	static uint8_t mav_nav = 255;							// For setting mode (some require receipt of 2 messages...)

	switch (msg->msgid) {

	case MAVLINK_MSG_ID_REQUEST_DATA_STREAM: //66
		{
			// decode
			mavlink_request_data_stream_t packet;
			mavlink_msg_request_data_stream_decode(msg, &packet);

			if (mavlink_check_target(packet.target_system, packet.target_component))
				break;

			int freq = 0; // packet frequency

			if (packet.start_stop == 0)
				freq = 0; // stop sending
			else if (packet.start_stop == 1)
				freq = packet.req_message_rate; // start sending
			else
				break;

			switch(packet.req_stream_id){

				case MAV_DATA_STREAM_ALL:
					streamRateRawSensors		= freq;
					streamRateExtendedStatus	= freq;
					streamRateRCChannels		= freq;
					streamRateRawController		= freq;
					streamRatePosition			= freq;
					streamRateExtra1			= freq;
					streamRateExtra2			= freq;
					//streamRateExtra3.set_and_save(freq);	// We just do set and save on the last as it takes care of the whole group.
					streamRateExtra3			= freq;	// Don't save!!
					break;

				case MAV_DATA_STREAM_RAW_SENSORS:
					streamRateRawSensors = freq;		// We do not set and save this one so that if HIL is shut down incorrectly
														// we will not continue to broadcast raw sensor data at 50Hz.
					break;
				case MAV_DATA_STREAM_EXTENDED_STATUS:
					//streamRateExtendedStatus.set_and_save(freq);
					streamRateExtendedStatus = freq;
					break;

				case MAV_DATA_STREAM_RC_CHANNELS:
					streamRateRCChannels  = freq;
					break;

				case MAV_DATA_STREAM_RAW_CONTROLLER:
					streamRateRawController = freq;
					break;

				//case MAV_DATA_STREAM_RAW_SENSOR_FUSION:
				//	streamRateRawSensorFusion.set_and_save(freq);
				//	break;

				case MAV_DATA_STREAM_POSITION:
					streamRatePosition = freq;
					break;

				case MAV_DATA_STREAM_EXTRA1:
					streamRateExtra1 = freq;
					break;

				case MAV_DATA_STREAM_EXTRA2:
					streamRateExtra2 = freq;
					break;

				case MAV_DATA_STREAM_EXTRA3:
					streamRateExtra3 = freq;
					break;

				default:
					break;
			}
			break;
		}

	case MAVLINK_MSG_ID_ACTION: //10
		{
			// decode
			mavlink_action_t packet;
			mavlink_msg_action_decode(msg, &packet);
			if (mavlink_check_target(packet.target,packet.target_component)) break;

            if (in_mavlink_delay) {
                // don't execute action commands while in sensor
                // initialisation
                break;
            }

			uint8_t result = 0;

			// do action
			send_text(SEVERITY_LOW,PSTR("action received: "));
//Serial.println(packet.action);
			switch(packet.action){

				case MAV_ACTION_LAUNCH:
					//set_mode(TAKEOFF);
					break;

				case MAV_ACTION_RETURN:
					set_mode(RTL);
					result=1;
					break;

				case MAV_ACTION_EMCY_LAND:
					set_mode(LAND);
					break;

				case MAV_ACTION_HALT:
					do_loiter_at_location();
					result=1;
					break;

					/* No mappable implementation in APM 2.0
				case MAV_ACTION_MOTORS_START:
				case MAV_ACTION_CONFIRM_KILL:
				case MAV_ACTION_EMCY_KILL:
				case MAV_ACTION_MOTORS_STOP:
				case MAV_ACTION_SHUTDOWN:
					break;
				*/

				case MAV_ACTION_CONTINUE:
					//process_command_queue();
					result=1;
					break;

				case MAV_ACTION_SET_MANUAL:
					set_mode(STABILIZE);
					result=1;
					break;

				case MAV_ACTION_SET_AUTO:
					set_mode(AUTO);
					result=1;
					break;

				case MAV_ACTION_STORAGE_READ:
                    // we load all variables at startup, and
                    // save on each mavlink set
					result=1;
					break;

				case MAV_ACTION_STORAGE_WRITE:
                    // this doesn't make any sense, as we save
                    // all settings as they come in
					result=1;
					break;

				case MAV_ACTION_CALIBRATE_RC: break;
					trim_radio();
					result=1;
					break;

				case MAV_ACTION_CALIBRATE_GYRO:
				case MAV_ACTION_CALIBRATE_MAG:
				case MAV_ACTION_CALIBRATE_PRESSURE:
					break;

				case MAV_ACTION_CALIBRATE_ACC:
					imu.init_accel(mavlink_delay, flash_leds);
					result=1;
					break;


				//case MAV_ACTION_REBOOT:  // this is a rough interpretation
					//startup_IMU_ground();
					//result=1;
				//	break;

				/*	For future implemtation
				case MAV_ACTION_REC_START: break;
				case MAV_ACTION_REC_PAUSE: break;
				case MAV_ACTION_REC_STOP: break;
				*/

				/* Takeoff is not an implemented flight mode in APM 2.0
				case MAV_ACTION_TAKEOFF:
					set_mode(TAKEOFF);
					break;
				*/

				case MAV_ACTION_NAVIGATE:
					set_mode(AUTO);
					result=1;
					break;

				case MAV_ACTION_LAND:
					set_mode(LAND);
					break;

				case MAV_ACTION_LOITER:
					set_mode(LOITER);
					result=1;
					break;

				default: break;
				}

				mavlink_msg_action_ack_send(
					chan,
					packet.action,
					result
					);

			break;
		}

	case MAVLINK_MSG_ID_SET_MODE:  //11
		{
			// decode
			mavlink_set_mode_t packet;
			mavlink_msg_set_mode_decode(msg, &packet);

			switch(packet.mode){

				case MAV_MODE_MANUAL:
					set_mode(STABILIZE);
					break;

				case MAV_MODE_GUIDED:
					set_mode(GUIDED);
					break;

				case MAV_MODE_AUTO:
					if(mav_nav == 255 || mav_nav == MAV_NAV_WAYPOINT) 	set_mode(AUTO);
					if(mav_nav == MAV_NAV_RETURNING)					set_mode(RTL);
					if(mav_nav == MAV_NAV_LOITER)						set_mode(LOITER);
					mav_nav = 255;
					break;

				case MAV_MODE_TEST1:
					set_mode(STABILIZE);
					break;
			}
		}

	/*case MAVLINK_MSG_ID_SET_NAV_MODE:
		{
			// decode
			mavlink_set_nav_mode_t packet;
			mavlink_msg_set_nav_mode_decode(msg, &packet);
			// To set some flight modes we must first receive a "set nav mode" message and then a "set mode" message
			mav_nav = packet.nav_mode;
			break;
		}
	*/
	case MAVLINK_MSG_ID_WAYPOINT_REQUEST_LIST: //43
		{
			//send_text_P(SEVERITY_LOW,PSTR("waypoint request list"));

			// decode
			mavlink_waypoint_request_list_t packet;
			mavlink_msg_waypoint_request_list_decode(msg, &packet);
			if (mavlink_check_target(packet.target_system, packet.target_component))
				break;

			// Start sending waypoints
			mavlink_msg_waypoint_count_send(
				chan,msg->sysid,
				msg->compid,
				g.command_total); // includes home

			waypoint_timelast_send		= millis();
			waypoint_sending			= true;
			waypoint_receiving			= false;
			waypoint_dest_sysid			= msg->sysid;
			waypoint_dest_compid		= msg->compid;
			break;
		}

	// XXX read a WP from EEPROM and send it to the GCS
	case MAVLINK_MSG_ID_WAYPOINT_REQUEST: // 40
		{
			//send_text_P(SEVERITY_LOW,PSTR("waypoint request"));

			// Check if sending waypiont
			//if (!waypoint_sending) break;
			// 5/10/11 - We are trying out relaxing the requirement that we be in waypoint sending mode to respond to a waypoint request.  DEW

			// decode
			mavlink_waypoint_request_t packet;
			mavlink_msg_waypoint_request_decode(msg, &packet);

 			if (mavlink_check_target(packet.target_system, packet.target_component))
 				break;

			// send waypoint
			tell_command = get_cmd_with_index(packet.seq);

			// set frame of waypoint
			uint8_t frame;

			if (tell_command.options & MASK_OPTIONS_RELATIVE_ALT) {
				frame = MAV_FRAME_GLOBAL_RELATIVE_ALT; // reference frame
			} else {
				frame = MAV_FRAME_GLOBAL; // reference frame
			}

			float param1 = 0, param2 = 0 , param3 = 0, param4 = 0;

			// time that the mav should loiter in milliseconds
			uint8_t current = 0; // 1 (true), 0 (false)

			if (packet.seq == (uint16_t)g.command_index)
				current = 1;

			uint8_t autocontinue = 1; // 1 (true), 0 (false)

			float x = 0, y = 0, z = 0;

			if (tell_command.id < MAV_CMD_NAV_LAST) {
				// command needs scaling
				x = tell_command.lat/1.0e7; // local (x), global (latitude)
				y = tell_command.lng/1.0e7; // local (y), global (longitude)
				// ACM is processing alt inside each command. so we save and load raw values. - this is diffrent to APM
				z = tell_command.alt/1.0e2; // local (z), global/relative (altitude)
			}

			// Switch to map APM command fields inot MAVLink command fields
			switch (tell_command.id) {

				case MAV_CMD_NAV_LOITER_TURNS:
				case MAV_CMD_CONDITION_CHANGE_ALT:
				case MAV_CMD_DO_SET_HOME:
					param1 = tell_command.p1;
					break;

				case MAV_CMD_CONDITION_YAW:
					param3 = tell_command.p1;
					param1 = tell_command.alt;
					param2 = tell_command.lat;
					param4 = tell_command.lng;
					break;

				case MAV_CMD_NAV_TAKEOFF:
					param1 = 0;
					break;

				case MAV_CMD_NAV_LOITER_TIME:
					param1 = tell_command.p1;	// ACM loiter time is in 1 second increments
					break;

				case MAV_CMD_CONDITION_DELAY:
				case MAV_CMD_CONDITION_DISTANCE:
					param1 = tell_command.lat;
					break;

				case MAV_CMD_DO_JUMP:
					param2 = tell_command.lat;
					param1 = tell_command.p1;
					break;

				case MAV_CMD_DO_REPEAT_SERVO:
					param4 = tell_command.lng;
				case MAV_CMD_DO_REPEAT_RELAY:
				case MAV_CMD_DO_CHANGE_SPEED:
					param3 = tell_command.lat;
					param2 = tell_command.alt;
					param1 = tell_command.p1;
					break;

				case MAV_CMD_NAV_WAYPOINT:
					param1 = tell_command.p1;
					break;

				case MAV_CMD_DO_SET_PARAMETER:
				case MAV_CMD_DO_SET_RELAY:
				case MAV_CMD_DO_SET_SERVO:
					param2 = tell_command.alt;
					param1 = tell_command.p1;
					break;
			}

			mavlink_msg_waypoint_send(chan,msg->sysid,
										msg->compid,
										packet.seq,
										frame,
										tell_command.id,
										current,
										autocontinue,
										param1,
										param2,
										param3,
										param4,
										x,
										y,
										z);

			// update last waypoint comm stamp
			waypoint_timelast_send = millis();
			break;
		}

	case MAVLINK_MSG_ID_WAYPOINT_ACK: //47
		{
			//send_text_P(SEVERITY_LOW,PSTR("waypoint ack"));

			// decode
			mavlink_waypoint_ack_t packet;
			mavlink_msg_waypoint_ack_decode(msg, &packet);
			if (mavlink_check_target(packet.target_system,packet.target_component)) break;

			// turn off waypoint send
			waypoint_sending = false;
			break;
		}

	case MAVLINK_MSG_ID_PARAM_REQUEST_LIST: // 21
		{
			//send_text_P(SEVERITY_LOW,PSTR("param request list"));

			// decode
			mavlink_param_request_list_t packet;
			mavlink_msg_param_request_list_decode(msg, &packet);
			if (mavlink_check_target(packet.target_system,packet.target_component)) break;

			// Start sending parameters - next call to ::update will kick the first one out

			_queued_parameter = AP_Param::first(&_queued_parameter_token, &_queued_parameter_type);
			_queued_parameter_index = 0;
			_queued_parameter_count = _count_parameters();
			break;
		}

	case MAVLINK_MSG_ID_WAYPOINT_CLEAR_ALL: // 45
		{
			//send_text_P(SEVERITY_LOW,PSTR("waypoint clear all"));

			// decode
			mavlink_waypoint_clear_all_t packet;
			mavlink_msg_waypoint_clear_all_decode(msg, &packet);
			if (mavlink_check_target(packet.target_system, packet.target_component)) break;

			// clear all waypoints
			uint8_t type = 0; // ok (0), error(1)
			g.command_total.set_and_save(1);

			// send acknowledgement 3 times to makes sure it is received
			for (int i=0;i<3;i++)
				mavlink_msg_waypoint_ack_send(chan, msg->sysid, msg->compid, type);

			break;
		}

	case MAVLINK_MSG_ID_WAYPOINT_SET_CURRENT: // 41
		{
			//send_text_P(SEVERITY_LOW,PSTR("waypoint set current"));

			// decode
			mavlink_waypoint_set_current_t packet;
			mavlink_msg_waypoint_set_current_decode(msg, &packet);
			if (mavlink_check_target(packet.target_system,packet.target_component)) break;

			// set current command
			change_command(packet.seq);

			mavlink_msg_waypoint_current_send(chan, g.command_index);
			break;
		}

	case MAVLINK_MSG_ID_WAYPOINT_COUNT: // 44
		{
			//send_text_P(SEVERITY_LOW,PSTR("waypoint count"));

			// decode
			mavlink_waypoint_count_t packet;
			mavlink_msg_waypoint_count_decode(msg, &packet);
			if (mavlink_check_target(packet.target_system,packet.target_component)) break;

			// start waypoint receiving
			if (packet.count > MAX_WAYPOINTS) {
				packet.count = MAX_WAYPOINTS;
			}
			g.command_total.set_and_save(packet.count);

			waypoint_timelast_receive = millis();
			waypoint_receiving   = true;
			waypoint_sending	 = false;
			waypoint_request_i   = 0;
            waypoint_timelast_request = 0;
			break;
		}

#ifdef MAVLINK_MSG_ID_SET_MAG_OFFSETS
    case MAVLINK_MSG_ID_SET_MAG_OFFSETS:
    {
        mavlink_set_mag_offsets_t packet;
        mavlink_msg_set_mag_offsets_decode(msg, &packet);
        if (mavlink_check_target(packet.target_system,packet.target_component)) break;
        compass.set_offsets(Vector3f(packet.mag_ofs_x, packet.mag_ofs_y, packet.mag_ofs_z));
        break;
    }
#endif

	// XXX receive a WP from GCS and store in EEPROM
	case MAVLINK_MSG_ID_WAYPOINT: //39
		{
			// decode
			mavlink_waypoint_t packet;
			mavlink_msg_waypoint_decode(msg, &packet);
			if (mavlink_check_target(packet.target_system,packet.target_component)) break;

			// defaults
			tell_command.id = packet.command;

			/*
			switch (packet.frame){

				case MAV_FRAME_MISSION:
				case MAV_FRAME_GLOBAL:
					{
						tell_command.lat = 1.0e7*packet.x; // in as DD converted to * t7
						tell_command.lng = 1.0e7*packet.y; // in as DD converted to * t7
						tell_command.alt = packet.z*1.0e2; // in as m converted to cm
						tell_command.options = 0; // absolute altitude
						break;
					}

				case MAV_FRAME_LOCAL: // local (relative to home position)
					{
						tell_command.lat = 1.0e7*ToDeg(packet.x/
						(radius_of_earth*cos(ToRad(home.lat/1.0e7)))) + home.lat;
						tell_command.lng = 1.0e7*ToDeg(packet.y/radius_of_earth) + home.lng;
						tell_command.alt = packet.z*1.0e2;
						tell_command.options = MASK_OPTIONS_RELATIVE_ALT;
						break;
					}
				//case MAV_FRAME_GLOBAL_RELATIVE_ALT: // absolute lat/lng, relative altitude
				default:
					{
						tell_command.lat = 1.0e7 * packet.x; // in as DD converted to * t7
						tell_command.lng = 1.0e7 * packet.y; // in as DD converted to * t7
						tell_command.alt = packet.z * 1.0e2;
						tell_command.options = MASK_OPTIONS_RELATIVE_ALT; // store altitude relative!! Always!!
						break;
					}
			}
			*/

			// we only are supporting Abs position, relative Alt
			tell_command.lat = 1.0e7 * packet.x; // in as DD converted to * t7
			tell_command.lng = 1.0e7 * packet.y; // in as DD converted to * t7
			tell_command.alt = packet.z * 1.0e2;
			tell_command.options = 1; // store altitude relative!! Always!!

			switch (tell_command.id) {					// Switch to map APM command fields inot MAVLink command fields
				case MAV_CMD_NAV_LOITER_TURNS:
				case MAV_CMD_DO_SET_HOME:
				case MAV_CMD_DO_SET_ROI:
					tell_command.p1 = packet.param1;
					break;

				case MAV_CMD_CONDITION_YAW:
					tell_command.p1 = packet.param3;
					tell_command.alt = packet.param1;
					tell_command.lat = packet.param2;
					tell_command.lng = packet.param4;
					break;

				case MAV_CMD_NAV_TAKEOFF:
					tell_command.p1 = 0;
					break;

				case MAV_CMD_CONDITION_CHANGE_ALT:
					tell_command.p1 = packet.param1 * 100;
					break;

				case MAV_CMD_NAV_LOITER_TIME:
					tell_command.p1 = packet.param1;	// APM loiter time is in ten second increments
					break;

				case MAV_CMD_CONDITION_DELAY:
				case MAV_CMD_CONDITION_DISTANCE:
					tell_command.lat = packet.param1;
					break;

				case MAV_CMD_DO_JUMP:
					tell_command.lat = packet.param2;
					tell_command.p1  = packet.param1;
					break;

				case MAV_CMD_DO_REPEAT_SERVO:
					tell_command.lng = packet.param4;
				case MAV_CMD_DO_REPEAT_RELAY:
				case MAV_CMD_DO_CHANGE_SPEED:
					tell_command.lat = packet.param3;
					tell_command.alt = packet.param2;
					tell_command.p1 = packet.param1;
					break;

				case MAV_CMD_NAV_WAYPOINT:
					tell_command.p1 = packet.param1;
					break;

				case MAV_CMD_DO_SET_PARAMETER:
				case MAV_CMD_DO_SET_RELAY:
				case MAV_CMD_DO_SET_SERVO:
					tell_command.alt = packet.param2;
					tell_command.p1 = packet.param1;
					break;
			}

			if(packet.current == 2){ 				//current = 2 is a flag to tell us this is a "guided mode" waypoint and not for the mission
				guided_WP = tell_command;

				// add home alt if needed
				if (guided_WP.options & MASK_OPTIONS_RELATIVE_ALT){
					guided_WP.alt += home.alt;
				}

				set_mode(GUIDED);

				// make any new wp uploaded instant (in case we are already in Guided mode)
				set_next_WP(&guided_WP);

				// verify we recevied the command
				mavlink_msg_waypoint_ack_send(
						chan,
						msg->sysid,
						msg->compid,
						0);

			} else {
				// Check if receiving waypoints (mission upload expected)
				if (!waypoint_receiving) break;


				//Serial.printf("req: %d, seq: %d, total: %d\n", waypoint_request_i,packet.seq, g.command_total.get());

				// check if this is the requested waypoint
				if (packet.seq != waypoint_request_i)
					break;

				if(packet.seq != 0)
					set_cmd_with_index(tell_command, packet.seq);

				// update waypoint receiving state machine
				waypoint_timelast_receive = millis();
            	waypoint_timelast_request = 0;
				waypoint_request_i++;

				if (waypoint_request_i == (uint16_t)g.command_total){
					uint8_t type = 0; // ok (0), error(1)

					mavlink_msg_waypoint_ack_send(
						chan,
						msg->sysid,
						msg->compid,
						type);

					send_text(SEVERITY_LOW,PSTR("flight plan received"));
					waypoint_receiving = false;
					// XXX ignores waypoint radius for individual waypoints, can
					// only set WP_RADIUS parameter
				}
			}
			break;
		}

	case MAVLINK_MSG_ID_PARAM_SET: // 23
		{
            AP_Param                  *vp;
            enum ap_var_type        var_type;

			// decode
			mavlink_param_set_t packet;
			mavlink_msg_param_set_decode(msg, &packet);

			if (mavlink_check_target(packet.target_system, packet.target_component))
				break;

			// set parameter

			char key[ONBOARD_PARAM_NAME_LENGTH+1];
			strncpy(key, (char *)packet.param_id, ONBOARD_PARAM_NAME_LENGTH);
			key[ONBOARD_PARAM_NAME_LENGTH] = 0;

			// find the requested parameter
            vp = AP_Param::find(key, &var_type);
			if ((NULL != vp) &&							 		// exists
					!isnan(packet.param_value) &&			   // not nan
					!isinf(packet.param_value)) {			   // not inf

				// add a small amount before casting parameter values
				// from float to integer to avoid truncating to the
				// next lower integer value.
				float rounding_addition = 0.01;

				// handle variables with standard type IDs
                if (var_type == AP_PARAM_FLOAT) {
					((AP_Float *)vp)->set_and_save(packet.param_value);
                } else if (var_type == AP_PARAM_INT32) {
#if LOGGING_ENABLED == ENABLED
					Log_Write_Data(1, ((AP_Int32 *)vp)->get());
#endif
					if (packet.param_value < 0) rounding_addition = -rounding_addition;
                    float v = packet.param_value+rounding_addition;
                    v = constrain(v, -2147483648.0, 2147483647.0);
					((AP_Int32 *)vp)->set_and_save(v);
                } else if (var_type == AP_PARAM_INT16) {
#if LOGGING_ENABLED == ENABLED
					Log_Write_Data(3, (int32_t)((AP_Int16 *)vp)->get());
#endif
					if (packet.param_value < 0) rounding_addition = -rounding_addition;
                    float v = packet.param_value+rounding_addition;
                    v = constrain(v, -32768, 32767);
					((AP_Int16 *)vp)->set_and_save(v);
                } else if (var_type == AP_PARAM_INT8) {
#if LOGGING_ENABLED == ENABLED
					Log_Write_Data(4, (int32_t)((AP_Int8 *)vp)->get());
#endif
					if (packet.param_value < 0) rounding_addition = -rounding_addition;
                    float v = packet.param_value+rounding_addition;
                    v = constrain(v, -128, 127);
					((AP_Int8 *)vp)->set_and_save(v);
				} else {
					// we don't support mavlink set on this parameter
					break;
				}

				// Report back the new value if we accepted the change
				// we send the value we actually set, which could be
				// different from the value sent, in case someone sent
				// a fractional value to an integer type
				mavlink_msg_param_value_send(
					chan,
					(int8_t *)key,
                    vp->cast_to_float(var_type),
					_count_parameters(),
					-1); // XXX we don't actually know what its index is...

			}

			break;
		} // end case

    case MAVLINK_MSG_ID_RC_CHANNELS_OVERRIDE: //70
        {
            // allow override of RC channel values for HIL
            // or for complete GCS control of switch position
            // and RC PWM values.
			if(msg->sysid != g.sysid_my_gcs) break;		// Only accept control from our gcs
            mavlink_rc_channels_override_t packet;
            int16_t v[8];
            mavlink_msg_rc_channels_override_decode(msg, &packet);

			if (mavlink_check_target(packet.target_system,packet.target_component))
				break;

            v[0] = packet.chan1_raw;
            v[1] = packet.chan2_raw;
            v[2] = packet.chan3_raw;
            v[3] = packet.chan4_raw;
            v[4] = packet.chan5_raw;
            v[5] = packet.chan6_raw;
            v[6] = packet.chan7_raw;
            v[7] = packet.chan8_raw;
            APM_RC.setHIL(v);
            break;
        }

#if HIL_MODE != HIL_MODE_DISABLED
        // This is used both as a sensor and to pass the location
        // in HIL_ATTITUDE mode.
	case MAVLINK_MSG_ID_GPS_RAW: //32
        {
            // decode
            mavlink_gps_raw_t packet;
            mavlink_msg_gps_raw_decode(msg, &packet);

            // set gps hil sensor
            g_gps->setHIL(packet.usec/1000.0,packet.lat,packet.lon,packet.alt,
            packet.v,packet.hdg,0,0);
            if (gps_base_alt == 0) {
                gps_base_alt = packet.alt*100;
            }
            current_loc.lng = packet.lon * T7;
            current_loc.lat = packet.lat * T7;
            current_loc.alt = g_gps->altitude - gps_base_alt;
            if (!home_is_set) {
                init_home();
            }
            break;
        }
#if HIL_MODE == HIL_MODE_ATTITUDE
    case MAVLINK_MSG_ID_ATTITUDE: //30
        {
            // decode
            mavlink_attitude_t packet;
            mavlink_msg_attitude_decode(msg, &packet);

            // set AHRS hil sensor
            ahrs.setHil(packet.roll,packet.pitch,packet.yaw,packet.rollspeed,
            packet.pitchspeed,packet.yawspeed);

            // rad/sec
            /*
            Vector3f gyros;
            gyros.x = (float)packet.rollspeed;
            gyros.y = (float)packet.pitchspeed;
            gyros.z = (float)packet.yawspeed;

            imu.set_gyro(gyros);
			*/
            //imu.set_accel(accels);

            // rad/sec            // JLN update - FOR HIL SIMULATION WITH AEROSIM
            Vector3f gyros;
            gyros.x = (float)packet.rollspeed / 1000.0;
            gyros.y = (float)packet.pitchspeed / 1000.0;
            gyros.z = (float)packet.yawspeed / 1000.0;

            imu.set_gyro(gyros);

            // m/s/s
            Vector3f accels;
            accels.x = (float)packet.roll * gravity / 1000.0;
            accels.y = (float)packet.pitch * gravity / 1000.0;
            accels.z = (float)packet.yaw * gravity / 1000.0;

            imu.set_accel(accels);

            break;
        }
#endif
#endif
/*
	case MAVLINK_MSG_ID_HEARTBEAT:
		{
			// We keep track of the last time we received a heartbeat from our GCS for failsafe purposes
			if(msg->sysid != g.sysid_my_gcs) break;
			rc_override_fs_timer = millis();
			break;
		}

	#if HIL_MODE != HIL_MODE_DISABLED
		// This is used both as a sensor and to pass the location
		// in HIL_ATTITUDE mode.
	case MAVLINK_MSG_ID_GPS_RAW:
		{
			// decode
			mavlink_gps_raw_t packet;
			mavlink_msg_gps_raw_decode(msg, &packet);

			// set gps hil sensor
			g_gps->setHIL(packet.usec/1000.0,packet.lat,packet.lon,packet.alt,
			packet.v,packet.hdg,0,0);
			break;
		}
#endif
*/
#if HIL_MODE == HIL_MODE_SENSORS

    case MAVLINK_MSG_ID_RAW_IMU: // 28
        {
            // decode
            mavlink_raw_imu_t packet;
            mavlink_msg_raw_imu_decode(msg, &packet);

            // set imu hil sensors
            // TODO: check scaling for temp/absPress
            float temp = 70;
            float absPress = 1;
            //      Serial.printf_P(PSTR("accel:\t%d\t%d\t%d\n"), packet.xacc, packet.yacc, packet.zacc);
            //      Serial.printf_P(PSTR("gyro:\t%d\t%d\t%d\n"), packet.xgyro, packet.ygyro, packet.zgyro);

            // rad/sec
            Vector3f gyros;
            gyros.x = (float)packet.xgyro / 1000.0;
            gyros.y = (float)packet.ygyro / 1000.0;
            gyros.z = (float)packet.zgyro / 1000.0;
            // m/s/s
            Vector3f accels;
            accels.x = (float)packet.xacc / 1000.0;
            accels.y = (float)packet.yacc / 1000.0;
            accels.z = (float)packet.zacc / 1000.0;

            imu.set_gyro(gyros);

            imu.set_accel(accels);

            compass.setHIL(packet.xmag,packet.ymag,packet.zmag);
            break;
        }

    case MAVLINK_MSG_ID_RAW_PRESSURE: //29
        {
            // decode
            mavlink_raw_pressure_t packet;
            mavlink_msg_raw_pressure_decode(msg, &packet);

            // set pressure hil sensor
            // TODO: check scaling
            float temp = 70;
            barometer.setHIL(temp,packet.press_diff1);
            break;
        }
#endif // HIL_MODE

    case MAVLINK_MSG_ID_RADIO:
        {
            mavlink_radio_t packet;
            mavlink_msg_radio_decode(msg, &packet);
            // use the state of the transmit buffer in the radio to
            // control the stream rate, giving us adaptive software
            // flow control
            if (packet.txbuf < 20 && stream_slowdown < 100) {
                // we are very low on space - slow down a lot
                stream_slowdown += 3;
            } else if (packet.txbuf < 50 && stream_slowdown < 100) {
                // we are a bit low on space, slow down slightly
                stream_slowdown += 1;
            } else if (packet.txbuf > 95 && stream_slowdown > 10) {
                // the buffer has plenty of space, speed up a lot
                stream_slowdown -= 2;
            } else if (packet.txbuf > 90 && stream_slowdown != 0) {
                // the buffer has enough space, speed up a bit
                stream_slowdown--;
            }
            break;
        }

	} // end switch
} // end handle mavlink

uint16_t
GCS_MAVLINK::_count_parameters()
{
	// if we haven't cached the parameter count yet...
	if (0 == _parameter_count) {
        AP_Param  *vp;
        AP_Param::ParamToken token;

        vp = AP_Param::first(&token, NULL);
		do {
				_parameter_count++;
        } while (NULL != (vp = AP_Param::next_scalar(&token, NULL)));
	}
	return _parameter_count;
}

/**
* @brief Send the next pending parameter, called from deferred message
* handling code
*/
void
GCS_MAVLINK::queued_param_send()
{
    // Check to see if we are sending parameters
    if (NULL == _queued_parameter) return;

    AP_Param      *vp;
    float       value;

    // copy the current parameter and prepare to move to the next
    vp = _queued_parameter;

    // if the parameter can be cast to float, report it here and break out of the loop
    value = vp->cast_to_float(_queued_parameter_type);

    char param_name[ONBOARD_PARAM_NAME_LENGTH];
    vp->copy_name(param_name, sizeof(param_name), true);

    mavlink_msg_param_value_send(
        chan,
        (int8_t*)param_name,
        value,
        _queued_parameter_count,
        _queued_parameter_index);

    _queued_parameter = AP_Param::next_scalar(&_queued_parameter_token, &_queued_parameter_type);
    _queued_parameter_index++;
}

/**
* @brief Send the next pending waypoint, called from deferred message
* handling code
*/
void
GCS_MAVLINK::queued_waypoint_send()
{
    if (waypoint_receiving &&
        waypoint_request_i < (unsigned)g.command_total) {
        mavlink_msg_waypoint_request_send(
            chan,
            waypoint_dest_sysid,
            waypoint_dest_compid,
            waypoint_request_i);
    }
}

/*
 a delay() callback that processes MAVLink packets. We set this as the
 callback in long running library initialisation routines to allow
 MAVLink to process packets while waiting for the initialisation to
 complete
*/
static void mavlink_delay(unsigned long t)
{
    uint32_t tstart;
    static uint32_t last_1hz, last_50hz;

	if (in_mavlink_delay) {
        // this should never happen, but let's not tempt fate by
        // letting the stack grow too much
		delay(t);
		return;
	}

	in_mavlink_delay = true;

    tstart = millis();
    do {
        uint32_t tnow = millis();
        if (tnow - last_1hz > 1000) {
            last_1hz = tnow;
            gcs_send_message(MSG_HEARTBEAT);
            gcs_send_message(MSG_EXTENDED_STATUS1);
        }
        if (tnow - last_50hz > 20) {
            last_50hz = tnow;
            gcs_update();
        }
        delay(1);
		#if USB_MUX_PIN > 0
        check_usb_mux();
		#endif
    } while (millis() - tstart < t);

	in_mavlink_delay = false;
}

/*
  send a message on both GCS links
 */
static void gcs_send_message(enum ap_message id)
{
    gcs0.send_message(id);
    if (gcs3.initialised) {
    gcs3.send_message(id);
}
}

/*
  send data streams in the given rate range on both links
 */
static void gcs_data_stream_send(void)
{
    gcs0.data_stream_send();
    if (gcs3.initialised) {
        gcs3.data_stream_send();
    }
}

/*
  look for incoming commands on the GCS links
 */
static void gcs_update(void)
{
	gcs0.update();
    if (gcs3.initialised) {
    gcs3.update();
}
}

static void gcs_send_text(gcs_severity severity, const char *str)
{
    gcs0.send_text(severity, str);
    if (gcs3.initialised) {
    gcs3.send_text(severity, str);
}
}

static void gcs_send_text_P(gcs_severity severity, const prog_char_t *str)
{
    gcs0.send_text(severity, str);
    if (gcs3.initialised) {
    gcs3.send_text(severity, str);
}
}

/*
  send a low priority formatted message to the GCS
  only one fits in the queue, so if you send more than one before the
  last one gets into the serial buffer then the old one will be lost
 */
static void gcs_send_text_fmt(const prog_char_t *fmt, ...)
{
    char fmtstr[40];
    va_list ap;
    uint8_t i;
    for (i=0; i<sizeof(fmtstr)-1; i++) {
        fmtstr[i] = pgm_read_byte((const prog_char *)(fmt++));
        if (fmtstr[i] == 0) break;
    }
    fmtstr[i] = 0;
    pending_status.severity = (uint8_t)SEVERITY_LOW;
    va_start(ap, fmt);
    vsnprintf((char *)pending_status.text, sizeof(pending_status.text), fmtstr, ap);
    va_end(ap);
    mavlink_send_message(MAVLINK_COMM_0, MSG_STATUSTEXT, 0);
    if (gcs3.initialised) {
        mavlink_send_message(MAVLINK_COMM_1, MSG_STATUSTEXT, 0);
    }
}
