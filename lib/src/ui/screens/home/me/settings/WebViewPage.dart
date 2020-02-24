import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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

  var progress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(leading: IconButton(
            icon: Icon(Icons.arrow_back, color: KColors.primaryColor),
            onPressed: () {
              Navigator.pop(context);
            }),
            backgroundColor: Colors.white,
            title: Text(
                widget.title, style: TextStyle(color: KColors.primaryColor))),
        body: Container(
            child: Column(
                children: <Widget>[
                  (progress != 1.0)
                      ? LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(KColors.primaryYellowColor))
                      : null, // Should be removed while showing
                  Expanded(
                    child: Container(
                      /*   child: InAppWebView(
                          initialUrl: widget.link,
                          initialHeaders: {},
//                        initialOptions: {},
                          onWebViewCreated: (
                              InAppWebViewController controller) {},
                          onLoadStart: (InAppWebViewController controller,
                              String url) {},
                          onProgressChanged:
                              (InAppWebViewController controller, int progress) {
                            setState(() {
                              this.progress = progress / 100;
                            });
                          },
                          initialOptions: InAppWebViewWidgetOptions(
                              inAppWebViewOptions: InAppWebViewOptions(
                                debuggingEnabled: true,
                              )
                          )
                      ),*/
                        child: WebView (
                            onPageStarted:(page){showLoading(true);},
                            onPageFinished:(page){showLoading(false);},

                            initialUrl: widget.link,
                            javascriptMode: JavascriptMode.unrestricted
                        )
                    ),
                  )
                ].where((Object o) => o != null).toList()))
      /*  WebView (
          initialUrl: widget.link,
        javascriptMode: JavascriptMode.unrestricted
      )*/
    );
  }

  void showLoading(bool isLoading) {
    setState(() {
      if (isLoading)
        progress = 50.0;
      else
        progress = 100.0;
    });
  }

}
