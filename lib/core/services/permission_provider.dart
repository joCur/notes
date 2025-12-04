import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'permission_service.dart';

part 'permission_provider.g.dart';

/// Provider for [PermissionService]
@riverpod
PermissionService permissionService(Ref ref) {
  final talker = Talker();
  return PermissionService(talker);
}
