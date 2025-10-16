import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OwnMessageCard extends StatelessWidget {
  final String message;
  final String messageType;
  final String senderName;
  final DateTime time;

  const OwnMessageCard({
    super.key,
    required this.message,
    this.messageType = "text",
    required this.senderName,
    required this.time,
  });

  bool _isLink(String text) {
    final urlRegExp = RegExp(
      r'((https?:\/\/)?([\w\-]+\.)+[a-zA-Z]{2,}(\/[\w\-._~:/?#\[\]@!$&\()*+,;=.]*?)?)',
      caseSensitive: false,
    );
    return urlRegExp.hasMatch(text.trim());
  }

  bool _isImageUrl(String text) {
    final lower = text.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  String _formatDateTime(DateTime dateTime) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    final formattedTime = DateFormat('HH:mm').format(dateTime);
    return '$formattedDate $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: const Color(0xffffffff),
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 80, top: 8, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🧍 Sender Name
                    Text(
                      senderName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // 📷 Image / 🔗 Link / 💬 Text
                    if (messageType == "image" || _isImageUrl(message))
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          message,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                              "Failed to load image",
                              style: TextStyle(color: Colors.red),
                            );
                          },
                        ),
                      )
                    else if (_isLink(message))
                      GestureDetector(
                        onTap: () async {
                          final url = message.startsWith("http")
                              ? message
                              : "https://$message";
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    else
                      Text(
                        message,
                        style: const TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              ),

              // 🕒 Date & Time
              Positioned(
                bottom: 4,
                right: 10,
                child: Text(
                  _formatDateTime(time),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
