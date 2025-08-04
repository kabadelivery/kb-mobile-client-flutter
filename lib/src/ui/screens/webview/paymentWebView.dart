import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;
  final Function(bool success)? onPaymentComplete;

  const WebViewScreen({
    Key? key,
    required this.url,
    required this.title,
    this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
              hasError = false;
              errorMessage = '';
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            _checkPaymentCompletion(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            _checkPaymentCompletion(request.url);
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              hasError = true;
              isLoading = false;
              errorMessage = '${error.errorCode}: ${error.description}';
            });
            Navigator.pop(context);
            widget.onPaymentComplete?.call(false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _checkPaymentCompletion(String url) {
    if (url.contains('success') ||
        url.contains('successful') ||
        url.contains('payment_success') ||
        url.contains('transaction_success') ||
        url.contains('completed') ||
        url.contains('success.html') ||
        url.contains('success.php')) {
      widget.onPaymentComplete?.call(true);
    } else if (url.contains('failure') ||
        url.contains('failed') ||
        url.contains('error') ||
        url.contains('cancel') ||
        url.contains('cancelled') ||
        url.contains('failure.html') ||
        url.contains('failure.php')) {
      widget.onPaymentComplete?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: KabaChineColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                hasError = false;
                errorMessage = '';
              });
              controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!hasError)
            WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                color:  KabaChineColors.primary,
              ),
            ),
          if (hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, size: 48, color:  KabaChineColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: KabaChineColors.primary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          hasError = false;
                          errorMessage = '';
                          isLoading = true;
                        });
                        controller.reload();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
