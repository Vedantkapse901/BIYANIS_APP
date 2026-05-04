import 'package:hive_flutter/hive_flutter.dart';

part 'user_model.g.dart';

@HiveType(typeId: 4)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final String? phone;

  @HiveField(5)
  final String? serialId; // e.g. '001'

  @HiveField(6)
  final String? pin; // 4-digit quick login PIN

  @HiveField(7)
  final String? batch;

  @HiveField(8)
  final String? branch;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.serialId,
    this.pin,
    this.batch,
    this.branch,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      phone: json['phone'],
      serialId: json['serial_id'],
      pin: json['pin'],
      batch: json['batch'],
      branch: json['branch'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'serial_id': serialId,
      'pin': pin,
      'batch': batch,
      'branch': branch,
    };
  }
}
