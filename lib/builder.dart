// Copyright (c) 2025 BLE Parser Contributors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/annotations.dart';

// Entry point
Builder bleParserBuilder(BuilderOptions options) =>
    SharedPartBuilder([BleParserGenerator()], 'ble_parser');

class BleParserGenerator extends GeneratorForAnnotation<BleObject> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw '@BleObject can only be used on classes';
    }

    final className = element.name;
    print('Generating parser for class: $className');

    // Read default values from @BleObject annotation
    final defaultEndian = _readDefaultEndian(annotation);
    final defaultSigned = _readDefaultSigned(annotation);

    // Collect field information first
    int autoOffset = 0;
    List<String> constructorArgsUint8 = [];
    List<String> constructorArgsList = [];

    // Iterate through all fields
    for (var field in element.fields) {
      if (field.isStatic) continue;

      // Get @BleField annotation with defaults applied
      final fieldAnn = _getAnnotation(field, defaultEndian, defaultSigned);
      if (fieldAnn == null) continue;

      // 1. Determine offset
      int currentOffset = fieldAnn.offset ?? autoOffset;

      // 2. Generate read expressions for both Uint8List and List<int> versions
      String readExprUint8 = _genReadExpr(fieldAnn, currentOffset, true);
      String readExprList = _genReadExpr(fieldAnn, currentOffset, false);

      // 3. Store constructor arguments separately for each version
      constructorArgsUint8.add('${field.name}: $readExprUint8');
      constructorArgsList.add('${field.name}: $readExprList');

      // 4. Update auto offset
      autoOffset = currentOffset + fieldAnn.length;
    }

    final constructorBody = '  return $className(\n${constructorArgsUint8.join(',\n')}\n  );';
    final constructorBodyList = '  return $className(\n${constructorArgsList.join(',\n')}\n  );';

    final buffer = StringBuffer();

    // Generate Uint8List version (primary method, keeps original name)
    buffer.writeln('$className _\$${className}FromBytes(Uint8List rawData) {');
    buffer.writeln('  final view = ByteData.sublistView(rawData);');
    buffer.write(constructorBody);
    buffer.writeln('}');
    buffer.writeln('');

    // Generate List<int> version (additional method for compatibility)
    buffer.writeln('$className _\$${className}FromBytesList(List<int> rawData) {');
    buffer.writeln('  final view = ByteData.sublistView(Uint8List.fromList(rawData));');
    buffer.write(constructorBodyList);
    buffer.writeln('}');

    return buffer.toString();
  }

  // Read default endian from @BleObject annotation
  String _readDefaultEndian(ConstantReader annotation) {
    if (annotation.read('endian').isNull) {
      return 'Endian.little';
    }
    final endianReader = annotation.read('endian');
    final endianObj = endianReader.objectValue;
    final endianStr = endianObj.toString();
    final littleEndianMatch = RegExp(
      r"littleEndian = bool \((true|false)\)",
    ).firstMatch(endianStr);
    if (littleEndianMatch != null && littleEndianMatch.group(1) == 'true') {
      return 'Endian.little';
    } else {
      return 'Endian.big';
    }
  }

  // Read default signed from @BleObject annotation
  bool _readDefaultSigned(ConstantReader annotation) {
    if (annotation.read('signed').isNull) {
      return false;
    }
    return annotation.read('signed').boolValue;
  }

  // Helper method to get annotation data with defaults applied
  _BleFieldData? _getAnnotation(
    FieldElement field,
    String defaultEndian,
    bool defaultSigned,
  ) {
    for (var metadata in field.metadata) {
      final annotation = metadata.computeConstantValue();
      final annotationType = annotation?.type?.getDisplayString(
        withNullability: false,
      );

      if (annotationType == 'BleField') {
        final typeChecker = TypeChecker.fromRuntime(BleField);
        if (typeChecker.isExactlyType(annotation!.type!)) {
          final reader = ConstantReader(annotation);

          // Read length parameter (required)
          final lengthReader = reader.read('length');
          if (lengthReader.isNull) {
            throw 'Missing required parameter: length';
          }
          final int length = lengthReader.intValue;

          // Read offset parameter (optional)
          int? offset;
          if (!reader.read('offset').isNull) {
            offset = reader.read('offset').intValue;
          }

          // Read endian parameter - use default if null
          String endian = defaultEndian;
          if (!reader.read('endian').isNull) {
            final endianReader = reader.read('endian');
            final endianObj = endianReader.objectValue;
            final endianStr = endianObj.toString();
            final littleEndianMatch = RegExp(
              r"littleEndian = bool \((true|false)\)",
            ).firstMatch(endianStr);
            if (littleEndianMatch != null &&
                littleEndianMatch.group(1) == 'true') {
              endian = 'Endian.little';
            } else {
              endian = 'Endian.big';
            }
          }

          // Read signed parameter - use default if null
          bool signed = defaultSigned;
          if (!reader.read('signed').isNull) {
            signed = reader.read('signed').boolValue;
          }

          // Read objectType parameter (optional)
          String? objectType;
          if (!reader.read('objectType').isNull) {
            final objectTypeReader = reader.read('objectType');
            final objectTypeObj = objectTypeReader.objectValue;
            final objectTypeStr = objectTypeObj.toString();
            final typeMatch = RegExp(
              r"Type \(([^)]+)\)",
            ).firstMatch(objectTypeStr);
            if (typeMatch != null) {
              objectType = typeMatch.group(1);
            }
          }

          // Infer field type from the field's type
          String? fieldType;
          final fieldTypeStr = field.type.getDisplayString(withNullability: false);
          if (fieldTypeStr == 'int' || fieldTypeStr == 'double' || fieldTypeStr == 'String') {
            fieldType = fieldTypeStr;
          }

          return _BleFieldData(length, offset, endian, signed, objectType, fieldType);
        }
      }
    }
    return null;
  }

  // Generate ByteData read expression based on length and type
  String _genReadExpr(_BleFieldData data, int offset, bool isUint8List) {
    final endian = data.endian == 'Endian.little'
        ? 'Endian.little'
        : 'Endian.big';

    // Handle nested object
    if (data.objectType != null) {
      final methodName = isUint8List
          ? '_\$${data.objectType}FromBytes'
          : '_\$${data.objectType}FromBytesList';
      if (isUint8List) {
        return '$methodName(rawData.sublist($offset, ${offset + data.length}))';
      } else {
        return '$methodName(rawData.sublist($offset, ${offset + data.length}))';
      }
    }

    // Handle String type (using String.fromCharCodes - no import needed)
    if (data.fieldType == 'String') {
      return 'String.fromCharCodes(rawData.sublist($offset, ${offset + data.length}))';
    }

    // Handle double type (float32/float64)
    if (data.fieldType == 'double') {
      if (data.length == 4) {
        return 'view.getFloat32($offset, $endian)';
      } else if (data.length == 8) {
        return 'view.getFloat64($offset, $endian)';
      } else {
        throw 'Double type must be 4 or 8 bytes, got ${data.length}';
      }
    }

    // Handle integer types based on length
    switch (data.length) {
      case 1:
        return data.signed ? 'view.getInt8($offset)' : 'view.getUint8($offset)';
      case 2:
        return data.signed
            ? 'view.getInt16($offset, $endian)'
            : 'view.getUint16($offset, $endian)';
      case 4:
        return data.signed
            ? 'view.getInt32($offset, $endian)'
            : 'view.getUint32($offset, $endian)';
      case 8:
        if (data.signed) {
          return 'view.getInt64($offset, $endian)';
        } else {
          return 'view.getUint64($offset, $endian)';
        }
      default:
        // For other lengths, return bytes as sublist
        return 'rawData.sublist($offset, ${offset + data.length})';
    }
  }
}

// Simple data container
class _BleFieldData {
  int length;
  int? offset;
  String endian;
  bool signed;
  String? objectType;
  String? fieldType; // 'int', 'double', 'String', or null for auto

  _BleFieldData(
    this.length,
    this.offset,
    this.endian,
    this.signed, [
    this.objectType,
    this.fieldType,
  ]);
}
