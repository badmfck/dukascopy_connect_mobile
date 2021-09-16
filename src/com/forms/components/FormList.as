package com.forms.components{
    
    import flash.xml.XMLNode;
    import com.forms.FormComponent;
    import com.forms.Form;
    import flash.utils.setTimeout;
    import flash.utils.clearTimeout;

    public class FormList extends FormComponent{

        private var item:XMLNode;
        private var items:Vector.<FormComponent>;
        private var init:Boolean=false;
        private var lastUpdateTime:Number=0;
        private var lastUpdateData:Object;
        private var timeoutID:int;

        public function FormList(xml:XMLNode,form:Form){
            super(xml,form,{
                overflow:"scroll"
            });
        }

        public function setData(data:Array):void{

            // TODO - recalculate/reuse items
            if(data==null){
                //TODO: CLEAR ALL ITEMS
                if(_components.length>0)
                    clearAll();
                return;
            }

            var time:Number=new Date().getTime();
            lastUpdateData=data;

            if(time-lastUpdateTime<500){
                clearTimeout(timeoutID)
                trace("SETTING DATA TO LIST IS TO FAST")
                timeoutID=setTimeout(function():void{
                    if(lastUpdateData && !destroyed)
                        setData(lastUpdateData as Array);
                    trace("SET LAST DATA");
                },200)
                return
            }

            if(timeoutID>0)
                clearTimeout(timeoutID);
            timeoutID=-1;
            lastUpdateTime=time;
            lastUpdateData=null;

            if(items==null)
                items=new <FormComponent>[];
            
            var l:int=data.length;
            var itemsToAdd:Vector.<FormComponent>;
            var itemsToRemve:Vector.<FormComponent>;

            // TAKE EACH ITEM, CHECK REDRAW
            var needRebuild:Boolean=false;
            for(var n:int=0;n<l;n++){
                
                if(data[n]==null)
                    continue;

                var presentItem:FormListItem=null;
                
                
                if(n<_components.length)
                    presentItem=_components[n] as FormListItem;


                // GOT ITEM
                if(presentItem!=null){
                    // check data 
                    var sameHash:Boolean=presentItem.compareUserValues(data[n]);
                    if(sameHash)
                        continue; // same data object
                    presentItem.setupUserValues(data[n]);
                    needRebuild=true;
                    continue;
                }

                // create new item
                presentItem=new FormListItem(item,form);
                presentItem.setupUserValues(data[n]);
                if(itemsToAdd==null)
                    itemsToAdd=new <FormComponent>[];
                itemsToAdd.push(presentItem);
            }

            
            if(data.length<_components.length){
                for(var i:int=data.length;i<_components.length;i++){
                    if(itemsToRemve==null)
                        itemsToRemve=new <FormComponent>[];
                    itemsToRemve.push(_components[i]);
                }
            }

            if(itemsToRemve && itemsToRemve.length>0)
                _removeAll(itemsToRemve,false);

            if(itemsToAdd && itemsToAdd.length>0)
                addAll(itemsToAdd);
            else if(needRebuild)
                rebuild();
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
                        item=node;
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
            item=null;
            lastUpdateData=null;
        }
    }
}