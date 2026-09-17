#include <Arduino.h>
#include "telemetry.h"
#include "battery.h"
#include "temperature.h"
#include "hall.h"
#include "imu.h"
#include "bluetooth.h"

void setup() {
    Serial.begin(115200);

    initializeBatterySensor();
    initializeTemperatureSensor();
    initializeHallSensor();
    initializeIMU();
    initializeBluetooth();

    Serial.println("Telemetry System Started");
}

void loop() {
    TelemetryData telemetry = getTelemetryData();
    printTelemetryData(telemetry);
    sendTelemetryBluetooth(telemetry);

    delay(1000);
}