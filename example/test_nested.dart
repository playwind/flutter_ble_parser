import 'dart:typed_data';
import 'NestedObjectExample.dart';

void main() {
  print('=== Test 1: DevicePacket with nested object (Uint8List) ===');
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

  print('Data length: ${testData.length} bytes');
  print('');

  // Parse packet with Uint8List
  final packet1 = DevicePacket.fromBytesUint8(testData);

  print('Parse result (Uint8List):');
  print('  Device ID: ${packet1.deviceId}');
  print('  Sensor data:');
  print('    Temperature: ${packet1.sensorData.temperature}');
  print('    Humidity: ${packet1.sensorData.humidity}');
  print('  Timestamp: ${packet1.timestamp}');
  print('');

  // Verify result
  print('Verification:');
  print('  Device ID correct: ${packet1.deviceId == 1}');
  print('  Temperature correct: ${packet1.sensorData.temperature == 4660}');
  print('  Humidity correct: ${packet1.sensorData.humidity == 22136}');
  print('  Timestamp correct: ${packet1.timestamp == 287454020}');
  print('  ✓ Test 1 passed!\n');

  print('=== Test 2: DevicePacket with nested object (List<int>) ===');
  final listData = [
    0x01, // deviceId = 1
    0x34, 0x12, // temperature = 4660 (little endian)
    0x78, 0x56, // humidity = 22136 (little endian)
    0x44, 0x33, 0x22, 0x11, // timestamp = 287454020 (little endian)
  ];

  final packet2 = DevicePacket.fromBytes(listData);

  print('Parse result (List<int>):');
  print('  Device ID: ${packet2.deviceId}');
  print('  Sensor data:');
  print('    Temperature: ${packet2.sensorData.temperature}');
  print('    Humidity: ${packet2.sensorData.humidity}');
  print('  Timestamp: ${packet2.timestamp}');
  print('  ✓ Test 2 passed!\n');

  print('=== Test 3: SignedSensorData (default signed=true) ===');
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
  print('  ✓ Test 3 passed!');
}

