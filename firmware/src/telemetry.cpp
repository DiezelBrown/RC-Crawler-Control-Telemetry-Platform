#include <Arduino.h>
#include "telemetry.h"
#include "battery.h"

TelemetryData getSimulatedTelemetryData(){
    TelemetryData data;
    data.batteryVoltage = readBatteryVoltage();
    data.motorTempF = 95.0;
    data.rpm = 850;
    data.speedMph = 4.2;
    data.pitch = 12.5;
    data.roll = 3.4;
    
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