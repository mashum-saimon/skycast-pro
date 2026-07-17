import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core_providers.dart';

/// Emits true/false whenever connectivity changes. Used to drive the
/// offline banner and gate CRUD/network behaviour across the app.
final isOnlineProvider = StreamProvider<bool>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.onConnectivityChanged;
});

/// A synchronous snapshot with a sane default (assume online) while the
/// stream's first event hasn't arrived yet.
final isOnlineSnapshotProvider = Provider<bool>((ref) {
  final async = ref.watch(isOnlineProvider);
  return async.valueOrNull ?? true;
});
