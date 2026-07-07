#include <Arduino.h>
#include "telemetry.h"
#include "battery.h"

void setup() {
  Serial.begin(115200);
  initializeBatterySensor();
  
  Serial.println("Telemetry System Started");
}

void loop() {
  TelemetryData telemetry = getSimulatedTelemetryData();
  printTelemetryData(telemetry);

  delay(1000);
}