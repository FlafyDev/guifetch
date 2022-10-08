import 'dart:async';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

class InfoField {
  final String title;
  final String text;

  InfoField({required this.title, required this.text});
}

final infoFieldsProvider = FutureProvider<List<InfoField>>(
  (ref) async {
    final fields = <InfoField>[];

    Future<void> _addField(String title, FutureOr<String?> textFuture) async {
      final text = await textFuture;

      if (text == null) return;

      fields.add(InfoField(title: title, text: text));
    }

    await Future.wait(<Future<void>>[
      _addField("OS", _getOSName()),
      _addField("Kernel", _getKernel()),
      _addField("Uptime", _getUptime()),
      _addField("Packages", _getPackages()),
      _addField("NixOS System Closure Size", _getNixOSSize()),
      _addField("Shell", _getShell()),
      _addField("Wayland Compositor", _getWaylandCompositor()),
      _addField("Terminal", _getTerminal()),
      _addField("CPU", _getCPU()),
    ]);

    return fields;
  },
);

Future<String?> _getOSName() async {
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
}

Future<String?> _getUptime() async {
  double? secondsPassed = double.tryParse(
      (await File("/proc/uptime").readAsString()).split(" ").first);
  if (secondsPassed == null) return null;
  return Duration(seconds: secondsPassed.floor())
      .toString()
      .split('.')
      .first
      .padLeft(8, "0");
  ;
}

Future<String?> _getKernel() async {
  return (await Process.run("uname", ["-sr"])).stdout.toString().trim();
}

Future<String?> _getPackages() async {
  return null;
}

Future<String?> _getNixOSSize() async {
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
}

Future<String?> _getShell() async {
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
}

Future<String?> _getResolution() async {}

String? _getWaylandCompositor() {
  if ((Platform.environment["WAYLAND_DISPLAY"]?.length ?? 0) == 0) {
    return null;
  }

  return Platform.environment["XDG_CURRENT_DESKTOP"];
}

String? _getTerminal() {
  return Platform.environment["TERM"];
}

Future<String?> _getCPU() async {
  final String cpuInfo = await File("/proc/cpuinfo").readAsString();
  int cores =
      cpuInfo.split("\n").where((line) => line.startsWith("processor")).length;
  String cpu = cpuInfo
      .split("\n")
      .firstWhere((line) => line.startsWith("model name"))
      .split(": ")[1]
      .split("@")[0];

  // Remove un-needed patterns from cpu output.
  cpu = cpu.replaceAll("(R)", "");
  cpu = cpu.replaceAll("Core(TM)", "");
  cpu = cpu.replaceAll("CPU", "");
  cpu = cpu.trim();

  return "$cpu ($cores)";
}
