import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final infoHostProvider = FutureProvider((ref) async {
  return (await File("/proc/sys/kernel/hostname").readAsString()).trim();
});
