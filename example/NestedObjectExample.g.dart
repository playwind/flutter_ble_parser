// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars

part of 'NestedObjectExample.dart';

// **************************************************************************
// BleParserGenerator
// **************************************************************************

SensorData _$SensorDataFromBytes(List<int> rawData) {
  final view = ByteData.sublistView(Uint8List.fromList(rawData));
  return SensorData(
      temperature: view.getUint16(0, Endian.little),
      humidity: view.getUint16(2, Endian.little));
}

DevicePacket _$DevicePacketFromBytes(List<int> rawData) {
  final view = ByteData.sublistView(Uint8List.fromList(rawData));
  return DevicePacket(
      deviceId: view.getUint8(0),
      sensorData: _$SensorDataFromBytes(rawData.sublist(1, 5)),
      timestamp: view.getUint32(5, Endian.little));
}

SignedSensorData _$SignedSensorDataFromBytes(List<int> rawData) {
  final view = ByteData.sublistView(Uint8List.fromList(rawData));
  return SignedSensorData(
      temperature: view.getInt16(0, Endian.little),
      pressure: view.getInt16(2, Endian.little),
      timestamp: view.getUint32(4, Endian.little));
}
