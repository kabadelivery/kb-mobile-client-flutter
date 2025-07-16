enum PaymentState {
  success(100),
  error(101),
  notEnoughToPay(102);
  final int value;
  const PaymentState(this.value);
}