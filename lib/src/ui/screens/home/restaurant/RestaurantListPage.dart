import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kaba_flutter/src/blocs/RestaurantBloc.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/ui/customwidgets/RestaurantListWidget.dart';


class RestaurantListPage extends StatefulWidget {
  RestaurantListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RestaurantListPageState createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {

  var _filterEditController = TextEditingController();

  List<RestaurantModel> data;

  @override
  void initState() {
    // TODO: implement initState
    restaurantBloc.fetchRestaurantList();
    super.initState();
    _getLastKnowLocation();

    _filterEditController.addListener(_filterEditContent);
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
        body:  StreamBuilder(
            stream: restaurantBloc.restaurantList,
            builder: (context, AsyncSnapshot<List<RestaurantModel>> snapshot) {
              if (snapshot.hasData) {
                return _buildRestaurantList(snapshot.data);
              } else if (snapshot.hasError) {
                return ErrorPage(onClickAction: (){restaurantBloc.fetchRestaurantList();});
              }
              return Center(child: CircularProgressIndicator());
            }));
    /*  */
  }

  _buildRestaurantList(List<RestaurantModel> d) {

    this.data = d;

    return Scaffold(
      appBar: AppBar(
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
              _filterEditController.clear();
//            _filterEditController.
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

  Future _getLastKnowLocation() async {
    Position position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    /* now that we are good, we must launch again */
    if (position != null) {
      restaurantBloc.fetchRestaurantList(position: position);
    }
  }

  List<RestaurantModel> _filterEditContent() {
    setState(() {});
  }

  _filteredData(List<RestaurantModel> data) {
    String content = _filterEditController.text;
    List<RestaurantModel> d = List();
    for (var restaurant in data) {
      if (restaurant.menu_foods.contains(content.trim())) {
        d.add(restaurant);
      }
    }
    return d;
  }
}

