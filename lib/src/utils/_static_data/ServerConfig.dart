

class ServerConfig {

//  static const String ip_address = "app.kaba-delivery.com"; // prod server
//  static const String pay_ip_address = "pay.kaba-delivery.com";

  static const String ip_address = "dev.kaba-delivery.com"; // dev server
  static const String pay_ip_address = "dev.pay.kaba-delivery.com";

  static const String SERVER_ADDRESS = "http://"+ip_address;
  static const String SERVER_ADDRESS_SECURE = "https://"+ip_address;
  static const String PAY_SERVER_ADDRESS_SECURE = "https://"+pay_ip_address;
  static const String APP_SERVer = "https://app.kaba-delivery.com";

//  static String TOPIC = "kaba_flutter";
static String TOPIC = "kaba_delivery_all";

  static String LOGIN_EXPIRATION = "_login_expiration_date_${DateTime.now().year}";
}

