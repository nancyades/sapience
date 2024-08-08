import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sapience/Services/apiservice.dart';

final addtermsNotifier =
    StateNotifierProvider<addtermsProvider, addtermsState>((ref) {
  return addtermsProvider(ref);
});

class addtermsProvider extends StateNotifier<addtermsState> {
  Ref ref;

  addtermsProvider(this.ref)
      : super(addtermsState(false, const AsyncLoading(), 'initial'));

  addterms(String sectionid) async {
    state = _loading();
    final data = await ref.read(apiprovider).getTerms(sectionid);

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

  addtermsState _dataState(dynamic entity) {
    return addtermsState(false, AsyncData(entity), '');
  }

  addtermsState _loading() {
    return addtermsState(true, state.id, '');
  }

  addtermsState _errorState(String errMsg) {
    return addtermsState(false, state.id, errMsg);
  }
}

class addtermsState {
  bool isLoading;
  AsyncValue<dynamic> id;
  String error;

  addtermsState(this.isLoading, this.id, this.error);
}
