class UserModel {
  final String id;
  final String name;
  final String email;
  final String studentId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        studentId: json['student_id'],
      );
}
