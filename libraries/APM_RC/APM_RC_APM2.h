#ifndef __APM_RC_APM2_H__
#define __APM_RC_APM2_H__

#define NUM_CHANNELS 8
#define MIN_PULSEWIDTH 900
#define MAX_PULSEWIDTH 2100

#include "APM_RC.h"
#include "../Arduino_Mega_ISR_Registry/Arduino_Mega_ISR_Registry.h"

class APM_RC_APM2 : public APM_RC_Class
{
  private:
  public:
	APM_RC_APM2();
	void Init( Arduino_Mega_ISR_Registry * isr_reg );
	void OutputCh(unsigned char ch, uint16_t pwm);
	uint16_t InputCh(unsigned char ch);
	unsigned char GetState();
	bool setHIL(int16_t v[NUM_CHANNELS]);
	void clearOverride(void);
	void Force_Out(void);
	void SetFastOutputChannels(uint32_t chmask, uint16_t speed_hz = 400);

  void enable_out(uint8_t);
  void disable_out(uint8_t);

	void Force_Out0_Out1(void);
	void Force_Out2_Out3(void);
	void Force_Out6_Out7(void);

  private:

    static void _timer5_capt_cb(void);
    static volatile uint16_t _PWM_RAW[NUM_CHANNELS];
    static volatile uint8_t _radio_status;
    int16_t _HIL_override[NUM_CHANNELS];
};


#endif
