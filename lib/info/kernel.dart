import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

final infoKernelProvider = FutureProvider((ref) async {
  return (await Process.run("uname", ["-sr"])).stdout.toString().trim();
});

