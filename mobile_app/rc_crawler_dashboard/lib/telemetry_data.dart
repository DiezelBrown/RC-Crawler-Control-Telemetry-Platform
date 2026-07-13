class TelemetryData {
  final double batteryVoltage;
  final double motorTempF;
  final double rpm;
  final double speedMph;
  final double pitch;
  final double roll;

  const TelemetryData({
    required this.batteryVoltage,
    required this.motorTempF,
    required this.rpm,
    required this.speedMph,
    required this.pitch,
    required this.roll,
  });

  const TelemetryData.empty()
    : batteryVoltage = 0,
      motorTempF = 0,
      rpm = 0,
      speedMph = 0,
      pitch = 0,
      roll = 0;

  factory TelemetryData.fromCsv(String message) {
    final parts = message.trim().split(',');

    if (parts.length != 6) {
      throw FormatException(
        'Expected 6 telemetry values, received ${parts.length}: $message',
      );
    }

    return TelemetryData(
      batteryVoltage: double.parse(parts[0]),
      motorTempF: double.parse(parts[1]),
      rpm: double.parse(parts[2]),
      speedMph: double.parse(parts[3]),
      pitch: double.parse(parts[4]),
      roll: double.parse(parts[5]),
    );
  }
}
