import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final infoGPUProvider = FutureProvider((ref) async {
  final data = (await Process.run(
    "lspci",
    [],
  ))
      .stdout
      .toString();

  return data
      .split("\n")
      .map((line) {
        if (!line.contains(":")) return null;

        final first = line.split(" ")[1];
        if (first != "Display" && first != "3D" && first != "VGA") {
          return null;
        }

        String gpu =
            line.split(": ")[1].replaceAll(RegExp("\\(rev .*\\)\$"), "").trim();
        if (gpu.startsWith("NVIDIA")) {
          gpu = RegExp("\\[(.*)\\]").firstMatch(gpu)?.group(1) ?? gpu;
        }
        if (gpu.startsWith("Intel")) {
          gpu = gpu.replaceAll("(R)", "");
          gpu = gpu.replaceAll("Corporation", "");
          gpu = gpu.replaceAll("Integrated Graphics Controller", "");
        }
        if (gpu.startsWith("Advanced")) {
          gpu = gpu.replaceAll("Advanced Micro Devices, Inc.", "");
          gpu = gpu.replaceAll("[AMD/ATI]", "AMD");
          gpu = gpu.replaceAll("[", "");
          gpu = gpu.replaceAll(RegExp("\\/.*"), "");
        }
        if (gpu.contains("VirtualBox")) {
          gpu = "VirtualBox Graphics Adapter";
        }
        return gpu.trim();
      })
      .whereType<String>()
      .join("\n");
});
