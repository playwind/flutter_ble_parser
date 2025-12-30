# BLE Parser

A Dart/Flutter code generation library for parsing Bluetooth Low Energy (BLE) byte data into typed objects.

## Features

- **Annotation-driven**: Use simple annotations to define data structure
- **Type-safe**: Automatically generates parsing code at compile time
- **Flexible**: Supports multiple integer sizes, byte orders, and nested objects
- **Easy to use**: Just annotate your data models and run code generation

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  ble_parser: any

dev_dependencies:
  build_runner: any
```

Then run:

```bash
dart pub get
```

## Annotations

### @BleObject()

Marks a class as a BLE data object. Used at the class level.

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `endian` | `Endian` | `Endian.little` | Default byte order for all fields |
| `signed` | `bool` | `false` | Default signed flag for all integer fields |

**Example:**

```dart
@BleObject(endian: Endian.little, signed: true)
class MySensorData {
  // fields here
}
```

### @BleField()

Marks a field for BLE data parsing. Used on class fields.

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `length` | `int` | **Yes** | - | Field length in bytes (1, 2, 4, or 8) |
| `offset` | `int?` | No | `null` | Force specific byte offset (auto-calculated if null) |
| `endian` | `Endian?` | No | `null` | Byte order (null = use default from @BleObject) |
| `signed` | `bool?` | No | `null` | Whether integer is signed (null = use default from @BleObject) |
| `objectType` | `Type?` | No | `null` | Nested object type (required for nested objects) |

**Supported Lengths:**

- `1` byte → `int8`/`uint8`
- `2` bytes → `int16`/`uint16`
- `4` bytes → `int32`/`uint32`
- `8` bytes → `int64`/`uint64`
- Other values → Returns `List<int>` (raw bytes)

## Quick Start

### Step 1: Define your data model

```dart
import 'package:ble_parser/ble_parser.dart';
part 'my_sensor.g.dart';  // Required part directive

@BleObject()
class HeartRatePacket {
  @BleField(length: 1)
  final int flags;

  @BleField(length: 2)
  final int heartRateValue;

  @BleField(length: 2, offset: 4)  // Skip to byte 4
  final int energyExpended;

  HeartRatePacket({
    required this.flags,
    required this.heartRateValue,
    required this.energyExpended,
  });

  static HeartRatePacket fromBytes(List<int> data) {
    return _$HeartRatePacketFromBytes(data);
  }
}
```

### Step 2: Generate code

```bash
dart run build_runner build
```

### Step 3: Use the generated parser

```dart
void main() {
  // Raw BLE data
  final bleData = [0x06, 0x78, 0x00, 0x00, 0x05, 0x00];

  // Parse into typed object
  final packet = HeartRatePacket.fromBytes(bleData);

  print('Heart Rate: ${packet.heartRateValue} BPM');
  print('Energy: ${packet.energyExpended}');
}
```

## Usage Examples

### Example 1: Basic Usage with Default Endian

```dart
@BleObject(endian: Endian.little)
class SensorData {
  @BleField(length: 1)
  final int sensorId;

  @BleField(length: 2)  // Uses default endian
  final int temperature;

  @BleField(length: 4)  // Uses default endian
  final int timestamp;

  SensorData({
    required this.sensorId,
    required this.temperature,
    required this.timestamp,
  });

  static SensorData fromBytes(List<int> data) {
    return _$SensorDataFromBytes(data);
  }
}
```

### Example 2: Signed Integers

```dart
@BleObject(endian: Endian.little, signed: true)
class EnvironmentalSensor {
  @BleField(length: 2)  // int16, can be negative
  final int temperature;  // Range: -32768 to 32767

  @BleField(length: 2)  // int16, can be negative
  final int pressure;    // Range: -32768 to 32767

  @BleField(length: 4, signed: false)  // Override: uint32
  final int timestamp;

  EnvironmentalSensor({
    required this.temperature,
    required this.pressure,
    required this.timestamp,
  });

  static EnvironmentalSensor fromBytes(List<int> data) {
    return _$EnvironmentalSensorFromBytes(data);
  }
}
```

### Example 3: Mixed Byte Orders

```dart
@BleObject(endian: Endian.big)  // Default is big endian
class NetworkPacket {
  @BleField(length: 2)  // Uses big endian
  final int packetId;

  @BleField(length: 4, endian: Endian.little)  // Override: little endian
  final int payloadSize;

  @BleField(length: 1)
  final int flags;

  NetworkPacket({
    required this.packetId,
    required this.payloadSize,
    required this.flags,
  });

  static NetworkPacket fromBytes(List<int> data) {
    return _$NetworkPacketFromBytes(data);
  }
}
```

### Example 4: Nested Objects

```dart
// Inner object
@BleObject(endian: Endian.little)
class SensorData {
  @BleField(length: 2)
  final int temperature;

