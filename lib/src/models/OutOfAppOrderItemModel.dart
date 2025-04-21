
class OutOfAppOrderItemModel {
   String? name;
   String? price;
   String? quantity;
   String? pic="";

  // Constructor
  OutOfAppOrderItemModel({
     this.name,
     this.price,
     this.quantity,
     this.pic,
  });

  factory OutOfAppOrderItemModel.fromJson(Map<String, dynamic> json) {
    return OutOfAppOrderItemModel(
      name: json['name'] as String,
      price: json['price'] as String,
      quantity: json['quantity'] as String,
      pic: json['pic'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'pic': pic,
    };
  }
}
