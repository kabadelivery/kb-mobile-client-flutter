enum DeliveryStatus {
  pending(0),
  accepted(1),
  collected(2),
  inTransit(3),
  arrived(4),
  readyForPickup(5),
  outForDelivery(6),
  delivered(7),
  cancelled(8);

  final int value;
  const DeliveryStatus(this.value);
}
