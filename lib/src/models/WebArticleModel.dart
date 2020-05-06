import 'package:KABA/src/models/ArticleContentModel.dart';

class WebArticle {

  int id;
  int likeCount;
  ArticleContentModel article;
  String udpatedAt;

  WebArticle.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    likeCount = json['likeCount'];
    article = ArticleContentModel.fromJson(json['article']);
    udpatedAt = json['udpatedAt'];
  }

  Map toJson () => {
    "id" : (id as int),
    "likeCount" : likeCount,
    "article" : article.toJson(),
    "udpatedAt" : udpatedAt,
  };

  @override
  String toString() {
    return toJson().toString();
  }
}

class WebBloc {

  static final int SINGLE_IMAGE = 94;
  static final int TEXT_CONTENT = 96;

  static final int OPEN_RESTAURANT_ACTION = 98;
  static final int OPEN_FOOD_ACTION = 97;
  static final int OPEN_MENU_ACTION = 90;

  /* type ? content ?  style ? */
  int type;
  String data;

  WebBloc.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    data = json['data'];
  }

  Map toJson () => {
    "type" : (type as int),
    "data" : data,
  };

  @override
  String toString() {
    return toJson().toString();
  }

}



