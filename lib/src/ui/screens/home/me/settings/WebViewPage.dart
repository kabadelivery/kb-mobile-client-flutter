import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kaba_flutter/src/contracts/login_contract.dart';
import 'package:kaba_flutter/src/ui/screens/auth/login/LoginPage.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/ui/screens/splash/SplashPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';


class WebViewPage extends StatefulWidget {

  static var routeName = "/WebViewPage";

  bool agreement;

  WebViewPage({Key key, this.title="CGU", this.link="http://app1.kaba-delivery.com/page/cgu", this.agreement = false}) : super(key: key);

  final String title, link;

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  bool _pageLoading = true;
  bool _pageError = false;

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
            Builder(builder: (BuildContext context) {
              return WebView(
                initialUrl: '${widget.link}',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },
                javascriptChannels: <JavascriptChannel>[].toSet(),
                navigationDelegate: (NavigationRequest request) {
                  if (!request.url.contains("kaba") && !request.url.contains("pay")) {
                    print('blocking navigation to $request}');
                    _pageLoading = false;
                    _pageError = true;
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
            _pageLoading ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(KColors.primaryColor))) : Container(),
            _pageError ? Center(child: ErrorPage(onClickAction: ()=> {})) : Container(),
            !_pageError && !_pageLoading && widget.agreement ? Positioned(bottom:0,child:
            Container(padding: EdgeInsets.only(top:10, bottom:30),color: Colors.white.withAlpha(180), width: MediaQuery.of(context).size.width, child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: <Widget>[
              /* accept or say no */
              RaisedButton(child:Text("Accept", style: TextStyle(color: Colors.white)), color: KColors.primaryColor, onPressed: () => _acceptTerms(true)),
              RaisedButton(child:Text("Refuse", style: TextStyle(color: Colors.black)), color: KColors.white,  onPressed: () => _acceptTerms(false)),
            ])
            )) : Container()
          ],
        )
    );
  }

  _acceptTerms(bool accept) async {

    if (accept) {
      //
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("_is_ok_with_terms", true);

      // jump to login page.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(presenter: LoginPresenter()),
        ),
      );

    } else {
      // close app.
      Navigator.pop(context);
    }
  }
}
