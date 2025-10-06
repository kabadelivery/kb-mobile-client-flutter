import 'package:flutter/material.dart';

class OwnMessageCard extends StatelessWidget {
  final String message;
  final String messageType;

  final String time; // "text" or "image"

  const OwnMessageCard({
    super.key,
    required this.message,
    this.messageType = "text",  required this.time,
  });

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
          color: const Color(0xffdcf8c6),
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 80, top: 10, bottom: 20),
                child: messageType == "image"
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    message,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        "📷 Image not available",
                        style: TextStyle(color: Colors.grey),
                      );
                    },
                  ),
                )
                    : Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 10,
                child: Row(
                  children:  [
                    Text(time, style: TextStyle(fontSize: 13, color: Colors.grey)),
                    SizedBox(width: 5),
                    Icon(Icons.done_all, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
