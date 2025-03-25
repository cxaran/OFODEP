enum SubscriptionType {
  general('general'),
  special('special'),
  premium('premium');

  const SubscriptionType(this.description);
  final String description;

  static SubscriptionType fromString(String value) {
    return SubscriptionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SubscriptionType.general,
    );
  }

  String toShortString() => name;
}

enum OrderStatus {
  pending,
  accepted,
  onTheWay,
  delivered,
  cancelled;

  static OrderStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return OrderStatus.pending;
      case 'accepted':
        return OrderStatus.accepted;
      case 'on_the_way':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String toShortString() {
    switch (this) {
      case OrderStatus.onTheWay:
        return 'on_the_way';
      default:
        return name;
    }
  }
}

enum DeliveryMethod {
  delivery,
  pickup;

  static DeliveryMethod fromString(String value) {
    return DeliveryMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DeliveryMethod.delivery,
    );
  }

  String toShortString() => name;
}
