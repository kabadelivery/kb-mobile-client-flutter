import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
//import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';


class PersonalPage extends StatefulWidget {

  static var routeName = "/PersonalPage";

  PersonalPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  
  int _genderRadioValue = 0;


  bool editable = false;
  DateTime date;

  final format = DateFormat("yyyy-MM-dd");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[ IconButton(tooltip: "Confirm", icon: Icon(Icons.check, color:KColors.primaryColor), onPressed: (){_confirmContent();})],
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
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider("https://imgix.bustle.com/uploads/image/2018/5/9/fa2d3d8d-9b6c-4df4-af95-f4fa760e3c5c-2t4a9501.JPG?w=970&h=546&fit=crop&crop=faces&auto=format&q=70")
                        )
                    )
                ),
                Positioned(child: FloatingActionButton(
                  backgroundColor: KColors.primaryColor,
                  onPressed: () {},
                  child: Icon(Icons.photo_camera, color: Colors.white),
                ), right: 0,bottom: 0)]),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(
                    decoration: InputDecoration(labelText: "Phone Number",
                      border: InputBorder.none,
                    )),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(
                    decoration: InputDecoration(labelText: "Job Title",
                      border: InputBorder.none,
                    )),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(
                    decoration: InputDecoration(labelText: "Your district",
                      border: InputBorder.none,
                    )),
              ),
              SizedBox(height: 10),
              Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.white,
                  child:Column(children: <Widget>[
                    Text("I am ?", textAlign: TextAlign.left, style: TextStyle(color: KColors.primaryColor, fontSize: 12)),
                    /*  */
                    Row(children: <Widget>[
                      Text("Woman", style: TextStyle(color: Colors.black, fontSize: 16)), Radio(value: 0, groupValue: _genderRadioValue, onChanged: _handleGenderRadioValueChange),
                      Text("Man"), Radio(value: 1, groupValue: _genderRadioValue, onChanged: _handleGenderRadioValueChange)
                    ]),
                  ])
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(left: 10, right: 10,  bottom: 10),
                color: Colors.white,
               /* child: DateTimeField(
                  format: format,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                ),*/
              ),
              SizedBox(height: 20)
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

