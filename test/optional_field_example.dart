import 'dart:typed_data';
import 'package:ble_parser/ble_parser.dart';

part 'optional_field_example.g.dart';

@BleObject(endian: Endian.little)
class OptionalPacket {
  @BleField(length: 1)
  final int flags;

  @BleField(length: 2)
  final int value;

  @BleField(length: 2, optional: true)
  final int? extraValue;

  @BleField(length: 2, optional: true)
  final int? trailer;

  OptionalPacket({
    required this.flags,
    required this.value,
    this.extraValue,
    this.trailer,
  });

  static OptionalPacket fromBytes(List<int> data) {
    return _$OptionalPacketFromBytesList(data);
  }

  static OptionalPacket fromBytesUint8(Uint8List data) {
    return _$OptionalPacketFromBytes(data);
  }
}
