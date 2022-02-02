
class MoneyTransactionModel {

  int id;
  String details;
  String value;
  int state;
  int type; // 1 -> in, -1 -> out
  int created_at;
  bool payAtDelivery;

  MoneyTransactionModel({this.id, this.details, this.value, this.state, this.type, this.payAtDelivery,
    this.created_at}); // timestamp

  MoneyTransactionModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    details = json['details'];
    value = json['value'];
    state = json['state'];
    type = json['type'];
    payAtDelivery = json["payAtDelivery"];
    created_at = json['created_at'];
  }

  Map toJson () => {
    "type" : (type as int),
    "details" : details,
    "value" : value,
    "state" : state,
    "type" : type,
    "payAtDelivery" : payAtDelivery,
    "created_at" : created_at,
  };

  @override
  String toString() {
    return toJson().toString();
  }

}