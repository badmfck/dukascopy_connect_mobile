package com.dukascopy.connect.sys.debug {
import com.dukascopy.connect.GD;
import com.dukascopy.connect.sys.chatManager.ChatManager;
    import com.dukascopy.connect.sys.php.PHP;
    import com.dukascopy.connect.sys.php.PHPRespond;
    import com.dukascopy.connect.sys.ws.WS;

public class RemoteDebugger {

        private  var chatUID:String;

        // NOTEBOOK USER: WdDOWTIKWiIk
        public function RemoteDebugger() {
            return;
            PHP.chat_start(function (response:PHPRespond):void {
                if(response.error)
                    return;
                if(response.data!=null && "uid" in response.data) {
                    chatUID = response.data.uid;
                    ChatManager.sendMessage("REMOTE DEBUGGER STARTED!")
                }
            }, ["WdDOWTIKWiIk"],true);

            GD.S_NET_DEBUG.add(function (msg:String):void {
                ChatManager.sendMessage(msg,chatUID);
            })

        }

    }
}
