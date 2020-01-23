
class TransactionModel {

  int id;
  String details;
  String value;
  int state;
  int type; // 1 -> in, -1 -> out
  String created_at;

  TransactionModel({this.id, this.details, this.value, this.state, this.type,
      this.created_at}); // timestamp

  TransactionModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    details = json['details'];
    value = json['value'];
    state = json['state'];
    type = json['type'];
    created_at = json['created_at'];
  }

  Map toJson () => {
    "type" : (type as int),
    "details" : details,
    "value" : value,
    "state" : state,
    "type" : type,
    "created_at" : created_at,
  };

  @override
  String toString() {
    return toJson().toString();
  }

}