class Staff {
  final String staffId;
  final String name;
  final int age;
  final String phoneNumber;
  final String email;
  final String password;

  Staff({
    required this.staffId,
    required this.name,
    required this.age,
    required this.phoneNumber,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'name': name,
      'age': age,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
    };
  }

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      staffId: json['staffId'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }
}
