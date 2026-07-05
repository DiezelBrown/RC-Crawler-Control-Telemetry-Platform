#include <Arduino.h>

void setup() {
  Serial.begin(115200);
  Serial.println("Telemetry System Started");

}

void loop() {
  Serial.println("ESP32 Running...");
  delay(1000);
}