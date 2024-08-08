import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sapience/Services/apiservice.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
final addbookqrNotifier =
    StateNotifierProvider<addbookqrProvider, addbookqrState>((ref) {
  return addbookqrProvider(ref);
});

class addbookqrProvider extends StateNotifier<addbookqrState> {
  Ref ref;

  addbookqrProvider(this.ref)
      : super(addbookqrState(false, const AsyncLoading(), 'initial'));

  addbookqr(
    String bookqr,
  ) async {
    state = _loading();
    final data = await ref.read(apiprovider).getBookQrCode(
          bookqr,
        );

    if (data != null) {
      state = _dataState(data);
      if (state != null) {

       // await ref.read(apiprovider).clearCacheForKey("API_Section");
        return state;
      }
    } else if (data == null) {
      state = _errorState('Timeout');
    }

    return state;
  }

  addbookqrState _dataState(dynamic entity) {
    return addbookqrState(false, AsyncData(entity), '');
  }

  addbookqrState _loading() {
    return addbookqrState(true, state.id, '');
  }

  addbookqrState _errorState(String errMsg) {
    return addbookqrState(false, state.id, errMsg);
  }
}

class addbookqrState {
  bool isLoading;
  AsyncValue<dynamic> id;
  String error;

  addbookqrState(this.isLoading, this.id, this.error);
}
