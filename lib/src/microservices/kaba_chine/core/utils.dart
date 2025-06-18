import 'dart:ui';

class KabaChineColors {
  static const Color primary = Color(0xFFB81B3E);
  static const Color primary_darker = Color(0xFF7C0A23);
  static const Color secondary = Color(0xFF2B4C7E);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF333333);
  static const Color textLight = Color(0xFF666666);
  static const Color border = Color(0xFFE0E0E0);
  static const Color card = Color(0xFFFFFFFF);
}

class Offices {
  static const collection = _CollectionOffices();
  static const destination = _DestinationOffices();
}

class _CollectionOffices {
  const _CollectionOffices();

  final String guangzhou = 'GuangZhou';
  final String shenzhen = 'Shenzhen';
  final String yiwu = 'Yiwu';
}

class _DestinationOffices {
  const _DestinationOffices();

  final String lome = 'Lomé';
  final String agbalepedogan = 'Agbalépédogan';
}
