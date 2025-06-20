import 'package:KABA/src/microservices/kaba_chine/presentation/pages/information_page.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/pages/order_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WelcomeToKabaChine extends StatefulWidget {
  static var routeName = "/WelcomeToKabaChine";

  const WelcomeToKabaChine({super.key});

  @override
  State<WelcomeToKabaChine> createState() => _WelcomeToKabaChineState();
}

class _WelcomeToKabaChineState extends State<WelcomeToKabaChine> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KabaChineOrderPage(),
    );
  }
}
