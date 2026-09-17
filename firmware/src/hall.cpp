#include <Arduino.h>
#include "hall.h"

const int HALL_PIN = 26;   // pin 26 d26
volatile unsigned long pulseCount = 0;
unsigned long lastTime = 0;
int currentRPM = 0;

void IRAM_ATTR hallInterrupt()
{
    pulseCount++;
}

void initializeHallSensor()
{
    pinMode(HALL_PIN, INPUT_PULLUP);

    attachInterrupt(digitalPinToInterrupt(HALL_PIN), hallInterrupt, FALLING);

    lastTime = millis();
}

int readMotorRPM()
{
    unsigned long currentTime = millis();

    if (currentTime - lastTime >= 1000)
    {
        noInterrupts();
        unsigned long pulses = pulseCount;
        pulseCount = 0;
        interrupts();

        // One magnet = one pulse per revolution
        currentRPM = pulses * 60;

        lastTime = currentTime;
    }

    return currentRPM;
}

float readVehicleSpeed()
{
    const float tireDiameterInches = 4.61;
    const float tireCircumferenceInches = tireDiameterInches * 3.14159;

    float inchesPerMinute = currentRPM * tireCircumferenceInches;
    float mph = (inchesPerMinute * 60.0) / 63360.0;

    return mph;
}