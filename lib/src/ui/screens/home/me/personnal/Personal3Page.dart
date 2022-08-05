import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/personal_page_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class Personal3Page extends StatefulWidget {
  static var routeName = "/Personal2Page";

  CustomerModel customer;

  PersonnalPagePresenter presenter;

  Personal3Page({Key key, this.title, this.presenter, this.customer})
      : super(key: key);

  final String title;

  @override
  _Personal3PageState createState() => _Personal3PageState();
}

class _Personal3PageState extends State<Personal3Page>
    implements PersonnalPageView {
  bool editable = false;
  DateTime date;

  final format = DateFormat("yyyy-MM-dd");

  String localPicture;

  TextEditingController _phoneNumberFieldController = TextEditingController(),
      _jobTitleFieldController = TextEditingController(),
      _emailFieldController = TextEditingController(),
      _nickNameFieldController = TextEditingController(),
      _whatsappNoFieldController = TextEditingController(),
      _districtFieldController = TextEditingController();

  bool isUpdating = false;

  int accountType = 1; // 1 phone-number , 2 email

  TextEditingValue s;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    this.widget.presenter.personnalPageView = this;
    _phoneNumberFieldController.text = widget.customer?.phone_number;
    _emailFieldController.text = widget.customer?.email;
    _nickNameFieldController.text = widget.customer?.nickname;
    _jobTitleFieldController.text = widget.customer?.job_title;
    _districtFieldController.text = widget.customer?.district;
    _whatsappNoFieldController.text = widget.customer?.whatsapp_number;
//    _emailFieldController.text = widget.customer?.email;

    setState(() {
      if (widget.customer?.phone_number != null) accountType = 1;
      if (widget.customer?.email != null) accountType = 2;
    });
  }

  File _image;

  final picker = ImagePicker();

  Future getImage() async {
//    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
//    setState(() {
//      _image = image;
//    });

    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        xrint('No image selected.');
      }
    });
  }

  String _validateName(String value) {
    if (value.length < 2) {
      return "${AppLocalizations.of(context).translate('field_more_2_chars')}";
//      return 'This field must have more than 6 characters.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: StateContainer.ANDROID_APP_SIZE,
          brightness: Brightness.light,
          backgroundColor: KColors.primaryColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, size: 20),
              onPressed: () {
                Navigator.pop(context);
              }),
