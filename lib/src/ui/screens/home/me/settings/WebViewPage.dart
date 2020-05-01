import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:webview_flutter/webview_flutter.dart';


class WebViewPage extends StatefulWidget {

  static var routeName = "/WebViewPage";

  WebViewPage({Key key, this.title="CGU", this.link="http://app1.kaba-delivery.com/page/cgu"}) : super(key: key);

  final String title, link;

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {

  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  bool _pageLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(brightness: Brightness.light, leading: IconButton(
            icon: Icon(Icons.arrow_back, color: KColors.primaryColor),
            onPressed: () {
              Navigator.pop(context);
            }),
            backgroundColor: Colors.white,
            title: Text(
                widget.title, style: TextStyle(color: KColors.primaryColor))),
        body: Stack(
          children: <Widget>[
           _pageLoading ? Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(KColors.primaryColor)))) : Container(),
            Builder(builder: (BuildContext context) {
              return WebView(
                initialUrl: '${widget.link}',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },
                javascriptChannels: <JavascriptChannel>[
//              _toasterJavascriptChannel(context),
                ].toSet(),
                navigationDelegate: (NavigationRequest request) {
                  if (!request.url.contains("kaba") && !request.url.contains("pay")) {
                    print('blocking navigation to $request}');
                    return NavigationDecision.prevent;
                  }
                  print('allowing navigation to $request');
                  return NavigationDecision.navigate;
                },
                onPageStarted: (String url) {
                  print('Page started loading: $url');
                setState(() {
                  _pageLoading = true;
                });
                },
                onPageFinished: (String url) {
                  setState(() {
                    _pageLoading = false;
                  });
                  print('Page finished loading: $url');
                },
                gestureNavigationEnabled: true,
              );
            }),
          ],
        )
    );
  }



}
