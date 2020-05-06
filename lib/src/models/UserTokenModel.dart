import 'package:flutter/foundation.dart';
import 'dart:core';

import 'package:KABA/src/models/NotificationFDestination.dart';

class UserTokenModel {

  /* feed is an entity */
  String token;

  UserTokenModel({this.token});

  UserTokenModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
  }

  Map toJson () => {
    "token" : token,
  };

  @override
  String toString() {
    return toJson().toString();
  }

  static UserTokenModel fake() {
   UserTokenModel userTokenModel = UserTokenModel();
   userTokenModel.token = "eyJhbGciOiJSUzI1NiJ9.eyJyb2xlcyI6WyJST0xFX1VTRVIiXSwidXNlcm5hbWUiOiI5MDYyODcyNSIsImlhdCI6MTU2Nzc5OTIyNSwiZXhwIjoxNTk4OTAzMjI1fQ.jcpPam_wLgCjjB2G6yQyNl_S_ze1Pc41qZ0oFdYP3ZC7GXBmIfp0JkJZ_nrWkeJgGvrNabGAfer1G21XHfb00FPezZh6g-uTszQ5mK1tCcl-De-Yv89XH5XkZ0EqLu3lYUqy28d-JlKlEBhJDZ7fc8y6ZpUWBfz0MUIpmIMICdvPm8UARvcEum0JiurS_tr4onishgNVqKX8bso7WWBuhNi4-dtsfu-X8TvnAhz7XNZLgl9a8eOSACFMhCaWEkXorirgMQ3n6cfK07SLy0MZQ9ExGSz_WBYzLy9ZWVtEwXOKLEGDdRUjZuH2Amnq9Gycmf5SWCJzoE_vgu4fE_fLax6pNoiyU8LfDWWvHWaaQoIKmWYvwE7J8I-ThW3q2W7kOD7NqHqarDu40v9mmaM0n6pLCO8IgzW-nyYAr6TNnP5rRFG1am0kiCp1gsM4Bnt3iECJY2_YsBKXrKfP0srOFlZbp8brpvE3ZN1-MYwYot395ov9QEdegKOpbf1FYu0FtbGeu--i29y6FtKI1zx_JcwNcrPMF9YLI0ntNpbOM7vqywkq-jwVmt50jdf-RzEmTh56juuw4BZHY8LhPGUGcnzffM0W3knrM6oJDUuS8-RINHxsiqceexQT9P_1bT_PWEMCnysFD6dLwLySDoNsWUZ-7GgJ2J5KM7CHpFIL2GA";
    return userTokenModel;
  }

}