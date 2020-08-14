import 'package:KABA/src/contracts/address_contract.dart';
import 'package:KABA/src/contracts/customercare_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerCareChatMessageModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:toast/toast.dart';

import '../../../../../../StateContainer.dart';


class CustomerCareChatPage extends StatefulWidget {

  static var routeName = "/CustomerCareChatPage";

  CustomerCareChatPresenter presenter;

  CustomerModel customer;

  CustomerCareChatPage({Key key, this.presenter}) : super(key: key);

  List<CustomerCareChatMessageModel> messages = null;

  @override
  _CustomerCareChatPageState createState() => _CustomerCareChatPageState();
}

class _CustomerCareChatPageState extends State<CustomerCareChatPage> implements CustomerCareChatView {

  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  TextEditingController _messageController = TextEditingController();

  bool isSendingMessageLoading = false;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.customerCareChatView = this;
    CustomerUtils.getCustomer().then((customer){
      widget.customer = customer;
      widget.presenter.fetchCustomerCareChat(widget.customer);
      StateContainer.of(context).updateUnreadMessage(hasUnreadMessage: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: AppBar(brightness: Brightness.light,leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
          backgroundColor: Colors.white, title: Text("${AppLocalizations.of(context).translate('customer_care')}", style:TextStyle(color:KColors.primaryColor))),
      body: Stack(
        children: <Widget>[
          Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, decoration: BoxDecoration(image: new DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(Utils.inflateLink("/web/assets/app_icons/kabachat.jpg"))
          ))),
          Container(
              child: isLoading ? Center(child:CircularProgressIndicator()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
              _buildChatList())
          ),
        ],
      ),
    );
  }

  _buildSysErrorPage() {
    return Center(child: Container(color: Colors.black.withAlpha(200), width: MediaQuery.of(context).size.width,
      child: Column(mainAxisSize: MainAxisSize.min,
        children: <Widget>[
        SizedBox(height: 10),
          Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Expanded(child: Text("${AppLocalizations.of(context).translate('system_error')}",textAlign: TextAlign.center, style: TextStyle(color: Colors.white))), SizedBox(width: 10)
          ]),
          SizedBox(height: 10),
          RaisedButton (onPressed: ()=>widget.presenter.fetchCustomerCareChat(widget.customer), color: Colors.white,
              child: Text("Reload",style: TextStyle(color: Colors.black))),
          SizedBox(height: 10),
        ],
      ),
    ));
  }

  _buildNetworkErrorPage() {
    return Center(child: Container(color: Colors.black.withAlpha(200), width: MediaQuery.of(context).size.width,
      child: Column(mainAxisSize: MainAxisSize.min,
        children: <Widget>[
        SizedBox(height: 10),
          Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Expanded(child: Text("${AppLocalizations.of(context).translate('network_error')}", textAlign: TextAlign.center, style: TextStyle(color: Colors.white))), SizedBox(width: 10)
          ]),
          SizedBox(height: 10),
          RaisedButton (onPressed: ()=>widget.presenter.fetchCustomerCareChat(widget.customer), color: Colors.white,
              child: Text("Reload",style: TextStyle(color: Colors.black))),
          SizedBox(height: 10),
        ],
      ),
    ));
  }

  _buildChatList() {

    return Container(
      child: Stack(
        children: <Widget>[
          Container(margin: EdgeInsets.only(bottom:63, right:10, left:10),
            child: (widget.messages == null || widget.messages?.length == 0) ? _buildEmptyPage() : ListView(children: <Widget>[]..addAll(
                List.generate(widget.messages?.length,
                        (int position) {
                      return Column(
                        children: <Widget>[
                          SizedBox(height: 15),
                          Row(mainAxisAlignment: widget.messages[position]?.user_id == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: <Widget>[
//                              widget.messages[position]?.user_id == 0 ? Expanded(flex:2, child: Container()) : Expanded(flex:0, child: Container()),
                              widget.messages[position]?.user_id == 0 ? Expanded(flex:0, child: Container()) : Expanded(flex:2, child: Container()),
                              Expanded(flex:8,
                                child: Container(decoration: BoxDecoration(color: widget.messages[position]?.user_id == 0 ?  Colors.white : KColors.primaryColor, borderRadius: BorderRadius.all(Radius.circular(5))),
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: <Widget>[
                                      Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(child: Text("${widget.messages[position]?.message}", textAlign: TextAlign.left,style: TextStyle(fontSize: 14, color:  widget.messages[position]?.user_id == 0 ? Colors.black : Colors.white),)),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                                        Expanded(child: Text("${Utils.readTimestamp(widget.messages[position]?.created_at)}",  textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color:  widget.messages[position]?.user_id == 0 ? Colors.black : Colors.white),)),
                                      ])
                                    ],
                                  ),
                                ),
                              ),
                              widget.messages[position]?.user_id == 0 ?  Expanded(flex:2, child: Container()) : Expanded(flex:0, child: Container()),
//                              widget.messages[position]?.user_id == 0 ? Expanded(flex:0, child: Container()) : Expanded(flex:2, child: Container()),

                            ],
                          ),
                        ],
                      );
                    })
            ), controller: _scrollController, reverse: true),
          ),
          Positioned(
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.only(left:4.0, right:4, bottom:4),
              child: Row(mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(width: 5),
                  Stack(
                    children: <Widget>[
                      SizedBox(/*height: 50+50*(_messageController.text.length~/30)*1.5, */ width: MediaQuery.of(context).size.width-80,
                        child: Container(padding: EdgeInsets.only(left:8, right:(8+20).toDouble(), top:8, bottom:8),child: TextField(controller: _messageController, maxLines: 6, minLines: 1,
                            decoration: InputDecoration.collapsed(hintText: "${AppLocalizations.of(context).translate('insert_message')}")), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(4))),),
                      ),
                      Positioned(right:10,child: IconButton(icon: Icon(Icons.my_location, color: Colors.green), onPressed: ()=>_pickAddress()))
                    ],
                  ),
                  SizedBox(width: 5),
                  FloatingActionButton(child: isSendingMessageLoading ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : Icon(Icons.send, color: Colors.white), onPressed: ()=> _sendMessage())
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

