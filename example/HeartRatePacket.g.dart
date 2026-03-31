// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars

part of 'HeartRatePacket.dart';

// **************************************************************************
// BleParserGenerator
// **************************************************************************

HeartRatePacket _$HeartRatePacketFromBytes(Uint8List rawData) {
  final view = ByteData.sublistView(rawData);
  return HeartRatePacket(
      flags: view.getUint8(0),
      heartRateValue: view.getUint16(1, Endian.little),
      energyExpended:
          rawData.length >= 6 ? view.getUint16(4, Endian.little) : null);
}

HeartRatePacket _$HeartRatePacketFromBytesList(List<int> rawData) {
  final view = ByteData.sublistView(Uint8List.fromList(rawData));
  return HeartRatePacket(
      flags: view.getUint8(0),
      heartRateValue: view.getUint16(1, Endian.little),
      energyExpended:
          rawData.length >= 6 ? view.getUint16(4, Endian.little) : null);
}
