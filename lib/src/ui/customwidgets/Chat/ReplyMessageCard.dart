import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ReplyMessageCard extends StatelessWidget {
  final String message;
  final String messageType; // 'text', 'image', 'link'
  final DateTime time;
  final String senderName;

  const ReplyMessageCard({
    Key? key,
    required this.message,
    required this.messageType,
    required this.time,
    required this.senderName,
  }) : super(key: key);

  bool _isLink(String text) {
    final urlRegExp = RegExp(
        r'^(https?:\/\/)?([\w\-]+\.)+[a-zA-Z]{2,}(:\d+)?(\/[\w\-._~:/?#[\]@!$&\()*+,;=]*)?$',
    );
    return urlRegExp.hasMatch(text);
    }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('HH:mm').format(time);
    final formattedDate = DateFormat('yyyy-MM-dd').format(time);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeMargin(),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: KColors.primaryColor,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender name
            Text(
              senderName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),

            // Message content
            if (messageType == "text" || _isLink(message)) ...[
              GestureDetector(
                onTap: _isLink(message) ? () => _launchUrl(message) : null,
                child: Text(
                  message,
                  style: TextStyle(
                    color: _isLink(message) ? Colors.white : Colors.white,
                    decoration: _isLink(message)
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                ),
              ),
            ] else if (messageType == "image") ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  message,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            const SizedBox(height: 5),

            // Time and date
            Text(
              "$formattedDate • $formattedTime",
              style: TextStyle(
                fontSize: 11,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EdgeMargin extends EdgeInsets {
  const EdgeMargin() : super.symmetric(vertical: 5, horizontal: 15);
}
