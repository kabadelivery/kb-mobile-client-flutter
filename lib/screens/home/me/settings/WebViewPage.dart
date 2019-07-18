import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';

import 'package:webview_flutter/webview_flutter.dart';


class WebViewPage extends StatefulWidget {

  static var routeName = "/WebViewPage";

  WebViewPage({Key key, this.title="CGU", this.link="http://app1.kaba-delivery.com/page/cgu"}) : super(key: key);

  final String title, link;

  @override
  _WebViewPageState createState() => _WebViewPageState(title: title, link:link);
}

class _WebViewPageState extends State<WebViewPage> {

  String link;
  String title;

  _WebViewPageState({this.title, this.link});

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(backgroundColor: Colors.white, title: Text(title, style:TextStyle(color:KColors.primaryColor))),
      body: WebView (
          initialUrl: link,
        javascriptMode: JavascriptMode.unrestricted
      )
    );
  }

}
