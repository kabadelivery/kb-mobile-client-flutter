


class PointObjModel {

  int? balance;
  int? can_use;
  bool? can_be_used;
  bool? is_eligible;
  // reasons
  bool? is_new_beneficiary;
  int? month_transactions_amount;
  int? month_transactions_amount_plus_amount_to_debit;
  int? client_command_count;
  int? client_ca_delivery;
  List<PointTransactionModel>? last_ten_transactions;
  
  int? eligible_order_count ; // 50
  int? monthly_limit_amount;
  int? amount_already_used;

//<editor-fold desc="Data Methods">

  PointObjModel({
      this.balance,
      this.can_use,
      this.can_be_used,
      this.is_eligible,
      this.is_new_beneficiary,
      this.month_transactions_amount,
     this.month_transactions_amount_plus_amount_to_debit,
     this.client_command_count,
     this.client_ca_delivery,
     this.last_ten_transactions,
     this.eligible_order_count,
     this.monthly_limit_amount,
    this.amount_already_used,
  });

// 30@override
  bool  operator ==(Object other) =>
      identical(this, other) ||
          (other is PointObjModel &&
              runtimeType == other.runtimeType &&
              balance == other.balance &&
              can_use == other.can_use &&
              can_be_used == other.can_be_used &&
              is_eligible == other.is_eligible &&
              is_new_beneficiary == other.is_new_beneficiary &&
              month_transactions_amount == other.month_transactions_amount &&
              month_transactions_amount_plus_amount_to_debit ==
                  other.month_transactions_amount_plus_amount_to_debit &&
              client_command_count == other.client_command_count &&
              client_ca_delivery == other.client_ca_delivery &&
              last_ten_transactions == other.last_ten_transactions &&
              eligible_order_count == other.eligible_order_count &&
              monthly_limit_amount == other.monthly_limit_amount &&
                amount_already_used == other.amount_already_used
          );


  @override
  int get hashCode =>
      balance.hashCode ^
      can_use.hashCode ^
      can_be_used.hashCode ^
      is_eligible.hashCode ^
      is_new_beneficiary.hashCode ^
      month_transactions_amount.hashCode ^
      month_transactions_amount_plus_amount_to_debit.hashCode ^
      client_command_count.hashCode ^
      client_ca_delivery.hashCode ^
      last_ten_transactions.hashCode ^
      eligible_order_count.hashCode ^
        amount_already_used!^
      monthly_limit_amount.hashCode;


  @override
  String toString() {
    return 'PointObjModel{' +
        ' balance: $balance,' +
        ' can_use: $can_use,' +
        ' can_be_used: $can_be_used,' +
        ' is_eligible: $is_eligible,' +
        ' is_new_beneficiary: $is_new_beneficiary,' +
        ' month_transactions_amount: $month_transactions_amount,' +
        ' month_transactions_amount_plus_amount_to_debit: $month_transactions_amount_plus_amount_to_debit,' +
        ' client_command_count: $client_command_count,' +
        ' client_ca_delivery: $client_ca_delivery,' +
        ' last_ten_transactions: $last_ten_transactions,' +
        ' eligible_order_count: $eligible_order_count,' +
        ' monthly_limit_amount: $monthly_limit_amount,' +
        ' amount_already_used: $amount_already_used,' +
        '}';
  }


  PointObjModel copyWith({
    int?  balance,
    int?  can_use,
    bool?  can_be_used,
    bool?  is_eligible,
    bool?  is_new_beneficiary,
    int?  month_transactions_amount,
    int?  month_transactions_amount_plus_amount_to_debit,
    int?  client_command_count,
    int?  client_ca_delivery,
    List<PointTransactionModel>? last_ten_transactions,
    int?  eligible_order_count,
    int?  monthly_limit_amount,
    int?  amount_already_used
  }) {
    return PointObjModel(
        amount_already_used : amount_already_used ?? this.amount_already_used,
      balance: balance ?? this.balance,
      can_use: can_use ?? this.can_use,
      can_be_used: can_be_used ?? this.can_be_used,
      is_eligible: is_eligible ?? this.is_eligible,
      is_new_beneficiary: is_new_beneficiary ?? this.is_new_beneficiary,
      month_transactions_amount: month_transactions_amount ??
          this.month_transactions_amount,
      month_transactions_amount_plus_amount_to_debit: month_transactions_amount_plus_amount_to_debit ??
          this.month_transactions_amount_plus_amount_to_debit,
      client_command_count: client_command_count ?? this.client_command_count,
      client_ca_delivery: client_ca_delivery ?? this.client_ca_delivery,
      last_ten_transactions: last_ten_transactions ??
          this.last_ten_transactions,
      eligible_order_count: eligible_order_count ?? this.eligible_order_count,
      monthly_limit_amount: monthly_limit_amount ?? this.monthly_limit_amount,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'balance': this.balance,
      'can_use': this.can_use,
      'can_be_used': this.can_be_used,
      'is_eligible': this.is_eligible,
      'is_new_beneficiary': this.is_new_beneficiary,
      'month_transactions_amount': this.month_transactions_amount,
      'month_transactions_amount_plus_amount_to_debit': this
          .month_transactions_amount_plus_amount_to_debit,
      'client_command_count': this.client_command_count,
      'client_ca_delivery': this.client_ca_delivery,
      'last_ten_transactions': this.last_ten_transactions,
      'eligible_order_count': this.eligible_order_count,
      'monthly_limit_amount': this.monthly_limit_amount,
      'amount_already_used': this.amount_already_used
    };
  }

