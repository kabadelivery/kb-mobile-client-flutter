import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionState {
  final bool isAdded;
  final bool isSelected;
  final bool isRevoked;
  final String code;
  final bool isLoading;
  final bool isError;

  SubscriptionState({
    this.isAdded = false,
    this.isSelected = false,
    this.isRevoked = true,
    this.code = "",
    this.isLoading = false,
    this.isError = false,
  });

  SubscriptionState copyWith({
    bool? isAdded,
    bool? isSelected,
    bool? isRevoked,
    String? code,
    bool? isLoading,
    bool? isError,
  }) {
    return SubscriptionState(
      isAdded: isAdded ?? this.isAdded,
      isSelected: isSelected ?? this.isSelected,
      isRevoked: isRevoked ?? this.isRevoked,
      code: code ?? this.code,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
    );
  }
}

class SubscriptionStateNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionStateNotifier() : super(SubscriptionState());

  void setAdded(bool value) {
    state = state.copyWith(isAdded: value);
  }
  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  void setSelected(bool value) {
    state = state.copyWith(isSelected: value);
  }

  void setRevoked(bool value) {
    state = state.copyWith(isRevoked: value);
  }

  void setCode(String value) {
    state = state.copyWith(code: value);
  }

  void reset() {
    state = SubscriptionState();
  }
  void setError(bool value) {
    state = state.copyWith(isError: value);
  }
}

final subscriptionStateProvider = StateNotifierProvider.autoDispose<
    SubscriptionStateNotifier, SubscriptionState>((ref) {
  return SubscriptionStateNotifier();
});
