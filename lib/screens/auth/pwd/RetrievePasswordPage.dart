import 'package:flutter/material.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';


class RetrievePasswordPage extends StatefulWidget {

  static var routeName = "/RetrievePasswordPage";

  RetrievePasswordPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RetrievePasswordPageState createState() => _RetrievePasswordPageState();
}

class _RetrievePasswordPageState extends State<RetrievePasswordPage> {

  int _inputCount = 4;

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
                            child: SizedBox(width: 65, height:65,child:Center(child:Text("*", style: TextStyle(fontSize: 30,color: Colors.black)))));
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
                      TableCell(child:MaterialButton(child:Text("1"),color:Colors.grey.shade50, onPressed: () {})),
                      TableCell(child:MaterialButton(child:Text("2"),color:Colors.grey.shade50, onPressed: () {})),
                      TableCell(child:MaterialButton(child:Text("3"),color:Colors.grey.shade50, onPressed: () {})),
                    ]
                ),

                TableRow(
                    children: <TableCell>[
                      TableCell(child:MaterialButton(child:Text("4"),color:Colors.grey.shade50, onPressed: () {})),
                      TableCell(child:MaterialButton(child:Text("5"),color:Colors.grey.shade50, onPressed: () {})),
                      TableCell(child:MaterialButton(child:Text("6"),color:Colors.grey.shade50, onPressed: () {})),
                    ]
                ),

                TableRow(
                    children: <TableCell>[
                      TableCell(child:MaterialButton(child:Text("7"),color:Colors.grey.shade50, onPressed: () {})),
                      TableCell(child:MaterialButton(child:Text("8"),color:Colors.grey.shade50, onPressed: () {})),
                      TableCell(child:MaterialButton(child:Text("9"),color:Colors.grey.shade50, onPressed: () {})),
                    ]
                ),
                TableRow(
                    children: <TableCell>[
                      TableCell(child:Text("")),
                      TableCell(child:MaterialButton(child:Text("8"),color:Colors.grey.shade50, onPressed: () {})),
                      TableCell(child:MaterialButton(child:Text("DELETE"),color:Colors.grey.shade50, onPressed: () {}))
                    ]
                ),
              ],
            ))
          ]
      ),
    );
  }
}

/*
* *
*

*
* */
