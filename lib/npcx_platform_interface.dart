import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'npcx_method_channel.dart';
import 'package:npc/npc.dart';

abstract class NpcxPlatform extends PlatformInterface {
  /// Constructs a NpcxPlatform.
  NpcxPlatform() : super(token: _token);

  static final Object _token = Object();

  static NpcxPlatform _instance = MethodChannelNpcx();

  /// The default instance of [NpcxPlatform] to use.
  ///
  /// Defaults to [MethodChannelNpcx].
  static NpcxPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NpcxPlatform] when
  /// they register themselves.
  static set instance(NpcxPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> emit(
    String method, {
    dynamic param,
  }) async {
    throw UnimplementedError('emit(...) has not been implemented.');
  }

  void on(
    String method,
    Handle handle,
  ) {
    throw UnimplementedError('on(...) has not been implemented.');
  }

  Future deliver(
    String method, {
    dynamic param,
    Duration? timeout,
    Cancelable? cancelable,
    Notify? onNotify,
  }) async {
    throw UnimplementedError('deliver(...) has not been implemented.');
  }
}
