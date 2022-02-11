
class MoneyTransactionModel {

  int id;
  String details;
  String value;
  int state;
  int type;
  int created_at;
  bool payAtDelivery;
  int command_id;

  MoneyTransactionModel({
    this.id,
    this.details,
    this.value,
    this.state,
    this.type,
    this.created_at,
    this.payAtDelivery,
    this.command_id,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is MoneyTransactionModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              details == other.details &&
              value == other.value &&
              state == other.state &&
              type == other.type &&
              created_at == other.created_at &&
              payAtDelivery == other.payAtDelivery &&
              command_id == other.command_id);

  @override
  int get hashCode =>
      id.hashCode ^
      details.hashCode ^
      value.hashCode ^
      state.hashCode ^
      type.hashCode ^
      created_at.hashCode ^
      payAtDelivery.hashCode ^
      command_id.hashCode;

  @override
  String toString() {
    return 'MoneyTransactionModel{' +
        ' id: $id,' +
        ' details: $details,' +
        ' value: $value,' +
        ' state: $state,' +
        ' type: $type,' +
        ' created_at: $created_at,' +
        ' payAtDelivery: $payAtDelivery,' +
        ' command_id: $command_id,' +
        '}';
  }

  MoneyTransactionModel copyWith({
    int id,
    String details,
    String value,
    int state,
    int type,
    int created_at,
    bool payAtDelivery,
    int command_id,
  }) {
    return MoneyTransactionModel(
      id: id ?? this.id,
      details: details ?? this.details,
      value: value ?? this.value,
      state: state ?? this.state,
      type: type ?? this.type,
      created_at: created_at ?? this.created_at,
      payAtDelivery: payAtDelivery ?? this.payAtDelivery,
      command_id: command_id ?? this.command_id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'details': this.details,
      'value': this.value,
      'state': this.state,
      'type': this.type,
      'created_at': this.created_at,
      'payAtDelivery': this.payAtDelivery,
      'command_id': this.command_id,
    };
  }

  factory MoneyTransactionModel.fromMap(Map<String, dynamic> map) {
    return MoneyTransactionModel(
      id: map['id'] as int,
      details: map['details'] as String,
      value: map['value'] as String,
      state: map['state'] as int,
      type: map['type'] as int,
      created_at: map['created_at'] as int,
      payAtDelivery: map['payAtDelivery'] as bool,
      command_id: map['command_id'] as int,
    );
  }

//</editor-fold>
}