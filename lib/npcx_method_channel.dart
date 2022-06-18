import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'npcx_platform_interface.dart';
import 'package:npc/npc.dart';

/// An implementation of [NpcxPlatform] that uses method channels.
class MethodChannelNpcx extends NpcxPlatform {
  /// The method channel used to interact with the native platform.
  @override
  void on(
    String method,
    Handle handle,
  ) {
    _npc.on(method, handle);
  }

  @override
  Future<void> emit(
    String method, {
    dynamic param,
  }) async {
    return _npc.emit(method, param: param);
  }

  @override
  Future deliver(
    String method, {
    dynamic param,
    Duration? timeout,
    Cancelable? cancelable,
    Notify? onNotify,
  }) async {
    return _npc.deliver(method,
        param: param,
        timeout: timeout,
        cancelable: cancelable,
        onNotify: onNotify);
  }

  static final _npc = NPC((message) async {
    try {
      final map = <String, dynamic>{};
      map["typ"] = message.typ.index;
      final id = message.id;
      if (id != null) {
        map["id"] = id;
      }
      final method = message.method;
      if (method != null) {
        map["method"] = method;
      }
      final param = message.param;
      if (param != null) {
        map["param"] = param;
      }
      final error = message.error;
      if (error != null) {
        map["error"] = error;
      }
      final bytes = _codec.encodeMessage(map);
      _messenger.send(name, bytes);
    } catch (_) {}
  });

  @visibleForTesting
  static const name = "com.neutronstarer.npcx";

  static final _messenger = () {
    final v = ServicesBinding.instance.defaultBinaryMessenger;
    v.setMessageHandler(name, (bytes) {
      try {
        final map = _codec.decodeMessage(bytes) as Map<String, dynamic>;
        final typ = Typ.values[map["typ"] as int];
        int? id;
        String? method;
        try {
          id = map["id"] as int;
        } catch (_) {}
        try {
          method = map["method"] as String;
        } catch (_) {}
        _npc.receive(Message(
            typ: typ,
            id: id,
            method: method,
            param: map["param"],
            error: map["error"]));
      } catch (_) {}
      return null;
    });
    return v;
  }();

  static const _codec = JSONMessageCodec();
}