  @BleField(length: 2)
  final int humidity;

  SensorData({
    required this.temperature,
    required this.humidity,
  });

  static SensorData fromBytes(List<int> data) {
    return _$SensorDataFromBytes(data);
  }
}

// Outer object containing nested data
@BleObject(endian: Endian.little)
class DevicePacket {
  @BleField(length: 1)
  final int deviceId;

  @BleField(length: 4, objectType: SensorData)  // Nested object
  final SensorData sensorData;

  @BleField(length: 4)
  final int timestamp;

  DevicePacket({
    required this.deviceId,
    required this.sensorData,
    required this.timestamp,
  });

  static DevicePacket fromBytes(List<int> data) {
    return _$DevicePacketFromBytes(data);
  }
}

// Usage
void main() {
  final data = [
    0x01,              // deviceId
    0x34, 0x12,        // temperature
    0x78, 0x56,        // humidity
    0x44, 0x33, 0x22, 0x11,  // timestamp
  ];

  final packet = DevicePacket.fromBytes(data);
  print('Device: ${packet.deviceId}');
  print('Temp: ${packet.sensorData.temperature}');
  print('Humidity: ${packet.sensorData.humidity}');
}
```

### Example 5: Manual Offset Control

```dart
@BleObject()
class SparseData {
  @BleField(length: 1, offset: 0)
  final int byte0;

  @BleField(length: 2, offset: 4)  // Skip bytes 2-3
  final int valueAt4;

  @BleField(length: 4, offset: 10)  // Skip bytes 6-9
  final int valueAt10;

  SparseData({
    required this.byte0,
    required this.valueAt4,
    required this.valueAt10,
  });

  static SparseData fromBytes(List<int> data) {
    return _$SparseDataFromBytes(data);
  }
}
```

### Example 6: Raw Bytes

For custom data lengths, the parser returns raw bytes:

```dart
@BleObject()
class CustomData {
  @BleField(length: 1)
  final int header;

  @BleField(length: 3)  // Returns List<int>
  final List<int> customData;

  @BleField(length: 1)
  final int checksum;

  CustomData({
    required this.header,
    required this.customData,
    required this.checksum,
  });

  static CustomData fromBytes(List<int> data) {
    return _$CustomDataFromBytes(data);
  }
}
```

## Generated Code

The builder generates a `_<ClassName>FromBytes` function that you can use to parse raw BLE data.

**Example generated code:**

```dart
HeartRatePacket _$HeartRatePacketFromBytes(List<int> rawData) {
  final view = ByteData.sublistView(Uint8List.fromList(rawData));
  return HeartRatePacket(
    flags: view.getUint8(0),
    heartRateValue: view.getUint16(1, Endian.little),
    energyExpended: view.getUint16(4, Endian.little)
  );
}
```

## Development Commands

```bash
# Generate code once
dart run build_runner build

# Watch for changes and regenerate
dart run build_runner watch

# Clean generated files
dart run build_runner clean

# Run tests
dart test

# Static analysis
dart analyze
```

## Byte Order (Endianness)

- **Little Endian** (`Endian.little`): Least significant byte first (common in BLE)
  - Example: `0x1234` stored as `[0x34, 0x12]`
- **Big Endian** (`Endian.big`): Most significant byte first (network byte order)
  - Example: `0x1234` stored as `[0x12, 0x34]`

## Common Pitfalls

1. **Missing part directive**: Always add `part 'filename.g.dart';` to your model files
2. **Length mismatch**: Ensure the `length` parameter matches your actual data length
3. **Offset alignment**: When using manual offsets, ensure fields don't overlap
4. **Nested object length**: For nested objects, `length` must match the total size of all nested fields
5. **Signed vs Unsigned**: Be careful with negative values - ensure `signed` is set correctly

## Advanced Tips

### Calculating Nested Object Size

When using nested objects, you must manually calculate the total length:

```dart
class InnerData {
  @BleField(length: 2)  // 2 bytes
  final int field1;

  @BleField(length: 4)  // 4 bytes
  final int field2;

  // Total = 6 bytes
}

class OuterData {
  @BleField(length: 6, objectType: InnerData)  // Must be 6
  final InnerData inner;
}
```

### Auto-offset vs Manual Offset

```dart
// Auto-offset: fields placed consecutively
@BleObject()
class Example1 {
  @BleField(length: 2)  // offset 0
  final int a;

  @BleField(length: 2)  // offset 2
  final int b;

  @BleField(length: 4)  // offset 4
  final int c;
}

// Manual offset: explicit control
@BleObject()
class Example2 {
  @BleField(length: 2)  // offset 0
  final int a;

  @BleField(length: 2, offset: 4)  // skip to offset 4
  final int b;

  @BleField(length: 4, offset: 10)  // skip to offset 10
  final int c;
}
```

## License

See LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.