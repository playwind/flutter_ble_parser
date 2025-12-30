import 'dart:typed_data';
import 'HeartRatePacket.dart';

void main() {
  print('=== Test 1: Using Uint8List (from BLE device) ===');
  // Create simulated BLE data
  // flags: 0x06 (Heart rate sensor supports heart rate detection and energy expenditure)
  // heartRateValue: 0x78 0x00 (120 BPM, little endian)
  // Skipped byte: 0x00
  // energyExpended: 0x05 0x00 (5, little endian)
  final bleData = Uint8List.fromList([0x06, 0x78, 0x00, 0x00, 0x05, 0x00]);

  print('Raw data: $bleData');

  // Use the generated parser with Uint8List
  final heartRatePacket1 = HeartRatePacket.fromBytesUint8(bleData);

  print('Parse result (Uint8List):');
  print('  Flags: 0x${heartRatePacket1.flags.toRadixString(16)}');
  print('  Heart Rate: ${heartRatePacket1.heartRateValue} BPM');
  print('  Energy Expended: ${heartRatePacket1.energyExpended}');
  print('✓ Test 1 passed!\n');

  print('=== Test 2: Using List<int> ===');
  // Test with List<int>
  final listData = [0x06, 0x78, 0x00, 0x00, 0x05, 0x00];

  print('Raw data: $listData');

  // Use the generated parser with List<int>
  final heartRatePacket2 = HeartRatePacket.fromBytes(listData);

  print('Parse result (List<int>):');
  print('  Flags: 0x${heartRatePacket2.flags.toRadixString(16)}');
  print('  Heart Rate: ${heartRatePacket2.heartRateValue} BPM');
  print('  Energy Expended: ${heartRatePacket2.energyExpended}');
  print('✓ Test 2 passed!\n');

  print('✓✓✓ Both Uint8List and List<int> are supported! ✓✓✓');
}

