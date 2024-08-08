import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sapience/Services/apiservice.dart';

final addfoodvideosNotifier =
    StateNotifierProvider<addfoodvideosProvider, addfoodvideosState>((ref) {
  return addfoodvideosProvider(ref);
});

class addfoodvideosProvider extends StateNotifier<addfoodvideosState> {
  Ref ref;

  addfoodvideosProvider(this.ref)
      : super(addfoodvideosState(false, const AsyncLoading(), 'initial'));

  addfoodvideos(String foodcategory, String foodtype, String fooddays) async {
    state = _loading();
    final data =
        await ref.read(apiprovider).foodVideo(foodcategory, foodtype, fooddays);

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

  addfoodvideosState _dataState(dynamic entity) {
    return addfoodvideosState(false, AsyncData(entity), '');
  }

  addfoodvideosState _loading() {
    return addfoodvideosState(true, state.id, '');
  }

  addfoodvideosState _errorState(String errMsg) {
    return addfoodvideosState(false, state.id, errMsg);
  }
}

class addfoodvideosState {
  bool isLoading;
  AsyncValue<dynamic> id;
  String error;

  addfoodvideosState(this.isLoading, this.id, this.error);
}
