import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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


  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
          backgroundColor: Colors.white, title: Text(widget.title, style:TextStyle(color:KColors.primaryColor))),
      body: WebView (
          initialUrl: widget.link,
        javascriptMode: JavascriptMode.unrestricted
      )
    );
  }

}
