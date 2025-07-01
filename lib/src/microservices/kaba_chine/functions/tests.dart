import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';

Future<void> getDeliveries() async {
  final String url = LINK_GET_DELIVERIES;

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Successfully got data
      final data = json.decode(response.body);
      print('Deliveries: $data');
    } else {
      // Server returned an error
      print('Failed to load deliveries. Status: ${response.statusCode}');
    }
  } catch (e) {
    // Error during the request
    print('Error: $e');
  }
}