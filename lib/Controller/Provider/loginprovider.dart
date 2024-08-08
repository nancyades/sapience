import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sapience/Services/apiservice.dart';

final addloginNotifier =
    StateNotifierProvider<addloginProvider, addloginState>((ref) {
  return addloginProvider(ref);
});

class addloginProvider extends StateNotifier<addloginState> {
  Ref ref;

  addloginProvider(this.ref)
      : super(addloginState(false, const AsyncLoading(), 'initial'));

  addlogin(String phone, String otp) async {
    state = _loading();
    final data = await ref.read(apiprovider).getLogin(phone, otp);

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

  addloginState _dataState(dynamic entity) {
    return addloginState(false, AsyncData(entity), '');
  }

  addloginState _loading() {
    return addloginState(true, state.id, '');
  }

  addloginState _errorState(String errMsg) {
    return addloginState(false, state.id, errMsg);
  }
}

class addloginState {
  bool isLoading;
  AsyncValue<dynamic> id;
  String error;

  addloginState(this.isLoading, this.id, this.error);
}
