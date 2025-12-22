import 'dart:typed_data';
import 'package:ble_parser/ble_parser.dart';

import 'NestedObjectExample.dart';

void main() {
  // 模拟 BLE 数据包：
  // deviceId: 0x01 (1字节)
  // temperature: 0x1234 (2字节, 小端序) = 4660
  // humidity: 0x5678 (2字节, 小端序) = 22136
  // timestamp: 0x11223344 (4字节, 小端序) = 287454020

  final List<int> testData = [
    0x01,                    // deviceId = 1
    0x34, 0x12,             // temperature = 4660 (小端序)
    0x78, 0x56,             // humidity = 22136 (小端序)
    0x44, 0x33, 0x22, 0x11, // timestamp = 287454020 (小端序)
  ];

  print('测试数据长度: ${testData.length} 字节');
  print('数据长度: ${testData.length} 字节');
  print('');

  // 解析数据包
  final packet = DevicePacket.fromBytes(testData);

  print('解析结果:');
  print('  设备ID: ${packet.deviceId}');
  print('  传感器数据:');
  print('    温度: ${packet.sensorData.temperature}');
  print('    湿度: ${packet.sensorData.humidity}');
  print('  时间戳: ${packet.timestamp}');
  print('');

  // 验证结果
  print('验证:');
  print('  设备ID正确: ${packet.deviceId == 1}');
  print('  温度正确: ${packet.sensorData.temperature == 4660}');
  print('  湿度正确: ${packet.sensorData.humidity == 22136}');
  print('  时间戳正确: ${packet.timestamp == 287454020}');
}