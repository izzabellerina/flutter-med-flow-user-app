class Patient {
  final String id;
  final String prefix;
  final String firstName;
  final String lastName;
  final String hn;
  final String phone;
  final int age;
  final String gender; // 'male' or 'female'
  final String? avatarUrl;

  Patient({
    required this.id,
    required this.prefix,
    required this.firstName,
    required this.lastName,
    required this.hn,
    required this.phone,
    required this.age,
    required this.gender,
    this.avatarUrl,
  });

  String get fullName => '$prefix$firstName $lastName';
}
