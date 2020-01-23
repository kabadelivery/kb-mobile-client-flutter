import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kaba_flutter/src/contracts/personal_page_contract.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
import 'package:toast/toast.dart';


class Personal2Page extends StatefulWidget {

  static var routeName = "/Personal2Page";

  CustomerModel customer;

  PersonnalPagePresenter presenter;

  Personal2Page({Key key, this.title, this.presenter, this.customer}) : super(key: key);

  final String title;

  @override
  _Personal2PageState createState() => _Personal2PageState();
}

class _Personal2PageState extends State<Personal2Page> implements PersonnalPageView {


  bool editable = false;
  DateTime date;

  final format = DateFormat("yyyy-MM-dd");

  String localPicture;

  TextEditingController _phoneNumberFieldController = TextEditingController(), _jobTitleFieldController = TextEditingController(), _emailFieldController = TextEditingController(), _nickNameFieldController = TextEditingController(), _districtFieldController = TextEditingController();

  bool isUpdating = false;

  TextEditingValue s ;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.widget.presenter.personnalPageView = this;
    _phoneNumberFieldController.text = widget.customer?.phone_number;
    _emailFieldController.text = widget.customer?.email;
    _nickNameFieldController.text = widget.customer?.nickname;
    _jobTitleFieldController.text = widget.customer?.job_title;
    _districtFieldController.text = widget.customer?.district;
    _emailFieldController.text = widget.customer?.email;
  }

  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  String _validatePassword(String value) {
    if (value.length < 8) {
      return 'The Password must be at least 8 characters.';
    }
    return null;
  }

  String _validateName(String value) {
    if (value.length < 6) {
      return 'This field must have more than 6 characters.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
//        actions: <Widget>[ IconButton(tooltip: "Confirm", icon: Icon(Icons.check, color:KColors.primaryColor), onPressed: (){_confirmContent();})],
        backgroundColor: Colors.white,
        title: Text("ME", style:TextStyle(color:KColors.primaryColor)),
      ),
      body: SingleChildScrollView(
          child: Column(
              children: <Widget>[
                /* boxes to show the pictures selected. */
                SizedBox(height: 20),
                Stack(children: <Widget>[
                  Container(
                      height:140, width: 140,
                      decoration: BoxDecoration(color: Colors.grey.withAlpha(30),
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: (_image != null ? FileImage(_image) : CachedNetworkImageProvider(Utils.inflateLink(widget.customer?.profile_picture)))
                          ))),
                  Positioned(child: FloatingActionButton(
                    backgroundColor: KColors.primaryColor,
                    onPressed: getImage,
                    child: Icon(Icons.photo_camera, color: Colors.white),
                  ), right: 0,bottom: 0)]),
                SizedBox(height: 20),
                /* form */
                Form(
                    key: this._formKey,
                    child: new Column(
                        children: <Widget>[
                          SizedBox(height: 20),
                          InkWell(
                            onTap: ()=> setUpLogin(1),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              color: Colors.white,
                              /* phone number must be confirmed by another interface before setting it up. */
                              child:TextField(controller: _phoneNumberFieldController, enabled: false,
                                  decoration: InputDecoration(labelText: "Phone Number", /* if  already sat, we cant put nothing else */
                                    border: InputBorder.none,
                                  )),
                            ),
                          ),
                          SizedBox(height: 20),
                          InkWell(
                            onTap: ()=> setUpLogin(2),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              color: Colors.white,
                              /* phone number must be confirmed by another interface before setting it up. */
                              child:TextField(controller: _emailFieldController, enabled: false,
                                  decoration: InputDecoration(labelText: "Email", /* if  already sat, we cant put nothing else */
                                    border: InputBorder.none,
                                  )),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.all(10),
                            color: Colors.white,
                            child:TextFormField(controller: _nickNameFieldController,
                                decoration: InputDecoration(labelText: "Nickname", border: InputBorder.none),
                                validator: this._validateName,
                                onSaved: (String value) {
                                  widget.customer.nickname = value;
                                }
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(10),
                            color: Colors.white,
                            child:TextFormField(controller: _jobTitleFieldController,
                                decoration: InputDecoration(labelText: "Job Title", border: InputBorder.none, ),
                                validator: _validateName,
                                onSaved: (String value) {
                                  widget.customer.job_title = value;
                                }
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(10),
                            color: Colors.white,
                            child:TextFormField(
                                controller: _districtFieldController,
                                decoration: InputDecoration(labelText: "Your district", border: InputBorder.none),
                                validator: _validateName,
                                onSaved: (String value) {
                                  widget.customer.district = value;
                                }
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                              padding: EdgeInsets.all(10),
                              color: Colors.white,
                              child:Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                                Container(width: MediaQuery.of(context).size.width, child: Text("Gender", textAlign: TextAlign.left, style: TextStyle(color: KColors.primaryColor, fontSize: 12))),
                                /*  */
                                Row(children: <Widget>[
                                  Text("Woman", style: TextStyle(color: Colors.black, fontSize: 16)), Radio(value: 1, groupValue: widget.customer.gender, onChanged: _handleGenderRadioValueChange),
                                  Text("Man"), Radio(value: 2, groupValue: widget.customer.gender, onChanged: _handleGenderRadioValueChange)
                                ]),
                              ])
                          ),
                          SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  onChanged: (date) {
//                        print('change $date');
                                  }, onConfirm: (date) {
                                    print('confirm $date');
                                    setState(() {
                                      widget.customer.birthday = "${date.year} - ${date.month<10 ? "0${date.month}" : "${date.month}"} - ${date.day<10 ? "0${date.day}" : "${date.day}"}";
                                    });
                                  }, currentTime: DateTime.now(), locale: LocaleType.en);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(left: 10, right: 10,  bottom: 20, top: 20),
                              color: Colors.white,
                              child: Row(
                                children: <Widget>[
                                  Text("Birthday", style: TextStyle(color: Colors.black, fontSize: 16)),
                                  Container(width: 20),
                                  Text("${widget.customer.birthday}", style: TextStyle(color: KColors.primaryColor)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          /* bouttons sauvegarder */
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:<Widget>[
                                MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10), color:KColors.primaryColor,child: Row(
                                  children: <Widget>[
                                    Text("SAUVEGARDER", style: TextStyle(fontSize: 14, color: Colors.white)),
                                    isUpdating ?  Row(
                                      children: <Widget>[
                                        SizedBox(width: 10),
                                        SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)), height: 15, width: 15) ,
                                      ],
                                    )  : Container(),
                                  ],
                                ), onPressed: () {_saveCustomerData();}),
                                SizedBox(width:20),
                                MaterialButton(padding: EdgeInsets.only(top:15, bottom:15, left:10, right:10),color:Colors.white,child: Text("ANNULER", style: TextStyle(fontSize: 14, color: Colors.black)), onPressed: () {_cancelAll();}),
                              ]),
                          SizedBox(height:50),
                        ]
                    ))])
      ),
    );
  }

  void _handleGenderRadioValueChange(int value) {
    setState(() {
      widget.customer.gender = value;//
    });
  }

  Future _saveCustomerData() async {

    // First validate form.
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      /* no need to check pictures, birthday and so on, we just need to upload them.*/
      if (_image != null) {
        // convert the imagefile to base64 and upload it to the server through the same process
      }
      /* upload the whole object to the server. */
      widget.customer.district = _districtFieldController.text;
      widget.customer.job_title = _jobTitleFieldController.text;
      widget.customer.nickname = _nickNameFieldController.text;

      if (_image != null) { /* convert to base64, and upload to server. */
        List<int> imageBytes = await _image.readAsBytesSync();
        print(imageBytes);
        String base64Image = base64Encode(imageBytes);
        widget.customer.profile_picture = base64Image;
      } else {
        widget.customer.profile_picture = null;
      }
      showLoading(true);
      widget.presenter.updatePersonnalPage(widget.customer);
    } else {
      mToast("error somewhere");
    }
  }

  void _cancelAll() {
    Navigator.pop(context);
  }

  /// set up
  ///
  /// 1. phone number
  /// 2. email
  setUpLogin (int type) {

    /* jump to a page that sends a confirmation message to each of them. */
  }

  @override
  void networkError() {
    showLoading(false);
  }

  @override
  void showErrorMessage(String message) {
    showLoading(false);
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      isUpdating = isLoading;
    });
  }

  @override
  void sysError() {
    showLoading(false);
  }

  @override
  void updatePersonnalPage(CustomerModel data) {
    /* quit */
    mToast(data.toJson().toString());
    /* persist it into the sys */
    CustomerUtils.updateCustomerPersist(data);
    // quit the page after three seconds
    Future.delayed(Duration(seconds: 3)).whenComplete((){Navigator.pop(context);});
  }

  void mToast(String message) { Toast.show(message, context, duration: Toast.LENGTH_LONG);}

}


class BasicTimeField extends StatelessWidget {
  final format = DateFormat("HH:mm");
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text('Basic time field (${format.pattern})'),
      /*     DateTimeField(
        format: format,
        onShowPicker: (context, currentValue) async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
          );
          return DateTimeField.convert(time);
        },
      ),*/
    ]);
  }
}

