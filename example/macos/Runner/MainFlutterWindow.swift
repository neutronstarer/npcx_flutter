import Cocoa
import FlutterMacOS
import npcx

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController.init()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        RegisterGeneratedPlugins(registry: flutterViewController)
        setup(npcx: NpcxPlugin.of(flutterViewController))
        super.awakeFromNib()
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
