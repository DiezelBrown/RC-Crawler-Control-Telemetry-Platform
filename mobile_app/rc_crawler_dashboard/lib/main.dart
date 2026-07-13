import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ble_service.dart';
import 'telemetry_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const RcCrawlerApp());
}

class RcCrawlerApp extends StatelessWidget {
  const RcCrawlerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RC Crawler Telemetry',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050708),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final BleService _bleService;

  @override
  void initState() {
    super.initState();

    _bleService = BleService();
    _bleService.addListener(_refreshDashboard);
    _bleService.connect();
  }

  void _refreshDashboard() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _bleService.removeListener(_refreshDashboard);
    _bleService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TelemetryData telemetry = _bleService.telemetry;

    final double rpm = telemetry.rpm;
    final double speedMph = telemetry.speedMph;
    final double batteryVoltage = telemetry.batteryVoltage;
    final double motorTempF = telemetry.motorTempF;
    final double pitch = telemetry.pitch;
    final double roll = telemetry.roll;

    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 390;

            return Container(
              padding: EdgeInsets.all(compact ? 8 : 12),
              decoration: BoxDecoration(
                color: const Color(0xFF080B0D),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF30363B), width: 2),
              ),
              child: Column(
                children: [
                  StatusStrip(
                    batteryVoltage: batteryVoltage,
                    motorTempF: motorTempF,
                    bleConnected: _bleService.isConnected,
                  ),
                  SizedBox(height: compact ? 6 : 10),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 10,
                          child: AnalogGauge(
                            title: 'RPM',
                            value: rpm,
                            maximum: 8000,
                            majorDivisions: 8,
                            unit: 'REV/MIN',
                            bottomLabel: 'MOTOR TEMP',
                            bottomValue: '${motorTempF.toStringAsFixed(1)} °F',
                            bottomIcon: Icons.thermostat,
                            bottomValueColor: motorTempF >= 160
                                ? const Color(0xFFFF3030)
                                : motorTempF >= 120
                                ? const Color(0xFFFFA726)
                                : Colors.white,
                          ),
                        ),
                        SizedBox(width: compact ? 5 : 8),
                        Expanded(
                          flex: 4,
                          child: CenterInformationPanel(
                            pitch: pitch,
                            roll: roll,
                            bleConnected: _bleService.isConnected,
                          ),
                        ),
                        SizedBox(width: compact ? 5 : 8),
                        Expanded(
                          flex: 10,
                          child: AnalogGauge(
                            title: 'SPEED',
                            value: speedMph,
                            maximum: 30,
                            majorDivisions: 6,
                            unit: 'MPH',
                            bottomLabel: 'BATTERY',
                            bottomValue:
                                '${batteryVoltage.toStringAsFixed(2)} V',
                            bottomIcon: Icons.battery_charging_full,
                            bottomValueColor: batteryVoltage < 6.7
                                ? const Color(0xFFFF3030)
                                : batteryVoltage < 7.0
                                ? const Color(0xFFFFA726)
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: compact ? 6 : 9),
                  SizedBox(
                    height: compact ? 38 : 45,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.build_circle_outlined, size: 20),
                      label: const Text(
                        'RECOVERY MODE',
                        style: TextStyle(
                          letterSpacing: 2.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: const Color(0xFF220D0F),
                        disabledForegroundColor: const Color(0xFFFF3D45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                            color: Color(0xFF672126),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class StatusStrip extends StatelessWidget {
  final double batteryVoltage;
  final double motorTempF;
  final bool bleConnected;

  const StatusStrip({
    super.key,
    required this.batteryVoltage,
    required this.motorTempF,
    required this.bleConnected,
  });

  @override
  Widget build(BuildContext context) {
    final lowBattery = batteryVoltage < 7.0;
    final highTemperature = motorTempF > 140;

    return Row(
      children: [
        const Expanded(
          child: Text(
            'RC CRAWLER',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              letterSpacing: 2.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        StatusLight(
          label: 'BLE',
          active: bleConnected,
          activeColor: const Color(0xFF00E676),
        ),
        const SizedBox(width: 12),
        const StatusLight(
          label: 'IMU',
          active: true,
          activeColor: Color(0xFF29B6F6),
        ),
        const SizedBox(width: 12),
        StatusLight(
          label: 'TEMP',
          active: highTemperature,
          activeColor: const Color(0xFFFF3D00),
        ),
        const SizedBox(width: 12),
        StatusLight(
          label: 'BATTERY',
          active: lowBattery,
          activeColor: const Color(0xFFFFD600),
        ),
        const SizedBox(width: 12),
        const StatusLight(
          label: 'RECOVERY',
          active: false,
          activeColor: Color(0xFFFF1744),
        ),
      ],
    );
  }
}

class StatusLight extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;

  const StatusLight({
    super.key,
    required this.label,
    required this.active,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : Colors.white24;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.7),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white70 : Colors.white30,
            fontSize: 9,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class AnalogGauge extends StatelessWidget {
  final String title;
  final double value;
  final double maximum;
  final int majorDivisions;
  final String unit;
  final String bottomLabel;
  final String bottomValue;
  final IconData bottomIcon;
  final Color bottomValueColor;

  const AnalogGauge({
    super.key,
    required this.title,
    required this.value,
    required this.maximum,
    required this.majorDivisions,
    required this.unit,
    required this.bottomLabel,
    required this.bottomValue,
    required this.bottomIcon,
    this.bottomValueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InstrumentPanel(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, child) {
          final displayedValue = maximum >= 1000
              ? animatedValue.toStringAsFixed(0)
              : animatedValue.toStringAsFixed(2);

          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: DialPainter(
                      value: animatedValue,
                      maximum: maximum,
                      majorDivisions: majorDivisions,
                    ),
                  ),

                  Positioned(
                    top: 11,
                    left: 0,
                    right: 0,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 3.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Positioned(
                    top: constraints.maxHeight * 0.40,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            displayedValue,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 0),
                        Text(
                          unit,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 8,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      decoration: const BoxDecoration(
                        color: Color(0xE6000000),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border(top: BorderSide(color: Colors.white12)),
                      ),
                      child: Row(
                        children: [
                          Icon(bottomIcon, color: Colors.white38, size: 17),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              bottomLabel,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 8,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Text(
                            bottomValue,
                            style: TextStyle(
                              color: bottomValueColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class DialPainter extends CustomPainter {
  final double value;
  final double maximum;
  final int majorDivisions;

  DialPainter({
    required this.value,
    required this.maximum,
    required this.majorDivisions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.57);

    final radius = math.min(size.width * 0.43, size.height * 0.45);

    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    final outerRect = Rect.fromCircle(center: center, radius: radius + 12);

    final faceRect = Rect.fromCircle(center: center, radius: radius);

    // Outer gauge housing.
    canvas.drawCircle(
      center,
      radius + 13,
      Paint()..color = const Color(0xFF020304),
    );

    canvas.drawCircle(
      center,
      radius + 12,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A5258), Color(0xFF161B1F), Color(0xFF42494E)],
        ).createShader(outerRect),
    );

    canvas.drawCircle(
      center,
      radius + 7,
      Paint()..color = const Color(0xFF050708),
    );

    // Gauge face.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF13191D), Color(0xFF070A0C), Color(0xFF020304)],
          stops: [0.0, 0.72, 1.0],
        ).createShader(faceRect),
    );

    // Subtle inner ring.
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final minorTickPaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 1.3;

    final majorTickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square;

    const minorTicksPerDivision = 5;
    final totalMinorTicks = majorDivisions * minorTicksPerDivision;

    for (int index = 0; index <= totalMinorTicks; index++) {
      final fraction = index / totalMinorTicks;
      final angle = startAngle + sweepAngle * fraction;
      final isMajor = index % minorTicksPerDivision == 0;

      final outerPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final innerRadius = radius - (isMajor ? 17 : 9);

      final innerPoint = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );

      canvas.drawLine(
        innerPoint,
        outerPoint,
        isMajor ? majorTickPaint : minorTickPaint,
      );
    }

    // Number labels.
    for (int index = 0; index <= majorDivisions; index++) {
      final fraction = index / majorDivisions;
      final angle = startAngle + sweepAngle * fraction;
      final labelValue = maximum * fraction;
      final labelRadius = radius - 32;

      final labelOffset = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );

      final text = maximum >= 1000
          ? (labelValue / 1000).toStringAsFixed(0)
          : labelValue.toStringAsFixed(0);

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        labelOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Red warning zone over the final 18% of the gauge.
    final warningPaint = Paint()
      ..color = const Color(0xFFD71920)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 20),
      startAngle + (sweepAngle * 0.82),
      sweepAngle * 0.18,
      false,
      warningPaint,
    );

    final progress = (value / maximum).clamp(0.0, 1.0);
    final needleAngle = startAngle + sweepAngle * progress;
    final needleLength = radius - 27;

    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    // Needle glow.
    canvas.drawLine(
      center,
      needleEnd,
      Paint()
        ..color = const Color(0xFFFF2929).withValues(alpha: 0.45)
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // Main needle.
    canvas.drawLine(
      center,
      needleEnd,
      Paint()
        ..color = const Color(0xFFFF2525)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    // Rear needle counterweight.
    final counterweight = Offset(
      center.dx - 18 * math.cos(needleAngle),
      center.dy - 18 * math.sin(needleAngle),
    );

    canvas.drawLine(
      center,
      counterweight,
      Paint()
        ..color = const Color(0xFF9B1116)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );

    // Center hub.
    canvas.drawCircle(
      center,
      13,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF4A5156), Color(0xFF111518)],
        ).createShader(Rect.fromCircle(center: center, radius: 13)),
    );

    canvas.drawCircle(center, 8, Paint()..color = const Color(0xFFFF2525));

    canvas.drawCircle(
      center,
      8,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant DialPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.maximum != maximum ||
        oldDelegate.majorDivisions != majorDivisions;
  }
}

class CenterInformationPanel extends StatelessWidget {
  final double pitch;
  final double roll;
  final bool bleConnected;

  const CenterInformationPanel({
    super.key,
    required this.pitch,
    required this.roll,
    required this.bleConnected,
  });

  @override
  Widget build(BuildContext context) {
    return InstrumentPanel(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(
          children: [
            const Text(
              'ATTITUDE',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 8,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: 3),

            CenterMetric(label: 'PITCH', value: '${pitch.toStringAsFixed(1)}°'),

            const Divider(color: Colors.white12, height: 12),

            CenterMetric(label: 'ROLL', value: '${roll.toStringAsFixed(1)}°'),

            const Spacer(),

            Icon(
              Icons.bluetooth_connected,
              color: bleConnected ? const Color(0xFF00E676) : Colors.white24,
            ),
            const SizedBox(height: 2),

            const Text(
              'BLE',
              style: TextStyle(
                color: Color(0xFF00E676),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),

            Text(
              bleConnected ? 'CONNECTED' : 'SCANNING',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 6,
                letterSpacing: 0.8,
              ),
            ),

            const SizedBox(height: 5),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white10),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'DRIVE',
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 6,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'NORMAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CenterMetric extends StatelessWidget {
  final String label;
  final String value;

  const CenterMetric({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 8,
            letterSpacing: 1.4,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class InstrumentPanel extends StatelessWidget {
  final Widget child;

  const InstrumentPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1114),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFF30373C), width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: BackgroundPatternPainter()),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.018)
      ..strokeWidth = 1;

    for (double x = -size.height; x < size.width; x += 10) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPatternPainter oldDelegate) {
    return false;
  }
}
