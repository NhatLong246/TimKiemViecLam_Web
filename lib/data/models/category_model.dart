import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String iconBase64;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconBase64,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? toDateTime(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return null;
    }

    return CategoryModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      iconBase64: map['iconBase64'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: toDateTime(map['createdAt']),
      updatedAt: toDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'iconBase64': iconBase64,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CategoryModel copyWith({
    String? name,
    String? description,
    String? iconBase64,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconBase64: iconBase64 ?? this.iconBase64,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
