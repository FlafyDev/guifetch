import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final infoTerminalProvider = Provider((ref) {
  return Platform.environment["TERM"];
});
