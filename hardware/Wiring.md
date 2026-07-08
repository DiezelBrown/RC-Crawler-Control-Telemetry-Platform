# Wiring Guide

This document describes the electrical connections used by the ESP32 telemetry system.

---

# Prototype

The current telemetry system is built on a breadboard for rapid prototyping. The breadboard distributes the ESP32's **3.3V** and **GND** to all sensors. In the final design, the breadboard will be replaced by a custom PCB while maintaining the same electrical connections.

---

# Battery Voltage Sensor

The battery voltage sensor measures the LiPo battery by tapping into the positive and negative leads between the battery and the ESC.

| Sensor Pin | Connected To |
|------------|--------------|
| VIN+ | Battery Positive |
| VIN- | Battery Negative |
| VCC | ESP32 3.3V |
| GND | ESP32 GND |
| OUT | ESP32 GPIO34 |

---

# DS18B20 Temperature Sensor

The waterproof DS18B20 temperature sensor is mounted directly to the brushless motor to monitor motor temperature.

| Sensor Pin | Connected To |
|------------|--------------|
| VCC | ESP32 3.3V |
| GND | ESP32 GND |
| DATA | ESP32 GPIO27 |

---

# Hall Effect Sensor

The Hall-effect sensor is mounted near one of the crawler's wheels. A magnet attached to the wheel passes in front of the sensor once per revolution, allowing the ESP32 to calculate wheel RPM and vehicle speed.

| Sensor Pin | Connected To |
|------------|--------------|
| VCC | ESP32 3.3V |
| GND | ESP32 GND |
| Signal | ESP32 GPIO26 |

---

# Planned BNO055 IMU

The BNO055 IMU will be mounted near the center of the chassis to measure vehicle orientation.

| IMU Pin | Connected To |
|----------|--------------|
| VIN | ESP32 3.3V |
| GND | ESP32 GND |
| SDA | ESP32 GPIO21 |
| SCL | ESP32 GPIO22 |

---

# Power Distribution

All telemetry sensors share a common **3.3V** and **GND** connection supplied by the ESP32.

---

# Future Design

The breadboard prototype will be replaced by a custom PCB that will provide:

- ESP32 mounting headers
- Power distribution
- Dedicated sensor connectors
- Integrated battery voltage divider
- Expansion headers for future hardware