  factory PointObjModel.fromMap(Map<String, dynamic> map) {
    return PointObjModel(
      balance: map['balance'] as int,
      can_use: map['can_use'] as int,
      amount_already_used: map['amount_already_used'] as int,
      can_be_used: map['can_be_used'] as bool,
      is_eligible: map['is_eligible'] as bool,
      is_new_beneficiary: map['is_new_beneficiary'] as bool,
      month_transactions_amount: map['month_transactions_amount'] as int,
      month_transactions_amount_plus_amount_to_debit: map['month_transactions_amount_plus_amount_to_debit'] as int,
      client_command_count: map['client_command_count'] as int,
      client_ca_delivery: map['client_ca_delivery'] as int,
      last_ten_transactions:
      (map['last_ten_transactions'] as List ?? [])?.map((f) => PointTransactionModel.fromMap(f))?.toList(),
      eligible_order_count: map['eligible_order_count'] as int,
      monthly_limit_amount: map['monthly_limit_amount'] as int,
    );
  }

  
  //</editor-fold>

//<editor-fold desc="Data Methods">
 
          //  
}



class PointTransactionModel {

  int?  id;
  int?  client_id;
  int?  amount;
  int?  before_balance;
  int?  after_balance;
  String?  type;
  bool?  is_remboursed;
  String?  created_at;
  String?  updated_at;



  PointTransactionModel({
    this.id,
    this.client_id,
    this.amount,
    this.before_balance,
    this.after_balance,
    this.type,
    this.is_remboursed,
    this.created_at,
    this.updated_at,
  });

  @override
  bool  operator ==(Object other) =>
      identical(this, other) ||
          (other is PointTransactionModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              client_id == other.client_id &&
              amount == other.amount &&
              before_balance == other.before_balance &&
              after_balance == other.after_balance &&
              type == other.type &&
              is_remboursed == other.is_remboursed &&
              created_at == other.created_at &&
              updated_at == other.updated_at);

  @override
  int  get hashCode =>
      id.hashCode ^
      client_id.hashCode ^
      amount.hashCode ^
      before_balance.hashCode ^
      after_balance.hashCode ^
      type.hashCode ^
      is_remboursed.hashCode ^
      created_at.hashCode ^
      updated_at.hashCode;

  @override
  String  toString() {
    return 'PointTransactionModel{' +
        ' id: $id,' +
        ' client_id: $client_id,' +
        ' amount: $amount,' +
        ' before_balance: $before_balance,' +
        ' after_balance: $after_balance,' +
        ' type: $type,' +
        ' is_remboursed: $is_remboursed,' +
        ' created_at: $created_at,' +
        ' updated_at: $updated_at,' +
        '}';
  }

  PointTransactionModel copyWith({
    int?  id,
    int?  client_id,
    int?  amount,
    int?  before_balance,
    int?  after_balance,
    String?  type,
    bool?  is_remboursed,
    String?  created_at,
    String?  updated_at,
  }) {
    return PointTransactionModel(
      id: id ?? this.id,
      client_id: client_id ?? this.client_id,
      amount: amount ?? this.amount,
      before_balance: before_balance ?? this.before_balance,
      after_balance: after_balance ?? this.after_balance,
      type: type ?? this.type,
      is_remboursed: is_remboursed ?? this.is_remboursed,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'client_id': this.client_id,
      'amount': this.amount,
      'before_balance': this.before_balance,
      'after_balance': this.after_balance,
      'type': this.type,
      'is_remboursed': this.is_remboursed,
      'created_at': this.created_at,
      'updated_at': this.updated_at,
    };
  }

  factory PointTransactionModel.fromMap(Map<String, dynamic> map) {
    return PointTransactionModel(
      id: map['id'] as int,
      client_id: map['client_id'] as int,
      amount: map['amount'] as int,
      before_balance: map['before_balance'] as int,
      after_balance: map['after_balance'] as int,
      type: map['type'] as String,
      is_remboursed: map['is_remboursed'] as bool,
      created_at: map['created_at'] as String,
      updated_at: map['updated_at'] as String,
    );
  }

}