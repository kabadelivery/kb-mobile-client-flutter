import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OutOfAppProductNotifier extends StateNotifier<List<Map<String,dynamic>>>{
  OutOfAppProductNotifier():super([]);

  void addProduct(Map<String,dynamic> product){
    state =[...state,product];
  }
  void removeProduct(int index){
    final updatedList = List<Map<String,dynamic>>.from(state)..removeAt(index);
    state = updatedList;
  }
  void clearProducts(){
    state =[];
  }
  void modifyProduct(Map<String,dynamic> product){
    final index = state.indexWhere((element) => element['name'] == product['name']);
    if(index != -1){
      state[index] = product;
    }
  }

}

final productListProvider = StateNotifierProvider.autoDispose<OutOfAppProductNotifier,List<Map<String,dynamic>>>(
        (ref) => OutOfAppProductNotifier()
);

class QuantityNotifier extends StateNotifier<int>{
  QuantityNotifier():super(1);
  void reset(){
    state=1;
  }
  void increase() {
    state++;
    print("Quantity increased: $state");
  }
  void decrease(){
    if(state>1){
      state--;
      print("Quantity decreased: $state");
    }
  }
}
final quantityProvider = StateNotifierProvider<QuantityNotifier,int>((ref) {
  return QuantityNotifier();
});

class ImageCacheNotifier extends StateNotifier<File>{
  ImageCacheNotifier():super(null);

  void saveImagePath(File path){
    state = path;
  }
}

final imageCacheProvider = StateNotifierProvider<ImageCacheNotifier,File>((ref) {
  return ImageCacheNotifier();
});

final isDeletedProvider = StateProvider.autoDispose.family<bool, int>((ref, index) => false);
