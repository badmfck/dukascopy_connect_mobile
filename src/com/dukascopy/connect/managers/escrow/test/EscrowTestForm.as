package com.dukascopy.connect.managers.escrow.test{
    
    import flash.display.Sprite;
    import com.forms.Form;
    import flash.filesystem.File;
    import com.forms.FormComponent;
    import com.dukascopy.connect.GD;
    import com.dukascopy.connect.managers.escrow.EscrowDealSide;
    import com.dukascopy.connect.managers.escrow.EscrowDealCreateRequest;
    import com.dukascopy.connect.sys.Dispatcher;
    import flash.events.Event;
    import flash.ui.Keyboard;
    import flash.events.KeyboardEvent;
    import flash.system.Capabilities;
    

    public class EscrowTestForm extends Sprite{
        private var form:Form;
        public function EscrowTestForm(){

            var dis:Dispatcher=new Dispatcher(this);
            dis.add(Event.ADDED_TO_STAGE,function(e:Event):void{
                if(Capabilities.isDebugger){
                    stage.addEventListener(KeyboardEvent.KEY_DOWN,function(e:KeyboardEvent):void{
                        if(e.keyCode==Keyboard.R && (e.commandKey || e.ctrlKey) && form!=null)
                            form.reload();
                    })
                }
                createForm();
                dis.clear();
            })
        }


        private function createForm():void{
            form=new Form(File.applicationDirectory.resolvePath("forms"+File.separator+"escrowDebug.xml"));
			addChild(form.view);
			form.setSize(stage.stageWidth,stage.stageHeight);
            
			form.onDocumentLoaded=function():void{
	
                var cmp:FormComponent=form.getComponentByID("btnEscrowCreate");
                if(cmp!=null){
                    cmp.onTap=function(comp:FormComponent):void{
                        trace("CREATE OFFER");
                        GD.S_ESCROW_DEAL_CREATE_REQUEST.invoke(
                            new EscrowDealCreateRequest()
                            .setChatUID("WLDZD8WFWBIsWQWx")
                            .setInstrument("btc")
                            .setMcaCcy("eur")
                            .setPrimAmount(0.0531)
                            .setSecAmount(23.32)
                            .setSide(EscrowDealSide.BUY)
                            .setMsgID(101)
                        )
                    }
                }
            }
        }
    }
}