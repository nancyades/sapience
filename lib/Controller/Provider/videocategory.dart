import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sapience/Services/apiservice.dart';

final addvideocategoryNotifier =
    StateNotifierProvider<addvideocategoryProvider, addvideocategoryState>(
        (ref) {
  return addvideocategoryProvider(ref);
});

class addvideocategoryProvider extends StateNotifier<addvideocategoryState> {
  Ref ref;

  addvideocategoryProvider(this.ref)
      : super(addvideocategoryState(false, const AsyncLoading(), 'initial'));

  addvideocategory(String sectionid, String termid, String monthid,
      String weekid, String subjectid) async {
    state = _loading();
    final data = await ref
        .read(apiprovider)
        .getVideoCategory(sectionid, termid, monthid, weekid, subjectid);

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

  addvideocategoryState _dataState(dynamic entity) {
    return addvideocategoryState(false, AsyncData(entity), '');
  }

  addvideocategoryState _loading() {
    return addvideocategoryState(true, state.id, '');
  }

  addvideocategoryState _errorState(String errMsg) {
    return addvideocategoryState(false, state.id, errMsg);
  }
}

class addvideocategoryState {
  bool isLoading;
  AsyncValue<dynamic> id;
  String error;

  addvideocategoryState(this.isLoading, this.id, this.error);
}
