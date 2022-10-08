import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class InfoField {
  final String title;
  final String text;

  InfoField({required this.title, required this.text});
}

final infoFieldsProvider = Provider<List<InfoField>>(
  (ref) {
    final fields = <InfoField>[];
    final gpu = ref.watch(infoGPUProvider);
    final cpu = ref.watch(infoCPUProvider);
    final shell = ref.watch(infoShellProvider);
    final kernel = ref.watch(infoKernelProvider);
    final packages = ref.watch(infoPackagesProvider);
    final uptime = ref.watch(infoUptimeProvider);
    final osName = ref.watch(infoOSNameProvider);
    final terminal = ref.watch(infoTerminalProvider);
    final nixOsSize = ref.watch(infoNixOSSizeProvider);
    final waylandCompositor = ref.watch(infoWaylandCompositorProvider);
    final uptimeCounter = ref.watch(infoUptimeCounterProvider);

    void addField(String title, Object? value) {
      if (value == null) return;
      final String text;
      if (value is String) {
        text = value;
      } else if (value is Duration) {
        text = value.toString().split('.').first.padLeft(8, "0");
      } else {
        throw Exception("Unknown type to convert.");
      }
      fields.add(InfoField(title: title, text: text));
    }

    void addFieldAsync(String title, AsyncValue<Object?> asyncValue) {
      asyncValue.whenData((value) {
        addField(title, value);
      });
    }

    addFieldAsync("OS", osName);
    addFieldAsync("Kernel", kernel);
    addFieldAsync("Packages", packages);
    uptimeCounter.whenOrNull(
      data: (uptimeCounter) {
        addField("Uptime", uptimeCounter);
      },
      loading: () {
        addFieldAsync("Uptime", uptime);
      },
    );
    addFieldAsync("NixOS System Closure Size", nixOsSize);
    addFieldAsync("Shell", shell);
    addField("Wayland Compositor", waylandCompositor);
    addField("Terminal", terminal);
    addFieldAsync("CPU", cpu);
    addFieldAsync("GPU", gpu);

    return fields;
  },
);

final infoGPUProvider = FutureProvider((ref) async {
  final data = (await Process.run(
    "/nix/store/ajnzlwhv5j7crjkrnjkckds2gr7fvrln-pciutils-3.8.0/bin/lspci",
    // "lspci",
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
        return gpu.trim();
      })
      .whereType<String>()
      .join("\n");
});

final infoCPUProvider = FutureProvider((ref) async {
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
});

final infoTerminalProvider = Provider((ref) {
  return Platform.environment["TERM"];
});

final infoWaylandCompositorProvider = Provider((ref) {
  if ((Platform.environment["WAYLAND_DISPLAY"]?.length ?? 0) == 0) {
    return null;
  }

  return Platform.environment["XDG_CURRENT_DESKTOP"];
});

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

final infoPackagesProvider = FutureProvider((ref) async {
  return null;
});

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

final infoKernelProvider = FutureProvider((ref) async {
  return (await Process.run("uname", ["-sr"])).stdout.toString().trim();
});

final infoUptimeCounterProvider = StreamProvider<Duration>((ref) {
  final uptime = ref.watch(infoUptimeProvider);
  return uptime.whenOrNull<Stream<Duration>>(
        data: (uptime) => uptime == null
            ? Stream.error("")
            : Stream.periodic(
                const Duration(seconds: 1),
                (int count) {
                  return Duration(seconds: uptime.inSeconds + count);
                },
              ),
      ) ??
      Stream.error(const Duration(seconds: 0));
});

final infoUptimeProvider = FutureProvider((ref) async {
  double? secondsPassed = double.tryParse(
      (await File("/proc/uptime").readAsString()).split(" ").first);
  if (secondsPassed == null) return null;
  return Duration(seconds: secondsPassed.floor());
});

final infoOSNameProvider = FutureProvider((ref) async {
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
