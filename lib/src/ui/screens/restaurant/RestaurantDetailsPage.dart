import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaba_flutter/src/blocs/RestaurantBloc.dart';
import 'package:kaba_flutter/src/locale/locale.dart';
import 'package:kaba_flutter/src/models/CommentModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/ui/customwidgets/RestaurantCommentWidget.dart';
import 'package:kaba_flutter/src/ui/screens/auth/login/LoginPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/HomePage.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/_static_data/Vectors.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';

class RestaurantDetailsPage extends StatelessWidget {

  static var routeName = "/RestaurantDetailsPage";

  RestaurantModel restaurant;

  ScrollController _scrollController;

  RestaurantDetailsPage({this.restaurant}) {
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {

    restaurantBloc.fetchCommentList(restaurant, UserTokenModel.fake());

    /* use silver-app-bar first */
    double expandedHeight = 9*MediaQuery.of(context).size.width/16 + 20;
    var flexibleSpaceWidget = new SliverAppBar(
      leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: ()=>Navigator.pop(context)),
      expandedHeight: expandedHeight,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.parallax,
          centerTitle: true,
          title: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(7)), color:KColors.primaryColor.withAlpha(100)),
            padding: EdgeInsets.all(5),
            child: Text(
                restaurant.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                )),
          ),
          background: Container(
            child: CachedNetworkImage(fit:BoxFit.cover,imageUrl: Utils.inflateLink(restaurant.theme_pic)),
          )),
    );

    return Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: new DefaultTabController(
            length: 1,
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  flexibleSpaceWidget,
                ];
              },
              body:  SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height:20),
                        /* rounded image - */
                        Container(
                            height:90, width: 90,
                            decoration: BoxDecoration(
                                border: new Border.all(color: KColors.primaryYellowColor, width: 2),
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(Utils.inflateLink(restaurant.pic))
                                )
                            )
                        ),
                        SizedBox(height:20),
                        /* see the menu entry */
                        InkWell(
                          splashColor: Colors.red,
                          child:Container(padding: EdgeInsets.only(top:5,bottom: 5),
                              child:ListTile(
                                  title: Text("See the Menu", style: TextStyle(color:KColors.primaryColor)),
                                  leading: IconButton(icon: Icon(Icons.menu, color: KColors.primaryColor), onPressed: null),
                                  trailing: IconButton(icon: Icon(Icons.chevron_right, color: KColors.primaryColor), onPressed: null),
                                  onTap: (){_jumpToRestaurantMenu(context, restaurant);}), color: Colors.white),
                        ),
                        SizedBox(height:20),
                        Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(10),
                            child:Column(
                              children: <Widget>[
                                /* description of restaurant */
                                Text(restaurant.description,
                                  style: TextStyle(color: Colors.black, fontSize: 16),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Opening Time", style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 16)),
                                    Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                                      IconButton(icon:Icon(Icons.access_time), onPressed: () {},),
                                      Text(restaurant.working_hour, style: TextStyle(color: Colors.black, fontSize: 16)),
                                    ])
                                  ],
                                ),
                                SizedBox(height: 10),
                                Container(
                                  child: Row(children: <Widget>[
                                    IconButton(icon:Icon(Icons.location_on, color: Colors.blue), onPressed: () {}),
                                    Flexible (child: Text(restaurant.address, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black, fontSize: 16))),
                                  ]),
                                ),
                                SizedBox(height: 10),
                                Text("Notes and Reviews", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                                SizedBox(height:10),
                                /* 4.0 - stars */
                                StreamBuilder<List<CommentModel>>(
                                    stream: restaurantBloc.commentList,
                                    builder: (context, AsyncSnapshot<List<CommentModel>> snapshot) {
                                      if (snapshot.hasData) {
                                        return Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Text("${restaurant.stars.toStringAsFixed(1)}", style: TextStyle(fontSize: 100, color: KColors.primaryColor)),
                                                /* stars */
                                                Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Row(children:  List<Widget>.generate(restaurant.stars.toInt(), (int index) {
                                                        return Icon(Icons.star, color: KColors.primaryYellowColor);
                                                      })
                                                      ),
                                                      Text("${restaurant.votes} Votes", style: TextStyle(color:Colors.grey))
                                                    ])
                                              ],
                                            ),
                                            /* the list of comments */
                                          ]..addAll(
                                              _buildCommentsList(snapshot.data)
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        return Container();
                                      }
                                      return Center(child: CircularProgressIndicator());
                                    }
                                ),
                              ],
                            )
                        ),
                      ]
                        ..add(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(iconSize: 20,onPressed: (){}, icon: Icon(Icons.star, size: 20, color: Colors.grey)),
                                Text("Powered by >> Kaba Technlogies")
                              ],
                            )
                        )
                  )),
            )));
  }

  void _jumpToRestaurantMenu (BuildContext context, RestaurantModel restaurantModel) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantMenuPage(restaurant: restaurantModel),
      ),
    );
  }

  _buildCommentsList(List<CommentModel> comments) {
    var list = List<Widget>.generate(comments.length, (int index) {
      if (!comments[index].hidden)
        return RestaurantCommentWidget(comment: comments[index]);
      return Container();
    })?.reversed;
    if (list!= null && list != Container()) {
      return list;
    }
  }

}
