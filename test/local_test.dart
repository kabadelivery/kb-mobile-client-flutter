import 'package:KABA/src/xrint.dart';

void test() {
  final type = 'faosirjqo23 faosirjqo23 faosirjqo23  https://app.kaba-delivery.com/vouchers/IO93023LS faosirjqo23 faosirjqo23';
  final newType = RegExp(r'https://\S+/\S+').firstMatch(type);
  // final newType = RegExp(r'https://app.kaba-delivery.com/vouchers/\S/$').firstMatch(type);
  if (newType != null) {
    xrint(newType.group(0));
  } else {
    xrint("No match found");
  }
}

void main() {
  test();
}
