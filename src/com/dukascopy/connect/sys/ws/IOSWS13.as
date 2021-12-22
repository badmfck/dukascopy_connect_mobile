package com.dukascopy.connect.sys.ws
{
    import com.dukascopy.connect.GD;
    import flash.desktop.NativeApplication;
    import flash.events.Event;
    import com.dukascopy.dccext.dccNetWatcher.DCCNetWatcher;
    import com.dukascopy.dccext.dccNetWatcher.DCCNetStatus;
    import com.dukascopy.dccext.dccWS.DccWS;
    import flash.utils.setTimeout;
    import com.dukascopy.connect.vo.URLConfigVO;
    import com.dukascopy.connect.vo.WSPacketSendRequestVO;
    import com.worlize.websocket.WebSocket;
    import com.dukascopy.connect.sys.Dispatcher;
    import com.worlize.websocket.WebSocketEvent;
    import com.worlize.websocket.WebSocketMessage;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    
    public class IOSWS13{

        private var ws:DccWS;
        private var worlize:WebSocket;
        private var worlizeDispatcher:Dispatcher;
        private var url:String;
        private var authorized:Boolean=false;
        private var emulate:Boolean=false;
        
        public function IOSWS13(){
            GD.S_AUTHORIZED.add(onAuthorized);
            GD.S_UNAUTHORIZED.add(onUnauthorized);

            NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeativate);

            GD.S_URL_CONFIG_READY.add(function(urlConfig:URLConfigVO):void{
                var doConnect:Boolean=url!=urlConfig.WSS_URL;
                url=urlConfig.WSS_URL;
                if(urlConfig.PLATFORM=="win"){
                    if(urlConfig.SCHEME=="live")    
					    url="ws://ws.site.dukascopy.com:8080";
				    if(urlConfig.SCHEME=="pre")
					    url="ws://ws-pre.site.dukascopy.com:8080";
                    emulate=true;
                }

                GD.S_LOG.invoke("Config ready",url);
                if(doConnect && authorized)
                    connect();
            })

            GD.S_WS_REQUEST_STATUS.add(function():void{
                fireWSState();
            })

            GD.S_NETWORK_STATUS.add(function(netStat:DCCNetStatus):void{
                
                // Open ws connection
                if(netStat.internet==DCCNetStatus.INTERNET_STATUS_AVAILABLE){
                    connect();
                    return;
                }

                // close connections
                if(ws!=null)
                   ws.dispose();

                if(emulate)
                    disposeWorlize();

                GD.S_WS_CLOSED.invoke();
                fireWSState();
            })

            GD.S_WS_REQUEST_SEND.add(function(packet:WSPacketSendRequestVO):void{

                // EMULATE
                if(emulate){
                    if(worlize==null){
                        GD.S_LOG.invoke("ERR Can't send packet: ",packet.toJSON()+", no ws created (EMU)");
                        if(packet.callback)
                            packet.callback(false);                        
                    }
                    var result:Boolean=false;
                    if(worlize.readyState==1 && !packet.simulateSend)
                        result=worlize.sendUTF(packet.toJSON());
                    if(packet.simulateSend)
                        result=true;
                    if(packet.callback)
                        packet.callback(result);
                    return;
                }


                // REAL LIFE
                if(ws==null){
                    GD.S_LOG.invoke("ERR Can't send packet: ",packet.toJSON()+", no ws created");
                    if(packet.callback)
                        packet.callback(false);
                    return;
                }
                GD.S_LOG.invoke("WS Request to send: ",packet.toJSON());

                // SIMULATE SEND
                if(packet.simulateSend){
                    GD.S_LOG.invoke("WS Request to simulate send: ",packet.toJSON());
                    if(packet.callback)
                        packet.callback(true);
                    return;
                }

                if(ws.isDisposed){
                    GD.S_LOG.invoke("Can't send on disposed socket");
                    if(packet.callback)
                        packet.callback(false);
                    return;
                }

                
                ws.send(
                    packet.toJSON(),
                    packet.callback
                )
            })
        }

        private function fireWSState():void{
            var state:Boolean;
            if(emulate){
                state=worlize!=null && worlize.readyState==1 && authorized;
                GD.S_WS_STATUS.invoke(state);
                GD.S_LOG.invoke("WS STATE (EMU): "+state);
                return;
            }
            state=ws!=null && ws.connected && ws.isActive && authorized;
            GD.S_LOG.invoke("WS STATE: "+state);
            GD.S_WS_STATUS.invoke(state);
        }

        private function onAuthorized(profile:Object):void{
            authorized=true;
            GD.S_LOG.invoke("Authorized comes to WS")
            connect();
        }

        private function onUnauthorized():void{
            GD.S_LOG.invoke("Unauthorized comes to WS")
            authorized=false;
            if(ws!=null)
                ws.dispose();
            ws=null;
        }

        private function onActivate(e:Event):void{
            
        }

        private function onDeativate(e:Event):void{
            
        }



        /*private function onNetStatus(stat:DCCNetStatus):void{
            // ON STATUS EVENT
            GD.S_LOG.invoke("DCCNetWatcher - status event: "+stat.internet)
            if(stat.internet==DCCNetStatus.INTERNET_STATUS_AVAILABLE){
                connect();
                return;
            }
            if(ws!=null){
                ws.dispose();
                GD.S_WS_CLOSED.invoke();
                fireWSState();
            }
        }*/

        private function connect():void{

            if(url==null){
                GD.S_LOG.invoke("ERR, NO WS URL TO CONNECT");
                return;
            }

            if(!authorized){
                GD.S_LOG.invoke("ERR, NO AUTHORIZED TO CONNECT TO WS");
                return;
            }

            if(emulate){
                if(worlize!=null)
                    disposeWorlize();
                worlize=new WebSocket(url,"TelefisionMobile");
                worlizeDispatcher=new Dispatcher(worlize);
                
                worlizeDispatcher.add(WebSocketEvent.OPEN,function(e:WebSocketEvent):void{
                    // OPENED
                    GD.S_LOG.invoke("OPENED (EMU)\n");
                    GD.S_WS_OPENED.invoke();
                    fireWSState();
                })
                
                worlizeDispatcher.add(WebSocketEvent.CLOSED,function(e:WebSocketEvent):void{
                    // CLOSED
                    disposeWorlize()
                    GD.S_LOG.invoke("WS CLOSED:, EMU");
                        setTimeout(function():void{
                            GD.S_REQUEST_NET_STATUS.invoke(function(online:Boolean):void{
                                if(online){
                                    connect();
                                    return;
                                }
                                GD.S_LOG.invoke("Abort connecting to ws, online is: "+online);
                            });
                        },1000);
                        GD.S_WS_CLOSED.invoke();
                    fireWSState();
                })
                
                worlizeDispatcher.add(WebSocketEvent.MESSAGE,function(e:WebSocketEvent):void{
			        if (e is WebSocketEvent && e.message.type == WebSocketMessage.TYPE_UTF8) {
				        GD.S_WS_MESSAGE.invoke(e.message.utf8Data);
                    }
                })
                worlizeDispatcher.add(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void{
                    GD.S_LOG.invoke("IO ERROR on Worlize Websocket ",e.text);
                })
                worlizeDispatcher.add(SecurityErrorEvent.SECURITY_ERROR,function(e:SecurityErrorEvent):void{
                    GD.S_LOG.invoke("Security ERROR on Worlize Websocket ",e.text);
                })
                worlize.connect("ios12emu",true);
                return;
            }
            // END OF EMULATION

            
             // Check if WS is not connected
            if(ws==null || (ws!=null && !ws.connected) || (ws!=null && !ws.isActive)){
                try{
                    if(ws!=null)
                        ws.dispose();
                        
                    ws=DccWS.getInstance();

                    ws.onClose=function(code:int,reason:String):void{
                        clearListeners();
                        GD.S_LOG.invoke("WS CLOSED:, code:"+code+", reason: "+reason);
                        setTimeout(function():void{
                            GD.S_LOG.invoke("RECONNECT IF INTERNET: >> "+(DCCNetWatcher.getStatus().internet==DCCNetStatus.INTERNET_STATUS_AVAILABLE)+" <<\n");
                            if(DCCNetWatcher.getStatus().internet==DCCNetStatus.INTERNET_STATUS_AVAILABLE)
                                connect();
                        },1000);
                        GD.S_WS_CLOSED.invoke();
                        fireWSState();
                    }

                    ws.onError=function(error:String):void{
                        if(error==null)
                            error="no error message passed";
                        GD.S_LOG.invoke("WS ERROR "+error);
                    }

                    ws.onOpen=function():void{
                        GD.S_LOG.invoke("OPENED\n");
                        GD.S_WS_OPENED.invoke();
                        fireWSState();
                    }

                    ws.onMessage=function(text:String):void{
                        GD.S_LOG.invoke("GOT MSG: ",text);
                        GD.S_WS_MESSAGE.invoke(text);
                    }

                    ws.onLog=function(text:String):void{
                        GD.S_LOG.invoke("WS LOG ---->: \n"+text);
                    }

                    ws.open(url);
                    GD.S_LOG.invoke("WS CONNECTING TO: "+url+"\n");

                }catch(e:Error){
                    GD.S_LOG.invoke("CONENCTON ERROR "+e.message+"\n");
                }
            }
        }

        private function disposeWorlize():void{
            if(worlizeDispatcher)
                worlizeDispatcher.clear();
            worlizeDispatcher=null;
            if(worlize)
                worlize.close();
        }

        private function clearListeners():void{
            if(ws==null)
                return;
            ws.onMessage=null;
            ws.onError=null;
            ws.onOpen=null;
            ws.onClose=null;
        }
    }
}