enum UserRole {
  admin('admin'),
  staff('staff'),
  user('user');

  const UserRole(this.value);

  final String value;

  static UserRole fromValue(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.user,
    );
  }
}
