//Header file for telemetry data structure and functions
#ifndef TELEMETRY_H
#define TELEMETRY_H

struct TelemetryData 
{
    float batteryVoltage;
    float motorTempF;
    int rpm;
    float speedMph;
    float pitch;
    float roll;
};

TelemetryData getSimulatedTelemetryData();
void printTelemetryData(const TelemetryData& data);

#endif // TELEMETRY_H