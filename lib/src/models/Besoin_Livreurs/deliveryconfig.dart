import 'dart:io';
import 'package:flutter/material.dart';

class DeliveryConfig {
  bool isExpanded = true;
  String startAddress = ""; // Will be populated by widget.pickupAddress

  // Destination Logic
  bool useGps = true;
  String destinationAddress = ""; // For both GPS address and Quartier name
  double? destLatitude;
  double? destLongitude;

  // Details
  String addressDetails = "";
  String phoneNumber = ""; // Renamed from phone to match UI logic

  // Timing & Type
  bool isScheduled = false;
  String? scheduledDate;
  String? scheduledTime;
  bool isShop = false;


  double deliveryFee = 2500.0;

  // Package
  String packageNature = ""; // Renamed from parcelNature
  List<File?> photos = [null, null, null];

  // Payment Options
  bool recoverAmount = false;
  String amountToRecover = "";

  /// 0: Non, paiement à la livraison
  /// 1: Oui, débiter mon portefeuille
  /// 2: Oui, à la récupération du colis
  int paymentType = 0;
}