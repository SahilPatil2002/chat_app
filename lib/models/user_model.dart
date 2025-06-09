import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? name;
  final String? email;
  final bool isOnline;
  final Timestamp? lastSeen;

  UserModel({
    required this.uid,
    this.name,
    this.email,
    required this.isOnline,
    this.lastSeen,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'],
      email: map['email'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
    };
  }
}