//  0.98x/90 = 6460


  @override
  void inflateCustomerCareChat(List<CustomerCareChatMessageModel> customerCareChats) {

    setState(() {
      widget.messages = customerCareChats.reversed.toList();
    });

    /* Timer(Duration(milliseconds: 500), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//    _scrollController.animateTo(40000, duration: Duration(milliseconds: 500), curve: null);
    });*/
  }


  _buildEmptyPage() {
    return Center(child: Column(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          /* icon */
          SizedBox(
              height: 80,
              width: 80,
              child: SvgPicture.asset(VectorsData.customer_care)),
          SizedBox(height: 10),
          Text("${AppLocalizations.of(context).translate('any_feedback_right_here')}", textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 13))
        ]
    ),);
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

  @override
  void sendMessagenetworkError() {
    mToast("${AppLocalizations.of(context).translate('send_message_network_error')}");
  }

  @override
  void sendMessagesystemError() {
    mToast("${AppLocalizations.of(context).translate('send_message_system_error')}");
  }

  _sendMessage() {

    String message = _messageController.text;
    if (message.trim()?.length <= 5) {
      // show a dialog telling the guy that message is to short.
      mToast("${AppLocalizations.of(context).translate('message_too_short')}");
    } else
      widget.presenter.sendMessageToCustomerCareChat(widget.customer, message);
  }

  @override
  void sendMessageLoading(bool isSendingMessageLoading) {

    setState(() {
      this.isSendingMessageLoading = isSendingMessageLoading;
    });
  }

  @override
  void chatSuccessfullySent(String message) {

    _messageController.text = "";

    CustomerCareChatMessageModel careChatMessageModel = CustomerCareChatMessageModel();
    careChatMessageModel.message = message;
    careChatMessageModel.user_id = widget.customer.id;
    careChatMessageModel.created_at = (DateTime.now().millisecondsSinceEpoch.toInt()/1000).toInt();

    setState(() {
      var tmp = widget.messages.reversed.toList();
      tmp.add(careChatMessageModel);
      widget.messages = tmp.reversed.toList();
    });

//    Timer(Duration(milliseconds: 100), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
  }

  void mToast(String message) {
    Toast.show(message, context, gravity: 2);
  }

  _pickAddress() async {

    /* jump and get it */
    Map results = await Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            MyAddressesPage(pick: true, presenter: AddressPresenter()),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin:begin, end:end);
              var curvedAnimation = CurvedAnimation(parent:animation, curve:curve);
              return SlideTransition(position: tween.animate(curvedAnimation), child: child);
            }
        ));

    if (results != null && results.containsKey('selection')) {
      DeliveryAddressModel _selectedAddress = results['selection'];

      String message = "DELIVERY ADDRESS - ${_selectedAddress.name}\n\n";
      message+="Phone number: ${_selectedAddress.phone_number}\n";
      message+="District: ${_selectedAddress.district}\n";
      message+="Near by: ${_selectedAddress.near}\n";
      message+="Description: ${_selectedAddress.description}\n";
//     message+="Suburb: ${_selectedAddress.suburb}\n";
      message+="Gps location: https://www.google.com/maps/search/?api=1&query=${_selectedAddress.location.replaceAll(":", ",")}\n";

      _messageController.text = message;
    }
  }

}
