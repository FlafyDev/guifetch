import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final infoWaylandCompositorProvider = Provider((ref) {
  if ((Platform.environment["WAYLAND_DISPLAY"]?.length ?? 0) == 0) {
    return null;
  }

  return Platform.environment["XDG_CURRENT_DESKTOP"];
});
