class UserModel {
  final Map data;

  UserModel({required this.data});

  String get id => data['id'] ?? '';

  String get username => data['username'] ?? '';

  String get fullName => data['fullName'] ?? '';

  String get email => data['email'] ?? '';

  String get systemRole => data['system_role'] ?? '';

  List<String> get permissions => data['permissions'] ?? [];

  List<String> get features => data['features'] ?? [];
}