/// Represents an authenticated administrator or operator in the VMS.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String avatarInitials;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarInitials,
  });

  factory UserModel.mockAdmin() {
    return const UserModel(
      id: 'usr-001',
      name: 'Alex Johnson',
      email: 'admin@vms.corp',
      role: 'Fleet Manager',
      avatarInitials: 'AJ',
    );
  }
}
