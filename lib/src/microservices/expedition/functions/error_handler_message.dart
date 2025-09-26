import 'package:KABA/src/microservices/expedition/data/expedition/create_expedition_model.dart';

String handleExpeditionFormMessage(CreateExpedition createExpedition) {
  if (createExpedition.adresseOrigine == null) {
    return "Choisissez une adresse d'origine";
  }

  if (createExpedition.telephoneOrigine == null) {
    return "Entrez votre numéro de téléphone";
  }

  if (createExpedition.methodeCollecte == null) {
    return "Choisissez une méthode de collecte";
  }

  if (createExpedition.colis == null) {
    return "Ajoutez un colis à expédier";
  }
  if(createExpedition.methodeCollecte==null){
    return "Choisissez une méthode de collecte";
  }
  if(createExpedition.methodeCollecte!="DEPOT_PARTENAIRE" && createExpedition.dateCollecte==null){
    return "Choisissez une date de collecte";
  }
  if(createExpedition.methodeCollecte!="DEPOT_PARTENAIRE" &&createExpedition.heureCollecte==null){
    return "Choisissez une heure de collecte";
  }
  if (createExpedition.colis!.isEmpty) {
    return "Ajoutez au moins un colis à expédier";
  }

  for (var i = 0; i < createExpedition.colis!.length; i++) {
    final colis = createExpedition.colis![i];
    final numero = i + 1;

    if (colis.poids == null) {
      return "Votre colis numéro $numero doit avoir un poids";
    }

    if (colis.description == null) {
      return "Votre colis numéro $numero doit avoir une description";
    }

    if (colis.adresseDestination == null && colis.adresseDestination==null) {
      return "Votre colis numéro $numero doit avoir une adresse de destination";
    }


    if (colis.departureTown == null) {
      return "Votre colis numéro $numero doit avoir une ville de départ";
    }

    if (colis.arrivalTown == null) {
      return "Votre colis numéro $numero doit avoir une ville d’arrivée";
    }

    if (colis.recipientAddress == null) {
      return "Votre colis numéro $numero doit avoir une adresse de destinataire";
    }

    if (colis.recipientPhoneNumber == null) {
      return "Votre colis numéro $numero doit avoir un numéro de téléphone destinataire";
    }

    if (colis.images == null || colis.images!.length < 2) {
      return "Votre colis numéro $numero doit avoir au moins 02 images";
    }
  }
  return "";
}
