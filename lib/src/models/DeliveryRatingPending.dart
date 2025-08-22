class DeliveryRatingPending{
  int?  command_id;
  String? delivery_man_image;
  String? delivery_man_name;
  List<Map<String,dynamic>>? articles;
  String? seller_name;
  String? seller_image;
  double? delivery_rating;
  double? article_rating;
  String? article_comment;
  String? delivery_comment;
  int? speedRating;
  int? respectOfGeolocation;
  int? attidudeOfDeliveryMan;
  int? groomingOfDeliveryMan;
  DeliveryRatingPending({
     this.command_id,
     this.delivery_man_image,
     this.delivery_man_name,
     this.articles,
     this.seller_name,
     this.seller_image,
     this.delivery_rating,
     this.article_rating,
      this.article_comment,
      this.delivery_comment,
      this.speedRating,
      this.respectOfGeolocation,
      this.attidudeOfDeliveryMan,
      this.groomingOfDeliveryMan,
});

  factory DeliveryRatingPending.fromJson(Map<String?, dynamic> json) {
   return DeliveryRatingPending(
     command_id: json['command_id'] as int,
     delivery_man_image: json['delivery_man_image'] as String?,
     delivery_man_name: json['delivery_man_name'] as String?,
     articles: json['article_name'] as List<Map<String,dynamic>>?,
     seller_name: json['seller_name'] as String?,
     seller_image: json['seller_image'] as String?,
     delivery_rating: (json['delivery_rating'] as num).toDouble(),
     article_rating: (json['article_rating'] as num).toDouble(),
     article_comment: json['article_comment'] as String?,
     delivery_comment: json['delivery_comment'] as String?,
      speedRating: json['speedRating'] as int?,
      respectOfGeolocation: json['respectOfGeolocation'] as int?,
      attidudeOfDeliveryMan: json['attidudeOfDeliveryMan'] as int?,
      groomingOfDeliveryMan: json['groomingOfDeliveryMan'] as int?,
   ) ;
  }

  Map<String?, dynamic> toJson() {
    return {
      'command_id': command_id,
      'delivery_man_image': delivery_man_image,
      'delivery_man_name': delivery_man_name,
      'articles': articles,
      'seller_name': seller_name,
      'seller_image': seller_image,
      'delivery_rating': delivery_rating,
      'article_rating': article_rating,
      'article_comment': article_comment,
      'delivery_comment': delivery_comment,
      'speedRating': speedRating,
      'respectOfGeolocation': respectOfGeolocation,
      'attidudeOfDeliveryMan': attidudeOfDeliveryMan,
      'groomingOfDeliveryMan': groomingOfDeliveryMan,
    };
  }
  DeliveryRatingPending fake(){
    return DeliveryRatingPending(
      command_id: 1,
      delivery_man_image: "https://t3.ftcdn.net/jpg/01/97/11/64/360_F_197116416_hpfTtXSoJMvMqU99n6hGP4xX0ejYa4M7.jpg",
      delivery_man_name: "Farid ZACK",
      articles: [
        {
          "name": "Poulet braisé",
          "id": 2,
          "rating":3
        },
        {
          "name": "Frites",
           "id": 1,
          "rating":3
        }
      ],
      seller_name: "Da vodou",
      seller_image: "https://c8.alamy.com/comp/F945NA/vodun-voodoo-priestess-in-a-village-near-abomey-benin-F945NA.jpg",
      delivery_rating: 3,
      article_rating: 3,
      article_comment: "C'est un bon plat, mais il manque de sel.",
      delivery_comment: "Le livreur était ponctuel et courtois.",
      speedRating: 3,
      respectOfGeolocation: 3,
      attidudeOfDeliveryMan: 3,
      groomingOfDeliveryMan: 3,
    );
  }

}