//        actions: <Widget>[ IconButton(tooltip: "Confirm", icon: Icon(Icons.check, color:KColors.primaryColor), onPressed: (){_confirmContent();})],
          actions: [Container(width: 40)],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  Utils.capitalize(
                      "${AppLocalizations.of(context).translate('my_profile')}"),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          /* boxes to show the pictures selected. */
          SizedBox(height: 20),
          Container(
            color: KColors.new_gray,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(children: <Widget>[
                  Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(30),
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: (_image != null
                                  ? FileImage(_image)
                                  : CachedNetworkImageProvider(
                                      Utils.inflateLink(widget
                                          .customer?.profile_picture)))))),
                  Positioned(
                      child: InkWell(
                        onTap: getImage,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: Icon(
                            Icons.edit,
                            color: KColors.mBlue,
                            size: 20,
                          ),
                        ),
                      ),
                      right: 0,
                      bottom: 0)
                ]),
              ],
            ),
          ),
          SizedBox(height: 20),
          /* form */
          Form(
              key: this._formKey,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                        color: KColors.new_gray,
                        borderRadius: BorderRadius.circular(5)),
                    child: Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 0.8, color: Colors.grey.withAlpha(35)),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                                child: Container(
                                    color: KColors.new_gray,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                        "${AppLocalizations.of(context).translate('phone_number')}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey)))),
                            Expanded(
                                child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    color: KColors.new_gray,
                                    child: TextField(
                                        style: TextStyle(
                                            color: KColors.new_black, fontSize: 14),
                                        maxLines: 1,
                                        controller: _phoneNumberFieldController,
                                        enabled: false,
                                        decoration: InputDecoration(
                                          /* if  already sat, we cant put nothing else */
                                          border: InputBorder.none,
                                        )))),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 0.8, color: Colors.grey.withAlpha(35)),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                                child: Container(
                                    color: KColors.new_gray,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                        "${AppLocalizations.of(context).translate('nickname')}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey)))),
                            Expanded(
                                child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    color: KColors.new_gray,
                                    child: TextField(
                                        style: TextStyle(
                                            color: KColors.new_black, fontSize: 14),
                                        maxLines: 1,
                                        controller: _nickNameFieldController,
                                        enabled: true,
                                        decoration: InputDecoration(
                                          /* if  already sat, we cant put nothing else */
                                          border: InputBorder.none,
                                        )))),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 0.8, color: Colors.grey.withAlpha(35)),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                                child: Container(
                                    color: KColors.new_gray,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                        "${AppLocalizations.of(context).translate('whatsapp_number_hint_ex')}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey)))),
                            Expanded(
                                child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    color: KColors.new_gray,
                                    child: TextField(
                                        style: TextStyle(
                                            color: KColors.new_black, fontSize: 14),
                                        maxLines: 1,
                                        controller: _whatsappNoFieldController,
                                        enabled: true,
                                        decoration: InputDecoration(
                                          /* if  already sat, we cant put nothing else */
                                          border: InputBorder.none,
                                        )))),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 0.8, color: Colors.grey.withAlpha(35)),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                                child: Container(
                                    color: KColors.new_gray,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                        "${AppLocalizations.of(context).translate('job_title')}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey)))),
                            Expanded(
                                child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    color: KColors.new_gray,
                                    child: TextField(
                                        style: TextStyle(
                                            color: KColors.new_black, fontSize: 14),
                                        maxLines: 1,
                                        controller: _jobTitleFieldController,
                                        enabled: true,
                                        decoration: InputDecoration(
                                          /* if  already sat, we cant put nothing else */
                                          border: InputBorder.none,
                                        )))),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                                child: Container(
                                    color: KColors.new_gray,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                        "${AppLocalizations.of(context).translate('your_district')}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey)))),
                            Expanded(
                                child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    color: KColors.new_gray,
                                    child: TextField(
                                        style: TextStyle(
                                            color: KColors.new_black, fontSize: 14),
                                        maxLines: 1,
                                        controller: _districtFieldController,
                                        enabled: true,
                                        decoration: InputDecoration(
                                          /* if  already sat, we cant put nothing else */
                                          border: InputBorder.none,
                                        )))),
                          ],
                        ),
                      )
                    ]),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                        color: KColors.new_gray,
                        borderRadius: BorderRadius.circular(5)),
                    child: Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 0.8, color: Colors.grey.withAlpha(35)),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                                child: Container(
                                    color: KColors.new_gray,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                        "${AppLocalizations.of(context).translate('gender')}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey)))),
                            Expanded(
                                child: Container(
                              child: Column(children: <Widget>[
                                Row(
                                  children: [
                                    Radio(
                                        value: 1,
                                        groupValue: widget.customer.gender,
                                        onChanged:
                                            _handleGenderRadioValueChange),
                                    Text(
                                        "${AppLocalizations.of(context).translate('woman_gender')}",
                                        style: TextStyle(
                                            color: KColors.new_black, fontSize: 12)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio(
                                        value: 2,
                                        groupValue: widget.customer.gender,
                                        onChanged:
                                            _handleGenderRadioValueChange),
                                    Text(
                                        "${AppLocalizations.of(context).translate('man_gender')}",
                                        style: TextStyle(
                                            color: KColors.new_black, fontSize: 12)),
                                  ],
                                ),
                              ]),
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              color: KColors.new_gray,
                            )),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                                child: Container(
                                    color: KColors.new_gray,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                        "${AppLocalizations.of(context).translate('birthday')}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey)))),
                            Expanded(
                                child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              color: KColors.new_gray,
                              child: InkWell(
                                onTap: () {
                                  DatePicker.showDatePicker(context,
                                      showTitleActions: true,
                                      onChanged: (date) {
                                    xrint('change $date');
                                  }, onConfirm: (date) {
                                    xrint('confirm $date');
                                    setState(() {
                                      widget.customer.birthday =
                                          "${date.year} - ${date.month < 10 ? "0${date.month}" : "${date.month}"} - ${date.day < 10 ? "0${date.day}" : "${date.day}"}";
                                    });
                                  },
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.en);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, bottom: 20, top: 20),
                                  child: Row(
                                    children: <Widget>[
                                      Text("${widget.customer.birthday}",
                                          style: TextStyle(
                                              color: KColors.primaryColor)),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  SizedBox(height: 20),
                  /* bouttons sauvegarder */
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: KColors.primaryColor,
                                  borderRadius: BorderRadius.circular(5)),
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              padding: EdgeInsets.only(
                                  top: 15, bottom: 15, left: 10, right: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                      "${AppLocalizations.of(context).translate('save')}",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                  isUpdating
                                      ? Row(
                                          children: <Widget>[
                                            SizedBox(width: 10),
                                            SizedBox(
                                                child: CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white)),
                                                height: 15,
                                                width: 15),
                                          ],
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            onTap: () {
                              _saveCustomerData();
                            }),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            _cancelAll();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: KColors.primaryColor.withAlpha(30)),
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: EdgeInsets.only(
                                top: 15, bottom: 15, left: 10, right: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    "${AppLocalizations.of(context).translate('cancel')}",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: KColors.primaryColor)),
                              ],
                            ),
                          ),
                        ),
                      ]),
                  SizedBox(height: 50),
                ],
              ))
        ])));
  }

  void _handleGenderRadioValueChange(int value) {
    setState(() {
      widget.customer.gender = value; //
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
      widget.customer.whatsapp_number = _whatsappNoFieldController.text;

      if (_image != null) {
        /* convert to base64, and upload to server. */
        List<int> imageBytes = await _image.readAsBytesSync();
        // xrint(imageBytes);
        String base64Image = base64Encode(imageBytes);
        widget.customer.profile_picture = base64Image;
      } else {
        widget.customer.profile_picture = null;
      }
      showLoading(true);
      widget.presenter.updatePersonnalPage(widget.customer);
    } else {
      mDialog(
          "${AppLocalizations.of(context).translate('please_fill_all_fields')}");
    }
  }

  void mDialog(String message) {
    _showDialog(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "${message}",
      isYesOrNo: false,
    );
  }

  void _showDialog(
      {String svgIcons,
      Icon icon,
      var message,
      bool okBackToHome = false,
      bool isYesOrNo = false,
      Function actionIfYes}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              SizedBox(
                  height: 80,
                  width: 80,
                  child: icon == null
                      ? SvgPicture.asset(
                          svgIcons,
                        )
                      : icon),
              SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: KColors.new_black, fontSize: 13))
            ]),
            actions: isYesOrNo
                ? <Widget>[
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              BorderSide(color: Colors.grey, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context).translate('refuse')}",
                          style: TextStyle(color: Colors.grey)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(BorderSide(
                              color: KColors.primaryColor, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context).translate('accept')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        actionIfYes();
                      },
                    ),
                  ]
                : <Widget>[
                    //
                    OutlinedButton(
                      child: new Text(
                          "${AppLocalizations.of(context).translate('ok')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ]);
      },
    );
  }

  void _cancelAll() {
    // pop and go back to the previous page.
    Navigator.pop(context);
  }

  /// set up
  ///
  /// 1. phone number
  /// 2. email
  setUpLogin(int type) {
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
//    mToast(data.toJson().toString());
    /* persist it into the sys */
    CustomerUtils.updateCustomerPersist(data);
    // quit the page after three seconds
    Future.delayed(Duration(seconds: 3)).whenComplete(() {
      Navigator.pop(context);
    });
  }

  void mToast(String message) {
//    mDialog(message);
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }
}
