import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final infoUserProvider = Provider((ref) {
  return Platform.environment["USER"];
});
