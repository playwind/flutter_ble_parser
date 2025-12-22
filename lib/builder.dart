import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'src/annotations.dart'; // 引入上面的注解

// 入口方法
Builder bleParserBuilder(BuilderOptions options) =>
    SharedPartBuilder([BleParserGenerator()], 'ble_parser');

class BleParserGenerator extends GeneratorForAnnotation<BleObject> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {

    if (element is! ClassElement) throw '只能在 class 上使用 @BleObject';

    final className = element.name;
    print('Generating parser for class: $className'); // Debug output
    final buffer = StringBuffer();

    // 生成私有的解析函数： _$ClassNameFromBytes
    // 这样用户在类里就可以调用它
    buffer.writeln('$className _\$${className}FromBytes(List<int> rawData) {');
    buffer.writeln('  final view = ByteData.sublistView(Uint8List.fromList(rawData));');

    int autoOffset = 0; // 自动维护的游标
    List<String> constructorArgs = [];

    // 遍历构造函数参数（这就要求你的类必须有命名参数的构造函数）
    // 这里简化逻辑：我们遍历类的所有字段
    for (var field in element.fields) {
      if (field.isStatic) continue; // 跳过静态变量

      // 获取 @BleField 注解
      final fieldAnn = _getAnnotation(field);
      if (fieldAnn == null) continue; // 没加注解的字段跳过

      // 1. 确定偏移量
      int currentOffset = fieldAnn.offset ?? autoOffset;

      // 2. 生成读取代码
      String readExpr = _genReadExpr(fieldAnn, currentOffset);

      // 3. 存入构造函数参数列表
      constructorArgs.add('${field.name}: $readExpr');

      // 4. 更新自动游标 (根据类型大小)
      autoOffset = currentOffset + _getTypeSize(fieldAnn);
    }

    // 生成 return 语句
    buffer.writeln('  return $className(');
    buffer.writeln(constructorArgs.join(',\n'));
    buffer.writeln('  );');
    buffer.writeln('}');

    return buffer.toString();
  }

  // 获取注解数据的辅助方法
  _BleFieldData? _getAnnotation(FieldElement field) {
    for (var metadata in field.metadata) {
      final annotation = metadata.computeConstantValue();
      final annotationType = annotation?.type?.getDisplayString(withNullability: false);

      if (annotationType == 'BleField') {
        final typeChecker = TypeChecker.fromRuntime(BleField);
        if (typeChecker.isExactlyType(annotation!.type!)) {
          final reader = ConstantReader(annotation);

          // 读取 type 参数 - 修复枚举值提取
          final typeReader = reader.read('type');
          String typeName;
          if (typeReader.isNull) {
            typeName = 'BleType.uint8'; // 默认值
          } else {
            // 使用 objectValue 获取枚举值，然后解析枚举名称
            final enumObj = typeReader.objectValue;
            final enumStr = enumObj.toString();
            // 从 "BleType (_name = String ('uint8'); index = int (0))" 中提取 'uint8'
            final match = RegExp(r"name = String \('([^']+)'\)").firstMatch(enumStr);
            if (match != null) {
              typeName = 'BleType.${match.group(1)}';
            } else {
              typeName = 'BleType.uint8'; // 默认值
            }
          }

          // 读取 offset 参数（可选）
          int? offset;
          if (!reader.read('offset').isNull) {
            offset = reader.read('offset').intValue;
          }

          // 读取 endian 参数（可选） - 修复 Endian 枚举值提取
          String endian = 'Endian.big';
          if (!reader.read('endian').isNull) {
            final endianReader = reader.read('endian');
            final endianObj = endianReader.objectValue;
            final endianStr = endianObj.toString();
            // 从 "Endian (_littleEndian = bool (true))" 中提取 boolean
            final littleEndianMatch = RegExp(r"littleEndian = bool \((true|false)\)").firstMatch(endianStr);
            if (littleEndianMatch != null && littleEndianMatch.group(1) == 'true') {
              endian = 'Endian.little';
            } else {
              endian = 'Endian.big';
            }
          }

          // 读取 objectType 参数（当 type 为 object 时）
          String? objectType;
          if (typeName == 'BleType.object') {
            if (!reader.read('objectType').isNull) {
              // 如果用户明确指定了 objectType
              final objectTypeReader = reader.read('objectType');
              final objectTypeObj = objectTypeReader.objectValue;
              final objectTypeStr = objectTypeObj.toString();
              // 从 Type 对象中提取类型名称
              final typeMatch = RegExp(r"Type \(([^)]+)\)").firstMatch(objectTypeStr);
              if (typeMatch != null) {
                objectType = typeMatch.group(1);
              }
            } else {
              // 如果没有指定 objectType，使用字段的类型作为默认值
              objectType = field.type.getDisplayString(withNullability: false);
              print('  自动推断嵌套对象类型: $objectType');
            }
          }

          return _BleFieldData(typeName, offset, endian, objectType);
        }
      }
    }
    return null;
  }

  // 生成 ByteData 读取表达式
  String _genReadExpr(_BleFieldData data, int offset) {
    final endian = data.endian == 'Endian.little' ? 'Endian.little' : 'Endian.big';

    switch (data.type) {
      case 'BleType.uint8': return 'view.getUint8($offset)';
      case 'BleType.uint16': return 'view.getUint16($offset, $endian)';
      case 'BleType.uint32': return 'view.getUint32($offset, $endian)';
      case 'BleType.object':
        if (data.objectType != null) {
          // 为嵌套对象生成递归调用
          return '_\$${data.objectType}FromBytes(rawData.sublist($offset))';
        } else {
          throw 'BleType.object requires objectType parameter';
        }
    // 处理 String 等其他类型...
      default: return '0';
    }
  }

  int _getTypeSize(_BleFieldData data) {
    switch (data.type) {
      case 'BleType.uint8': return 1;
      case 'BleType.uint16': return 2;
      case 'BleType.uint32': return 4;
      case 'BleType.object':
        // 对于嵌套对象，我们需要计算其大小
        // 这是一个简化版本，实际应用中可能需要更复杂的逻辑
        // 或者要求用户为嵌套对象指定固定长度
        if (data.objectType != null) {
          // 这里假设我们知道 SensorData 的大小是 4 字节 (2+2)
          // 在实际应用中，这应该通过递归计算得出
          return _getObjectSize(data.objectType!);
        }
        return 0;
      default: return 0;
    }
  }

  // 获取嵌套对象的大小（简化版本）
  int _getObjectSize(String objectTypeName) {
    // 这是一个硬编码的简化版本
    // 在实际应用中，应该通过分析目标类的字段来动态计算大小
    switch (objectTypeName) {
      case 'SensorData':
        return 4; // 2字节温度 + 2字节湿度
      default:
        return 0; // 未知对象类型，返回0
    }
  }
}

// 简单的数据容器
class _BleFieldData {
  String type;
  int? offset;
  String endian;
  String? objectType; // 嵌套对象的类型名称
  _BleFieldData(this.type, this.offset, this.endian, [this.objectType]);
}