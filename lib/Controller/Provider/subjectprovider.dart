import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sapience/Services/apiservice.dart';

final addsubjectsNotifier =
    StateNotifierProvider<addsubjectsProvider, addsubjectsState>((ref) {
  return addsubjectsProvider(ref);
});

class addsubjectsProvider extends StateNotifier<addsubjectsState> {
  Ref ref;

  addsubjectsProvider(this.ref)
      : super(addsubjectsState(false, const AsyncLoading(), 'initial'));

  addsubjects(
      String sectionid, String termid, String monthid, String weekid) async {
    state = _loading();
    final data = await ref
        .read(apiprovider)
        .getSubject(sectionid, termid, monthid, weekid);

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

  addsubjectsState _dataState(dynamic entity) {
    return addsubjectsState(false, AsyncData(entity), '');
  }

  addsubjectsState _loading() {
    return addsubjectsState(true, state.id, '');
  }

  addsubjectsState _errorState(String errMsg) {
    return addsubjectsState(false, state.id, errMsg);
  }
}

class addsubjectsState {
  bool isLoading;
  AsyncValue<dynamic> id;
  String error;

  addsubjectsState(this.isLoading, this.id, this.error);
}
