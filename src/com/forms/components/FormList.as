package com.forms.components{
    
    import flash.xml.XMLNode;
    import com.forms.FormComponent;
    import com.forms.Form;
    import flash.utils.clearTimeout;
    import flash.display.Sprite;


    public class FormList extends FormComponent{

        private var itemXML:XMLNode;
        private var items:Vector.<FormComponent>;
        private var init:Boolean=false;
        private var lastUpdateTime:Number=0;
        private var lastUpdateData:Object;
        private var timeoutID:int;
        private var data:Object;

      
        private var listBox:Sprite=new Sprite();
            

        public function FormList(xml:XMLNode,form:Form){
            super(xml,form,{
                overflow:"scroll"
            });
        }

        public function setData(data:Object):void{
            this.data=data;
            
            // remove all items
            // TODO: DO NOT REMOVE ALL ITEMS WHEN DATA POINTER IS THE SAME
            if(_components.length>0)
                clearAll(false);

            if(data==null){
                //TODO: CLEAR ALL ITEMS
                rebuild();
                return;
            }

            var nextY:int=0;
            var l:int=data.length;
            var renders:Vector.<FormComponent>=new <FormComponent>[];
            var li:FormListItem;
            if(data is Array || data is Vector){
                for(var i:int=0;i<l;i++){
                    li=new FormListItem(itemXML,form);
                    li.setupUserValues(data[i]);
                    renders.push(li)
                }
            }else{
                for(var j:String in data){
                    li=new FormListItem(itemXML,form);
                    li.setupUserValues(data[j]);
                    renders.push(li)
                }
            }
            addAll(renders);
            
        }

        

        override protected function redraw(percentOffsetW:int = -1, percentOffsetH:int = -1,parentValues:Object=null):void{
            super.redraw(percentOffsetW,percentOffsetH,parentValues);
        }

        override protected function createView(xml:XMLNode):void{
            if(!init){
                if(_components.length>0){
                    for each(var cc:FormComponent in _components)
                        cc.destroy();
                    _components=new Vector.<FormComponent>();
                }

                // FIND ITEM
                var childs:Array=xml.childNodes;
                for each(var node:XMLNode in childs){
                    if(node.nodeType==3)
                        continue;
                    if(node.nodeName.toLowerCase()=="li"){
                        // found li
                        itemXML=node;
                        return;
                    }
                }
                
                init=true;
                return;
            }
                

            super.calculateBounds(xml);
        }
        
        override public function destroy():void{
            super.destroy();
            clearTimeout(timeoutID);
            items=null;
            itemXML=null;
            lastUpdateData=null;
        }
    }
}