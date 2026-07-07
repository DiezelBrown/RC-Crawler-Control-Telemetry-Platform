#include <Arduino.h>
#include "battery.h"

const int BATTERY_PIN = 34;
const float ADC_MAX = 4095.0;
const float ESP32_MAX_VOLTAGE = 3.3;
const float VOLTAGE_DIVIDER_RATIO = 5.0;

void initializeBatterySensor()
{
    pinMode(BATTERY_PIN, INPUT);
}

float readBatteryVoltage()
{
    int rawValue = analogRead(BATTERY_PIN);

    float sensorVoltage = (rawValue / ADC_MAX) * ESP32_MAX_VOLTAGE;
    float batteryVoltage = sensorVoltage * VOLTAGE_DIVIDER_RATIO;

    return batteryVoltage;
}