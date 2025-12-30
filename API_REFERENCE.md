# BLE Parser API Reference

Complete API documentation for the BLE Parser library.

## Table of Contents

- [Annotations](#annotations)
  - [@BleObject()](#bleobject)
  - [@BleField()](#blefield)
- [Data Types](#data-types)
- [Generated Functions](#generated-functions)
- [Advanced Usage](#advanced-usage)
- [Error Handling](#error-handging)

---

## Annotations

### @BleObject()

Class-level annotation that marks a class as a BLE data object parser.

**Constructor:**

```dart
const BleObject({
  Endian endian = Endian.little,
  bool signed = false,
})
```

**Parameters:**

#### `endian` (optional)
- **Type:** `Endian`
- **Default:** `Endian.little`
- **Description:** Sets the default byte order for all fields in the class. Can be overridden per-field using the `endian` parameter in `@BleField()`.
- **Values:**
  - `Endian.little` - Little-endian byte order (least significant byte first)
  - `Endian.big` - Big-endian byte order (most significant byte first)

**Example:**
```dart
@BleObject(endian: Endian.big)
class NetworkPacket {
  @BleField(length: 2)  // Uses big endian
  final int packetId;
}
```

#### `signed` (optional)
- **Type:** `bool`
- **Default:** `false`
- **Description:** Sets the default signed/unsigned flag for all integer fields in the class. When `true`, integers are parsed as signed (can be negative). Can be overridden per-field using the `signed` parameter in `@BleField()`.

**Example:**
```dart
@BleObject(signed: true)
class SensorData {
  @BleField(length: 2)  // Parsed as int16 (signed)
  final int temperature;  // Can be negative
}
```

---

### @BleField()

Field-level annotation that marks a field for BLE data parsing.

**Constructor:**

```dart
const BleField({
  required int length,
  int? offset,
  Endian? endian,
  bool? signed,
  Type? objectType,
})
```

**Parameters:**

#### `length` (required)
- **Type:** `int`
- **Default:** N/A (required parameter)
- **Description:** Specifies the size of the field in bytes. Determines which parsing method to use.
- **Valid values and their mappings:**
  - `1` → Parses as `int8`/`uint8` (1 byte)
  - `2` → Parses as `int16`/`uint16` (2 bytes)
  - `4` → Parses as `int32`/`uint32` (4 bytes)
  - `8` → Parses as `int64`/`uint64` (8 bytes)
  - Any other value → Returns `List<int>` (raw bytes sublist)

**Examples:**
```dart
@BleField(length: 1)
final int flags;  // uint8 or int8

@BleField(length: 4)
final int timestamp;  // uint32 or int32

@BleField(length: 10)
final List<int> rawData;  // Custom length, returns raw bytes
```

#### `offset` (optional)
- **Type:** `int?`
- **Default:** `null` (auto-calculated)
- **Description:** Forces the field to be read from a specific byte offset in the data. When `null`, the offset is automatically calculated based on the previous field's position and size.
- **Note:** When using manual offsets, ensure fields don't overlap.

**Examples:**
```dart
@BleObject()
class SparseData {
  @BleField(length: 2, offset: 0)  // Read from byte 0
  final int field1;

  @BleField(length: 2, offset: 4)  // Skip bytes 2-3, read from byte 4
  final int field2;

  @BleField(length: 4, offset: 10)  // Skip bytes 6-9, read from byte 10
  final int field3;
}
```

#### `endian` (optional)
- **Type:** `Endian?`
- **Default:** `null` (uses `@BleObject` default)
- **Description:** Overrides the byte order for this specific field. When `null`, uses the default specified in `@BleObject()`.
- **Values:**
  - `null` - Use default from `@BleObject`
  - `Endian.little` - Little-endian byte order
  - `Endian.big` - Big-endian byte order

**Examples:**
```dart
@BleObject(endian: Endian.big)
class MixedEndianPacket {
  @BleField(length: 2)  // Uses big endian (from class default)
  final int header;

  @BleField(length: 4, endian: Endian.little)  // Override to little endian
  final int payload;
}
```

#### `signed` (optional)
- **Type:** `bool?`
- **Default:** `null` (uses `@BleObject` default)
- **Description:** Overrides the signed flag for this specific integer field. When `null`, uses the default specified in `@BleObject()`.
- **Values:**
  - `null` - Use default from `@BleObject`
  - `true` - Parse as signed integer (can be negative)
  - `false` - Parse as unsigned integer (always positive)

**Examples:**
```dart
@BleObject(signed: true)
class SensorData {
  @BleField(length: 2)  // Uses signed=true (from class default)
  final int temperature;  // int16, can be negative

  @BleField(length: 4, signed: false)  // Override to unsigned
  final int timestamp;  // uint32, always positive
}
```

#### `objectType` (optional)
- **Type:** `Type?`
- **Default:** `null`
- **Description:** Specifies the type of a nested `@BleObject` class. Required when parsing nested objects. The `length` parameter must match the total size of all fields in the nested object.

**Examples:**
```dart
@BleObject()
class InnerData {
  @BleField(length: 2)
  final int field1;

  @BleField(length: 2)
  final int field2;
  // Total size = 4 bytes
}

@BleObject()
class OuterData {
  @BleField(length: 1)
  final int header;

  @BleField(length: 4, objectType: InnerData)  // Must specify type and correct length
  final InnerData nested;
}
```

---

## Data Types

### Integer Types

Based on the `length` and `signed` parameters, different integer types are generated:

| Length | Signed=false | Signed=true | Range |
|--------|--------------|-------------|-------|
| 1 byte | `uint8` | `int8` | -128 to 127 / 0 to 255 |
| 2 bytes | `uint16` | `int16` | -32768 to 32767 / 0 to 65535 |
| 4 bytes | `uint32` | `int32` | -2¹⁰ to 2³¹-1 / 0 to 2²²-1 |
| 8 bytes | `uint64` | `int64` | -2²³ to 2²³-1 / 0 to 2²⁴-1 |

### Raw Bytes

When `length` is not 1, 2, 4, or 8, the field returns `List<int>`:

```dart
@BleField(length: 3)
final List<int> customData;  // Returns 3 bytes as List<int>
```

---

## Generated Functions

For each class annotated with `@BleObject()`, the builder generates **two** parsing functions:

### 1. Uint8List Version (Primary - Zero-Copy)

**Function Signature:**

```dart
ClassName _$ClassNameFromBytes(Uint8List rawData)
```

**Parameters:**
- `rawData`: Raw byte array as `Uint8List` from BLE device

**Returns:**
- Parsed object of type `ClassName`

**Performance Characteristics:**
- Zero-copy parsing using `ByteData.sublistView()`
- Directly views the data without copying
- Best for BLE devices that return `Uint8List`
- No unnecessary memory allocation

**Example:**
```dart
HeartRatePacket _$HeartRatePacketFromBytes(Uint8List rawData) {
  final view = ByteData.sublistView(rawData);
  return HeartRatePacket(
    flags: view.getUint8(0),
    heartRate: view.getUint16(1, Endian.little)
  );
}
```

### 2. List<int> Version (Compatibility Wrapper)

**Function Signature:**

```dart
ClassName _$ClassNameFromBytesList(List<int> rawData)
```

**Parameters:**
- `rawData`: Raw byte array as `List<int>` from any source

**Returns:**
- Parsed object of type `ClassName`

**Performance Characteristics:**
- One-copy parsing using `Uint8List.fromList()`
- Automatically converts `List<int>` to `Uint8List`
- Works with any `List<int>` data source
- Slightly more memory overhead due to conversion

**Example:**
```dart
HeartRatePacket _$HeartRatePacketFromBytesList(List<int> rawData) {
  final view = ByteData.sublistView(Uint8List.fromList(rawData));
  return HeartRatePacket(
    flags: view.getUint8(0),
    heartRate: view.getUint16(1, Endian.little)
  );
}
```

### Usage Patterns

**Recommended factory method implementation:**

```dart
@BleObject()
class HeartRatePacket {
  @BleField(length: 1)
  final int flags;

  @BleField(length: 2)
  final int heartRate;

  HeartRatePacket({
    required this.flags,
    required this.heartRate,
  });

  // Convenience method - works with List<int>
  static HeartRatePacket fromBytes(List<int> data) {
    return _$HeartRatePacketFromBytesList(data);
  }

  // Optimized method - zero-copy parsing from Uint8List
  static HeartRatePacket fromBytesUint8(Uint8List data) {
    return _$HeartRatePacketFromBytes(data);
  }
}
```

**When to use each:**

```dart
// Using Uint8List (recommended for BLE data)
final bleData = Uint8List.fromList([0x06, 0x78, 0x00]);
final packet1 = HeartRatePacket.fromBytesUint8(bleData);  // Zero-copy

// Using List<int> (convenience)
final listData = [0x06, 0x78, 0x00];
final packet2 = HeartRatePacket.fromBytes(listData);  // Auto-conversion
```

**Note:** Both methods produce identical parsing results. The choice depends on your data source and performance requirements.

---

## Advanced Usage

### Nested Objects

Complete example with nested objects:

```dart
@BleObject(endian: Endian.little)
class GPSLocation {
  @BleField(length: 4, signed: true)
  final int latitude;  // int32

  @BleField(length: 4, signed: true)
  final int longitude;  // int32

  GPSLocation({
    required this.latitude,
    required this.longitude,
  });

  static GPSLocation fromBytes(List<int> data) {
    return _$GPSLocationFromBytes(data);
  }
}

@BleObject(endian: Endian.little)
class TrackerData {
  @BleField(length: 1)
  final int deviceId;

  @BleField(length: 8, objectType: GPSLocation)  // 4+4=8 bytes
  final GPSLocation location;

  @BleField(length: 4)
  final int timestamp;

  TrackerData({
    required this.deviceId,
    required this.location,
    required this.timestamp,
  });

  static TrackerData fromBytes(List<int> data) {
    return _$TrackerDataFromBytes(data);
  }
}
```

### Mixed Signed/Unsigned

```dart
@BleObject(endian: Endian.little, signed: true)
class EnvironmentalReading {
  @BleField(length: 2)  // int16 (signed)
  final int temperature;  // Can be negative: -10°C

  @BleField(length: 2)  // int16 (signed)
  final int pressure;    // Can be negative: below sea level

  @BleField(length: 1, signed: false)  // uint8 (unsigned)
  final int humidity;    // Always positive: 0-100%

  @BleField(length: 4, signed: false)  // uint32 (unsigned)
  final int timestamp;  // Unix timestamp

  EnvironmentalReading({
    required this.temperature,
    required this.pressure,
    required this.humidity,
    required this.timestamp,
  });

  static EnvironmentalReading fromBytes(List<int> data) {
    return _$EnvironmentalReadingFromBytes(data);
  }
}
```

### Auto-offset vs Manual Offset

**Auto-offset (recommended):**
```dart
@BleObject()
class CompactPacket {
  @BleField(length: 1)  // offset 0, total: 1 byte
  final int a;

  @BleField(length: 2)  // offset 1, total: 3 bytes
  final int b;

  @BleField(length: 4)  // offset 3, total: 7 bytes
  final int c;
}
```

**Manual offset (for sparse data):**
```dart
@BleObject()
class SparsePacket {
  @BleField(length: 1, offset: 0)  // at byte 0
  final int header;

  @BleField(length: 2, offset: 4)  // skip bytes 2-3
  final int value1;

  @BleField(length: 4, offset: 10)  // skip bytes 6-9
  final int value2;
}
```

---

## Byte Order Examples

### Little Endian (common in BLE)

```dart
// Data: [0x34, 0x12]
@BleObject(endian: Endian.little)
class LittleEndianData {
  @BleField(length: 2)
  final int value;  // Parsed as 0x1234 (4660)
}
```

### Big Endian (network byte order)

```dart
// Data: [0x12, 0x34]
@BleObject(endian: Endian.big)
class BigEndianData {
  @BleField(length: 2)
  final int value;  // Parsed as 0x1234 (4660)
}
```

### Mixed Endian

```dart
@BleObject(endian: Endian.big)
class MixedData {
  @BleField(length: 2)  // Big endian
  final int networkValue;

  @BleField(length: 4, endian: Endian.little)  // Little endian
  final int deviceValue;
}
```

---

## Error Handling

### Build-time Errors

1. **Missing `length` parameter:**
   ```
   Error: Missing required parameter: length
   ```
   **Solution:** Always provide `length` in `@BleField()`

2. **Missing part directive:**
   ```
   Error: Could not resolve _$ClassNameFromBytes
   ```
   **Solution:** Add `part 'filename.g.dart';` to your model file

### Runtime Errors

1. **Insufficient data:**
   If the input data is shorter than expected, you'll get a `RangeError`

2. **Incorrect nested object length:**
   May cause parsing errors or data misalignment

**Best Practice:** Always validate input data length before parsing:

```dart
class MyPacket {
  static MyPacket fromBytes(List<int> data) {
    if (data.length < 7) {
      throw ArgumentError('Data too short: expected 7 bytes, got ${data.length}');
    }
    return _$MyPacketFromBytes(data);
  }
}
```

---

## Best Practices

1. **Always add part directives:**
   ```dart
   part 'my_packet.g.dart';
   ```

2. **Use descriptive field names:**
   ```dart
   @BleField(length: 2)
   final int heartRateBpm;  // Good
   ```

3. **Document byte layouts in comments:**
   ```dart
   // BLE Protocol:
   // Byte 0: Flags
   // Bytes 1-2: Heart Rate (uint16, little endian)
   // Bytes 3-4: Energy Expended (uint16, little endian)
   ```

4. **Validate data length:**
   ```dart
   static MyPacket fromBytes(List<int> data) {
     if (data.length < expectedLength) {
       throw ArgumentError('Insufficient data');
     }
     return _$MyPacketFromBytes(data);
   }
   ```

5. **Use defaults to reduce repetition:**
   ```dart
   // Good - uses defaults
   @BleObject(endian: Endian.little, signed: true)
   class Sensor {
     @BleField(length: 2)  // Uses defaults
     final int temp;
   }

   // Verbose - repeats values
   @BleObject()
   class Sensor {
     @BleField(length: 2, endian: Endian.little, signed: true)
     final int temp;
   }
   ```

---

## Complete Example

```dart
import 'package:ble_parser/ble_parser.dart';
part 'device_status.g.dart';

/// BLE Device Status Packet
/// Byte layout:
/// - Byte 0: Device ID (uint8)
/// - Bytes 1-2: Temperature (int16, little endian, °C × 100)
/// - Bytes 3-4: Humidity (uint16, little endian, % × 100)
/// - Bytes 5-8: Timestamp (uint32, little endian, Unix epoch)
@BleObject(endian: Endian.little)
class DeviceStatus {
  @BleField(length: 1)
  final int deviceId;

  @BleField(length: 2, signed: true)
  final int temperature;  // int16, divide by 100 for actual value

  @BleField(length: 2)
  final int humidity;  // uint16, divide by 100 for actual value

  @BleField(length: 4)
  final int timestamp;  // uint32, Unix timestamp

  const DeviceStatus({
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  /// Parse from raw BLE data
  factory DeviceStatus.fromBytes(List<int> data) {
    if (data.length < 9) {
      throw ArgumentError('Invalid data length: expected 9, got ${data.length}');
    }
    return _$DeviceStatusFromBytes(data);
  }

  /// Get temperature in Celsius
  double get temperatureInC => temperature / 100.0;

  /// Get humidity in percent
  double get humidityInPercent => humidity / 100.0;

  /// Get DateTime from timestamp
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  @override
  String toString() {
    return 'DeviceStatus(deviceId: $deviceId, '
           'temp: ${temperatureInC}°C, '
           'humidity: ${humidityInPercent}%, '
           'time: $dateTime)';
  }
}

// Usage
void main() {
  // Raw BLE data from device
  final data = [
    0x01,              // deviceId = 1
    0x58, 0x02,        // temperature = 600 (6.00°C)
    0x10, 0x27,        // humidity = 10000 (100.00%)
    0x00, 0x00, 0x00, 0x01,  // timestamp = 1672531200 (Jan 1, 2023)
  ];

  final status = DeviceStatus.fromBytes(data);
  print(status);
  // Output: DeviceStatus(deviceId: 1, temp: 6.00°C, humidity: 100.00%, time: 2023-01-01 00:00:00.000)
}
```

---

For more examples, see the `/example` directory in the package repository.