#include <Arduino.h>
#include "telemetry.h"
#include "battery.h"
#include "temperature.h"
#include "hall.h"
#include "imu.h"

TelemetryData getTelemetryData(){
    TelemetryData data;
    data.batteryVoltage = readBatteryVoltage();
    data.motorTempF = readMotorTemperature();
    data.rpm = readMotorRPM();
    data.speedMph = readVehicleSpeed();
    data.pitch = readVehiclePitch();
    data.roll = readVehicleRoll();

    return data;
}

void printTelemetryData(const TelemetryData& data) {
   Serial.print("Battery: ");
    Serial.print(data.batteryVoltage);
    Serial.println(" V");

    Serial.print("Motor Temp: ");
    Serial.print(data.motorTempF);
    Serial.println(" F");

    Serial.print("RPM: ");
    Serial.println(data.rpm);

    Serial.print("Speed: ");
    Serial.print(data.speedMph);
    Serial.println(" mph");

    Serial.print("Pitch: ");
    Serial.print(data.pitch);
    Serial.println(" deg");

    Serial.print("Roll: ");
    Serial.print(data.roll);
    Serial.println(" deg");

    Serial.println("----------------------");
}