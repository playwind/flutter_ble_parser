import 'dart:typed_data';
import 'package:test/test.dart';
import 'MixedTypesExample.dart';

void main() {
  group('Mixed Types Test - Uint8List', () {
    test('Test parsing with Uint8List', () {
      // BLE data packet:
      // sensorId: 0x01 (1 byte, uint8)
      // temperature: 25.0°C as float32 (4 bytes, little endian)
      // pressure: 1000.0 hPa as float64 (8 bytes, little endian)
      // deviceName: "BLE Device" as ASCII/Latin-1 string (10 bytes)
      // humidity: 65% as int32 (4 bytes, little endian, signed)

      final testData = Uint8List.fromList([
        0x01, // sensorId = 1
        // temperature = 25.0 (float32 little endian: 0x00 0x00 0xC8 0x41)
        0x00, 0x00, 0xC8, 0x41,
        // pressure = 1000.0 (float64 little endian: 0x00 0x00 0x00 0x00 0x40 0x8F 0x40)
        0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x8F, 0x40,
        // deviceName = "BLE Device" (10 bytes ASCII)
        0x42, 0x4C, 0x45, 0x20, 0x44, 0x65, 0x76, 0x69, 0x63, 0x65,
        // humidity = 65 (int32 little endian, signed)
        0x41, 0x00, 0x00, 0x00,
      ]);

      final reading = SensorReading.fromBytesUint8(testData);

      expect(reading.sensorId, equals(1), reason: 'Sensor ID should be 1');
      expect(reading.temperature, equals(25.0), reason: 'Temperature should be 25.0°C');
      expect(reading.pressure, equals(1000.0), reason: 'Pressure should be 1000.0 hPa');
      expect(reading.deviceName, equals('BLE Device'), reason: 'Device Name should be "BLE Device"');
      expect(reading.humidity, equals(65), reason: 'Humidity should be 65%');
    });
  });

  group('Mixed Types Test - List<int>', () {
    test('Test parsing with List<int>', () {
      final listData = [
        0x01, // sensorId = 1
        0x00, 0x00, 0xC8, 0x41, // temperature
        0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x8F, 0x40, // pressure
        0x42, 0x4C, 0x45, 0x20, 0x44, 0x65, 0x76, 0x69, 0x63, 0x65, // deviceName
        0x41, 0x00, 0x00, 0x00, // humidity
      ];

      final reading = SensorReading.fromBytes(listData);

      expect(reading.sensorId, equals(1), reason: 'Sensor ID should be 1');
      expect(reading.temperature, equals(25.0), reason: 'Temperature should be 25.0°C');
      expect(reading.pressure, equals(1000.0), reason: 'Pressure should be 1000.0 hPa');
      expect(reading.deviceName, equals('BLE Device'), reason: 'Device Name should be "BLE Device"');
      expect(reading.humidity, equals(65), reason: 'Humidity should be 65%');
    });
  });

  group('Type Inference Tests', () {
    test('int type inference', () {
      final data = [
        0x01, // sensorId = 1
        0x00, 0x00, 0xC8, 0x41, // temperature = 25.0
        0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x8F, 0x40, // pressure = 1000.0
        0x42, 0x4C, 0x45, 0x20, 0x44, 0x65, 0x76, 0x69, 0x63, 0x65, // deviceName
        0x41, 0x00, 0x00, 0x00, // humidity = 65
      ];
      final reading = SensorReading.fromBytes(data);

      expect(reading.sensorId, equals(1), reason: 'int type should be inferred correctly');
      expect(reading.humidity, equals(65), reason: 'signed int should work');
    });

    test('double type inference', () {
      final data = [
        0x00, // sensorId = 0
        0x00, 0x00, 0x00, 0x40, // temperature = 2.0
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0x3F, // pressure = 1.0
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // deviceName
        0x00, 0x00, 0x00, 0x00, // humidity = 0
      ];
      final reading = SensorReading.fromBytes(data);

      expect(reading.temperature, closeTo(2.0, 0.001), reason: 'float32 should be inferred');
      expect(reading.pressure, closeTo(1.0, 0.001), reason: 'float64 should be inferred');
    });

    test('String type inference', () {
      final data = [
        0x00, // sensorId = 0
        0x00, 0x00, 0x00, 0x00, // temperature
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // pressure
        0x54, 0x65, 0x73, 0x74, 0x20, 0x4D, 0x79, 0x44, 0x65, 0x76, // deviceName = "Test MyDev"
        0x00, 0x00, 0x00, 0x00, // humidity = 0
      ];
      final reading = SensorReading.fromBytes(data);

      expect(reading.deviceName, equals('Test MyDev'), reason: 'String should be decoded from ASCII');
    });
  });
}