/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.
  Example uses a static library to show off generate_arduino_library().
 
  This example code is in the public domain.
 */
#if ARDUINO >= 100
    #include "Arduino.h"
#else
    #include "WProgram.h"
#endif

#include "blink_lib.h"

void setup() {                
    blink_setup(); // Setup for blinking
}

void loop() {
    blink(1000); // Blink for a second
}
