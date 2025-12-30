import 'dart:typed_data';
import 'package:ble_parser/ble_parser.dart';
import 'HeartRatePacket.dart';

void main() {
  // Create simulated BLE data
  // flags: 0x06 (Heart rate sensor supports heart rate detection and energy expenditure)
  // heartRateValue: 0x78 0x00 (120 BPM, little endian)
  // Skipped byte: 0x00
  // energyExpended: 0x05 0x00 (5, little endian)
  final bleData = Uint8List.fromList([0x06, 0x78, 0x00, 0x00, 0x05, 0x00]);

  print('Raw data: $bleData');

  // Use the generated parser
  final heartRatePacket = HeartRatePacket.fromBytes(bleData);

  print('Parse result:');
  print('  Flags: 0x${heartRatePacket.flags.toRadixString(16)}');
  print('  Heart Rate: ${heartRatePacket.heartRateValue} BPM');
  print('  Energy Expended: ${heartRatePacket.energyExpended}');
}
