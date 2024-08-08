import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sapience/Services/apiservice.dart';

final sharedDataProvider = StateProvider<int>((ref) {
  return 0; // Default value for the data
});

final getSectionNotifier = FutureProvider<dynamic>((ref) async {
  return await ref.read(apiprovider).getSection();
});

final getfoodcategoryNotifier = FutureProvider<dynamic>((ref) async {
  return await ref.read(apiprovider).foodCategory();
});

final getfooddaysNotifier = FutureProvider<dynamic>((ref) async {
  return await ref.read(apiprovider).foodDays();
});


final getfoodtypesNotifier = FutureProvider<dynamic>((ref) async {
  return await ref.read(apiprovider).foodType();
});

final getsettingNotifier = FutureProvider<dynamic>((ref) async {
  return await ref.read(apiprovider).setting();
});


final getslidervideoNotifier = FutureProvider<dynamic>((ref) async {
  return await ref.read(apiprovider).sliderVideo();
});

