import 'package:KABA/src/models/WebArticleModel.dart';



class ArticleContentModel {

  int? id;
  List<WebBloc>? content;
  String? title;
  List<String>? image_title;
  String? udpatedAt;

  ArticleContentModel.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    title = json['title'];
    image_title = json['image_title'];
    udpatedAt = json['udpatedAt'];
  }

  Map toJson () => {
    "id" : (id as int),
    "title" : title,
    "udpatedAt" : udpatedAt,
    "image_title" : image_title,
    "content" : content,
  };



}
