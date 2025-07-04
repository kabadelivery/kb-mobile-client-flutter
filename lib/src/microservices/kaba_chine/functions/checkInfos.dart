import '../data/order/delivery_model.dart';

Map isFormInfosCorrect({required Delivery delivery,required bool generalConditionsAccepted,required bool packageIsSafeConditionAccepted})  {
  // Check if all required fields are filled
  if (delivery.packageName!.isEmpty) {
    return {"is_good":false, "msg":"Veuillez renseigner le nom du colis"};
  }
  if(delivery.trackingCode!.isEmpty){
    return {"is_good":false, "msg": "Veuillez renseigner le code du colis"};
  }
  if (delivery.declaredValue! <= 0) {
    return {"is_good":false, "msg":"Veuillez renseigner le prix du colis"};
  }
  if (delivery.estimatedWeight! <= 0) {
    return {"is_good":false, "msg":"Veuillez renseigner le poids du colis"};
  }
  if(delivery.productImage!.isEmpty)
    return {"is_good":false, "msg":"Veuillez renseigner une image du colis"};
  if(delivery.purchaseProofImage!.isEmpty)
    return {"is_good":false, "msg": "Veuillez renseigner une image de la preuve d'achat"};
  if (delivery.recipientName!.isEmpty) {
    return {"is_good":false, "msg": "Veuillez renseigner le nom du destinataire"};
  }
  if (delivery.buyerPhoneNumber!.isEmpty) {
    return {"is_good":false, "msg": "Veuillez renseigner le numéro de téléphone du destinataire"};
  }
  if(delivery.buyerPhoneNumber!.length<8){
    return {"is_good":false, "msg": "Votre numéro de téléphone doit être de 08 chiffres"};
  }

  if(generalConditionsAccepted==false){
    return {"is_good":false, "msg": "Veuillez accepter les conditions générales"};
  }
  if(packageIsSafeConditionAccepted==false){
    return {"is_good":false, "msg": "Veuillez confirmer que le colis est en bon état"};
  }
 // If all checks pass, return true
  return {"is_good":true, "msg": "Formulaire valide"};

}