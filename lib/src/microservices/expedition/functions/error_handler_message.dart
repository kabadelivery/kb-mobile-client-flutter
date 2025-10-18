import 'package:KABA/src/microservices/expedition/data/expedition/create_expedition_model.dart';
import 'package:flutter/cupertino.dart';

import '../../../localizations/AppLocalizations.dart';
String handleExpeditionFormMessage(AppLocalizations loc, CreateExpedition createExpedition) {

  if (createExpedition.telephoneOrigine == null || createExpedition.telephoneOrigine!.isEmpty) {
    return "${loc.translate('enter_phone_number')}";
  }

  if (createExpedition.methodeCollecte == null || createExpedition.methodeCollecte!.isEmpty) {
    return "${loc.translate('choose_collection_method')}";
  }

  if (createExpedition.colis == null || createExpedition.colis!.isEmpty) {
    return "${loc.translate('add_package')}";
  }

  if (createExpedition.methodeCollecte != "DEPOT_PARTENAIRE" && createExpedition.dateCollecte == null) {
    return "${loc.translate('choose_collection_date')}";
  }

  if (createExpedition.methodeCollecte != "DEPOT_PARTENAIRE" && createExpedition.heureCollecte == null) {
    return "${loc.translate('choose_collection_time')}";
  }

  if (createExpedition.colis!.isEmpty || createExpedition.colis!.length == 0) {
    return "${loc.translate('add_at_least_one_package')}";
  }

  for (var i = 0; i < createExpedition.colis!.length; i++) {
    final colis = createExpedition.colis![i];
    final numero = i + 1;

    if (colis.poids == null || colis.poids==0) {
      return loc.translate('package_must_have_weight').replaceAll('{number}', '$numero');
    }

    if (colis.description == null|| colis.description!.isEmpty) {
      return loc.translate('package_must_have_description').replaceAll('{number}', '$numero');
    }

    if ((colis.adresseDestination == null && colis.recipientAddress == null) || (colis.adresseDestination!.isEmpty)) {
      return loc.translate('package_must_have_destination').replaceAll('{number}', '$numero');
    }

    if (colis.departureTown == null || colis.departureTown!.isEmpty) {
      return loc.translate('package_must_have_departure_town').replaceAll('{number}', '$numero');
    }

    if (colis.arrivalTown == null || colis.arrivalTown!.isEmpty) {
      return loc.translate('package_must_have_arrival_town').replaceAll('{number}', '$numero');
    }

    if (colis.recipientPhoneNumber == null || colis.recipientPhoneNumber!.isEmpty) {
      return loc.translate('package_must_have_recipient_phone').replaceAll('{number}', '$numero');
    }

    if (colis.images == null || colis.images!.length < 2) {
      return loc.translate('package_must_have_two_images').replaceAll('{number}', '$numero');
    }
  }

  return "";
}
