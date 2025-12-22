import 'dart:typed_data';

import 'package:ble_parser/ble_parser.dart';

part 'NestedObjectExample.g.dart';

// 嵌套对象：传感器数据
@BleObject()
class SensorData {
  @BleField(type: BleType.uint16, endian: Endian.little)
  final int temperature;

  @BleField(type: BleType.uint16, endian: Endian.little)
  final int humidity;

  SensorData({
    required this.temperature,
    required this.humidity,
  });

  static SensorData fromBytes(List<int> data) {
    return _$SensorDataFromBytes(data);
  }
}

// 外层对象：设备数据包，包含嵌套的传感器数据（使用自动推断）
@BleObject()
class DevicePacket {
  @BleField(type: BleType.uint8)
  final int deviceId;

  // 注意：这里没有指定 objectType，将自动推断为 SensorData
  @BleField(type: BleType.object)
  final SensorData sensorData;

  @BleField(type: BleType.uint32, endian: Endian.little)
  final int timestamp;

  DevicePacket({
    required this.deviceId,
    required this.sensorData,
    required this.timestamp,
  });

  static DevicePacket fromBytes(List<int> data) {
    return _$DevicePacketFromBytes(data);
  }
}