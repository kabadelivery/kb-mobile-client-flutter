import 'package:KABA/src/ui/screens/home/me/MeNewAccountPage.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> messages = [
    {"text": "Bienvenue au Service client de Kaba 👋, how can I help you today?", "isUser": false},
    {"text": "J'ai une reclamation ?", "isUser": true},
  ];

  final TextEditingController _controller = TextEditingController();
  bool isTyping = false; // 👈 state for typing indicator

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      messages.add({"text": _controller.text, "isUser": true});
      isTyping = true; // bot starts typing
      _controller.clear();
    });

    // Fake bot reply
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isTyping = false;
        messages.add({
          "text": "Veuillez patienter pendant que nous traitons votre demande.",
          "isUser": false,
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: KColors.primaryColor,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: (){
              Navigator.pop(context); // close the bottom sheet
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MeNewAccountPage(),
                ),
              ); 
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/kaba_logo.png'),
              radius: 18,
              backgroundColor: Colors.white,
            ),
            SizedBox(width: 8),
            Text('Service Client', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (isTyping && index == messages.length) {
                  // Typing indicator bubble
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Dot(),
                          SizedBox(width: 4),
                          Dot(),
                          SizedBox(width: 4),
                          Dot(),
                        ],
                      ),
                    ),
                  );
                }

                final msg = messages[index];
                bool isUser = msg["isUser"];
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green[400] : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft:
                            Radius.circular(isUser ? 16 : 0),
                        bottomRight:
                            Radius.circular(isUser ? 0 : 16),
                      ),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input area
          SafeArea(
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Tapez votre message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: sendMessage,
                    child: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.send, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// 👇 Small animated dot widget
class Dot extends StatefulWidget {
  @override
  _DotState createState() => _DotState();
}

class _DotState extends State<Dot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _animation =
        Tween<double>(begin: 0.3, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
