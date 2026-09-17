#include <Arduino.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include "temperature.h"

const int TEMP_PIN = 27;  //pin used D27
OneWire oneWire(TEMP_PIN);
DallasTemperature sensors(&oneWire);

void initializeTemperatureSensor()
{
    sensors.begin();
}

float readMotorTemperature()
{
    sensors.requestTemperatures();

    float tempC = sensors.getTempCByIndex(0);

    if (tempC == DEVICE_DISCONNECTED_C)
    {
        return -999.0;
    }

    return tempC * 9.0 / 5.0 + 32.0;
}