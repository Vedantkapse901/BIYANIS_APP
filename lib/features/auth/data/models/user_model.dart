<<<<<<< HEAD
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
=======
import 'package:hive/hive.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@HiveType(typeId: 10)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String username;

  @HiveField(3)
  String password;

  @HiveField(4)
  String role; // 'student', 'teacher', 'parent', 'super_admin'

  @HiveField(5)
  String? branch;

  @HiveField(6)
  String? batch;

  @HiveField(7)
  String? wardName;

  @HiveField(8)
  String? wardId;
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1

  UserModel({
    required this.id,
    required this.name,
<<<<<<< HEAD
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
=======
    required this.username,
    required this.password,
    required this.role,
    this.branch,
    this.batch,
    this.wardName,
    this.wardId,
  });

  UserEntity toEntity() {
    UserRole userRole;
    if (role == 'super_admin') {
      userRole = UserRole.superAdmin;
    } else {
      userRole = UserRole.values.firstWhere((e) => e.toString().split('.').last == role);
    }
    
    return UserEntity(
      id: id,
      name: name,
      username: username,
      password: password,
      role: userRole,
      branch: branch,
      batch: batch,
      wardName: wardName,
      wardId: wardId,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    String roleStr = entity.role.toString().split('.').last;
    if (entity.role == UserRole.superAdmin) {
      roleStr = 'super_admin';
    }
    return UserModel(
      id: entity.id,
      name: entity.name,
      username: entity.username,
      password: entity.password,
      role: roleStr,
      branch: entity.branch,
      batch: entity.batch,
      wardName: entity.wardName,
      wardId: entity.wardId,
    );
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
  }
}
