// Copyright (c) 2025 BLE Parser Contributors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

// Marker class for BLE data objects
class BleObject {
  final Endian endian; // Default byte order for all fields
  final bool signed; // Default signed flag for all fields

  const BleObject({this.endian = Endian.little, this.signed = false});
}

// Marker class for BLE data fields
class BleField {
  final int length; // Field length in bytes (required)
  final int? offset; // Force specific offset (optional)
  final Endian? endian; // Byte order (null = use default from BleObject)
  final bool?
  signed; // Whether the integer is signed (null = use default from BleObject)
  final Type? objectType; // Nested object type (optional)

  const BleField({
    required this.length,
    this.offset,
    this.endian,
    this.signed,
    this.objectType,
  });
}
