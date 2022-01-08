package com.neutronstarer.npcx_example

import android.os.Bundle
import com.neutronstarer.npcx.NpcxPlugin
import io.flutter.embedding.android.FlutterActivity
import java.util.*

class MainActivity: FlutterActivity(
) {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val npcx = NpcxPlugin.of(engine = flutterEngine)
        setup(npcx = npcx)
    }

    private fun setup(npcx: NpcxPlugin?){
        if (npcx == null) {
            return
        }
        npcx.on("download") { param, notify, reply ->
            var timer = Timer()
            var i = 0
            timer.schedule(object: TimerTask(){
                override fun run() {
                    i++
                    if (i < 5) {
                        notify("progress:$i/5")
                        return
                    }
                    timer.cancel()
                    reply("did download to $param", null)
                }
            },1000,1000)
            return@on {
                timer.cancel()
            }
        }
    }
}


