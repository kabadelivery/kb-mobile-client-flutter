import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PresentationPage extends StatefulWidget {
  static var routeName = "/PresentationPage";

  PresentationPage({Key? key}) : super(key: key);

  @override
  _PresentationPageState createState() => _PresentationPageState();
}

class _PresentationPageState extends State<PresentationPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<String> _images = [
    "assets/images/png/Slide_1.png",
    "assets/images/png/Slide_2.png",
    "assets/images/png/Slide_3.png",
    "assets/images/png/SLide_4.png",
    "assets/images/png/Slide_5.png",
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _endOfTheSlides() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ServerConfig.SHARED_PREF_FIRST_TIME_IN_APP, false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SplashPage()),
    );
  }

  Widget _buildFullScreenImage(String assetPath) {
    // Image fills entire screen and keeps aspect ratio with BoxFit.cover
    return SizedBox.expand(
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context, int index) {
    // Title & body are placed near the top (you can adjust positions)
    final loc = AppLocalizations.of(context)!;
    final titles = [
      loc.translate('choice'),
      loc.translate('payment'),
      loc.translate('address'),
      loc.translate('enjoy'),
      loc.translate('enjoy'),
    ];
    final bodies = [
      loc.translate('choice_desc'),
      loc.translate('payment_desc'),
      loc.translate('address_desc'),
      loc.translate('enjoy_desc'),
      loc.translate('enjoy_desc'),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Small bubble / logo top-left (matches your previous bubble)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset("assets/images/png/kaba_logo_red_man.png", width: 48, height: 48),
                // Skip button top-right
                TextButton(
                  onPressed: _endOfTheSlides,
                  child: Container(
                    padding:EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:Colors.black.withOpacity(.2)
                    ),
                    child: Text(
                      Utils.capitalize("${loc.translate('skip_text')}"),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Expanded spacer to push navigation controls to bottom
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingControls() {
    final loc = AppLocalizations.of(context)!;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
          child: Row(
            children: [
              Spacer(),
              // Next / Done button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KColors.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  if (_currentIndex == _images.length - 1) {
                    _endOfTheSlides();
                  } else {
                    _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
                  }
                },
                child: Text(
                  _currentIndex == _images.length - 1
                      ? Utils.capitalize("${loc.translate('done_text')}")
                      : Utils.capitalize("${loc.translate('next_text')} >"),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      bottom: 86,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_images.length, (i) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 250),
            margin: EdgeInsets.symmetric(horizontal: 4),
            width: i == _currentIndex ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == _currentIndex ? KColors.primaryColor : Colors.white70,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // make scaffold background transparent so images truly fill screen
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView with full-screen images
          PageView.builder(
            controller: _controller,
            itemCount: _images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  _buildFullScreenImage(_images[index]),
                  _buildOverlayContent(context, index),
                ],
              );
            },
          ),
          _buildPageIndicator(),
          _buildFloatingControls(),
        ],
      ),
    );
  }
}
