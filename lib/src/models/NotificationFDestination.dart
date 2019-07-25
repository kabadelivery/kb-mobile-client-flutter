


class NotificationFDestination {


  final int FOOD_DETAILS = 373;
  final int RESTAURANT_PAGE = 758;
  final int RESTAURANT_MENU = 434;
  final int MONEY_MOVMENT = 888;

  /* get comand details */
  final int COMMAND_PAGE = 90;
  final int COMMAND_DETAILS = 154;

  final int COMMAND_PREPARING = 300;
  final int COMMAND_SHIPPING = 301;
  final int COMMAND_END_SHIPPING = 302;
  final int COMMAND_CANCELLED = 303;
  final int COMMAND_REJECTED = 304;

  /* get article details */
  final int ARTICLE_DETAILS = 128;


  /* help to know which activity we're going in */
  int type;

  /* meta data attached with it */
  int product_id; /* cn be product / restaurant */


  NotificationFDestination({this.type, this.product_id});

  NotificationFDestination.fromJson(Map<String, dynamic> json) {

    type = json['type'];
    product_id = json['product_id'];
  }

  Map toJson () => {
    "type" : (type as int),
    "product_id" : product_id,
  };

  @override
  String toString() {
    return toJson().toString();
  }

}
