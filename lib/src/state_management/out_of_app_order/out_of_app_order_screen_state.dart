import 'package:flutter_riverpod/flutter_riverpod.dart';

class OutOfAppScreenState{
  bool showLoading;
  bool isBillBuilt;

  OutOfAppScreenState({
    this.showLoading = false,
    this.isBillBuilt = false,

  });
  OutOfAppScreenState copyWith({
    bool showLoading,
    bool isBillBuilt
}){
    return OutOfAppScreenState(showLoading:showLoading,isBillBuilt:isBillBuilt);
  }
}

class OutOfAppScreenStateNotifier extends StateNotifier<OutOfAppScreenState>{
  OutOfAppScreenStateNotifier():super(OutOfAppScreenState());

  void setShowLoading(bool showLoading){
    state = state.copyWith(showLoading:showLoading);
  }
  void setIsBillBuilt(bool isBillBuilt){
    state = state.copyWith(isBillBuilt:isBillBuilt);
  }
}

final outOfAppScreenStateProvier = StateNotifierProvider<OutOfAppScreenStateNotifier,OutOfAppScreenState>((ref){
});