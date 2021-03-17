package com.dukascopy.connect.sys.phoneWeightManager {

import com.dukascopy.connect.Config;
import com.dukascopy.connect.data.SystemInfo;
import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
import com.dukascopy.connect.sys.php.PHP;

import flash.media.Camera;


public class PhoneWeightManager {

        static private var weight:int=0;
        static private var deviceInfo:String="unknown";

        // INITIALIZE
        static public function init():void {

            try {
                if (Camera.names != null)
                    weight += Camera.names.length;

                // APPLE
                if (Config.PLATFORM_APPLE) {
                    weight += 10;
                    deviceInfo = JSON.stringify({
                        cameras: Camera.names
                    })

                    sendInfo();

                // ANDROID
                } else if (Config.PLATFORM_ANDROID) {
                    NativeExtensionController.S_SYSTEM_INFO.add(onSystemInfo);
                    NativeExtensionController.getSystemInfo();
                }else{
                    // WINDOWS
                    sendInfo();
                }

            }catch (err:Error) {
                Main.sendError("Can't get dev. init",err.message);
            }
        }

        // Collect android info
        static private function onSystemInfo(info:SystemInfo):void{

            if(info==null || info.rawData==null){
                Main.sendError("No dev info!","Dev info is null or dev.info is null");
                return;
            }else{
                try {
                    PHP.call_statVI("dev", JSON.stringify(info.rawData));
                }catch (err:Error) {
                    Main.sendError("Can't get dev. can't create json","cant stringify json with info.rawdata");
                }
            }

            try {

                for (var i:String in info.rawData) {
                    var val:Object = info.rawData[i];
                    if (val!=null && val is Boolean) {
                        if (val == true)
                            weight++;
                    } else if (val!=null && (val + "").toLowerCase() == "true")
                        weight++
                }

                // DETERMINE SCREEN


                var cpu:int=1;
                if(info!=null && info.CPU_CORES && info.CPU_CORES>0)
                    cpu=info.CPU_CORES;

                try {
                    weight += cpu;
                }catch (err:Error) {
                    Main.sendError("Can't calc cpus",err.message);
                }

                try {
                    if (info != null && info.totalMemory > 0) {
                        var total:String = info.totalMemory.toString().substr(2);
                        if (total != null && total.length > 1)
                            total = total.charAt(0) + "." + total.charAt(1)
                        try {
                            var totalMem:int = Math.ceil(parseFloat(total));
                            weight += totalMem;
                        } catch (err:Error) {
                            Main.sendError("Can't get dev. total memory", err.message);
                        }
                    }
                }catch (err:Error) {
                    Main.sendError("Can't get dev. no total mem", err.message);
                }

                sendInfo();

            }catch (err:Error) {
                Main.sendError("Can't get dev. info",err.message);
            }
        }

        static private function sendInfo():void{
            PHP.call_statVI("weight",weight+"");
        }
    }
}
