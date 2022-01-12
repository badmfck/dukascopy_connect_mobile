package
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.display.DisplayObjectContainer;
    import com.forms.Form;
    import com.forms.FormComponent;
    import com.dukascopy.connect.GD;
    import com.dukascopy.dccext.dccNetWatcher.DCCNetStatus;
    import com.forms.components.FormList;
    import flash.utils.setTimeout;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import com.dukascopy.dccext.dccNetWatcher.DCCNetWatcher;
    
    public class DebugPanel extends Sprite{

        [Embed(source="DebugPanel.xml", mimeType="application/octet-stream")]
        private const EmbeddedXML:Class;

        private var removed:Boolean=true;
        private var placeholder:DisplayObjectContainer;
        private var counter:int=0;
        private var form:Form;

        private var netStat:FormComponent;
        private var wsStat:FormComponent;
        private var btnIgnore:FormComponent;
        private var btnReqNetStat:FormComponent;
        private var logTextArea:TextField;
        private var autoscroll:Boolean=true;
        private var err:FormComponent;

        

        public function DebugPanel(placeholder:DisplayObjectContainer){
            this.placeholder=placeholder;
            GD.S_WS_STATUS.add(onWSStatus);
            GD.S_NETWORK_STATUS.add(onNetStatus);
            GD.S_LOG.add(onLog);
            GD.S_DEBUG_LOG.add(onDebugLog);
            logTextArea=new TextField();
            logTextArea.defaultTextFormat=new TextFormat("tahoma",13,0xFFFFFF);
            
        }

        private function onDebugLog(txt:String):void{
            if(err!=null)
                err.textContent=txt;
        }

        private function onWSStatus(status:Boolean):void{
            if(wsStat)
                wsStat.textContent=((status)?"CONNECTED":"DISCONNECTED")+" - "+(new Date().getTime()+"").substr(-6);
        }

        private function onNetStatus(status:DCCNetStatus):void{
            setNetStatus(status.internet);
        }

        private function onLog(...rest):void{
	        var str:String="";
            for(var i:int=0;i<rest.length;i++){
                if(i>0)
                    str+=", "
                str+=rest[i];
            }

            if(str.length>128)
                str=str.substr(0,126)+"... (total:"+str.length+")";

            //append
            var dta:String=(Math.round(new Date().getTime()/1000)+"").substr(-6);
            logTextArea.appendText(dta+" - "+str+"\n\n");
            logTextArea.wordWrap=true;
            logTextArea.multiline=true;
            logTextArea.selectable=false;
            logTextArea.scrollV=logTextArea.maxScrollV;
            logTextArea.border=true;
        }

        private function setNetStatus(status:String):void{
            if(!netStat)
                return;
            GD.S_REQUEST_NET_STATUS.invoke(function(online:Boolean):void{
                netStat.textContent=((online)?"INTERNET":"NO INTERNET")+" - "+(new Date().getTime()+"").substr(-6);
            })
                
        }

        public function show(message:String=null):void{
            removed=false;
            addEventListener(Event.ENTER_FRAME,onFrame);
            addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
        }

        private function onAddedToStage(e:Event):void{
            removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
            removeForm();

            if(form==null){
                form=new Form(XML(new EmbeddedXML()));
                form.setSize(stage.stageWidth,stage.stageHeight);
                addChild(form.view);

                var btn:FormComponent=form.getComponentByID("btnClose");
                btn.onTap=function(...rest):void{
                    hide();
                }

                var btnScroll:FormComponent=form.getComponentByID("btnScroll");
                btnScroll.onTap=function(...rest):void{
                    autoscroll=!autoscroll;
                    if(autoscroll)
                        btnScroll.textContent="NO SCROLL"
                    else
                        btnScroll.textContent="AUTOSCROLL"
                }

                btnIgnore=form.getComponentByID("btnIgnore");
                var ignored:Boolean=false
                var self:DebugPanel=this;
                btnIgnore.onTap=function(...rest):void{
                    if(ignored)
                        return;
                    self.mouseEnabled=false;
                    self.mouseChildren=false;
                    self.alpha=.3;
                    ignored=true;
                    setTimeout(function():void{
                        self.mouseEnabled=true;
                        self.mouseChildren=true;
                        self.alpha=1;
                        ignored=false;
                    },5000)
                }

                var btnClear:FormComponent=form.getComponentByID("btnClear")
                btnClear.onTap=function(...rest):void{
                    logTextArea.text="";
                }

                var btnReqNetStat:FormComponent=form.getComponentByID("btnReqNetStat")
                btnReqNetStat.onTap=function(...rest):void{
                    DCCNetWatcher.requestStatus();
                }

                netStat=form.getComponentByID("netStat");
                wsStat=form.getComponentByID("wsStat");
                

                var ta:FormComponent=form.getComponentByID("textarea");
                ta.onDraw=function():void{
                    (ta.view as Sprite).addChild(logTextArea);
                    logTextArea.width=ta.getBounds().display_width;
                    logTextArea.height=ta.getBounds().display_height;
                }
            }

            setNetStatus("");
            GD.S_WS_REQUEST_STATUS.invoke();
        }

        public function hide():void{
            removed=true;
            removeEventListener(Event.ENTER_FRAME,onFrame);
            removeForm();
        }

        private function removeForm():void{
            if(form==null)
                return;
            if(this.parent!=null)
                this.parent.removeChild(this);
        }

        private function onFrame(e:Event):void{ 
            if(removed)
                return;

            if(placeholder==null)   
                return;

            counter++;
            if(counter % 60!==0)
                return;
            counter=0;
            
            try{
                if(this.parent!=placeholder){
                    placeholder.addChild(this);
                    return;
                }

                if(placeholder.getChildIndex(this)<(placeholder.numChildren-1)){
                    placeholder.addChild(this);
                    return;
                }
            }catch(err:Error){}

        }
    }

}