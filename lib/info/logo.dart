import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:guifetch/config.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:ui' as ui;

final logoProvider = FutureProvider<ui.Image>((ref) async {
  final config = ref.watch(configProvider).value;
  final osID = ref.watch(_osIDProvider);

  if (config?.osImage != null) {
    _bytesToImage(await config!.osImage!.readAsBytes());
  }

  Future<ui.Image> getImage(String? id) async {
    switch (id) {
      case "nixos":
        return _assetToImage("assets/os_images/nixos.png");
      case "windows":
        return _assetToImage("assets/os_images/windows.png");
      case "apple":
        return _assetToImage("assets/os_images/apple.png");
      case "arch":
        return _assetToImage("assets/os_images/arch.png");
      case "gentoo":
        return _assetToImage("assets/os_images/gentoo.png");
      case "endeavouros":
        return _assetToImage("assets/os_images/endeavour.png");
      case "manjaro":
        return _assetToImage("assets/os_images/manjaro.png");
      default:
        return _assetToImage("assets/os_images/linux.png");
    }
  }

  if (config?.osId != null) return getImage(config!.osId);
  return getImage(osID.value);
});

Future<ui.Image> _assetToImage(String path) async {
  return await _bytesToImage(
      (await PlatformAssetBundle().load(path)).buffer.asUint8List());
}

Future<ui.Image> _bytesToImage(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  var frame = await codec.getNextFrame();
  return frame.image;
}

final _osIDProvider = FutureProvider((ref) async {
  final data = await File("/etc/os-release").readAsString();
  final lines = data.split("\n");
  final variables = <String, String>{};

  for (var line in lines) {
    final split = line.split("=");
    if (split.length == 2) {
      variables[split[0]] = split[1];
    }
  }

  String? os = variables["ID"];
  if (os == null) return null;
  if (os.startsWith('"')) os = os.substring(1, os.length - 1);
  return os;
});
