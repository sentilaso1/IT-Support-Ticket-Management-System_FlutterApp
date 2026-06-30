class UpdateUserRequestDto {
  const UpdateUserRequestDto({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.departmentId,
    this.phoneNumber,
    required this.isActive,
  });

  final int id;
  final String fullName;
  final String email;
  final String role;
  final int? departmentId;
  final String? phoneNumber;
  final bool isActive;

  Map<String, Object?> toMap(DateTime now) {
    return {
      'fullName': fullName,
      'email': email,
      'role': role,
      'departmentId': departmentId,
      'phoneNumber': phoneNumber,
      'isActive': isActive ? 1 : 0,
      'updatedAt': now.toIso8601String(),
    };
  }
}
