import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:async/async.dart';
import 'package:kaba_flutter/src/l10n/messages_all.dart';

class KabaLocalizations {
  static Future<KabaLocalizations> load(Locale locale) {
    final String name = (locale.countryCode == null || locale.countryCode.isEmpty)
        ? locale.languageCode
        : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return KabaLocalizations();
    });
  }

  static KabaLocalizations of(BuildContext context) {
    return Localizations.of<KabaLocalizations>(context, KabaLocalizations);
  }

/* model traduction page splash*/

  String get app_name {
    return Intl.message(
      'KABA',
      name: 'app_name',
      desc: 'Title for the Kaba application',
    );
  }

  /* model traduction page connexion */

  String get connexion {
    return Intl.message(
      'CONNEXION',
      name: 'connexion',
      desc: 'connexion',
    );
  }

  String get recover_password {
    return Intl.message(
      'Recover Password',
      name: 'recover_password',
      desc: 'recover_password',
    );
  }

}

class KabaLocalizationsDelegate extends LocalizationsDelegate<KabaLocalizations> {
  const KabaLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es', 'zh'].contains(locale.languageCode);

  @override
  Future<KabaLocalizations> load(Locale locale) {
    return KabaLocalizations.load(locale);
  }

  @override
  bool shouldReload(KabaLocalizationsDelegate old) => false;
}