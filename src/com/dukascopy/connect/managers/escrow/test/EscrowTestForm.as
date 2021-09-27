package com.dukascopy.connect.managers.escrow.test{
    
    import flash.display.Sprite;
    import com.forms.Form;
    import flash.filesystem.File;
    import com.dukascopy.connect.sys.Dispatcher;
    import flash.events.Event;
    import flash.ui.Keyboard;
    import flash.events.KeyboardEvent;
    import flash.system.Capabilities;
    import com.forms.IFormController;
    import com.forms.FormComponent;
    import com.forms.components.FormList;
    

    public class EscrowTestForm extends Sprite implements IFormController{
        
        private var form:Form;
        
        public var buyerKey:Sprite=null;


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
            Form.debug=true;
            form=new Form(File.applicationDirectory.resolvePath("forms"+File.separator+"escrowDebug.xml"));
			addChild(form.view);
			form.setSize(stage.stageWidth,stage.stageHeight);
            form.attachController(this);
			form.onDocumentLoaded=formReady;
        }

        private function formReady():void{
            var btn:FormComponent=form.createComponent("button",null);
            btn.setID("aaargh");
            btn.textContent="TEST CONTENT";
            form.add(btn);


            return;
            var list:FormList=form.getComponentByID("sample") as FormList;
            var dta:Array=[];
            for(var i:int=0;i<1000;i++){
                dta.push(Math.random());
            }
            list.setData(dta);
        } 

        public function destroy():void{

        }
        
        public function removeControllerLinkages():void{
            
        }

        var timer:Timer=new Timer(100,1);
            var disp:Dispatcher=new Dispatcher(timer);
            disp.add(TimerEvent.TIMER_COMPLETE,function(e:TimerEvent):void{
                disp.clear();
                if(managers==0){
                    trace("TEST.available - FAIL, NO EscrowManager instance found");
                    return;
                }
                if(managers!=1){
                    trace("TEST.available - FAIL, More than 1 EscrowManager instance found");
                    return;
                }
                trace("TEST.available - SUCCESS Escrow Manager avaiable");
                testInstruments();
            })
            timer.start();
        }

       private function testInstruments():void{
            trace("TEST.instruments - START")
            GD.S_ESCROW_INSTRUMENTS.add(function(instruments:Vector.<EscrowInstrument>):void{
                if(instruments==null){
                    trace("TEST.Instruments - FAIL, no instruments!")
                    return;
                }
                if(instruments.length==0){
                    trace("TEST.instruments - Instruments list is empty");
                    return;
                }
                for each(var i:EscrowInstrument in instruments){
                    trace("TEST.instrument: \t"+i);
                }
                trace("TEST.Instruments - COMPLETE")
                GD.S_ESCROW_INSTRUMENTS.clearID("escrowTests")
                testPrices(instruments);
            },this,"escrowTests");
            GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
        }

        private function testPrices(instruments:Vector.<EscrowInstrument>):void{
            trace("TEST.prices - START")
            var arr:Vector.<EscrowInstrument>=new Vector.<EscrowInstrument>();
            arr.push(instruments[0]);
            if(instruments.length>1)
                arr.push(instruments[1]);
            var changed:int=0;
            GD.S_ESCROW_PRICE.add(function(instrument:EscrowInstrument):void{
                trace('TEST.prices - changes: '+instrument)
                changed++;
                if(changed==arr.length){
                    trace('TEST.prices - COMPLETE')
                    GD.S_ESCROW_PRICE.clearID("escrowTests")
                    testAllPrices();
                }
            },this,"escrowTests")
            GD.S_ESCROW_PRICES_REQUEST.invoke(arr)
        }

        private function testAllPrices():void{
            trace("TEST.allPrices - START")
            GD.S_ESCROW_PRICE.add(function(instrument:EscrowInstrument):void{
                    trace('TEST.allPrices - COMPLETE')
                    GD.S_ESCROW_PRICE.clearID("escrowTests")
            },this,"escrowTests")
            GD.S_ESCROW_PRICES_REQUEST.invoke()
        }
    }
}