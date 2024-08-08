import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sapience/Services/apiservice.dart';

final addmonthNotifier =
    StateNotifierProvider<addmonthProvider, addmonthState>((ref) {
  return addmonthProvider(ref);
});

class addmonthProvider extends StateNotifier<addmonthState> {
  Ref ref;

  addmonthProvider(this.ref)
      : super(addmonthState(false, const AsyncLoading(), 'initial'));

  addmonth(String sectionid, String termid) async {
    state = _loading();
    final data = await ref.read(apiprovider).getMonth(sectionid, termid);

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

  addmonthState _dataState(dynamic entity) {
    return addmonthState(false, AsyncData(entity), '');
  }

  addmonthState _loading() {
    return addmonthState(true, state.id, '');
  }

  addmonthState _errorState(String errMsg) {
    return addmonthState(false, state.id, errMsg);
  }
}

class addmonthState {
  bool isLoading;
  AsyncValue<dynamic> id;
  String error;

  addmonthState(this.isLoading, this.id, this.error);
}
