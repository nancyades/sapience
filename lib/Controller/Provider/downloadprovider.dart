import 'package:flutter_riverpod/flutter_riverpod.dart';

final downloadProvider = StateProvider<List<bool>>((ref) {
  return []; // This will be initialized dynamically based on fetched data
});

void initializeDownloadStatus(WidgetRef ref, int itemCount) {
  ref.read(downloadProvider.notifier).state = List<bool>.filled(itemCount, false);
}
