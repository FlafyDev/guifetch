
import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final infoShellProvider = FutureProvider((ref) async {
  String? shellPath = Platform.environment["SHELL"];
  if (shellPath == null) return null;
  String shell = shellPath.split("/").last;
  String version = "";

  switch (shell) {
    case "zsh":
      version = (await Process.run(shellPath, ["--version"]))
          .stdout
          .toString()
          .split(" ")[1]
          .trim();
      break;
  }

  return "$shell $version".trim();
});
