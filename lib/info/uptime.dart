import 'dart:io';

import 'package:guifetch/utils/counter_stream.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final infoUptimeProvider = StreamProvider<String>((ref) async* {
  final uptime = ref.watch(_initialUptimeProvider);
  if (uptime.value == null) {
    yield _durationToString(Duration.zero);
  } else {
    await for (final int passed in counterStream()) {
      yield _durationToString(
          Duration(seconds: uptime.value!.inSeconds + passed));
    }
  }
});

final _initialUptimeProvider = FutureProvider((ref) async {
  double? secondsPassed = double.tryParse(
      (await File("/proc/uptime").readAsString()).split(" ").first);
  if (secondsPassed == null) return null;
  return Duration(seconds: secondsPassed.floor());
});

String _durationToString(Duration duration) {
  return duration.toString().split('.').first.padLeft(8, "0");
}
