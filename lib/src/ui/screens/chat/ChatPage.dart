import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ChatPage extends StatefulWidget {
  final String token;
  const ChatPage({Key? key, required this.token}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ValueNotifier<GraphQLClient> client;

  @override
  void initState() {
    super.initState();

    /// ✅ HTTP link for queries & mutations
    final HttpLink httpLink = HttpLink(
      'https://793ae8bdb95e.ngrok-free.app/graphql',
      defaultHeaders: {
        "Authorization": widget.token,
      },
    );

    /// ✅ WebSocket link for subscriptions
    final WebSocketLink wsLink = WebSocketLink(
      'wss://793ae8bdb95e.ngrok-free.app/graphql',
      config: const SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
      ),
    );

    /// ✅ Combine HTTP + WS links
    final Link link = Link.split(
          (request) => request.isSubscription,
      wsLink,
      httpLink,
    );

    /// ✅ Create client
    client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(store: InMemoryStore()),
      ),
    );
  }

  /// Example query
  final String testQuery = r'''
    query Test {
      __typename
    }
  ''';

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("KABA Service Client"),
          backgroundColor: Colors.red.shade700,
        ),
        body: Query(
          options: QueryOptions(
            document: gql(testQuery),
          ),
          builder: (result, {fetchMore, refetch}) {
            if (result.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (result.hasException) {
              /// ✅ Handle errors gracefully
              return Center(
                child: Text(
                  "Error: ${result.exception!.graphqlErrors.isNotEmpty
                      ? result.exception!.graphqlErrors.map((e) => e.message).join(", ")
                      : "Invalid response from server"}",
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              );
            }

            /// ✅ Show result data
            return Center(
              child: Text(
                "Response: ${result.data.toString()}",
                style: const TextStyle(fontSize: 16),
              ),
            );
          },
        ),
      ),
    );
  }
}
