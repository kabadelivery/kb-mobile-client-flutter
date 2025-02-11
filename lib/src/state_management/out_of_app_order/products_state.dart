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
  void modifyProducts(){}

}

final productListProvider = StateNotifierProvider<OutOfAppProductNotifier,List<Map<String,dynamic>>>(
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

class ImageCacheNotifier extends StateNotifier<String>{
  ImageCacheNotifier():super("");

  void saveImagePath(String path){
    state = path;
  }
}

final imageCacheProvider = StateNotifierProvider<ImageCacheNotifier,String>((ref) {
  return ImageCacheNotifier();
});

final isDeletedProvider = StateProvider.autoDispose.family<bool, int>((ref, index) => false);
