void test() {
  final type = 'faosirjqo23 faosirjqo23 faosirjqo23  https://app.kaba-delivery.com/vouchers/IO93023LS faosirjqo23 faosirjqo23';
  final newType = RegExp(r'https://\S+/\S+').firstMatch(type);
  // final newType = RegExp(r'https://app.kaba-delivery.com/vouchers/\S/$').firstMatch(type);
  if (newType != null) {
    print(newType.group(0));
  } else {
    print("No match found");
  }
}

void main() {
  test();
}
