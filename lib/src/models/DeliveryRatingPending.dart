class DeliveryRatingPending{
  int?  command_id;
  String? delivery_man_image;
  String? delivery_man_name;
  String? article_name;
  String? seller_name;
  String? seller_image;
  double? delivery_rating;
  double? article_rating;

  DeliveryRatingPending({
     this.command_id,
     this.delivery_man_image,
     this.delivery_man_name,
     this.article_name,
     this.seller_name,
     this.seller_image,
     this.delivery_rating,
     this.article_rating,
});

  factory DeliveryRatingPending.fromJson(Map<String?, dynamic> json) {
   return DeliveryRatingPending(
     command_id: json['command_id'] as int,
     delivery_man_image: json['delivery_man_image'] as String?,
     delivery_man_name: json['delivery_man_name'] as String?,
     article_name: json['article_name'] as String?,
     seller_name: json['seller_name'] as String?,
     seller_image: json['seller_image'] as String?,
     delivery_rating: (json['delivery_rating'] as num).toDouble(),
     article_rating: (json['article_rating'] as num).toDouble(),

   ) ;
  }

  Map<String?, dynamic> toJson() {
    return {
      'command_id': command_id,
      'delivery_man_image': delivery_man_image,
      'delivery_man_name': delivery_man_name,
      'article_name': article_name,
      'seller_name': seller_name,
      'seller_image': seller_image,
      'delivery_rating': delivery_rating,
      'article_rating': article_rating,
    };
  }
  DeliveryRatingPending fake(){
    return DeliveryRatingPending(
      command_id: 1,
      delivery_man_image: "https://t3.ftcdn.net/jpg/01/97/11/64/360_F_197116416_hpfTtXSoJMvMqU99n6hGP4xX0ejYa4M7.jpg",
      delivery_man_name: "Farid ZACK",
      article_name: "Ayimolou,riz blanc, poisson braisé",
      seller_name: "Da vodou",
      seller_image: "https://c8.alamy.com/comp/F945NA/vodun-voodoo-priestess-in-a-village-near-abomey-benin-F945NA.jpg",
      delivery_rating: 3,
      article_rating: 3,
    );
  }

}