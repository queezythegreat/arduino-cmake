#include "Arduino.h"

#define LED_PIN 23

void setup() {
    pinMode(LED_PIN, OUTPUT);
    digitalWrite(LED_PIN, LOW);

    Serial.begin(9600);
	Serial.println("Example arduino start");
}

void loop() {
    Serial.println("loop");

    for (int i = 0; i < 2; i++) {
        digitalWrite(LED_PIN, HIGH);
        delay(1000);
        digitalWrite(LED_PIN, LOW);
        delay(1000);
    }

    delay(1000);
}
