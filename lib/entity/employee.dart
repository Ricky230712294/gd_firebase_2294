class Employee {
  final String? id;

  String name, email;
  String? phone;
  bool isDeleted;

  Employee({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'isDeleted': isDeleted,
      };

  static Employee fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        isDeleted: json['isDeleted'] ?? false,
      );
}