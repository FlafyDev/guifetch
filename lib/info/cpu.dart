import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final infoCPUProvider = FutureProvider((ref) async {
  final String cpuInfo = await File("/proc/cpuinfo").readAsString();
  int threads =
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
  cpu = cpu.replaceAll(RegExp(" [-\\S]*-Core Processor"), "");
  cpu = cpu.trim();

  return "$cpu ($threads)";
});
