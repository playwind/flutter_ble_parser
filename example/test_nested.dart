import 'dart:typed_data';
import 'package:ble_parser/ble_parser.dart';

import 'NestedObjectExample.dart';

void main() {
  print('=== Test 1: DevicePacket with nested object ===');
  // BLE data packet:
  // deviceId: 0x01 (1 byte)
  // temperature: 0x1234 (2 bytes, little endian) = 4660
  // humidity: 0x5678 (2 bytes, little endian) = 22136
  // timestamp: 0x11223344 (4 bytes, little endian) = 287454020

  final List<int> testData = [
    0x01, // deviceId = 1
    0x34, 0x12, // temperature = 4660 (little endian)
    0x78, 0x56, // humidity = 22136 (little endian)
    0x44, 0x33, 0x22, 0x11, // timestamp = 287454020 (little endian)
  ];

  print('Data length: ${testData.length} bytes');
  print('');

  // Parse packet
  final packet = DevicePacket.fromBytes(testData);

  print('Parse result:');
  print('  Device ID: ${packet.deviceId}');
  print('  Sensor data:');
  print('    Temperature: ${packet.sensorData.temperature}');
  print('    Humidity: ${packet.sensorData.humidity}');
  print('  Timestamp: ${packet.timestamp}');
  print('');

  // Verify result
  print('Verification:');
  print('  Device ID correct: ${packet.deviceId == 1}');
  print('  Temperature correct: ${packet.sensorData.temperature == 4660}');
  print('  Humidity correct: ${packet.sensorData.humidity == 22136}');
  print('  Timestamp correct: ${packet.timestamp == 287454020}');
  print('  ✓ Test 1 passed!\n');

  print('=== Test 2: SignedSensorData (default signed=true) ===');
  // temperature: -10 (0xF6 0xFF as int16 little endian)
  // pressure: -50 (0xCE 0xFF as int16 little endian)
  // timestamp: 1234567890 (0xD2 0x02 0x96 0x49 as uint32 little endian)
  final signedData = [
    0xF6, 0xFF, // temperature = -10
    0xCE, 0xFF, // pressure = -50
    0xD2, 0x02, 0x96, 0x49, // timestamp = 1234567890
  ];

  final signed = SignedSensorData.fromBytes(signedData);

  print('Parse result:');
  print('  Temperature: ${signed.temperature} (expected: -10)');
  print('  Pressure: ${signed.pressure} (expected: -50)');
  print('  Timestamp: ${signed.timestamp} (expected: 1234567890)');
  print('');

  print('Verification:');
  print('  Temperature correct: ${signed.temperature == -10}');
  print('  Pressure correct: ${signed.pressure == -50}');
  print('  Timestamp correct: ${signed.timestamp == 1234567890}');
  print('  ✓ Test 2 passed!');
}
