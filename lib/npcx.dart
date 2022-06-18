import 'npcx_platform_interface.dart';
import 'package:npc/npc.dart';
export 'package:npc/npc.dart';

class Npcx {
  void on(
    String method,
    Handle handle,
  ) {
    NpcxPlatform.instance.on(method, handle);
  }

  Future<void> emit(
    String method, {
    dynamic param,
  }) async {
    return NpcxPlatform.instance.emit(method, param: param);
  }

  Future deliver(
    String method, {
    dynamic param,
    Duration? timeout,
    Cancelable? cancelable,
    Notify? onNotify,
  }) async {
    return NpcxPlatform.instance.deliver(method,
        param: param,
        timeout: timeout,
        cancelable: cancelable,
        onNotify: onNotify);
  }
}
