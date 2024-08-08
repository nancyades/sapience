import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sapience/Services/apiservice.dart';

final addvideoNotifier =
    StateNotifierProvider<addvideoProvider, addvideoState>((ref) {
  return addvideoProvider(ref);
});

class addvideoProvider extends StateNotifier<addvideoState> {
  Ref ref;

  addvideoProvider(this.ref)
      : super(addvideoState(false, const AsyncLoading(), 'initial'));

  addvideo(String sectionid, String termid, String monthid, String weekid,
      String subjectid, String category) async {
    state = _loading();
    final data = await ref
        .read(apiprovider)
        .getVideo(sectionid, termid, monthid, weekid, subjectid, category);

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

  addvideoState _dataState(dynamic entity) {
    return addvideoState(false, AsyncData(entity), '');
  }

  addvideoState _loading() {
    return addvideoState(true, state.id, '');
  }

  addvideoState _errorState(String errMsg) {
    return addvideoState(false, state.id, errMsg);
  }
}

class addvideoState {
  bool isLoading;
  AsyncValue<dynamic> id;
  String error;

  addvideoState(this.isLoading, this.id, this.error);
}
