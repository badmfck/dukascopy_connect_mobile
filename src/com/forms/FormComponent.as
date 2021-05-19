package com.forms{

    import flash.display.Sprite;
    import flash.xml.XMLNode;
    import flash.display.DisplayObjectContainer;
    import flash.display.DisplayObject;
    

    public class FormComponent{

        
        protected var bounds:FormBounds=new FormBounds(0,0);

        protected var style:FormStyle;
    
        protected var nodeName:String;
        protected var nodeType:int;
        private var _id:String=null;
        public function get id():String{return _id}
        
        protected var _view:DisplayObject;
        public function get view():DisplayObject{return _view;}
        private var _components:Vector.<FormComponent>=new Vector.<FormComponent>();
        
        protected var parent:FormComponent=null;
        
        public function FormComponent(xml:XMLNode){
            style=new FormStyle(xml);
            nodeName=xml.nodeName;
            nodeType=xml.nodeType;
            if(xml.attributes!=null && ("id" in xml.attributes))
                _id=xml.attributes["id"];
            createView(xml);
        }

        protected function createView(xml:XMLNode):void{
            _view=new Sprite();
            var childs:Array=xml.childNodes;
            for each(var node:XMLNode in childs){
                var c:FormComponent;
                if(node.nodeType==3){
                    var txt:String=node.nodeValue.replace(/[\s\n\t\r]/gm,"");
                    if(txt.length==0)
                        continue;
                    c=new FormText(node);
                }else
                    c=new FormComponent(node);
                _add(c,-1,false);
            }
        }


        public function addAll(components:Vector.<FormComponent>):void{
            for each(var c:FormComponent in components)
                _add(c,-1,false)
            rebuild();
        }

        public function add(component:FormComponent,index:int=-1):void{
            _add(component,index,true);
        }

        private function _add(component:FormComponent,index:int,doRebuild:Boolean):void{
            var found:Boolean=false;
            var l:int=_components.length;
            for(var i:int=0;i<l;i++){
                var c:FormComponent=_components[i];
                if(c==component){
                    found=true;
                    _components.removeAt(i);
                    break;
                }
            }
            component.removeFromStage();
            if(index>-1){
                _components.insertAt(index,component)
                (_view as DisplayObjectContainer).addChildAt(component.view,index);
            }else{
                _components.push(component);
                (_view as DisplayObjectContainer).addChild(component.view);
            }
            component.parent=this;
            if(doRebuild)
                rebuild();
        }

        private function rebuild():void{
            // root level;
            if(parent==null){
                redraw();
                return;
            }
            // find root
            var p:FormComponent=parent;
            while(p.parent!=null){
                p=p.parent;
            }
            p.redraw();
        }

        protected function getParentSize(side:String):int{
            var p:FormComponent=parent;
            var result:int=0;

            // MATCH PARENT
            while(p!=null){
                if(p.style[side]>-1)
                    return p.style[side];
                p=p.parent;
            }

            return result;
        }

        protected function redraw():void{
            
            // SETUP SIZE
            bounds.display_width=style.width>0?style.width:0;
            bounds.display_height=style.height>0?style.height:0;

            // check parent style & setup dimm
            if(parent!=null){
                if(style.width==-1 && parent.style.layout.toString()==FormLayout.VERTICAL){
                    bounds.display_width=getParentSize("width");
                    bounds.display_height=-1; // wrap content, set value after layout
                }else if(style.height==-1 && parent.style.layout.toString()==FormLayout.HORIZONTAL){
                    bounds.display_height=getParentSize("height");
                    bounds.display_width=-1; // wrap content, set value after layout
                }
            }
            
            
            if(nodeType==3){
                // TODO: textField sizes
                bounds.width=100;
                bounds.height=20;
                bounds.display_width=100;
                bounds.display_height=20;
            }else{

                // setup layout

                var nextPos:int=0;
                var maxSize:int=0;
                for each(var c:FormComponent in _components){
                    c.redraw(); // build child
                    c.view[style.layout.axis]=nextPos; // setup position
                    nextPos+=c.bounds[style.layout.side]; // inc position
                    if(c.bounds[style.layout.oppositeSide]>maxSize)
                        maxSize=c.bounds[style.layout.oppositeSide]
                }
                bounds[style.layout.side]=nextPos;
                bounds[style.layout.oppositeSide]=maxSize;

                // setup wrap content for display size
                if(bounds['display_'+style.layout.oppositeSide]<0)
                    bounds['display_'+style.layout.oppositeSide]=maxSize;
            }

            if(bounds.width==0){
               trace(bounds) 
            }

            // draw env
            if(_view is Sprite){
                var spr:Sprite=_view as Sprite;
                spr.graphics.beginFill(style.background.color,style.background.alpha);
                spr.graphics.drawRect(0,0,bounds.display_width,bounds.display_height);
            }

        }

        protected function removeFromStage():void{
            parent=null;
            if(_view!=null && _view.parent!=null)
                _view.parent.removeChild(_view);
        }
    }
}