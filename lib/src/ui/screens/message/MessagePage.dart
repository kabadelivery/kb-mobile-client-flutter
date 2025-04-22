import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class MessagePage extends StatelessWidget {

  String? message;

  MessagePage({
    Key? key, this.message
  }): super(key:key);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: (Column(mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(message!)])
      ),
    );
  }



}