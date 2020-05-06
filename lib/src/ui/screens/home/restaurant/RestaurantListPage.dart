import 'package:android_intent/android_intent.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/blocs/RestaurantBloc.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/ui/customwidgets/RestaurantListWidget.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:location/location.dart' as lo;
import 'package:shared_preferences/shared_preferences.dart';


class RestaurantListPage extends StatefulWidget {


  Position location;

  RestaurantListPage({Key key, this.location}) : super(key: key);


  @override
  _RestaurantListPageState createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {

  var _filterEditController = TextEditingController();

  List<RestaurantModel> data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _filterEditController.addListener(_filterEditContent);

    WidgetsBinding.instance
        .addPostFrameCallback((_) async {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool has_subscribed = false;
      try {
        prefs.getBool('has_subscribed');
      } catch(_) {
        has_subscribed = false;
      }
      if (has_subscribed == false) {
        FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
        _firebaseMessaging.subscribeToTopic(ServerConfig.TOPIC).whenComplete(() => {
          prefs.setBool('has_subscribed', true)
        });
      }

      if (StateContainer?.of(context)?.location == null) {
        restaurantBloc.fetchRestaurantList();
        _getLastKnowLocation();
      } else
        restaurantBloc.fetchRestaurantList(position: StateContainer?.of(context)?.location);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _filterEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        body:  AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child:  StreamBuilder(
                stream: restaurantBloc.restaurantList,
                builder: (context, AsyncSnapshot<List<RestaurantModel>> snapshot) {
                  if (snapshot.hasData) {
                    return _buildRestaurantList(snapshot.data);
                  } else if (snapshot.hasError) {
                    return ErrorPage(message:"Sorry, network error! Please check your connection and try again.", onClickAction: (){restaurantBloc.fetchRestaurantList(position: StateContainer.of(context).location);});
                  }
                  return Center(child: CircularProgressIndicator());
                })));
    /*  */
  }

  _buildRestaurantList(List<RestaurantModel> d) {

    this.data = d;

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        leading: null,
        backgroundColor: Colors.grey.shade100,
        title: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
//            border: new Border.all(color: Colors.white),
              color: Colors.white
          ),
          padding: EdgeInsets.only(left:8, right: 8),
          margin: EdgeInsets.only(top:8, bottom:8),
          child:Row(
            children: <Widget>[
              Expanded(
                child: TextField(controller: _filterEditController, style: TextStyle(color: KColors.primaryColor, fontSize: 16),
                    decoration: InputDecoration.collapsed(hintText: "Which restaurant? Menu?", hintStyle: TextStyle(fontSize: 15, color:Colors.grey)), enabled: true),
              ),
              IconButton(icon: Icon(Icons.close, color: Colors.grey), onPressed: () {
                _clearFocus();
              })
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
//                  SizedBox(height: 40)
                ]
                  ..addAll(
                      List<Widget>.generate(_filteredData(data).length, (int index) {
                        return RestaurantListWidget(restaurantModel: _filteredData(data)[index]);
                      })
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _checkLocationActivated () async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Can't get gurrent location"),
              content:
              const Text('Please make sure you enable GPS and try again'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    final AndroidIntent intent = AndroidIntent(
                        action: 'android.settings.LOCATION_SOURCE_SETTINGS');

                    intent.launch();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future _getLastKnowLocation() async {

    _checkLocationActivated();

    // save in to state container.
    Position position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);

    print("location :: ${position?.toJson()?.toString()}");

    if (position != null)
      StateContainer.of(context).updateLocation(location: position);
    if (StateContainer.of(context).location != null) {
      restaurantBloc.fetchRestaurantList(position: StateContainer
          .of(context)
          .location);
    }
  }


  List<RestaurantModel> _filterEditContent() {
    setState(() {});
  }

  _filteredData(List<RestaurantModel> data) {
    String content = _filterEditController.text;
    List<RestaurantModel> d = List();
    for (var restaurant in data) {
      if ("${restaurant.menu_foods}${restaurant.name}".toLowerCase().contains(content.trim().toLowerCase())) {
        d.add(restaurant);
      }
    }
    return d;
  }

  void _clearFocus() {
    _filterEditController.clear();
  }
}

