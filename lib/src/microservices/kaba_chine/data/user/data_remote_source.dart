
import 'dart:convert';

import 'package:KABA/src/microservices/kaba_chine/data/user/user_model.dart';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> verifyUser(String phoneNumber);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> verifyUser(String phoneNumber) async {
    final url = Uri.parse('$LINK_VERIFY_USER');

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'identifier': phoneNumber}),
    );

    if (response.statusCode == 404) {
      throw Exception('Cet utilisateur n\'existe pas.');
    }
    if (response.statusCode != 200) {
      throw Exception('Erreur réseau: ${response.statusCode}');
    }
    final jsonData = json.decode(response.body);

    if (jsonData == null || (!jsonData['exists'] && jsonData['nickname'] == null)) {
      throw Exception('Utilisateur non trouvé');
    }
    return UserModel(
      customer_code: jsonData['clientCode'],
      name: jsonData['nickname'],
      phone_number: jsonData['phoneNumber'],
    );
  }
}