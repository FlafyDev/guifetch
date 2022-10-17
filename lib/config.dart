import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:toml/toml.dart';

class Config {
  final Color backgroundColor;
  final String? osId;
  final ImageProvider? osImage;

  Config({
    required this.backgroundColor,
    required this.osId,
    required this.osImage,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      backgroundColor: Color(json["background_color"] as int? ?? 0),
      osId: json["os_id"] as String?,
      osImage: json.containsKey("os_image") ? FileImage(File(json["os_image"] as String)) : null,
    );
  }
}

final configProvider = FutureProvider<Config>((ref) async {
  final toml = ref.watch(_configTomlProvider);
  final completer = Completer<Config>();
  toml.whenData((data) {
    completer.complete(Config.fromJson(data));
  });
  return completer.future;
});

final _configDataProvider = StreamProvider<String>((ref) async* {
  final home = Platform.environment['HOME'];
  if (home == null) throw Exception("No HOME enviroment variable");

  final file =
      File(path.joinAll([home, ".config", "guifetch", "guifetch.toml"]));

  if (!await file.exists()) {
    await file.create(recursive: true);
    await file.writeAsString("background_color = 0x00000000");
  }

  yield await file.readAsString();
  await for (final event in file.parent.watch(events: FileSystemEvent.all)) {
    if (event is FileSystemModifyEvent || event is FileSystemCreateEvent) {
      yield await file.readAsString();
    }
  }
});

final _configTomlProvider = StreamProvider<Map<String, dynamic>>((ref) async* {
  final data = ref.watch(_configDataProvider);
  if (data.value == null) return;
  yield TomlDocument.parse(data.value!).toMap();
});
