import 'dart:typed_data';

import 'package:ble_parser/ble_parser.dart';

part 'HeartRatePacket.g.dart';

@BleObject(endian: Endian.little)
class HeartRatePacket {
  @BleField(length: 1)
  final int flags;

  @BleField(length: 2) // Uses default endian from BleObject
  final int heartRateValue;

  @BleField(length: 2, offset: 4) // Skip to offset 4, uses default endian
  final int energyExpended;

  // Constructor
  HeartRatePacket({
    required this.flags,
    required this.heartRateValue,
    required this.energyExpended,
  });

  // Convenient factory method - Parse from byte array
  static HeartRatePacket fromBytes(List<int> data) {
    return _$HeartRatePacketFromBytes(data);
  }
}
