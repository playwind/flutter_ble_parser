// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars

part of 'MixedTypesExample.dart';

// **************************************************************************
// BleParserGenerator
// **************************************************************************

SensorReading _$SensorReadingFromBytes(Uint8List rawData) {
  final view = ByteData.sublistView(rawData);
  return SensorReading(
      sensorId: view.getUint8(0),
      temperature: view.getFloat32(1, Endian.little),
      pressure: view.getFloat64(5, Endian.little),
      deviceName: String.fromCharCodes(rawData.sublist(13, 23)),
      humidity: view.getInt32(23, Endian.little));
}

SensorReading _$SensorReadingFromBytesList(List<int> rawData) {
  final view = ByteData.sublistView(Uint8List.fromList(rawData));
  return SensorReading(
      sensorId: view.getUint8(0),
      temperature: view.getFloat32(1, Endian.little),
      pressure: view.getFloat64(5, Endian.little),
      deviceName: String.fromCharCodes(rawData.sublist(13, 23)),
      humidity: view.getInt32(23, Endian.little));
}
