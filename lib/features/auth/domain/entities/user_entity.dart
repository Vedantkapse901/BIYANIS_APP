enum UserRole { student, teacher, parent, superAdmin }

class UserEntity {
  final String id;
  final String name;
  final String username;
  final String password;
  final UserRole role;
  final String? branch;
  final String? batch;
  final String? wardName;
  final String? wardId;

  UserEntity({
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
}
