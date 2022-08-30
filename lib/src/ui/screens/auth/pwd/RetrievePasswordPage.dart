import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/recover_password_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/screens/auth/recover/RecoverPasswordPage.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  List<String> retrievePasswordTitle;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrievePasswordTitle = ["", "", "", ""];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    retrievePasswordTitle = [
      "${AppLocalizations.of(context).translate('enter_password')}",
      "${AppLocalizations.of(context).translate('setup_password')}",
      "${AppLocalizations.of(context).translate('confirm_password')}",
      "${AppLocalizations.of(context).translate('confirm_password_launch_order')}"
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: StateContainer.ANDROID_APP_SIZE,
        brightness: Brightness.light,
        backgroundColor: KColors.primaryColor,
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: () {
              Navigator.pop(context);
            }),
//        actions: <Widget>[ IconButton(tooltip: "Confirm", icon: Icon(Icons.check, color:KColors.primaryColor), onPressed: (){_confirmContent();})],
        title: Row(mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                Utils.capitalize(
                    "${AppLocalizations.of(context).translate('input_password')}"),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RichText(
                text: TextSpan(
                    text: "* ",
                    children: [
                      TextSpan(
                          text:retrievePasswordTitle[this.widget.type],
                              // "${AppLocalizations.of(context).translate('insert_transfer_amount')}",
                          style: TextStyle(fontSize: 12, color: Colors.grey))
                    ],
                    style: TextStyle(color: KColors.primaryColor))),

            /* password fields */
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[]
                  ..addAll(List<Widget>.generate(_inputCount, (int index) {
                    return Container(
                        margin: EdgeInsets.only(
                            right: (index != _inputCount - 1 ? 10 : 0)),
                        decoration: new BoxDecoration(
                            border:
                                new Border.all(color: Colors.grey.shade300)),
                        child: SizedBox(
                            width: 65,
                            height: 65,
                            child: Center(
                                child: Text(
                                    pwd.trim().length > index
                                        ? /*pwd[index]*/ "*"
                                        : "",
                                    style: TextStyle(
                                        fontSize: 30, color: KColors.new_black)))));
                  }))),
            SizedBox(height: 30),
            /* add a table showing the numbers */
            SizedBox(
                width: 280,
                child: Table(
                  children: <TableRow>[
                    TableRow(children: <TableCell>[
                      TableCell(
                          child: MaterialButton(
                              child: Text("1"),
                              color: Colors.grey.shade50,
                              onPressed: () {
                                _passwordAppendChar("1");
                              })),
                      TableCell(
                          child: MaterialButton(
                              child: Text("2"),
                              color: Colors.grey.shade50,
                              onPressed: () {
                                _passwordAppendChar("2");
                              })),
                      TableCell(
                          child: MaterialButton(
                              child: Text("3"),
                              color: Colors.grey.shade50,
                              onPressed: () {
                                _passwordAppendChar("3");
                              })),
                    ]),
                    TableRow(children: <TableCell>[
                      TableCell(
                          child: MaterialButton(
                              child: Text("4"),
                              color: Colors.grey.shade50,
                              onPressed: () {
                                _passwordAppendChar("4");
                              })),
                      TableCell(
                          child: MaterialButton(
                              child: Text("5"),
                              color: Colors.grey.shade50,
                              onPressed: () {
                                _passwordAppendChar("5");
                              })),
                      TableCell(
                          child: MaterialButton(
                              child: Text("6"),
                              color: Colors.grey.shade50,
                              onPressed: () {
                                _passwordAppendChar("6");
                              })),
                    ]),
                    TableRow(children: <TableCell>[
                      TableCell(
                          child: MaterialButton(
                              child: Text("7"),
                              color: Colors.grey.shade50,
                              onPressed: () {
                                _passwordAppendChar("7");
                              })),
                      TableCell(
                          child: MaterialButton(
                              child: Text("8"),
                              color: Colors.grey.shade50,
                              onPressed: () {
                                _passwordAppendChar("8");
                              })),
                      TableCell(
                          child: MaterialButton(
                              child: Text("9"),
                              color: Colors.grey.shade50,
                              onPressed: () {
                                _passwordAppendChar("9");
                              })),
                    ]),
                    TableRow(children: <TableCell>[
                      TableCell(child: Text("")),
                      TableCell(
                          child: MaterialButton(
                              child: Text("0"),
                              color: Colors.grey.shade50,
                              onPressed: () {
                                _passwordAppendChar("0");
                              })),
                      TableCell(
                          child: MaterialButton(
                              child: Icon(Icons.delete, color: KColors.primaryColor, size: 20),
                              /*Text(
                                  "${AppLocalizations.of(context).translate('delete')}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14)),*/
                              color: Colors.grey.shade50,
                              onPressed: () {
                                _removeChar();
                              }))
                    ]),
                  ],
                )),
            widget.type == 3
                ? Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 19),
                        Center(
                            child: InkWell(
                          onTap: () => _jumpToRecoverPage(),
                          // only when you are about to launch an order.
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 8, bottom: 20.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(FontAwesomeIcons.questionCircle,
                                    color: Colors.grey),
                                SizedBox(width: 5),
                                Text(
                                    "${AppLocalizations.of(context).translate('lost_your_password')}",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ))
                      ],
                    ),
                  )
                : Container(),
          ]),
    );
  }

  _jumpToRecoverPage() {
    /* can back once the password is changed */
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecoverPasswordPage(
            presenter: RecoverPasswordPresenter(), is_a_process: true),
      ),
    );
  }

  void _passwordAppendChar(String char) {
    if (pwd.length <= 4) {
      setState(() {
        pwd = "${pwd}${char}";
      });
    }
    if (pwd.length != 4) return;
    Navigator.of(context).pop({'code': pwd, 'type': this.widget.type});
  }

  void _removeChar() {
    setState(() {
      pwd = pwd.substring(0, pwd.length - 1);
    });
  }
}
