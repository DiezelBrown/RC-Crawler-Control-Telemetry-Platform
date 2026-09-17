#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#include "bluetooth.h"

const char* DEVICE_NAME = "RC-Crawler-Telemetry";

const char* SERVICE_UUID =
    "12345678-1234-1234-1234-123456789000";

const char* TELEMETRY_UUID =
    "12345678-1234-1234-1234-123456789001";

BLECharacteristic* telemetryCharacteristic = nullptr;

bool phoneConnected = false;

class CrawlerServerCallbacks : public BLEServerCallbacks
{
    void onConnect(BLEServer* server) override
    {
        phoneConnected = true;
        Serial.println("Bluetooth device connected");
    }

    void onDisconnect(BLEServer* server) override
    {
        phoneConnected = false;
        Serial.println("Bluetooth device disconnected");

        // Allow another phone to find and connect to the ESP32.
        BLEDevice::startAdvertising();
    }
};

void initializeBluetooth()
{
    BLEDevice::init(DEVICE_NAME);

    BLEServer* server = BLEDevice::createServer();
    server->setCallbacks(new CrawlerServerCallbacks());

    BLEService* telemetryService =
        server->createService(SERVICE_UUID);

    telemetryCharacteristic =
        telemetryService->createCharacteristic(
            TELEMETRY_UUID,
            BLECharacteristic::PROPERTY_READ |
            BLECharacteristic::PROPERTY_NOTIFY
        );

    telemetryCharacteristic->addDescriptor(new BLE2902());

    telemetryService->start();

    BLEAdvertising* advertising =
        BLEDevice::getAdvertising();

    advertising->addServiceUUID(SERVICE_UUID);
    advertising->setScanResponse(true);

    BLEDevice::startAdvertising();

    Serial.println("Bluetooth ready");
    Serial.println("Waiting for phone connection...");
}

void sendTelemetryBluetooth(const TelemetryData& data)
{
    if (!phoneConnected)
    {
        return;
    }

    char message[120];

    snprintf(
        message,
        sizeof(message),
        "%.2f,%.2f,%d,%.2f,%.2f,%.2f",
        data.batteryVoltage,
        data.motorTempF,
        data.rpm,
        data.speedMph,
        data.pitch,
        data.roll
    );

    telemetryCharacteristic->setValue(message);
    telemetryCharacteristic->notify();
}