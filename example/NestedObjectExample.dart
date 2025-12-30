import 'dart:typed_data';

import 'package:ble_parser/ble_parser.dart';

part 'NestedObjectExample.g.dart';

// Nested object: sensor data with default little endian
@BleObject(endian: Endian.little)
class SensorData {
  @BleField(length: 2) // Uses default endian from BleObject
  final int temperature;

  @BleField(length: 2) // Uses default endian from BleObject
  final int humidity;

  SensorData({required this.temperature, required this.humidity});

  static SensorData fromBytes(List<int> data) {
    return _$SensorDataFromBytesList(data);
  }

  static SensorData fromBytesUint8(Uint8List data) {
    return _$SensorDataFromBytes(data);
  }
}

// Outer object: device packet containing nested sensor data
@BleObject(endian: Endian.little)
class DevicePacket {
  @BleField(length: 1)
  final int deviceId;

  // Nested object - must specify length and objectType
  @BleField(length: 4, objectType: SensorData)
  final SensorData sensorData;

  @BleField(length: 4) // Uses default endian from BleObject
  final int timestamp;

  DevicePacket({
    required this.deviceId,
    required this.sensorData,
    required this.timestamp,
  });

  static DevicePacket fromBytes(List<int> data) {
    return _$DevicePacketFromBytesList(data);
  }

  static DevicePacket fromBytesUint8(Uint8List data) {
    return _$DevicePacketFromBytes(data);
  }
}

// Example demonstrating default signed values
@BleObject(endian: Endian.little, signed: true)
class SignedSensorData {
  @BleField(length: 2) // Uses default: little endian + signed
  final int temperature; // Can be negative

  @BleField(length: 2) // Uses default: little endian + signed
  final int pressure; // Can be negative

  @BleField(length: 4, signed: false) // Override: unsigned
  final int timestamp;

  SignedSensorData({
    required this.temperature,
    required this.pressure,
    required this.timestamp,
  });

  static SignedSensorData fromBytes(List<int> data) {
    return _$SignedSensorDataFromBytesList(data);
  }

  static SignedSensorData fromBytesUint8(Uint8List data) {
    return _$SignedSensorDataFromBytes(data);
  }
}
