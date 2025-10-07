import 'package:flutter/material.dart';

class ReplyMessageCard extends StatelessWidget {
  final String message;
  final String messageType; // "text" or "image"
  final String time;
  const ReplyMessageCard({
    super.key,
    required this.message,
    this.messageType = "text",  required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Color(0xffcb1f44),
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
                        style: TextStyle(color: Colors.white),
                      );
                    },
                  ),
                )
                    : Text(
                  message,
                  style: const TextStyle(fontSize: 16,color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 10,
                child: Row(
                  children: [
                    Text(time, style: TextStyle(fontSize: 13, color: Colors.white)),
                    SizedBox(width: 5),
                    Icon(Icons.done_all, size: 20,color: Colors.white,),
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
