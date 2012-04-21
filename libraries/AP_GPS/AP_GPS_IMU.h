
// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: t -*-
#ifndef AP_GPS_IMU_h
#define AP_GPS_IMU_h

#include "GPS.h"
#define MAXPAYLOAD 32

class AP_GPS_IMU : public GPS {
public:

    // Methods
    AP_GPS_IMU(Stream *s);
    virtual void init(void);
    virtual bool read(void);

    // Properties
    long    roll_sensor;            // how much we're turning in deg * 100
    long    pitch_sensor;           // our angle of attack in deg * 100
    int     airspeed;
    float   imu_health;
    uint8_t imu_ok;

    // Unused
    virtual void setHIL(long time, float latitude, float longitude, float altitude,
                        float ground_speed, float ground_course, float speed_3d, uint8_t num_sats);

private:
    // Packet checksums
    uint8_t ck_a;
    uint8_t ck_b;
    uint8_t GPS_ck_a;
    uint8_t GPS_ck_b;

    uint8_t step;
    uint8_t msg_class;
    uint8_t message_num;
    uint8_t payload_length;
    uint8_t payload_counter;
    uint8_t buffer[MAXPAYLOAD];

    void join_data();
    void join_data_xplane();
    void GPS_join_data();
    void checksum(unsigned char data);
};

#endif
