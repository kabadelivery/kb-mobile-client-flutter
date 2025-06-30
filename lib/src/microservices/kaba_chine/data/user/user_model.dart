import 'package:KABA/src/microservices/kaba_chine/domain/user/user_entity.dart';

class UserModel extends UserEntity{
  UserModel({
    String? customer_code,
    String? name,
    String? phone_number,
  }) : super(
          customer_code: customer_code,
          name: name,
          phone_number: phone_number,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      customer_code: json['customer_code'],
      name: json['name'],
      phone_number: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_code': customer_code,
      'name': name,
      'phone_number': phone_number,
    };

  }

}