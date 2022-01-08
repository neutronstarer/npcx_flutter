import Flutter
import Foundation
import NPC

fileprivate struct AssociatedKeys {
    static var npcx: Void?
}

public class NpcxPlugin: NPC, FlutterPlugin {
    
    public static func of(_ registry: FlutterPluginRegistry) -> NpcxPlugin? {
        if let registry = registry as? FlutterAppDelegate {
            return registry.npcx()
        }
        if let registry = registry as? FlutterViewController {
            return registry.npcx()
        }
        if let registry = registry as? FlutterEngine {
            return registry.npcx()
        }
        return nil
    }
    
    private let name: String
    private weak var messenger: FlutterBinaryMessenger?
    private let codec = FlutterJSONMessageCodec.sharedInstance()
    
    private init(_ name: String, _ messenger: FlutterBinaryMessenger){
        self.name = name
        self.messenger = messenger
        super.init(nil)
        messenger.setMessageHandlerOnChannel(name) {[weak self] data, reply in
            guard let self = self, let message = self.codec.decode(data) as? [String: Any], let rawValue = message["typ"] as? Int, let typ = Typ(rawValue: rawValue) else {
                return
            }
            self.receive(Message(typ: typ, id: (message["id"] as? Int) ?? 0, method: message["method"] as? String, param: message["param"], error: message["error"]))
        }
    }
    
    public override func send(_ message: Message) {
        var map = [String: Any]()
        map["typ"] = message.typ.rawValue
        map["id"] = message.id
        if let method = message.method {
            map["method"] = method
        }
        if let param = message.param {
            map["param"] = param
        }
        if let error = message.error {
            map["error"] = error
        }
        let msg = codec.encode(map)
        messenger?.send(onChannel: name, message: msg)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Do not use channel for preventing circular references
        let name = "com.neutronstarer.npcx"
        let messenger = registrar.messenger()
        let instance = NpcxPlugin(name, messenger)
        objc_setAssociatedObject(messenger, &AssociatedKeys.npcx, instance, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}


extension FlutterAppDelegate {
    func npcx() -> NpcxPlugin? {
        return (self.perform(NSSelectorFromString("rootFlutterViewController")).takeUnretainedValue() as? FlutterViewController)?.npcx()
    }
}

@objc public extension FlutterViewController {
    func npcx() -> NpcxPlugin? {
        return engine?.npcx()
    }
}

@objc public extension FlutterEngine {
    func npcx() -> NpcxPlugin? {
        let messenger = binaryMessenger
        return objc_getAssociatedObject(messenger, &AssociatedKeys.npcx) as? NpcxPlugin
    }
}

