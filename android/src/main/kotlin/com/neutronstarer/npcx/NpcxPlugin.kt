package com.neutronstarer.npcx

import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import com.neutronstarer.npc.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.JSONMessageCodec
import org.json.JSONObject
import java.nio.ByteBuffer

/** NpcxPlugin */
class NpcxPlugin: NPC(null), FlutterPlugin {

  companion object {
    fun of(engine: FlutterEngine?): NpcxPlugin? {
      return engine?.plugins?.get(NpcxPlugin::class.java) as? NpcxPlugin
    }
  }

  private lateinit var name: String
  private lateinit var messenger : BinaryMessenger
  private val codec = JSONMessageCodec.INSTANCE
  private fun didReceive(bytes: ByteBuffer?) {
    try {
      val message = codec.decodeMessage(bytes) as? JSONObject ?: return
      val rawValue = message["typ"] as? Int ?: return
      val typ = Typ.fromRawValue(rawValue)
      val id = message.opt("id") as? Int
      val method = message.opt("method") as? String
      val param = message.opt("param")
      val error = message.opt("error")
      receive(Message(typ = typ, id = id, method = method, param = param, error = error))
    }finally {

    }

  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    name = "com.neutronstarer.npcx"
    messenger = flutterPluginBinding.binaryMessenger
    messenger.setMessageHandler(name) { message, _ ->
      didReceive(bytes = message)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    cleanUpDeliveries("disconnected")
  }

  override fun send(message: Message) {
    super.send(message)
    val map = mutableMapOf<String, Any>()
    val typ = message.typ.rawValue
    map["typ"] = typ
    val id = message.id
    if (id != null){
      map["id"] = id
    }
    val method = message.method
    if (method != null){
      map["method"] = method
    }
    val param = message.param
    if (param != null){
      map["param"] = param
    }
    val error = message.error
    if (error != null){
      map["error"] = error
    }
    val bytes = codec.encodeMessage(map)
    Handler(Looper.getMainLooper()).post {
      messenger.send(name, bytes)
    }
  }

}
