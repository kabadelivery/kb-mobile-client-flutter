import 'package:url_launcher/url_launcher.dart';

void contactWhatsApp({required String phoneNumber}) {
  final Uri whatsappUrl = Uri.parse(
      'https://api.whatsapp.com/send?phone=$phoneNumber');
  launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
}
void contactEmail({required String email}) {
  final Uri emailUrl = Uri.parse('mailto:$email');
  launchUrl(emailUrl, mode: LaunchMode.externalApplication);
}
void contactPhone({required String phoneNumber}) {
  final Uri phoneUrl = Uri.parse('tel:$phoneNumber');
  launchUrl(phoneUrl, mode: LaunchMode.externalApplication);
}
void goToNavigator({required String url}){
  final Uri urlLaunch = Uri.parse(url);
  launchUrl(urlLaunch, mode: LaunchMode.externalApplication);
}