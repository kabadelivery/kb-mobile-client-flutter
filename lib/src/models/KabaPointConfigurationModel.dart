

class KabaPointConfigurationModel {

  int balance;
  bool is_eligible;
  bool can_be_used;
  bool is_new_beneficiary;
  int can_use_amount;
  int amount_to_reduce;
  int client_command_count;
  int month_transactions_amount;
  int monthly_limit_amount;
  int lower_balance_limit_amount;
  int eligible_order_count;

//<editor-fold desc="Data Methods">

  KabaPointConfigurationModel({
       this.balance,
      this.is_eligible,
      this.can_be_used,
      this.is_new_beneficiary,
      this.can_use_amount,
      this.amount_to_reduce,
      this.client_command_count,
      this.month_transactions_amount,
      this.monthly_limit_amount,
      this.lower_balance_limit_amount,
      this.eligible_order_count,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KabaPointConfigurationModel &&
          runtimeType == other.runtimeType &&
          balance == other.balance &&
          is_eligible == other.is_eligible &&
          can_be_used == other.can_be_used &&
          is_new_beneficiary == other.is_new_beneficiary &&
          can_use_amount == other.can_use_amount &&
          amount_to_reduce == other.amount_to_reduce &&
          client_command_count == other.client_command_count &&
          month_transactions_amount == other.month_transactions_amount &&
          monthly_limit_amount == other.monthly_limit_amount &&
          lower_balance_limit_amount == other.lower_balance_limit_amount &&
          eligible_order_count == other.eligible_order_count);

  @override
  int get hashCode =>
      balance.hashCode ^
      is_eligible.hashCode ^
      can_be_used.hashCode ^
      is_new_beneficiary.hashCode ^
      can_use_amount.hashCode ^
      amount_to_reduce.hashCode ^
      client_command_count.hashCode ^
      month_transactions_amount.hashCode ^
      monthly_limit_amount.hashCode ^
      lower_balance_limit_amount.hashCode ^
      eligible_order_count.hashCode;

  @override
  String toString() {
    return 'KabaPointConfigurationModel{' +
        ' balance: $balance,' +
        ' is_eligible: $is_eligible,' +
        ' can_be_used: $can_be_used,' +
        ' is_new_beneficiary: $is_new_beneficiary,' +
        ' can_use_amount: $can_use_amount,' +
        ' amount_to_reduce: $amount_to_reduce,' +
        ' client_command_count: $client_command_count,' +
        ' month_transactions_amount: $month_transactions_amount,' +
        ' monthly_limit_amount: $monthly_limit_amount,' +
        ' lower_balance_limit_amount: $lower_balance_limit_amount,' +
        ' eligible_order_count: $eligible_order_count,' +
        '}';
  }

  KabaPointConfigurationModel copyWith({
    String balance,
    bool is_eligible,
    bool can_be_used,
    bool is_new_beneficiary,
    int can_use_amount,
    int amount_to_reduce,
    int client_command_count,
    int month_transactions_amount,
    int monthly_limit_amount,
    int lower_balance_limit_amount,
    int eligible_order_count,
  }) {
    return KabaPointConfigurationModel(
      balance: balance ?? this.balance,
      is_eligible: is_eligible ?? this.is_eligible,
      can_be_used: can_be_used ?? this.can_be_used,
      is_new_beneficiary: is_new_beneficiary ?? this.is_new_beneficiary,
      can_use_amount: can_use_amount ?? this.can_use_amount,
      amount_to_reduce: amount_to_reduce ?? this.amount_to_reduce,
      client_command_count: client_command_count ?? this.client_command_count,
      month_transactions_amount:
          month_transactions_amount ?? this.month_transactions_amount,
      monthly_limit_amount: monthly_limit_amount ?? this.monthly_limit_amount,
      lower_balance_limit_amount:
          lower_balance_limit_amount ?? this.lower_balance_limit_amount,
      eligible_order_count: eligible_order_count ?? this.eligible_order_count,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'balance': this.balance,
      'is_eligible': this.is_eligible,
      'can_be_used': this.can_be_used,
      'is_new_beneficiary': this.is_new_beneficiary,
      'can_use_amount': this.can_use_amount,
      'amount_to_reduce': this.amount_to_reduce,
      'client_command_count': this.client_command_count,
      'month_transactions_amount': this.month_transactions_amount,
      'monthly_limit_amount': this.monthly_limit_amount,
      'lower_balance_limit_amount': this.lower_balance_limit_amount,
      'eligible_order_count': this.eligible_order_count,
    };
  }

  factory KabaPointConfigurationModel.fromMap(Map<String, dynamic> map) {
    return KabaPointConfigurationModel(
      balance: map['balance'] as int,
      is_eligible: map['is_eligible'] as bool,
      can_be_used: map['can_be_used'] as bool,
      is_new_beneficiary: map['is_new_beneficiary'] as bool,
      can_use_amount: map['can_use_amount'] as int,
      amount_to_reduce: map['amount_to_reduce'] as int,
      client_command_count: map['client_command_count'] as int,
      month_transactions_amount: map['month_transactions_amount'] as int,
      monthly_limit_amount: map['monthly_limit_amount'] as int,
      lower_balance_limit_amount: map['lower_balance_limit_amount'] as int,
      eligible_order_count: map['eligible_order_count'] as int,
    );
  }

//</editor-fold>
}