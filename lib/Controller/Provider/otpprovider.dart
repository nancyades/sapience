import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sapience/Services/apiservice.dart';

final addotpNotifier =
    StateNotifierProvider<addotpProvider, addotpState>((ref) {
  return addotpProvider(ref);
});

class addotpProvider extends StateNotifier<addotpState> {
  Ref ref;

  addotpProvider(this.ref)
      : super(addotpState(false, const AsyncLoading(), 'initial'));

  addotp(String phone) async {
    state = _loading();
    final data = await ref.read(apiprovider).getOtp(phone);

    if (data != null) {
      state = _dataState(data);
      if (state != null) {
        return state;
      }
    } else if (data == null) {
      state = _errorState('Timeout');
    }
    return state;
  }

  addotpState _dataState(String entity) {
    return addotpState(false, AsyncData(entity), '');
  }

  addotpState _loading() {
    return addotpState(true, state.id, '');
  }

  addotpState _errorState(String errMsg) {
    return addotpState(false, state.id, errMsg);
  }
}

class addotpState {
  bool isLoading;
  AsyncValue<String> id;
  String error;

  addotpState(this.isLoading, this.id, this.error);
}
