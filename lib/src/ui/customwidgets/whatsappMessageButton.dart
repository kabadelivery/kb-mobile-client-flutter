import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget WhatsappMessageButton(String text, String phoneNumber) {
  void _sendMessage() async {
    final url = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(text)}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Could not launch $url");
    }
  }

  return GestureDetector(
    onTap: _sendMessage,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFF25D366).withOpacity(0.8), // Custom green
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
