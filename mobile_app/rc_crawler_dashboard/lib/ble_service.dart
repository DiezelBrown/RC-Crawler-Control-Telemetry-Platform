import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'telemetry_data.dart';

class BleService extends ChangeNotifier {
  static const String deviceName = 'RC-Crawler-Telemetry';

  static const String serviceUuid = '12345678-1234-1234-1234-123456789000';

  static const String telemetryUuid = '12345678-1234-1234-1234-123456789001';

  BluetoothDevice? _device;

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _telemetrySubscription;

  TelemetryData _telemetry = const TelemetryData.empty();

  TelemetryData get telemetry => _telemetry;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  String _status = 'Disconnected';
  String get status => _status;

  Future<void> connect() async {
    if (_isConnecting || _isConnected) {
      return;
    }

    _isConnecting = true;
    _status = 'Starting Bluetooth';
    notifyListeners();

    try {
      final supported = await FlutterBluePlus.isSupported;

      if (!supported) {
        throw Exception('Bluetooth is not supported on this device');
      }

      _status = 'Waiting for Bluetooth';
      notifyListeners();

      await FlutterBluePlus.adapterState
          .where((state) => state == BluetoothAdapterState.on)
          .first
          .timeout(const Duration(seconds: 15));

      _status = 'Scanning';
      notifyListeners();

      final deviceCompleter = Completer<BluetoothDevice>();

      await _scanSubscription?.cancel();

      _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
        for (final result in results) {
          final advertisedName = result.advertisementData.advName;

          final serviceMatches = result.advertisementData.serviceUuids.any(
            (uuid) =>
                uuid.toString().toLowerCase() == serviceUuid.toLowerCase(),
          );

          if ((advertisedName == deviceName || serviceMatches) &&
              !deviceCompleter.isCompleted) {
            deviceCompleter.complete(result.device);
          }
        }
      });

      await FlutterBluePlus.startScan(
        withServices: [Guid(serviceUuid)],
        timeout: const Duration(seconds: 10),
      );

      final device = await deviceCompleter.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          throw TimeoutException(
            'RC crawler not found. Make sure the ESP32 is powered on.',
          );
        },
      );

      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;

      _device = device;
      _status = 'Connecting';
      notifyListeners();

      await _connectionSubscription?.cancel();

      _connectionSubscription = device.connectionState.listen((state) {
        _isConnected = state == BluetoothConnectionState.connected;

        if (!_isConnected) {
          _status = 'Disconnected';
        }

        notifyListeners();
      });

      await device.connect(license: License.nonprofit);

      _status = 'Discovering services';
      notifyListeners();

      final services = await device.discoverServices();

      BluetoothCharacteristic? telemetryCharacteristic;

      for (final service in services) {
        if (service.uuid.toString().toLowerCase() !=
            serviceUuid.toLowerCase()) {
          continue;
        }

        for (final characteristic in service.characteristics) {
          if (characteristic.uuid.toString().toLowerCase() ==
              telemetryUuid.toLowerCase()) {
            telemetryCharacteristic = characteristic;
            break;
          }
        }
      }

      if (telemetryCharacteristic == null) {
        throw Exception('Telemetry characteristic was not found');
      }

      await _telemetrySubscription?.cancel();

      _telemetrySubscription = telemetryCharacteristic.onValueReceived.listen(
        _handleTelemetry,
      );

      device.cancelWhenDisconnected(_telemetrySubscription!);

      await telemetryCharacteristic.setNotifyValue(true);

      _isConnected = true;
      _status = 'Connected';
      notifyListeners();
    } catch (error) {
      _isConnected = false;
      _status = 'Connection failed';
      debugPrint('BLE error: $error');
      notifyListeners();
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  void _handleTelemetry(List<int> bytes) {
    try {
      final message = utf8.decode(bytes).trim();

      if (message.isEmpty) {
        return;
      }

      _telemetry = TelemetryData.fromCsv(message);

      debugPrint('BLE telemetry: $message');

      notifyListeners();
    } catch (error) {
      debugPrint('Bad telemetry packet: $error');
    }
  }

  Future<void> disconnect() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    await _telemetrySubscription?.cancel();
    await _connectionSubscription?.cancel();
    await _device?.disconnect();

    _device = null;
    _isConnected = false;
    _isConnecting = false;
    _status = 'Disconnected';

    notifyListeners();
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    _telemetrySubscription?.cancel();
    _connectionSubscription?.cancel();
    _device?.disconnect();

    super.dispose();
  }
}
