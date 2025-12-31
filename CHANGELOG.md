## 1.1.0

### Features
- **Type Inference**: Automatically infer parsing method based on Dart field type
  - `int` fields → Automatically parsed as uint8/int8/uint16/int16/uint32/int32 based on `length` and `signed` parameters
  - `double` fields → Automatically parsed as float32 (4 bytes) or float64 (8 bytes)
  - `String` fields → Automatically decoded from ASCII/Latin-1 using `String.fromCharCodes()`
- **Dual Input Type Support**:
  - `fromBytesUint8(Uint8List)` - Zero-copy parsing, recommended for BLE devices
  - `fromBytes(List<int>)` - Compatibility wrapper with automatic conversion

### Improvements
- **String Type Implementation**: Now uses `String.fromCharCodes()` instead of `utf8.decode()`
  - ✅ No imports required (works out of the box)
  - ✅ Supports ASCII and Latin-1 characters (0-255)
  - ✅ Perfect for BLE protocols (device names, UUIDs, commands)
  - ⚠️ Does not support UTF-8 multibyte characters (Chinese, emoji, etc.)

### Documentation
- Added comprehensive type inference documentation in README.md and API_REFERENCE.md
- Clarified String type support and limitations
- Added character support table and usage examples

### Testing
- Improved project structure: separated examples from comprehensive tests
- Added test suite for type inference (int, double, String)
- Added test suite for nested objects with signed/unsigned integers
- All 9 tests passing

### Examples
- `example/` - Simple, beginner-friendly examples (HeartRatePacket)
- `test/` - Comprehensive test coverage with various data types and scenarios

## 1.0.0

- Initial version.
