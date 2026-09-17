#ifndef BLUETOOTH_H
#define BLUETOOTH_H

#include "telemetry.h"

void initializeBluetooth();
void sendTelemetryBluetooth(const TelemetryData& data);

#endif