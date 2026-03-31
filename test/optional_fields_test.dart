import 'dart:typed_data';
import 'package:test/test.dart';
import 'optional_field_example.dart';

void main() {
  group('Optional Fields - Uint8List', () {
    test('All fields present', () {
      // flags(1) + value(2) + extraValue(2) + trailer(2) = 7 bytes
      final data = Uint8List.fromList([
        0x01, // flags = 1
        0x64, 0x00, // value = 100 (little endian)
        0xC8, 0x00, // extraValue = 200
        0x2C, 0x01, // trailer = 300
      ]);

      final packet = OptionalPacket.fromBytesUint8(data);
      expect(packet.flags, equals(1));
      expect(packet.value, equals(100));
      expect(packet.extraValue, equals(200));
      expect(packet.trailer, equals(300));
    });

    test('Only required fields present', () {
      // flags(1) + value(2) = 3 bytes
      final data = Uint8List.fromList([
        0x01, // flags = 1
        0x64, 0x00, // value = 100
      ]);

      final packet = OptionalPacket.fromBytesUint8(data);
      expect(packet.flags, equals(1));
      expect(packet.value, equals(100));
      expect(packet.extraValue, isNull);
      expect(packet.trailer, isNull);
    });

    test('First optional field present, second absent', () {
      // flags(1) + value(2) + extraValue(2) = 5 bytes
      final data = Uint8List.fromList([
        0x01, // flags = 1
        0x64, 0x00, // value = 100
        0xC8, 0x00, // extraValue = 200
      ]);

      final packet = OptionalPacket.fromBytesUint8(data);
      expect(packet.flags, equals(1));
      expect(packet.value, equals(100));
      expect(packet.extraValue, equals(200));
      expect(packet.trailer, isNull);
    });

    test('Partial optional field data (not enough bytes)', () {
      // flags(1) + value(2) + 1 byte of extraValue = 4 bytes
      // extraValue needs 2 bytes starting at offset 3, so rawData.length(4) >= 5 is false
      final data = Uint8List.fromList([
        0x01, // flags = 1
        0x64, 0x00, // value = 100
        0xC8, // partial extraValue (only 1 byte, needs 2)
      ]);

      final packet = OptionalPacket.fromBytesUint8(data);
      expect(packet.flags, equals(1));
      expect(packet.value, equals(100));
      expect(packet.extraValue, isNull);
      expect(packet.trailer, isNull);
    });
  });

  group('Optional Fields - List<int>', () {
    test('All fields present', () {
      final data = [
        0x01, // flags = 1
        0x64, 0x00, // value = 100
        0xC8, 0x00, // extraValue = 200
        0x2C, 0x01, // trailer = 300
      ];

      final packet = OptionalPacket.fromBytes(data);
      expect(packet.flags, equals(1));
      expect(packet.value, equals(100));
      expect(packet.extraValue, equals(200));
      expect(packet.trailer, equals(300));
    });

    test('Only required fields present', () {
      final data = [
        0x01, // flags = 1
        0x64, 0x00, // value = 100
      ];

      final packet = OptionalPacket.fromBytes(data);
      expect(packet.flags, equals(1));
      expect(packet.value, equals(100));
      expect(packet.extraValue, isNull);
      expect(packet.trailer, isNull);
    });
  });
}
