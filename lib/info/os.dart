import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final infoOSProvider = FutureProvider((ref) async {
  final data = await File("/etc/os-release").readAsString();
  final lines = data.split("\n");
  final variables = <String, String>{};

  for (var line in lines) {
    final split = line.split("=");
    if (split.length == 2) {
      variables[split[0]] = split[1];
    }
  }

  String? os = variables["PRETTY_NAME"] ?? variables["NAME"] ?? variables["ID"];
  if (os == null) return null;
  if (os.startsWith('"')) os = os.substring(1, os.length - 1);
  return os;
});
