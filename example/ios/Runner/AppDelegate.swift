import UIKit
import Flutter
import npcx

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        setup(npcx: NpcxPlugin.of(self))
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setup(npcx: NpcxPlugin?){
        guard let npcx = npcx else {
            return
        }
        npcx.on("download") { param, notify, reply in
            var i = 0
            let timer = DispatchSource.makeTimerSource()
            timer.setEventHandler {[weak timer] in
                i += 1
                if (i<5){
                    notify("progress:\(i)/5")
                    return
                }
                timer?.cancel()
                reply("did download to \(param!)", nil)
            }
            timer.schedule(deadline: .now()+1, repeating: 1)
            timer.resume()
            return {
                timer.cancel()
            }
        }
    }
}
