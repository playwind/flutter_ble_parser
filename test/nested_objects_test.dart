import 'dart:typed_data';
import 'package:test/test.dart';
import 'NestedObjectExample.dart';

void main() {
  group('Nested Objects Test - Uint8List', () {
    test('DevicePacket with nested SensorData using Uint8List', () {
      // BLE data packet:
      // deviceId: 0x01 (1 byte)
      // temperature: 0x1234 (2 bytes, little endian) = 4660
      // humidity: 0x5678 (2 bytes, little endian) = 22136
      // timestamp: 0x11223344 (4 bytes, little endian) = 287454020

      final testData = Uint8List.fromList([
        0x01, // deviceId = 1
        0x34, 0x12, // temperature = 4660 (little endian)
        0x78, 0x56, // humidity = 22136 (little endian)
        0x44, 0x33, 0x22, 0x11, // timestamp = 287454020 (little endian)
      ]);

      final packet = DevicePacket.fromBytesUint8(testData);

      expect(packet.deviceId, equals(1), reason: 'Device ID should be 1');
      expect(packet.sensorData.temperature, equals(4660), reason: 'Temperature should be 4660');
      expect(packet.sensorData.humidity, equals(22136), reason: 'Humidity should be 22136');
      expect(packet.timestamp, equals(287454020), reason: 'Timestamp should be 287454020');
    });
  });

  group('Nested Objects Test - List<int>', () {
    test('DevicePacket with nested SensorData using List<int>', () {
      final listData = [
        0x01, // deviceId = 1
        0x34, 0x12, // temperature = 4660 (little endian)
        0x78, 0x56, // humidity = 22136 (little endian)
        0x44, 0x33, 0x22, 0x11, // timestamp = 287454020 (little endian)
      ];

      final packet = DevicePacket.fromBytes(listData);

      expect(packet.deviceId, equals(1), reason: 'Device ID should be 1');
      expect(packet.sensorData.temperature, equals(4660), reason: 'Temperature should be 4660');
      expect(packet.sensorData.humidity, equals(22136), reason: 'Humidity should be 22136');
      expect(packet.timestamp, equals(287454020), reason: 'Timestamp should be 287454020');
    });
  });

  group('Nested Objects Test - Signed Integers', () {
    test('SignedSensorData with default signed=true', () {
      // temperature: -10 (0xF6 0xFF as int16 little endian)
      // pressure: -50 (0xCE 0xFF as int16 little endian)
      // timestamp: 1234567890 (0xD2 0x02 0x96 0x49 as uint32 little endian)
      final data = [
        0xF6, 0xFF, // temperature = -10
        0xCE, 0xFF, // pressure = -50
        0xD2, 0x02, 0x96, 0x49, // timestamp = 1234567890
      ];

      final sensor = SignedSensorData.fromBytes(data);

      expect(sensor.temperature, equals(-10), reason: 'Temperature should be -10');
      expect(sensor.pressure, equals(-50), reason: 'Pressure should be -50');
      expect(sensor.timestamp, equals(1234567890), reason: 'Timestamp should be 1234567890');
    });
  });

  group('Nested Objects Test - Auto Offset', () {
    test('Auto offset calculation for nested objects', () {
      // SensorData auto offset:
      // - temperature at offset 0 (2 bytes)
      // - humidity at offset 2 (2 bytes)
      // Total: 4 bytes

      final data = [
        0x01, // deviceId
        0x00, 0x01, // temperature = 256
        0x00, 0x02, // humidity = 512
        0x78, 0x56, 0x34, 0x12, // timestamp
      ];

      final packet = DevicePacket.fromBytes(data);

      expect(packet.deviceId, equals(1));
      expect(packet.sensorData.temperature, equals(256));
      expect(packet.sensorData.humidity, equals(512));
      expect(packet.timestamp, equals(0x12345678));
    });
  });
}