import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// --- GraphQL queries, mutations, subscriptions (inchangés) ---
const String GET_MSG = r'''
  query MessagesByUser($receiverId: Int!) {
    messagesByUser(receiverId: $receiverId) {
      id
      receiverId
      senderId
      text
      createdAt
    }
  }
''';

const String SEND_MSG = r'''
  mutation SendMessage($receiverId: Int!, $text: String!) {
    sendMessage(receiverId: $receiverId, text: $text) {
      id
      receiverId
      senderId
      text
      createdAt
    }
  }
''';

const String MSG_SUB = r'''
  subscription OnMessageSent($receiverId: Int!) {
    messageSent(receiverId: $receiverId) {
      id
      receiverId
      senderId
      text
      createdAt
    }
  }
''';

// --- ChatPage ---
class ChatPage extends StatefulWidget {
  final String token;
  final int receiverId;

  const ChatPage({
    super.key,
    required this.token,
    required this.receiverId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final GraphQLClient _client;
  late final TextEditingController _controller;
  late final int currentUserId; // ✅ ID extrait du token

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    // ✅ Décodage du token
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    currentUserId = decodedToken["userId"]; // dépend du payload de ton JWT

    // --- GraphQL setup ---
    final httpLink = HttpLink("https://53afc4e9691e.ngrok-free.app/graphql");

    final authLink = AuthLink(
      getToken: () async => widget.token,
      headerKey: "authorization",
    );

    final wsLink = WebSocketLink(
      "wss://53afc4e9691e.ngrok-free.app/graphql",
      config: SocketClientConfig(
        autoReconnect: true,
        initialPayload: () async {
          return {
            "authorization": widget.token,
          };
        },
      ),
    );

    final link = Link.split(
          (request) => request.isSubscription,
      wsLink,
      authLink.concat(httpLink),
    );

    _client = GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: link,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: ValueNotifier(_client),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Discussion"),
          backgroundColor: const Color(0xFFCD1F45),
        ),
        body: Column(
          children: [
            // --- Zone messages ---
            Expanded(
              child: Query(
                options: QueryOptions(
                  document: gql(GET_MSG),
                  variables: {"receiverId": widget.receiverId},
                  pollInterval: const Duration(seconds: 2),
                  fetchPolicy: FetchPolicy.networkOnly,
                ),
                builder: (result, {fetchMore, refetch}) {
                  if (result.isLoading && result.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (result.hasException) {
                    return Center(
                        child: Text("Erreur: ${result.exception.toString()}"));
                  }

                  final List messages =
                      result.data?["messagesByUser"] ?? [];

                  return Subscription(
                    options: SubscriptionOptions(
                      document: gql(MSG_SUB),
                      variables: {"receiverId": widget.receiverId},
                    ),
                    builder: (subResult) {
                      if (subResult.data != null) {
                        final msg = subResult.data!["messageSent"];
                        if (!messages.any((m) => m["id"] == msg["id"])) {
                          messages.add(msg);
                          messages.sort((a, b) =>
                              DateTime.parse(a["createdAt"])
                                  .compareTo(DateTime.parse(b["createdAt"])));
                        }
                      }

                      if (messages.isEmpty) {
                        return const Center(
                          child: Text("Aucun message pour le moment."),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: messages.length,
                        itemBuilder: (ctx, index) {
                          final msg = messages[index];
                          final bool isMe = msg["senderId"] == currentUserId;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFFCD1F45)
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg["text"],
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateTime.parse(msg["createdAt"])
                                        .toLocal()
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
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

            // --- Input en bas ---
            Mutation(
              options: MutationOptions(
                document: gql(SEND_MSG),
                onError: (err) => debugPrint("Erreur send: $err"),
              ),
              builder: (runMutation, result) {
                return SafeArea(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: "Écrire un message...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFFCD1F45)),
                          onPressed: () {
                            final text = _controller.text.trim();
                            if (text.isNotEmpty) {
                              runMutation({
                                "receiverId": widget.receiverId,
                                "text": text,
                              });
                              _controller.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
