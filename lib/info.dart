import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'config.dart';

// class InfoField {
//   final String title;
//   final String text;
//
//   InfoField({required this.title, required this.text});
// }
//
// final forcedOSIDProvider = StateProvider<String?>((ref) => null);
//
//
// final infoTitleProvider = Provider<String>((ref) {
//   final osID = ref.watch(infoOSIDProvider);
//   final user = ref.watch(infoUserProvider);
//
//   return osID.whenOrNull(data: (osID) => "$user@$osID") ?? user ?? "";
// });
//
// final infoFieldsProvider = Provider<List<InfoField>>(
//   (ref) {
//     final fields = <InfoField>[];
//     final gpu = ref.watch(infoGPUProvider);
//     final cpu = ref.watch(infoCPUProvider);
//     final shell = ref.watch(infoShellProvider);
//     final kernel = ref.watch(infoKernelProvider);
//     final packages = ref.watch(infoPackagesProvider);
//     final uptime = ref.watch(infoUptimeProvider);
//     final osName = ref.watch(infoOSNameProvider);
//     final terminal = ref.watch(infoTerminalProvider);
//     final nixOsSize = ref.watch(infoNixOSSizeProvider);
//     final waylandCompositor = ref.watch(infoWaylandCompositorProvider);
//     final uptimeCounter = ref.watch(infoUptimeCounterProvider);
//
//     void addField(String title, Object? value) {
//       if (value == null) return;
//       final String text;
//       if (value is String) {
//         text = value;
//       } else if (value is Duration) {
//         text = value.toString().split('.').first.padLeft(8, "0");
//       } else {
//         throw Exception("Unknown type to convert.");
//       }
//       fields.add(InfoField(title: title, text: text));
//     }
//
//     void addFieldAsync(String title, AsyncValue<Object?> asyncValue) {
//       asyncValue.whenData((value) {
//         addField(title, value);
//       });
//     }
//
//     addFieldAsync("OS", osName);
//     addFieldAsync("Kernel", kernel);
//     addFieldAsync("Packages", packages);
//     uptimeCounter.whenOrNull(
//       data: (uptimeCounter) {
//         addField("Uptime", uptimeCounter);
//       },
//       loading: () {
//         addFieldAsync("Uptime", uptime);
//       },
//     );
//     addFieldAsync("NixOS System Closure Size", nixOsSize);
//     addFieldAsync("Shell", shell);
//     addField("Wayland Compositor", waylandCompositor);
//     addField("Terminal", terminal);
//     addFieldAsync("CPU", cpu);
//     addFieldAsync("GPU", gpu);
//
//     return fields;
//   },
// );
//
