class Users {
  final String idUser;
  final String name;
  final String email;
  final String password;
  final DateTime createdAt;

  Users({
    required this.idUser,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      idUser: json['idUser'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'name': name,
      'email': email,
      'password': password,
      'createdAt': createdAt,
    };
  }
}
