#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>

#include "imu.h"

constexpr int IMU_SDA_PIN = 25;
constexpr int IMU_SCL_PIN = 33;
constexpr uint8_t BNO055_ADDRESS = 0x28;

Adafruit_BNO055 bno(55, BNO055_ADDRESS, &Wire);

bool imuConnected = false;

void initializeIMU()
{
    imuConnected = false;

    // Allow the BNO055 time to power up.
    delay(1000);

    // Start I2C on your custom ESP32 pins.
    Wire.begin(IMU_SDA_PIN, IMU_SCL_PIN);
    Wire.setClock(100000);

    Serial.println("Initializing BNO055 at address 0x28...");

    // Retry initialization several times.
    for (int attempt = 1; attempt <= 5; attempt++)
    {
        if (bno.begin())
        {
            imuConnected = true;
            break;
        }

        Serial.printf("BNO055 attempt %d failed.\n", attempt);
        delay(500);
    }

    if (!imuConnected)
    {
        Serial.println("BNO055 initialization failed.");
        return;
    }

    delay(1000);

    // Use the external crystal on the breakout board.
    bno.setExtCrystalUse(true);

    Serial.println("BNO055 initialized successfully.");
}

float readVehiclePitch()
{
    if (!imuConnected)
    {
        return 0.0f;
    }

    const imu::Vector<3> orientation =
        bno.getVector(Adafruit_BNO055::VECTOR_EULER);

    // BNO055 Euler Z value.
    return orientation.z();
}

float readVehicleRoll()
{
    if (!imuConnected)
    {
        return 0.0f;
    }

    const imu::Vector<3> orientation =
        bno.getVector(Adafruit_BNO055::VECTOR_EULER);

    // BNO055 Euler Y value.
    return orientation.y();
}