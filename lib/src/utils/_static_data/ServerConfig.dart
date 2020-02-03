

class ServerConfig {

//  static const String ip_address = "app1.kaba-delivery.com"; // prod server
//  static const String pay_ip_address = "pay.kaba-delivery.com";
  static const String ip_address = "dev.kaba-delivery.com"; // dev server
  static const String pay_ip_address = "dev.pay.kaba-delivery.com";
  static const String SERVER_ADDRESS = "http://"+ip_address;
  static const String SERVER_ADDRESS_SECURE = "https://"+ip_address;
  static const String PAY_SERVER_ADDRESS_SECURE = "https://"+pay_ip_address;

}
