import 'dart:typed_data';
import 'package:ble_parser/ble_parser.dart';

part 'MixedTypesExample.g.dart';

// Example demonstrating int, double, and String type inference
@BleObject(endian: Endian.little)
class SensorReading {
  @BleField(length: 1)
  final int sensorId; // int type - inferred as uint8

  @BleField(length: 4)
  final double temperature; // double type - inferred as float32

  @BleField(length: 8)
  final double pressure; // double type - inferred as float64

  @BleField(length: 10)
  final String deviceName; // String type - UTF-8 decoded

  @BleField(length: 4, signed: true)
  final int humidity; // int type - explicitly signed as int32

  SensorReading({
    required this.sensorId,
    required this.temperature,
    required this.pressure,
    required this.deviceName,
    required this.humidity,
  });

  static SensorReading fromBytes(List<int> data) {
    return _$SensorReadingFromBytesList(data);
  }

  static SensorReading fromBytesUint8(Uint8List data) {
    return _$SensorReadingFromBytes(data);
  }
}