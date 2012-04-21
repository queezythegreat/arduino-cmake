// 2010 Jose Julio
// 2011 Adapted for AC2 by Jason Short
//
// Automatic Acrobatic Procedure (AAP) v1 : Roll flip
// State machine aproach:
//    Some states are fixed commands (for a fixed time)
//    Some states are fixed commands (until some IMU condition)
//    Some states include controls inside
#if CH7_OPTION == CH7_FLIP
void roll_flip()
{
	#define AAP_THR_INC 180
	#define AAP_THR_DEC 90
	#define AAP_ROLL_OUT 200
	#define AAP_ROLL_RATE 3000	// up to 1250

	static int 	AAP_timer = 0;
	static byte AAP_state = 0;

	// Yaw
	g.rc_4.servo_out = get_stabilize_yaw(nav_yaw);
	// Pitch
	g.rc_2.servo_out = get_stabilize_pitch(0);

	// State machine
	switch (AAP_state){
		case 0: // Step 1 : Initialize
			AAP_timer = 0;
			AAP_state++;
			break;
		case 1: // Step 2 : Increase throttle to start maneuver
			if (AAP_timer < 95){ 	// .5 seconds
				g.rc_1.servo_out = get_stabilize_roll(0);
				g.rc_3.servo_out = g.rc_3.control_in + AAP_THR_INC;
				//g.rc_4.servo_out = get_stabilize_yaw(nav_yaw);
				AAP_timer++;
			}else{
				AAP_state++;
				AAP_timer = 0;
			}
			break;

		case 2: // Step 3 : ROLL (until we reach a certain angle [45º])
			if (dcm.roll_sensor < 4500){
				// Roll control
				g.rc_1.servo_out = AAP_ROLL_OUT;	//get_rate_roll(AAP_ROLL_RATE);
				g.rc_3.servo_out = g.rc_3.control_in - AAP_THR_DEC;
			}else{
				AAP_state++;
			}
			break;

		case 3: // Step 4 : CONTINUE ROLL (until we reach a certain angle [-45º])
			if ((dcm.roll_sensor >= 4500) || (dcm.roll_sensor < -4500)){
				g.rc_1.servo_out = 150; //get_rate_roll(AAP_ROLL_RATE);
				g.rc_3.servo_out = g.rc_3.control_in - AAP_THR_DEC;
			}else{
				AAP_state++;
			}
			break;

		case 4: // Step 5 : Increase throttle to stop the descend
			if (AAP_timer < 90){ // .5 seconds
				g.rc_1.servo_out = get_stabilize_roll(0);
				g.rc_3.servo_out = g.rc_3.control_in + AAP_THR_INC;
				AAP_timer++;
			}else{
				AAP_state++;
				AAP_timer = 0;
			}
			break;

		case 5: // exit mode
			//control_mode =
			do_flip = false;
			break;
	}
}
#endif
