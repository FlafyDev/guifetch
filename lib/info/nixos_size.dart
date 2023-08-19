import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final infoNixOSSizeProvider = FutureProvider((ref) async {
  if (!await Directory("/run/current-system").exists()) return null;

  return (await Process.run("nix", [
    "path-info",
    "-Sh",
    "/run/current-system",
  ]))
      .stdout
      .toString()
      .split("\t")[1]
      .trim();
});
