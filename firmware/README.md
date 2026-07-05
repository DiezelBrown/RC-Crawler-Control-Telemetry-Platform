## Firmware

The ESP32 firmware is being developed in C++ using PlatformIO.

### Project Structure

```text
firmware/
├── include/
│   └── telemetry.h        # Telemetry data structures and function declarations
├── src/
│   ├── main.cpp           # Main ESP32 application
│   └── telemetry.cpp      # Simulated telemetry generation and serial output
├── lib/                   # Future custom libraries
└── platformio.ini         # PlatformIO project configuration
```

### Current Capabilities
- Modular project structure
- TelemetryData structure for sensor information
- Simulated telemetry generation
- Serial output for testing

### Planned Capabilities
- Battery voltage monitoring
- Motor temperature monitoring
- Hall-effect RPM measurement
- BNO055 IMU (pitch/roll)
- Bluetooth telemetry transmission
- Mobile telemetry dashboard
