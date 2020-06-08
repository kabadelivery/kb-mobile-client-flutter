import 'package:KABA/src/contracts/evenement_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/EvenementModel.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


class EvenementPage extends StatefulWidget {

  static var routeName = "/EvenementPage";

  EvenementPresenter presenter;

  EvenementPage({Key key, this.title, this.presenter}) : super(key: key);

  final String title;

  @override
  _EvenementPageState createState() => _EvenementPageState();
}

class _EvenementPageState extends State<EvenementPage> implements EvenementView {


  List<EvenementModel> data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.evenementView = this;
    widget.presenter.fetchEvenements();
  }

  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text("${AppLocalizations.of(context).translate('events')}", style:TextStyle(color:KColors.primaryColor)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
      ),
      body: Container(
          child: isLoading ? Center(child:CircularProgressIndicator()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
          _buildEvenementsList())
      ),
    );
  }

  @override
  void inflateEvenement(List<EvenementModel> events) {

    showLoading(false);
    setState(() {
      this.data = events;
    });
  }

  @override
  void networkError() {
    showLoading(false);
    /* show a page of network error. */
    setState(() {
      this.hasNetworkError = true;
    });
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
      if (isLoading == true) {
        this.hasNetworkError = false;
        this.hasSystemError = false;
      }
    });
  }

  @override
  void systemError() {
    showLoading(false);
    /* show a page of network error. */
    setState(() {
      this.hasSystemError = true;
    });
  }

  _buildSysErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context).translate('system_error')}",onClickAction: (){ widget.presenter.fetchEvenements(); });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context).translate('network_error')}",onClickAction: (){ widget.presenter.fetchEvenements(); });
  }

  _buildEvenementsList() {

    if (data == null || data.length == 0) {
      /* just show empty page. */
      return _buildEmptyEventsPage();
    }

    return Container(
        child: ListView.builder(itemCount: data?.length,
            itemBuilder: (BuildContext context, int position) {
              return Card(
                  child: InkWell(
//                    onTap: ()=>_jumpToAdsList([]),
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          /* image 16 x 9*/
                          Flex(
                            direction: Axis.vertical,
                            children: <Widget>[
                              CachedNetworkImage(
                                  imageUrl: Utils.inflateLink(data[position].pic),
                                  fit: BoxFit.fill
                              )
                            ],
                          ),
                          SizedBox(height:5),
                          Row(mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              OutlineButton(
                                borderSide: BorderSide(color: Colors.black, width: 1),
                                child: Row(
                                  children: <Widget>[
                                    /* circular progress */
                                    isLoading ? Row(
                                      children: <Widget>[
                                        SizedBox(height: 12, width: 12,child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.white))),
                                        SizedBox(width: 5),
                                      ],
                                    ) : Container(),
                                    Text(data[position].category?.toUpperCase(), style: TextStyle(color: Colors.black)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height:5),
                          /* text */
                          Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.all(10),
                              child: Text(data[position]?.description,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  maxLines: 50,
                                  style: TextStyle(color: Colors.black))),
                        ],
                      ),
                    ),
                  )
              );
            }));
  }

  _buildEmptyEventsPage() {

    return Center(
        child:Column(mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(icon: Icon(Icons.event, color: Colors.grey)),
            SizedBox(height: 10),
            Text("${AppLocalizations.of(context).translate('no_upcoming_events')}", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ],
        ));
  }
}
