import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/utils/_static_data/Vectors.dart';


class MeAccountPage extends StatefulWidget {
  MeAccountPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MeAccountPageState createState() => _MeAccountPageState();
}

class _MeAccountPageState extends State<MeAccountPage> {

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    double expandedHeight = 9*MediaQuery.of(context).size.width/16 + 20;
    var flexibleSpaceWidget = new SliverAppBar(
      leading: IconButton(tooltip: "Scanner", icon: Icon(Icons.center_focus_strong), onPressed: (){_jumpToScanPage();}),
      expandedHeight: expandedHeight,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.parallax,
          centerTitle: true,
          /*title: Text("",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))*/
          background: Container(
            child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height:100, width: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider("https://imgix.bustle.com/uploads/image/2018/5/9/fa2d3d8d-9b6c-4df4-af95-f4fa760e3c5c-2t4a9501.JPG?w=970&h=546&fit=crop&crop=faces&auto=format&q=70")
                        )
                    )
                ),
                Container(
                    padding: EdgeInsets.only(right:20),
                    child:Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("阿乐", style:TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
                          SizedBox(height:10),
                          Text("XXXX8725", style:TextStyle(color: Colors.white, fontSize: 20), textAlign: TextAlign.right,),
                        ])
                )],
            ),
            padding:EdgeInsets.all(10),
            color: KColors.primaryYellowColor,
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
            body:
            SingleChildScrollView(
              child:   Column(
                  children: <Widget>[
                    /* top-up & xof */
                    Container(
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: <Widget>[
                                  IconButton (icon:Icon(Icons.monetization_on, color: KColors.primaryColor, size: 40), onPressed: () {}),
                                  SizedBox(height:10),
                                  Text("XOF ---", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)
                                ],
                              ),
                            ),
                            Container(
                              child: Column(
                                children: <Widget>[
                                  IconButton (icon:Icon(Icons.show_chart, color: KColors.primaryColor, size: 40), onPressed: () {}),
                                  SizedBox(height:5),
                                  Text("Top Up", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)
                                ],
                              ),
                            ),
                          ],
                        )),
                    /* do you have  a suggestion ? */
                    Container(
                        padding: EdgeInsets.only(top:20, bottom:20),
                        color: Colors.grey.shade300,
                        child:Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              InkWell(onTap: (){},
                                  child:Container(
                                      decoration: BoxDecoration(color:Colors.white, borderRadius: new BorderRadius.only(topRight:  const  Radius.circular(20.0), bottomRight: const  Radius.circular(20.0))),
                                      padding: EdgeInsets.only(left:10),
                                      child:
                                      Row(children:<Widget>[
                                        Text("Do you have any suggestion from us ?", style: TextStyle(color: KColors.primaryYellowColor)),
                                        IconButton(onPressed: null, icon: Icon(Icons.chevron_right, color: KColors.primaryColor))
                                      ]
                                      )))
                            ])),
                    /* menu box */
                    Card(
                        elevation: 8.0,
                        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                        child: Container(
                            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),   boxShadow: [
                              new BoxShadow(
                                color: Colors.grey..withAlpha(50),
                                offset: new Offset(0.0, 2.0),
                              )
                            ]),
                            child: Table(
                              /* menus */
                                children: <TableRow>[
                                  TableRow(
                                      children:<TableCell> [
                                        TableCell(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                 IconButton (icon:Icon(Icons.person, color: KColors.primaryYellowColor),iconSize: 50, onPressed: () {}),
                                                SizedBox(height:10),
                                                Text("PERSONNAL", style: TextStyle(color: KColors.primaryYellowColor, fontSize: 16),)
                                              ],
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                IconButton(icon: SizedBox(
                                                    height: 60,
                                                    width: 60,
                                                    child: SvgPicture.asset(
                                                      VectorsData.ic_voucher,
                                                      color: KColors.primaryColor,
                                                    )),iconSize: 50, onPressed: (){_jumpToScanPage();}),
                                                SizedBox(height:10),
                                                Text("VOUCHERS", style: TextStyle(color: KColors.primaryColor, fontSize: 16),)
                                              ],
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                IconButton (icon:Icon(Icons.location_on, color: KColors.primaryYellowColor, size: 60),iconSize: 50,  onPressed: () {}),
                                                SizedBox(height:10),
                                                Text("ADRESSES", style: TextStyle(color: KColors.primaryYellowColor, fontSize: 16),)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]
                                  ),
                                  TableRow(
                                      children:<TableCell> [
                                        TableCell(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                IconButton (icon:Icon(Icons.fastfood, color: KColors.primaryYellowColor, size: 60),iconSize: 50,  onPressed: () {}),
                                                SizedBox(height:10),
                                                Text("COMMAND", style: TextStyle(color: KColors.primaryYellowColor, fontSize: 16),)
                                              ],
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                IconButton (icon:Icon(Icons.notifications, color: KColors.primaryColor, size: 60),iconSize: 50,  onPressed: () {}),
                                                SizedBox(height:10),
                                                Text("FEEDS", style: TextStyle(color: KColors.primaryColor, fontSize: 16),)
                                              ],
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                IconButton (icon:Icon(Icons.settings, color: KColors.primaryYellowColor, size: 60),iconSize: 50,  onPressed: () {}),
                                                SizedBox(height:10),
                                                Text("ABOUT", style: TextStyle(color: KColors.primaryYellowColor, fontSize: 16),)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]
                                  )
                                ]
                            )
                        ))
                  ]),
            )),
      ),
    );
  }

  void _jumpToScanPage() {}
}
