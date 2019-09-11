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

  @override
  void initState() {
    // TODO: implement initState
    restaurantBloc.fetchRestaurantList();
    super.initState();
    _getLastKnowLocation();
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

  _buildRestaurantList(List<RestaurantModel> data) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 40)
        ]
          ..addAll(
              List<Widget>.generate(data.length, (int index) {
                return RestaurantListWidget(restaurantModel: data[index]);
              })
          ),
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
}

