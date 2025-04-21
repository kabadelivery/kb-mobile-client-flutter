


class NotificationFDestination {


 static const int FOOD_DETAILS = 373;
 static const int RESTAURANT_PAGE = 758;
 static const int RESTAURANT_MENU = 434;
 static const int MONEY_MOVMENT = 888;
 static const int SPONSORSHIP_TRANSACTION_ACTION = 889 ;
 static const int MESSAGE_SERVICE_CLIENT = 200;

 static const int IMPORTANT_INFORMATION = 999;

  /* get comand details */
 static const int COMMAND_PAGE = 90;
 static const int COMMAND_DETAILS = 154;

 static const int COMMAND_PREPARING = 300;
 static const int COMMAND_SHIPPING = 301;
 static const int COMMAND_END_SHIPPING = 302;
 static const int COMMAND_CANCELLED = 303;
 static const int COMMAND_REJECTED = 304;
  /* get article details */
 static const int ARTICLE_DETAILS = 128;


// TYPE_ARTICLE_WEB
  /* get food / menu details */


  /* help to know which activity we're going in */
  int? type;
  /* meta data attached with it */
  int? product_id; /* cn be product / restaurant */

  int? is_out_of_app;
  NotificationFDestination({this.type, this.product_id,this.is_out_of_app});

  NotificationFDestination.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    product_id = json['product_id'];
    is_out_of_app = json['is_out_of_app'];
  }
  Map toJson () => {
    "type" : type,
    "product_id" : product_id,
    "is_out_of_app" : is_out_of_app,
  };
  @override
  String toString() {
    return toJson().toString();
  }

 String toSpecialString() {
  return {
   "\"type\"" : type,
   "\"product_id\"" : product_id,
   "\"is_out_of_app\"" : is_out_of_app,
  }.toString();
 }

}
