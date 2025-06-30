enum DeliveryStatus {
  pending("PENDING"),
  accepted("ACCEPTED"),
  collected("COLLECTED"),
  inTransit("IN_TRANSIT"),
  arrived("ARRIVED"),
  readyForPickup("READY_FOR_PICKUP"),
  outForDelivery("OUT_FOR_DELIVERY"),
  delivered("DELIVERED"),
  cancelled("CANCELLED");
  final String value;
  const DeliveryStatus(this.value);
}
