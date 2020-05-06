import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';


class PersonalPage extends StatefulWidget {

  static var routeName = "/PersonalPage";

  CustomerModel customer;

  PersonalPage({Key key, this.title, this.customer}) : super(key: key);

  final String title;

  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {

  int _genderRadioValue = 0;

  bool editable = false;
  DateTime date;

  final format = DateFormat("yyyy-MM-dd");

  String localPicture;

  TextEditingController _phoneNumberFieldController = TextEditingController(), _jobTitleFieldController = TextEditingController(), _emailFieldController = TextEditingController(), _nickNameFieldController = TextEditingController(), _districtFieldController = TextEditingController();

  bool isSaving = false;

  TextEditingValue s ;


  bool _isNickNameError = false,
      _isJobTitleError = false,
      _isDistrictError = false,
      _isEmailError = false,
      _isGenderError = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _phoneNumberFieldController.text = widget.customer?.phone_number;
    _nickNameFieldController.text = widget.customer?.nickname;
    _jobTitleFieldController.text = widget.customer?.job_title;
    _districtFieldController.text = widget.customer?.district;
    _emailFieldController.text = widget.customer?.email;
    _genderRadioValue = widget.customer?.gender;



  }

  File _image;


  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
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
                        )
                    )
                ),
                Positioned(child: FloatingActionButton(
                  backgroundColor: KColors.primaryColor,
                  onPressed: getImage,
                  child: Icon(Icons.photo_camera, color: Colors.white),
                ), right: 0,bottom: 0)]),
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
              /*  Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
//             e-mail must be confirmed by another interface before setting it up.
                child:TextField(controller: _emailFieldController, enabled: false,
                    decoration: InputDecoration(labelText: "E-mail",
                      border: InputBorder.none,
                    )),
              ),
              SizedBox(height: 10),*/
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(controller: _nickNameFieldController, onChanged: (text){},
                    decoration: InputDecoration(labelText: "Nickname",
                      border: InputBorder.none,
                    )),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(controller: _jobTitleFieldController,
                    decoration: InputDecoration(labelText: "Job Title",
                      border: InputBorder.none,
                    )),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(
                    controller: _districtFieldController,
                    decoration: InputDecoration(labelText: "Your district",
                      border: InputBorder.none,
                    )),
              ),
              SizedBox(height: 10),
              Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.white,
                  child:Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                    Container(width: MediaQuery.of(context).size.width, child: Text("Gender", textAlign: TextAlign.left, style: TextStyle(color: KColors.primaryColor, fontSize: 12))),
                    /*  */
                    Row(children: <Widget>[
                      Text("Woman", style: TextStyle(color: Colors.black, fontSize: 16)), Radio(value: 0, groupValue: _genderRadioValue, onChanged: _handleGenderRadioValueChange),
                      Text("Man"), Radio(value: 1, groupValue: _genderRadioValue, onChanged: _handleGenderRadioValueChange)
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
                        isSaving ?  Row(
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
        ),
      ),
    );
  }

  void _confirmContent() {}

  void _handleGenderRadioValueChange(int value) {
    setState(() {
      this._genderRadioValue = value;
    });
  }

  void _saveCustomerData() {

    /* update data into the database ...
    * 1. check if all the field are ok, otherwhise, pass.
    *  */
    CustomerModel model = CustomerModel();
    // phone number
    String phoneNumber = _phoneNumberFieldController.text;
    // nickname
    String nickname = _nickNameFieldController.text;


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

