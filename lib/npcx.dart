import 'package:flutter/services.dart';
import 'package:npc/npc.dart';
export 'package:npc/npc.dart';

class Npcx {
  static void on(
    String method,
    Handle handle,
  ) {
    _npc.on(method, handle);
  }

  static Future<void> emit(
    String method, {
    dynamic param,
  }) async {
    return _npc.emit(method, param: param);
  }

  static Future deliver(
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
      _messenger.send(_name, bytes);
    } catch (_) {}
  });

  static const _name = "com.neutronstarer.npcx";

  static final _messenger = () {
    final v = ServicesBinding.instance.defaultBinaryMessenger;
    v.setMessageHandler(_name, (bytes) {
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
