import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';


class RetrievePasswordPage extends StatefulWidget {

  static var routeName = "/RetrievePasswordPage";

  RetrievePasswordPage({Key key, this.type = 0}) : super(key: key);

  final int type;

  @override
  _RetrievePasswordPageState createState() => _RetrievePasswordPageState();
}

class _RetrievePasswordPageState extends State<RetrievePasswordPage> {

  int _inputCount = 4;

  String pwd = "";


  /* create - confirm - insert */
  List<String> retrievePasswordTitle = ["Please enter your personnal Password", "Please setup a personnal Password", "Please confirm your personnal Password"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("INPUT PASSWORD", style:TextStyle(color:KColors.primaryColor)),
        leading: IconButton(icon: Icon(Icons.close, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[

            Container(margin: EdgeInsets.only(left:40, right: 40),child: Text(retrievePasswordTitle[this.widget.type], textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray)),

            /* password fields */
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[]
                  ..addAll(
                      List<Widget>.generate(_inputCount, (int index) {
                        return Container(
                            margin: EdgeInsets.only(right: (index!=_inputCount-1?10:0)),
                            decoration: new BoxDecoration(
                                border: new Border.all(color: Colors.grey.shade300)
                            ),
                            child: SizedBox(width: 65, height:65,child:Center(child:Text(pwd.trim().length > index ? pwd[index] : "", style: TextStyle(fontSize: 30,color: Colors.black)))));
                      })
                  )
            ),
            SizedBox(height:30),
            /* add a table showing the numbers */
            SizedBox(width: 280,child:
            Table(
              children: <TableRow>[
                TableRow(
                    children: <TableCell>[
                      TableCell(child:MaterialButton(child:Text("1"),color:Colors.grey.shade50, onPressed: () {_passwordAppendChar("1");})),
                      TableCell(child:MaterialButton(child:Text("2"),color:Colors.grey.shade50, onPressed: () {_passwordAppendChar("2");})),
                      TableCell(child:MaterialButton(child:Text("3"),color:Colors.grey.shade50, onPressed: () {_passwordAppendChar("3");})),
                    ]
                ),

                TableRow(
                    children: <TableCell>[
                      TableCell(child:MaterialButton(child:Text("4"),color:Colors.grey.shade50, onPressed: () {_passwordAppendChar("4");})),
                      TableCell(child:MaterialButton(child:Text("5"),color:Colors.grey.shade50, onPressed: () {_passwordAppendChar("5");})),
                      TableCell(child:MaterialButton(child:Text("6"),color:Colors.grey.shade50, onPressed: () {_passwordAppendChar("6");})),
                    ]
                ),

                TableRow(
                    children: <TableCell>[
                      TableCell(child:MaterialButton(child:Text("7"),color:Colors.grey.shade50, onPressed: () {_passwordAppendChar("7");})),
                      TableCell(child:MaterialButton(child:Text("8"),color:Colors.grey.shade50, onPressed: () {_passwordAppendChar("8");})),
                      TableCell(child:MaterialButton(child:Text("9"),color:Colors.grey.shade50, onPressed: () {_passwordAppendChar("9");})),
                    ]
                ),
                TableRow(
                    children: <TableCell>[
                      TableCell(child:Text("")),
                      TableCell(child:MaterialButton(child:Text("0"),color:Colors.grey.shade50, onPressed: () {_passwordAppendChar("0");})),
                      TableCell(child:MaterialButton(child:Text("DELETE"),color:Colors.grey.shade50, onPressed: () {_removeChar();}))
                    ]
                ),
              ],
            ))
          ]
      ),
    );
  }

  void _passwordAppendChar(String char) {
    if (pwd.length <= 4) {
      setState(() {
        pwd = "${pwd}${char}";
      });
    } else {
      switch (this.widget.type) {
        case 0:
        /* enter password.
        * send back the password to the popper
        *  */
        Navigator.of(context).pop({'code':pwd, 'type': this.widget.type});
          break;
        case 1:
        /* setup password
        *
        * send back the password to the popper ; and launch confirmation
        *  */
          Navigator.of(context).pop({'code':pwd, 'type': this.widget.type});
          break;
        case 2:
        /* confirm password creation
        *
        *  send back the password to the popper; and check if ok, go, or re-do the confirmation
        * */
          Navigator.of(context).pop({'code':pwd, 'type': this.widget.type});
          break;
      }
    }
  }

  void _removeChar() {
    setState(() {
      pwd = pwd.substring(0, pwd.length-1);
    });
  }
}
