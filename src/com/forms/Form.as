package com.forms
{
    import flash.xml.XMLDocument;
    import com.forms.components.FormButton;
    import com.forms.components.FormSpace;
    import flash.xml.XMLNode;
    import com.forms.components.FormGraph;
    import com.forms.components.FormInput;
    import com.forms.components.FormList;
    import com.forms.components.FormListItem;
    import com.forms.components.FormTopOffset;
    import com.forms.components.FormBottomOffset;
    
    public class Form extends FormComponent{
        private var disposed:Boolean=false;
        static public var debug:Boolean=false;
        private var form:Form;
        private var registeredComponents:Object={};
        private var doRedraw:Boolean=false;
        private var _width:int=-1;
        private var _height:int=-1;
        private var _topOffset:int=0;
        private var _bottomOffset:int=0;
        static private var _avaiableComponentRenderers:Vector.<FormRegisteredComponent>=new Vector.<FormRegisteredComponent>();
        
        public function get topOffset():int{return _topOffset;}
        public function get bottomOffset():int{ return _bottomOffset;}

        public var formController:Object;
        private var _onFormCreated:Function;
        private var doCallFormCreated:Boolean=false;
        public function set onFormCreated(val:Function):void{
            _onFormCreated=val;
            if(doCallFormCreated){
                _onFormCreated();
                doCallFormCreated=false;
            }
        };

        public function Form(xml:*,additionalComponents:Vector.<FormRegisteredComponent>=null){
            _avaiableComponentRenderers.push(new FormRegisteredComponent("button",FormButton));
            _avaiableComponentRenderers.push(new FormRegisteredComponent("space",FormSpace));
            _avaiableComponentRenderers.push(new FormRegisteredComponent("top-offset",FormTopOffset));
            _avaiableComponentRenderers.push(new FormRegisteredComponent("bottom-offset",FormBottomOffset));
            _avaiableComponentRenderers.push(new FormRegisteredComponent("graph",FormGraph));
            _avaiableComponentRenderers.push(new FormRegisteredComponent("input",FormInput));
            _avaiableComponentRenderers.push(new FormRegisteredComponent("list",FormList));
            _avaiableComponentRenderers.push(new FormRegisteredComponent("li",FormListItem));
            if(additionalComponents){
                for each(var c:FormRegisteredComponent in additionalComponents){
                    _avaiableComponentRenderers.push(c);
                }
            }

            super(xml,this);
        }

        override public function reload():void{
            registeredComponents={};
            var w:int=_width;
            var h:int=_height;
            style=null;
            super.reload();
            setSize(w,h,_topOffset,_bottomOffset)
        }

        public function showDeviceFrame(frame:String):void{
            
        }
        
        public function setSize(width:int,height:int,topOffset:int=0,bottomOffset:int=0):void{


            _width=width;
            _height=height;
            _topOffset=topOffset;
            _bottomOffset=bottomOffset;

            if(style==null){
                doRedraw=true;
                return;
            }

            var formSize:int=-1;
            
            if(attributes!=null && "formSize" in attributes && attributes.formSize!=null)
                formSize=parseInt(attributes.formSize);
            else
                formSize=_width
            
            var w:int=formSize;
            var h:int=Math.round((formSize*_height)/_width);
            style.width=w;
            style.height=h;

            var scaleFactor:Number=_width/w;
     
            //style.width=width/_scaleFactor;
            //style.height=height/_scaleFactor;
            _view.scaleX=scaleFactor;
            _view.scaleY=scaleFactor;
            redraw();
        }

        override protected function createView(xml:XMLNode):void{
            super.createView(xml);
            if(doRedraw){
                setSize(_width,_height);
                doRedraw=false;
            }

            if(_onFormCreated && _onFormCreated is Function)
                _onFormCreated();
            doCallFormCreated=true;
        }

        public function refresh():void{
            rebuild();
        }

        public function createComponent(name:String,predefinedStyle:Object=null):FormComponent{
            for each(var itm:FormRegisteredComponent in avaiableComponentRenderes){
                if(itm.name==name)
                    return new itm._class(null,this);
            }
            return new FormComponent(null,this,predefinedStyle);
        }

        public function createComponentFromXML(xml:XML,predefinedStyle:Object=null):FormComponent{
             for each(var itm:FormRegisteredComponent in avaiableComponentRenderes){
                if(itm.name==name)
                    return new itm._class(new XMLDocument(xml).firstChild);
            }
            return new FormComponent(new XMLDocument(xml).firstChild,this,predefinedStyle);
        }

        public function regID(id:String,component:FormComponent):void{
            registeredComponents[id]=component;
        }

        public function unregID(id:String):void{
            registeredComponents[id]=null;
            delete registeredComponents[id];
        }

        public function getComponentByID(id:String):FormComponent{
            return registeredComponents[id];
        }

        public function get avaiableComponentRenderes():Vector.<FormRegisteredComponent>{
            return _avaiableComponentRenderers;
        }

        public function onElementClick(c:FormComponent,clickHandler:String):void{
            if(clickHandler!=null && formController!=null && clickHandler in formController){
                if(formController[clickHandler] is Function && formController[clickHandler].length==1)
                   formController[clickHandler](c);
                   
            }
        }

        override public function destroy():void{
            super.destroy();
            onDocumentLoaded=null;
        }
    }
}