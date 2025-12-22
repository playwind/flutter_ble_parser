import 'dart:typed_data';

// 标记类
class BleObject {
  const BleObject();
}

// 支持的类型
enum BleType {
  uint8, int8,
  uint16, int16,
  uint32, int32,
  utf8String, // 定长字符串
  object, // 嵌套对象
}

// 标记字段
class BleField {
  final BleType type;
  final int? offset; // 强制指定偏移量（可选）
  final int length;  // 仅 String 需要
  final Endian endian;
  final Type? objectType; // 当 type 为 BleType.object 时，指定嵌套对象的类型

  const BleField({
    required this.type,
    this.offset,
    this.length = 0,
    this.endian = Endian.little,
    this.objectType,
  });
}