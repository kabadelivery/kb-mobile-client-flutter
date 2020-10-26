//FeedsProvider


import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/xrint.dart';
import 'package:http/http.dart' show Client;
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/FeedModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/DebugTools.dart';
import 'package:KABA/src/utils/functions/Utils.dart';

class FeedApiProvider {

  Client client = Client();

  Future<Object> fetchFeedList (CustomerModel customer) async {

    xrint("entered getFeedHistory");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_LASTEST_FEEDS,
          body: json.encode({}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
     xrint(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"]["notification_feeds"];
          if (lo == null || lo.isEmpty || lo.length == 0)
            return List<FeedModel>();
          else {
            List<FeedModel> feeds = lo?.map((feed) =>
                FeedModel.fromJson(feed))?.toList();
            return feeds;
          }
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

}