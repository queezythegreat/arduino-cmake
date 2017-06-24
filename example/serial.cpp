#include "Arduino.h"
#include "SoftwareSerial.h"

void setup()
{
    SoftwareSerial serial(9, 10);
    serial.begin(9600);
}

void loop()
{

}