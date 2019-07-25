import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/ui/screens/home/restaurant/RestaurantListPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaba_flutter/src/utils/_static_data/Vectors.dart';
//import CustomIcons from '../lib/utils/_static_data/custom_icons_icons.dart';
import 'package:kaba_flutter/src/utils/_static_data/my_flutter_app_icons.dart';

import '_home/HomeWelcomePage.dart';
import 'me/MeAccountPage.dart';
import 'orders/DailyOrdersPage.dart';

class HomePage extends StatefulWidget {

  static var routeName = "/HomePage";

  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  static final List<String> popupMenus = ["Settings"];
  var _selectedIndex = 0;

  HomeWelcomePage homeWelcomePage = HomeWelcomePage();
  RestaurantListPage restaurantListPage = RestaurantListPage();
  DailyOrdersPage dailyOrdersPage = DailyOrdersPage();
  MeAccountPage meAccountPage = MeAccountPage();

  List<StatefulWidget> pages;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pages = [homeWelcomePage, restaurantListPage, dailyOrdersPage, meAccountPage];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            title: Text('Restaurant'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            title: Text('Orders'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Account'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: KColors.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }

  void menuChoiceAction(String value) {
    /* jump to the other activity */
  }

  void _onItemTapped(int value) {
    /* zwitch */
    setState(() {
      _selectedIndex = value;
    });
  }
}

class AppbarhintFieldWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child:TextField(decoration: InputDecoration(border: OutlineInputBorder(), hintText:"Play basketball with us today", hintMaxLines: 1, hintStyle: TextStyle(color:Colors.white))),
      color: Colors.transparent,
    );
  }
}
