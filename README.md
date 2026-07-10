RC Crawler Telemetry Platform

A custom-built 1/10 scale RC crawler designed to demonstrate embedded systems, wireless telemetry, and real-time vehicle monitoring. The platform combines custom mechanical fabrication with ESP32 firmware, multiple onboard sensors, and Bluetooth Low Energy (BLE) communication to provide live telemetry for off-road robotic vehicles.

Features
✅ Custom-fabricated steel chassis
✅ ESP32 embedded telemetry platform
✅ Battery voltage monitoring
✅ Motor temperature monitoring
✅ Wheel RPM measurement
✅ Vehicle speed calculation
✅ BNO055 IMU (Pitch & Roll)
✅ Bluetooth Low Energy (BLE) telemetry
🔄 Mobile application (In Progress)
🔄 Custom PCB (Planned)
🔄 Operator-assisted recovery mode (Planned)
Technologies
C++
ESP32
PlatformIO
Bluetooth Low Energy (BLE)
Embedded Systems
Sensor Integration
I²C
OneWire
Hall Effect Sensors
MIG Welding
Current Telemetry
Sensor	Status
Battery Voltage	✅
Motor Temperature	✅
Wheel RPM	✅
Vehicle Speed	✅
Pitch	✅
Roll	✅
Bluetooth Communication	✅
Repository Structure
firmware/      ESP32 firmware
hardware/      Parts list, wiring diagrams, pinout
docs/          Development updates and testing
photos/        Build photos and demonstrations
Project Status
Completed
✅ Custom steel chassis
✅ ESP32 firmware architecture
✅ Battery voltage sensor
✅ DS18B20 temperature sensor
✅ Hall-effect RPM sensor
✅ BNO055 IMU integration
✅ Bluetooth Low Energy communication
In Progress
🔄 Mobile telemetry application
Planned
⏳ Custom KiCad PCB
⏳ Data logging
⏳ Operator-assisted recovery mode
Future Goals
Develop a cross-platform mobile telemetry application.
Design a custom PCB to replace the breadboard prototype.
Implement Bluetooth-based operator controls.
Develop an operator-assisted recovery mode that can attempt to free the crawler when it becomes stuck.
