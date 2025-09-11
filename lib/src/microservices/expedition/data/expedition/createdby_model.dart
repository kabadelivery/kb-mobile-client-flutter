class CreatedByModel {
   String? id;
   String? email;
   String? password;
   String? name;
   String? role;
   DateTime? createdAt;
   DateTime? updatedAt;
  CreatedByModel({
     this.id,
     this.email,
     this.password,
     this.name,
     this.role,
     this.createdAt,
     this.updatedAt,
  });
  factory CreatedByModel.fromJson(Map<String, dynamic> json) {
    return CreatedByModel(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'password': password,
    'name': name,
    'role': role,
    'createdAt': createdAt!.toIso8601String(),
    'updatedAt': updatedAt!.toIso8601String(),
  };
}