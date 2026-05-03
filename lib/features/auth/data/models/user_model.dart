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

  UserModel({
    required this.id,
    required this.name,
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
  }
}
