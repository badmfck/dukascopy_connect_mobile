package com.forms{

    import flash.display.Sprite;
    import flash.xml.XMLNode;
    import flash.display.DisplayObjectContainer;
    import flash.display.DisplayObject;
    import com.forms.components.FormButton;
       

    public class FormComponent{

        protected var predefinedStyle:FormStyle=null;
        protected var bounds:FormBounds=new FormBounds(0,0);
        protected var style:FormStyle;
        protected var nodeName:String;
        protected var nodeType:int;
        private var _id:String=null;
        public function get id():String{return _id}
        protected var _view:DisplayObject;
        public function get view():DisplayObject{return _view;}
        private var _components:Vector.<FormComponent>=new Vector.<FormComponent>();
        private var form:Form;
        protected var parent:FormComponent=null;

        // listeners
        private var _onTap:Function=null;
        public function set onTap(val:Function):void{ _onTap=val; }
        
        public function FormComponent(xml:XMLNode,form:Form){
            style=new FormStyle(xml,predefinedStyle);
            nodeName=xml.nodeName;
            nodeType=xml.nodeType;
            this.form=form;
            if(xml.attributes!=null && ("id" in xml.attributes)){
                _id=xml.attributes["id"];
                if(this.form!=null)
                    this.form.regID(_id,this);
            }
            createView(xml);
        }

        protected function createView(xml:XMLNode):void{
            _view=new Sprite();
            var childs:Array=xml.childNodes;
            for each(var node:XMLNode in childs){
                var c:FormComponent;
                if(node.nodeType==3){
                    var txt:String=node.nodeValue.replace(/[\s\n\t\r]/gm,"");
                    if(txt.indexOf("//<!--")==0)
                        continue;
                    if(txt.length==0)
                        continue;
                    c=new FormText(node);
                }else{
                    switch(node.nodeName.toLowerCase()){
                        case "button":
                            c=new FormButton(node,form);
                        default :
                            c=new FormComponent(node,form);
                        break;
                    }

                    c=new FormComponent(node,form);
                }
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
            /*var p:FormComponent=parent;
            var result:int=0;

            // MATCH PARENT
            while(p!=null){
                if(p.style[side]>-1)
                    return p.style[side];
                p=p.parent;
            }*/

            return parent.bounds["display_"+side];

            //return result;
        }

        protected function redraw(percentOffsetW:int=-1,percentOffsetH:int=-1):void{
            
            // SETUP SIZE
            bounds.display_width=style.width>0?style.width:-2;
            bounds.display_height=style.height>0?style.height:-2;
            
            if(id=="txt2")
                trace('123');
            // check parent style & setup dimm
            if(parent!=null){
                var parentH:int=getParentSize("height")
                var parentW:int=getParentSize("width")
                if(style.width==-1 && parent.style.layout.toString()==FormLayout.VERTICAL){
                    bounds.display_width=parentW;
                    if(style.height<0)
                        bounds.display_height=-1; // wrap content, set value after layout
                }else if(style.height==-1 && parent.style.layout.toString()==FormLayout.HORIZONTAL){
                    //bounds.display_height=parentH;
                    if(style.width<0)
                        bounds.display_width=-1; // wrap content, set value after layout
                }
                // percentage
                if(style.isHeightPercentage){
                    if(parentH>-1){
                        if(percentOffsetH==-1)
                            percentOffsetH=0;
                        bounds.display_height=Math.round((style.height/100)*(parentH-percentOffsetH));
                    }else{
                        trace("FC.WARN: parent height must be set, when using percentage value in child")
                        bounds.display_height=-1; // no parent height
                    }
                }
                if(style.isWidthPrecentage){
                    if(parentW>-1){
                        if(percentOffsetW==-1)
                            percentOffsetW=0;
                        bounds.display_width=Math.round((style.width/100)*(parentW-percentOffsetW));
                    }else{
                        trace("FC.WARN: parent width must be set, when using percentage value in child")
                        bounds.display_width=-1; // NO PARENT WIDTH
                    }
                }
            }
            
            
            if(nodeType==3){
                // TODO: textField sizes
                bounds.width=100;
                bounds.height=30;
                bounds.display_width=100;
                bounds.display_height=bounds.height;
            }else{

                var percentagesChidldren:Array=[];
                
                // setup layout
                var nextPos:int=0;
                var maxSize:int=0;
                var lastSize:int=0;
                for each(var c:FormComponent in _components){

                    var obj:Object=null;
                    if(c.style.isHeightPercentage){
                        if(obj==null)
                            obj={}
                        obj.child=c;
                        obj.height=true;
                    }
                    
                    if(c.style.isWidthPrecentage){
                        if(obj==null)
                            obj={}
                        obj.child=c;
                        obj.width=true;
                    }

                    if(obj!=null){
                       percentagesChidldren.push(obj)
                       continue;
                    }


                    c.redraw(); // build child
                    c.view[style.layout.axis]=nextPos; // setup position
                    nextPos+=c.bounds[style.layout.side]; // inc position
                    if(c.bounds[style.layout.oppositeSide]>maxSize)
                        maxSize=c.bounds[style.layout.oppositeSide]
                }

                bounds[style.layout.side]=nextPos;

                if(percentagesChidldren.length==0){
                    if(bounds[style.layout.side]<bounds['display_'+style.layout.side])
                        bounds[style.layout.side]=bounds["display_"+style.layout.side]
                }

                bounds[style.layout.oppositeSide]=maxSize;

                // setup wrap content for display size
                if(bounds['display_'+style.layout.oppositeSide]<0)
                    bounds['display_'+style.layout.oppositeSide]=maxSize;
                if(bounds['display_'+style.layout.side]<0)
                    bounds['display_'+style.layout.side]=bounds[style.layout.side];

                
                if(percentagesChidldren.length>0){
                    nextPos=0;
                    for each(c in _components){
                        for each(var pC:Object in percentagesChidldren){
                            if(pC.child==c){
                                var poffsetW:int=pC.width==true && bounds.display_width!=bounds.width?bounds.width:-1;
                                var poffsetH:int=pC.height==true && bounds.display_height!=bounds.height?bounds.height:-1;
                                c.redraw(poffsetW,poffsetH);
                                break;
                            }
                        }
                        
                        c.view[style.layout.axis]=nextPos; // setup position
                        nextPos+=c.bounds[style.layout.side]; // inc position
                        if(c.bounds[style.layout.oppositeSide]>maxSize)
                            maxSize=c.bounds[style.layout.oppositeSide]
                    }
                    bounds[style.layout.side]=nextPos;
                    if(bounds[style.layout.side]<bounds['display_'+style.layout.side])
                        bounds[style.layout.side]=bounds["display_"+style.layout.side]

                    bounds[style.layout.oppositeSide]=maxSize;

                    // setup wrap content for display size
                    if(bounds['display_'+style.layout.oppositeSide]<0)
                        bounds['display_'+style.layout.oppositeSide]=maxSize;

                    if(bounds['display_'+style.layout.side]<0)
                        bounds['display_'+style.layout.side]=bounds[style.layout.side];
                }
            }

            draw();
        }

        protected function draw():void{
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

        public function destroy():void{
            for each(var c:FormComponent in _components)
                c.destroy();
            removeFromStage();
            if(form!=null && id!=null)
                form.unregID(id);
            if(_onTap!=null)
                onTap=null
            parent=null;
            style=null;
            bounds=null;
            predefinedStyle=null;
        }
    }
}