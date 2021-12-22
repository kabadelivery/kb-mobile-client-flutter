// Import the test package and Counter class
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test server configurations before we go upper', () {

    // must increase version of the build which use to be at 3.2.3

    expect(ServerConfig.ip_address, "app.kaba-delivery.com");
    expect(ServerConfig.pay_ip_address, "pay.kaba-delivery.com");
    expect(ServerConfig.APP_SERVer, "https://app.kaba-delivery.com");
    expect(ServerConfig.APP_SERVER_HOST, "app.kaba-delivery.com");
    expect(ServerConfig.TOPIC, "kaba_delivery_all");
    expect(ServerConfig.HMS_TOPIC, "kaba_delivery_all");
    expect(ServerConfig.SHARED_PREF_FIRST_TIME_IN_APP, "_first_time_19062021");
  });
}