import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Enums/deliveryStatus.dart';
import '../core/utils.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
StatusInfo getStatusInfo(BuildContext context, DeliveryStatus status) {
  switch (status) {
    case DeliveryStatus.pending:
      return StatusInfo(
        text: "${AppLocalizations.of(context)!.translate('status_pending')}",
        color: Color(0xFFF39C12),
        icon: Icons.access_time,
        actionRequired: "${AppLocalizations.of(context)!.translate('status_pending_action')}",
      );
    case DeliveryStatus.accepted:
      return StatusInfo(
        text: "${AppLocalizations.of(context)!.translate('status_accepted')}",
        color: Color(0xFF2ECC71),
        icon: Icons.check_circle_outline,
      );
    case DeliveryStatus.collected:
      return StatusInfo(
        text: "${AppLocalizations.of(context)!.translate('status_collected')}",
        color: Color(0xFF3498DB),
        icon: Icons.archive_outlined,
        actionRequired: "${AppLocalizations.of(context)!.translate('status_collected_action')}",
      );
    case DeliveryStatus.inTransit:
      return StatusInfo(
        text: "${AppLocalizations.of(context)!.translate('status_in_transit')}",
        color: Color(0xFF9B59B6),
        icon: Icons.directions_boat_outlined,
      );
    case DeliveryStatus.arrived:
      return StatusInfo(
        text:"${AppLocalizations.of(context)!.translate('status_arrived')}",
        color: Color(0xFF1ABC9C),
        icon: Icons.flag_outlined,
      );
    case DeliveryStatus.readyForPickup:
      return StatusInfo(
        text: "${AppLocalizations.of(context)!.translate('status_ready_for_pickup')}",
        color: Color(0xFF27AE60),
        icon: Icons.inventory_2_outlined,
        actionRequired: "${AppLocalizations.of(context)!.translate('status_ready_for_pickup_action')}",
      );
    case DeliveryStatus.outForDelivery:
      return StatusInfo(
        text: "${AppLocalizations.of(context)!.translate('status_out_for_delivery')}",
        color: Color(0xFF2980B9),
        icon: Icons.local_shipping_outlined,
      );
    case DeliveryStatus.delivered:
      return StatusInfo(
        text: "${AppLocalizations.of(context)!.translate('status_delivered')}",
        color: Color(0xFF2ECC71),
        icon: Icons.done_all_outlined,
      );
    case DeliveryStatus.cancelled:
      return StatusInfo(
        text: "${AppLocalizations.of(context)!.translate('status_cancelled')}",
        color: Color(0xFFE74C3C),
        icon: Icons.cancel_outlined,
      );
    case DeliveryStatus.readyToPay:
      return StatusInfo(
        text: "${AppLocalizations.of(context)!.translate('status_ready_to_pay')}",
        color: Color(0xFF2ECC71),
        icon: Icons.payment_outlined,
      );
    default:
      return StatusInfo(
        text:"${AppLocalizations.of(context)!.translate('status_unknown')}",
        color: Color(0xFF95A5A6),
        icon: Icons.help_outline,
      );
  }
}
StatusInfo getPaymentStatusInfo(BuildContext context, String status) {
  switch (status) {
    case "PENDING":
      return StatusInfo(
        text: "${AppLocalizations.of(context)!.translate('status_pending')}",
        color: Color(0xFFF39C12),
        icon: Icons.access_time,
        actionRequired: "${AppLocalizations.of(context)!.translate('status_pending_action')}",
      );
    case "CANCELED":
      return StatusInfo(
        text: "${AppLocalizations.of(context)!.translate('status_cancelled')}",
        color: Color(0xFFE74C3C),
        icon: Icons.cancel_outlined,
      );
    case "PAID":
      return StatusInfo(
        text: "${AppLocalizations.of(context)!.translate('status_paid')}",
        color:KabaChineColors.success,
        icon: FontAwesomeIcons.check,
      );
    case "FAILED":
      return StatusInfo(
        text: "${AppLocalizations.of(context)!.translate('status_failed')}",
        color: Color(0xFFE74C3C),
        icon: Icons.cancel_outlined,
      );
    default:
      return StatusInfo(
        text:"${AppLocalizations.of(context)!.translate('status_unknown')}",
        color: Color(0xFF95A5A6),
        icon: Icons.help_outline,
      );
  }
}
