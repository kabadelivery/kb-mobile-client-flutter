import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String token;
  final int receiverId;

  const ChatPage({super.key, required this.token, required this.receiverId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  File? _pickedImage;

  final String messagesQuery = """
    query MessagesByUser(\$receiverId: Int!) {
      messagesByUser(receiverId: \$receiverId) {
        id
        text
        imageUrl
        senderId
        receiverId
        createdAt
      }
    }
  """;

  final String sendMessageMutation = """
    mutation CreateMessage(\$receiverId: Int!, \$text: String, \$imageUrl: String) {
      createMessage(receiverId: \$receiverId, text: \$text, imageUrl: \$imageUrl) {
        id
        text
        imageUrl
        senderId
        receiverId
        createdAt
      }
    }
  """;

  final String messageSentSubscription = """
    subscription MessageSent(\$receiverId: Int!) {
      messageSent(receiverId: \$receiverId) {
        id
        text
        imageUrl
        senderId
        receiverId
        createdAt
      }
    }
  """;

  // Pick image using image_picker
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink('https://793ae8bdb95e.ngrok-free.app/graphql',
        defaultHeaders: {"Authorization": widget.token});

    final WebSocketLink wsLink = WebSocketLink(
      'ws://793ae8bdb95e.ngrok-free.app/graphql',
      config: SocketClientConfig(
        initialPayload: () => {"authorization": widget.token},
        autoReconnect: true,
      ),
    );

    final Link link = Link.split((request) => request.isSubscription, wsLink, httpLink);

    final GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );

    return GraphQLProvider(
      client: ValueNotifier(client),
      child: Scaffold(
        appBar: AppBar(title: const Text("Chat Support")),
        body: Column(
          children: [
            Expanded(
              child: Query(
                options: QueryOptions(
                  document: gql(messagesQuery),
                  variables: {"receiverId": widget.receiverId},
                  fetchPolicy: FetchPolicy.networkOnly,
                ),
                builder: (result, {fetchMore, refetch}) {
                  if (result.hasException) {
                    return Center(child: Text(result.exception.toString()));
                  }

                  if (result.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = result.data!['messagesByUser'] as List<dynamic>;

                  return Subscription(
                    options: SubscriptionOptions(
                      document: gql(messageSentSubscription),
                      variables: {"receiverId": widget.receiverId},
                    ),
                    builder: (subResult) {
                      List<dynamic> updatedMessages = List.from(messages);
                      if (subResult.data != null) {
                        updatedMessages.add(subResult.data!['messageSent']);
                      }

                      // Scroll to bottom
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                        }
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: updatedMessages.length,
                        itemBuilder: (context, index) {
                          final msg = updatedMessages[index];
                          bool isMe = msg['senderId'].toString() == widget.token; // or use actual userId

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (msg['text'] != null)
                                    Text(
                                      msg['text'],
                                      style: TextStyle(color: isMe ? Colors.red : Colors.black),
                                    ),
                                  if (msg['imageUrl'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Image.network(msg['imageUrl']),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            if (_pickedImage != null)
              Container(
                margin: const EdgeInsets.all(8),
                height: 100,
                child: Image.file(_pickedImage!),
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: "Type a message"),
                  ),
                ),
                Mutation(
                  options: MutationOptions(
                    document: gql(sendMessageMutation),
                  ),
                  builder: (runMutation, mutationResult) => IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      String? imageUrl;
                      if (_pickedImage != null) {
                        // Upload image to your server or S3 and get URL
                        // For demo, we use a placeholder
                        imageUrl = "https://via.placeholder.com/150";
                      }

                      if (_messageController.text.isEmpty && imageUrl == null) return;

                      runMutation({
                        "receiverId": widget.receiverId,
                        "text": _messageController.text,
                        "imageUrl": imageUrl,
                      });

                      setState(() {
                        _messageController.clear();
                        _pickedImage = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
