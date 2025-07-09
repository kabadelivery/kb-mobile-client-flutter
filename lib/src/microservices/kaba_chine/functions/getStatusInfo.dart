import 'dart:ui';

import 'package:flutter/material.dart';

import '../Enums/deliveryStatus.dart';
import '../core/utils.dart';

StatusInfo getStatusInfo(DeliveryStatus status) {
  switch (status) {
    case DeliveryStatus.pending:
      return StatusInfo(
        text: 'En attente',
        color: Color(0xFFF39C12),
        icon: Icons.access_time,
        actionRequired: 'En attente de confirmation par KABA',
      );
    case DeliveryStatus.accepted:
      return StatusInfo(
        text: 'Accepté',
        color: Color(0xFF2ECC71),
        icon: Icons.check_circle_outline,
      );
    case DeliveryStatus.collected:
      return StatusInfo(
        text: 'Collecté',
        color: Color(0xFF3498DB),
        icon: Icons.archive_outlined,
        actionRequired: 'Paiement requis pour expédition',
      );
    case DeliveryStatus.inTransit:
      return StatusInfo(
        text: 'En transit',
        color: Color(0xFF9B59B6),
        icon: Icons.directions_boat_outlined,
      );
    case DeliveryStatus.arrived:
      return StatusInfo(
        text: 'Arrivé',
        color: Color(0xFF1ABC9C),
        icon: Icons.flag_outlined,
      );
    case DeliveryStatus.readyForPickup:
      return StatusInfo(
        text: 'Prêt pour récupération',
        color: Color(0xFF27AE60),
        icon: Icons.inventory_2_outlined,
        actionRequired: 'Venez récupérer votre colis',
      );
    case DeliveryStatus.outForDelivery:
      return StatusInfo(
        text: 'En cours de livraison',
        color: Color(0xFF2980B9),
        icon: Icons.local_shipping_outlined,
      );
    case DeliveryStatus.delivered:
      return StatusInfo(
        text: 'Livré',
        color: Color(0xFF2ECC71),
        icon: Icons.done_all_outlined,
      );
    case DeliveryStatus.cancelled:
      return StatusInfo(
        text: 'Annulé',
        color: Color(0xFFE74C3C),
        icon: Icons.cancel_outlined,
      );
    case DeliveryStatus.readyToPay:
      return StatusInfo(
        text: 'Prêt à payer',
        color: Color(0xFF2ECC71),
        icon: Icons.payment_outlined,
      );
    default:
      return StatusInfo(
        text: 'Inconnu',
        color: Color(0xFF95A5A6),
        icon: Icons.help_outline,
      );
  }
}
