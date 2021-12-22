package
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.display.DisplayObjectContainer;
    import com.forms.Form;
    import com.forms.FormComponent;

    public class DebugPanel extends Sprite{

        [Embed(source="DebugPanel.xml", mimeType="application/octet-stream")]
        private const EmbeddedXML:Class;

        private var removed:Boolean=true;
        private var placeholder:DisplayObjectContainer;
        private var counter:int=0;
        private var form:Form;
        public function DebugPanel(placeholder:DisplayObjectContainer){
            this.placeholder=placeholder;
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
            }
        }

        public function hide():void{
            removed=true;
            removeEventListener(Event.ENTER_FRAME,onFrame);
            removeForm();
        }

        private function removeForm():void{
            if(form==null)
                return;
            if(form.view!=null && form.view.parent!=null)
                form.view.parent.removeChild(form.view);
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