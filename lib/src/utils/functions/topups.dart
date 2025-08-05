bool detectTogoMomoOperator(String phoneNumber) {
  phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
  if (phoneNumber.length > 8) {
    phoneNumber = phoneNumber.substring(phoneNumber.length - 8);
  }

  if (phoneNumber.length != 8) {
    return false;
  }

  String prefix = phoneNumber.substring(0, 2);

  const List<String> tmoneyPrefixes = ['70', '71', '72', '73', '90', '91', '92', '93'];
  const List<String> floozPrefixes  = ['79', '96', '97', '98', '99'];

  if (tmoneyPrefixes.contains(prefix)) {
    return true;
  }

  if (floozPrefixes.contains(prefix)) {
    return true;
  }

  return false;
}
