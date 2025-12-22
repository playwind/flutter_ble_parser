import 'dart:typed_data';
import 'package:ble_parser/ble_parser.dart';
import 'HeartRatePacket.dart';

void main() {
  // 创建模拟的 BLE 数据
  // flags: 0x06 (心率传感器支持心率检测和能量消耗)
  // heartRateValue: 0x78 0x00 (120 BPM, little endian)
  // 跳过的字节: 0x00
  // energyExpended: 0x05 0x00 (5, little endian)
  final bleData = Uint8List.fromList([0x06, 0x78, 0x00, 0x00, 0x05, 0x00]);

  print('原始数据: $bleData');

  // 使用生成的解析器
  final heartRatePacket = HeartRatePacket.fromBytes(bleData);

  print('解析结果:');
  print('  Flags: 0x${heartRatePacket.flags.toRadixString(16)}');
  print('  Heart Rate: ${heartRatePacket.heartRateValue} BPM');
  print('  Energy Expended: ${heartRatePacket.energyExpended}');
}
