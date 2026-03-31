// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars

part of 'optional_field_example.dart';

// **************************************************************************
// BleParserGenerator
// **************************************************************************

OptionalPacket _$OptionalPacketFromBytes(Uint8List rawData) {
  final view = ByteData.sublistView(rawData);
  return OptionalPacket(
      flags: view.getUint8(0),
      value: view.getUint16(1, Endian.little),
      extraValue: rawData.length >= 5 ? view.getUint16(3, Endian.little) : null,
      trailer: rawData.length >= 7 ? view.getUint16(5, Endian.little) : null);
}

OptionalPacket _$OptionalPacketFromBytesList(List<int> rawData) {
  final view = ByteData.sublistView(Uint8List.fromList(rawData));
  return OptionalPacket(
      flags: view.getUint8(0),
      value: view.getUint16(1, Endian.little),
      extraValue: rawData.length >= 5 ? view.getUint16(3, Endian.little) : null,
      trailer: rawData.length >= 7 ? view.getUint16(5, Endian.little) : null);
}
