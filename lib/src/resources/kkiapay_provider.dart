import 'dart:convert';
import 'dart:math';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kkiapay_flutter_sdk/kkiapay_flutter_sdk.dart';

class KkiapayProvider {
  String temp_transaction_id="";
  bool init_launch=true;
  bool success_launch=true;
  bool isMomo =true;
  void kkiapayCallback(BuildContext context, Map<String, dynamic> response, Map<String, dynamic> paymentData) {
    debugPrint('In call back');
    switch (response['status']) {
      case 'PAYMENT_CANCELLED':
        Navigator.pop(context);
        debugPrint("canceled response $response");
        debugPrint('PAYMENT_CANCELLED');
        break;
      case 'PAYMENT_INIT':
        debugPrint('PAYMENT_INIT');
        if(init_launch)
        _sendPendingTransactionData(context,response, paymentData);
        break;
      case 'PENDING_PAYMENT':
        debugPrint('PENDING_PAYMENT');
        break;
      case 'PAYMENT_SUCCESS':
        Navigator.pop(context);
        debugPrint('PAYMENT_SUCCESS');
        if(success_launch)
        _sendKkiapaySuccessData(response, context, paymentData);
      default:
        debugPrint('UNKNOWN_EVENT');
        break;
    }
  }

  Future<void>  _sendPendingTransactionData(BuildContext context,Map<String, dynamic> kkiapayResponse,Map<String, dynamic> paymentData) async {
    debugPrint("entered _sendPendingTransactionData");
    try {
      temp_transaction_id = generateTempTransaction()+"_"+paymentData['userId'];
      final transactionId = temp_transaction_id;
      final amount = kkiapayResponse['requestData']['amount'] ?? 0;
      debugPrint('transactionId $transactionId');
      debugPrint('amount $amount');
      debugPrint('kkiapayResponse $kkiapayResponse');
      String userId = paymentData['userId'] ?? '';
      double feesAmount = 0;
      Map<String, dynamic> pendingData = {
        'transaction_id': transactionId,
        'amount': amount,
        'user_id': int.tryParse(userId) ?? -1,
        'phone_number':kkiapayResponse['requestData']['phone']??null,
        'fees': feesAmount,
        'details': 'payment Kkiapay for user $userId',
        'is_momo': isMomo,
      };
      String apiUrl = ServerRoutes.KKIAPAY_STORE_TRANSACTION;
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(pendingData),
      );
      debugPrint('Pending transaction data ${response.body}');
      if (response.statusCode == 200) {
        debugPrint('Pending transaction data ${response.body}');
        init_launch=false;
       } else {

        debugPrint('Failed to send INIT request: ${response.statusCode} - ${response.body}');
        return;
      }
    } catch (e) {
      debugPrint('Error sending INIT request: $e');
      return;
    }
  }
   Future<void> _sendKkiapaySuccessData(Map<String, dynamic> kkiapayResponse, BuildContext context, Map<String, dynamic> paymentData) async {
    try {
      final transactionId = kkiapayResponse['transactionId'];
      final amount = kkiapayResponse['requestData']['amount'];
      debugPrint('transactionId ZZZ $transactionId');
      debugPrint('amount $amount');
      debugPrint('kkiapayResponse $kkiapayResponse');

      String userId = paymentData['userId'] ?? '';
      double feesAmount = 0;
      Map<String, dynamic> successData = {
        'status': 'success',
        'reference': temp_transaction_id,
        'kkiapay_transaction_id': transactionId,
        'amount': amount.toString(),
        'is_momo': isMomo,
      };
      debugPrint('success data: ${jsonEncode(successData)}');
      final response = await http.post(
        Uri.parse(ServerRoutes.KKIAPAY_CONFIRM_TRANSACTION),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(successData),
      );
      if (response.statusCode == 200) {
        success_launch = false;
        debugPrint('SUCCESS request sent to Semoa API successfully');
        debugPrint('context ${context.mounted}');
        if(context.mounted)
        Navigator.of(context).pop({"check_balance":true});
      } else {
        debugPrint('Failed to send SUCCESS request: ${response.statusCode} - ${response.body}');
        if(context.mounted)
        Navigator.of(context).pop({"check_balance":false});
      }
    } catch (e) {
      Navigator.of(context).pop({"check_balance":false});
      if(context.mounted)
      debugPrint('Error sending SUCCESS request: $e');
    }
  }

  void launchKkiapayPayment(BuildContext context,
        {required int amount, String? selectedCard, String? phone_number,
        required CustomerModel customer,
        required double feesAmount,
        required String typeOfTransaction}) async {
    Map<String, dynamic> paymentData = {
      "userId": customer.id.toString(),
      "feesAmount": feesAmount,
      "montant": amount,
      "selectedCard": selectedCard??"",
      "phone_number":phone_number
    };
    if(typeOfTransaction=="momo") {
      isMomo = true;
    } else {
      isMomo = false;
    }
    final kkiapay = KKiaPay(
      amount: amount,
      apikey: 'd991dc8063b911f08da44b2b59e422d0',
      sandbox: true,
      callback: (response, ctx) => kkiapayCallback(context,response,paymentData ),
      reason: typeOfTransaction=="momo"?"Recharge Mobile Money":'Recharge carte bancaire',
      phone: phone_number,
      name: customer.nickname.toString(),
      email: customer.email??"",
      data: '',
      partnerId: '',
      countries: ['TG', 'CI', 'BJ', 'BF', 'NE', 'GH', 'NG', 'SL', 'ML', 'MR', 'SN'],
      paymentMethods:[typeOfTransaction] ,
      theme: '#FFB81B3E',
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => kkiapay),
    );
  }
}

String generateTempTransaction({int length = 9}) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random.secure();

  return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
}
