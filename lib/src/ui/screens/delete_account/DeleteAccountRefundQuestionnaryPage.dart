import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/material.dart';

class DeleteAccountQuestionningPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DeleteAccountQuestionningPageState();
  }
}

class DeleteAccountQuestionningPageState
    extends State<DeleteAccountQuestionningPage> {
  var considered_questiosn = [
    "delivery_too_long",
    "expensive_items",
    "damaged_item",
    "shipping_fees_expensive",
    "cant_find_product",
    "item_different_at_delivery",
    "none_of_the_above",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: StateContainer.ANDROID_APP_SIZE,
          brightness: Brightness.light,
          backgroundColor: KColors.primaryColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () {
                Navigator.pop(context);
              }),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  Utils.capitalize(
                      "${AppLocalizations.of(context).translate('delete_account')}"),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
              ),
              Container(
                width: 100,
                height: 100,
                color: Colors.grey,
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "${AppLocalizations.of(context).translate('delete_account')}",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${AppLocalizations.of(context).translate('why_delete_account')}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: []
                  ..addAll(List.generate(considered_questiosn.length, (index) {
                    return InformationCheckBox(
                      tag: "${considered_questiosn[index]}",
                      onChanged: _onCheckBoxChanged,
                    );
                  })),
              ),
              SizedBox(height: 20,),
              Container(child: Row(mainAxisSize: MainAxisSize.max,
                children: [
                  TextField(minLines: 4,maxLines: 5, textAlign: TextAlign.start, style: TextStyle(color: KColors.new_black),),
                ],
              ))
            ],
          ),
        ));
  }

  Map<String, bool> accountQuestionning = Map();

  _onCheckBoxChanged(bool value, String tag) {
    // keep a map and put the informations into that
    accountQuestionning[tag] = value;
  }
}

class InformationCheckBox extends StatefulWidget {
  String question;

  String tag;

  Function onChanged;

  InformationCheckBox({Key key, this.tag, this.onChanged}) : super(key: key);

  @override
  State<InformationCheckBox> createState() => _InformationCheckBoxState();
}

class _InformationCheckBoxState extends State<InformationCheckBox> {
  bool is_checked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(value: is_checked, onChanged: _onChanged),
              SizedBox(width: 5),
              Expanded(
                child: Text("${AppLocalizations.of(context).translate(widget.tag)}",
                    style: TextStyle(fontSize: 14, color: KColors.new_black)),
              )
            ]),
        SizedBox(
          height:5
        )
      ],
    );
  }

  void _onChanged(bool value) {
    setState(() {
      this.is_checked = !this.is_checked;
    });
    widget.onChanged(this.is_checked, widget.tag);
  }
}
