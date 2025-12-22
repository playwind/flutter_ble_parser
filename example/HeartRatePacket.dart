import 'dart:typed_data';

import 'package:ble_parser/ble_parser.dart';

part 'HeartRatePacket.g.dart';

@BleObject()
class HeartRatePacket {
  @BleField(type: BleType.uint8)
  final int flags;

  @BleField(type: BleType.uint16, endian: Endian.little)
  final int heartRateValue;

  @BleField(type: BleType.uint16, offset: 4) // 跳过一个字节，直接读offset 4
  final int energyExpended;

  // 构造函数
  HeartRatePacket({
    required this.flags,
    required this.heartRateValue,
    required this.energyExpended
  });

  // 便捷工厂方法 - 从字节数组解析
  static HeartRatePacket fromBytes(List<int> data) {
    return _$HeartRatePacketFromBytes(data);
  }
}