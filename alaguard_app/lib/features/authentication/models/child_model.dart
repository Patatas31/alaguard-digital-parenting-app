import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  final String id;
  final String parentId;
  final String name;
  final int age;
  final String deviceId;
  final String? deviceName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImage;

  ChildModel({
    required this.id,
    required this.parentId,
    required this.name,
    required this.age,
    required this.deviceId,
    this.deviceName,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.profileImage,
  });

  factory ChildModel.fromMap(Map<String, dynamic> map, String id) {
    return ChildModel(
      id: id,
      parentId: map['parentId'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      deviceId: map['deviceId'] ?? '',
      deviceName: map['deviceName'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      profileImage: map['profileImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'name': name,
      'age': age,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'profileImage': profileImage,
    };
  }
}
