import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:ui' as ui;
import 'package:guifetch/info/cpu.dart';
import 'package:guifetch/info/gpu.dart';
import 'package:guifetch/info/kernel.dart';
import 'package:guifetch/info/nixos_size.dart';
import 'package:guifetch/info/os.dart';
import 'package:guifetch/info/packages.dart';
import 'package:guifetch/info/shell.dart';
import 'package:guifetch/info/terminal.dart';
import 'package:guifetch/info/uptime.dart';
import 'package:guifetch/info/wayland_compositor.dart';

class InfoFields extends HookConsumerWidget {
  const InfoFields({
    super.key,
    required this.titleColor,
  });

  final ui.Color titleColor;

  @override
  Widget build(context, ref) {
    Widget buildField(String title, ProviderBase<dynamic> value) {
      return Consumer(
        builder: (context, ref, child) {
          final field = ref.watch(value) as Object?;
          final text = switch (field) {
            AsyncValue<String?>() => field.value,
            String() => field,
            Object() => throw Exception(
                "buildField got unacceptable type ${field.runtimeType}"),
            null => null,
          };
          if (text == null) return Container();
          return _Field(
            title: title,
            text: text,
            titleColor: titleColor,
          );
        },
      );
    }

    return Column(
      children: [
        buildField("OS", infoOSProvider),
        buildField("Kernel", infoKernelProvider),
        buildField("Packages", infoPackagesProvider),
        buildField("Uptime", infoUptimeProvider),
        buildField("NixOS System Closure Size", infoNixOSSizeProvider),
        buildField("Shell", infoShellProvider),
        buildField("Wayland Compositor", infoWaylandCompositorProvider),
        buildField("Terminal", infoTerminalProvider),
        buildField("CPU", infoCPUProvider),
        buildField("GPU", infoGPUProvider),
      ],
    );
  }
}

class _Field extends HookConsumerWidget {
  const _Field({
    Key? key,
    required this.title,
    required this.text,
    this.titleColor,
  }) : super(key: key);

  final String title;
  final String text;
  final Color? titleColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: titleColor ?? Colors.blue)),
        const Spacer(),
        Text(text, textAlign: TextAlign.end),
      ],
    );
  }
}
