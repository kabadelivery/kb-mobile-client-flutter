import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdditionnalInfoState {
  File image;
  String additionnal_info;
  String additionnal_address_info;
  bool can_add_address_info;
  AdditionnalInfoState({
    this.image,
    this.additionnal_info = '',
    this.additionnal_address_info = '',
    this.can_add_address_info = false,
  });

  // To copy the state with changes (immutable state)
  AdditionnalInfoState copyWith({
    File image,
    String additionnal_info,
    String additionnal_address_info,
    bool can_add_address_info,
  }) {
    return AdditionnalInfoState(
      image: image ?? this.image,
      additionnal_info: additionnal_info ?? this.additionnal_info,
      additionnal_address_info: additionnal_address_info ?? this.additionnal_address_info,
      can_add_address_info: can_add_address_info ?? this.can_add_address_info,
    );
  }
}
class AdditionnalInfoNotifier extends StateNotifier<AdditionnalInfoState> {
  AdditionnalInfoNotifier() : super(AdditionnalInfoState());

  void setImage(File image) {
    state = state.copyWith(image: image);
  }
  void setAdditionnalInfo(String info) {
    state = state.copyWith(additionnal_info: info);
  }
  void setAdditionnalAddressInfo(String addressInfo) {
    state = state.copyWith(additionnal_address_info: addressInfo);
  }
  void setCan_add_address_info(bool can_add_address_info) {
    state = state.copyWith(can_add_address_info: can_add_address_info);
  }
  void clear() {
    state = AdditionnalInfoState();
  }
}
final additionnalInfoProvider = StateNotifierProvider.autoDispose<AdditionnalInfoNotifier, AdditionnalInfoState>(
      (ref) => AdditionnalInfoNotifier(),
);