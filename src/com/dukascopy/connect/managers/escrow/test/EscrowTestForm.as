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
            var btn:FormComponent=form.createComponent("button");
            btn.textContent="TEST";
            form.add(btn);
        } 

        public function destroy():void{

        }
        
        public function removeControllerLinkages():void{
            
        }
    }
}