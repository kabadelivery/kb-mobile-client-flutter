import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/CustomerModel.dart';
import '../../resources/out_of_app_order_api.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/functions/CustomerUtils.dart';

class DistrictState {
  List<Map<String, dynamic>> districts;
  List<Map<String, dynamic>> old_districts;
  bool isLoading=true;
  String errorMessage;
  String SelectedDistrictName;
  Map<String, dynamic> selectedDistrict;
  DistrictState({
     this.districts,
     this.isLoading=true,
    this.errorMessage,
    this.SelectedDistrictName = "",
    this.old_districts,
    this.selectedDistrict
  });
  DistrictState copyWith({
    List<Map<String, dynamic>> districts,
    bool isLoading,
    String errorMessage,
    String SelectedDistrictName,
    List<Map<String, dynamic>> old_districts,
    Map<String, dynamic> selectedDistrict
  }) {
    return DistrictState(
      districts: districts ?? this.districts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      SelectedDistrictName: SelectedDistrictName ?? this.SelectedDistrictName,
      old_districts: old_districts ?? this.old_districts,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict
    );
  }
}

class DistrictNotifier extends StateNotifier<DistrictState> {
  DistrictNotifier() : super(DistrictState(districts: [], isLoading: true));


  void setSelectedDistrict(Map<String, dynamic> district) {
    state = state.copyWith(selectedDistrict: district);
  }
  void filterDistricts(String query) {

      final filteredList = state.districts
          .where((item) => item["name"].toLowerCase().contains(query.toLowerCase()))
          .toList();
      if (filteredList.isEmpty) {
        setSelectedDistrictName("");
        state.districts = state.old_districts;
      } else {
        setSelectedDistrictName(filteredList[0]["name"]);
      }
      state = state.copyWith(districts: filteredList);
       state.districts = state.old_districts;
      setSelectedDistrict(
          state.districts.firstWhere((element) => element["name"] == state.SelectedDistrictName));

  }
  void setSelectedDistrictName(String districtName) {
    state = state.copyWith(SelectedDistrictName: districtName);
  }
}

final districtProvider = StateNotifierProvider<DistrictNotifier, DistrictState>(
      (ref) => DistrictNotifier(),
);
