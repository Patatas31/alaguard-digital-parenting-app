import 'package:cloud_firestore/cloud_firestore.dart';

class LinkingSession {
  final String id;
  final String parentId;
  final String childId;
  final String childName;
  final int childAge;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;
  final String? deviceName;

  LinkingSession({
    required this.id,
    required this.parentId,
    required this.childId,
    required this.childName,
    required this.childAge,
    required this.createdAt,
    required this.expiresAt,
    this.isUsed = false,
    this.deviceName,
  });

  factory LinkingSession.fromMap(Map<String, dynamic> map, String id) {
    return LinkingSession(
      id: id,
      parentId: map['parentId'] ?? '',
      childId: map['childId'] ?? '',
      childName: map['childName'] ?? '',
      childAge: map['childAge'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
      isUsed: map['isUsed'] ?? false,
      deviceName: map['deviceName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'childId': childId,
      'childName': childName,
      'childAge': childAge,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isUsed': isUsed,
      'deviceName': deviceName,
    };
  }

  bool get isExpired => expiresAt.isBefore(DateTime.now());
}
