package com.forms
{
    import flash.xml.XMLDocument;
    import com.forms.components.FormButton;
    import com.forms.components.FormSpace;
    import flash.xml.XMLNode;
    import flash.system.Capabilities;
    import com.forms.components.FormGraph;
    
    public class Form extends FormComponent{
        private var disposed:Boolean=false;
        private var _scaleFactor:Number=1;
        private var form:Form;
        private var registeredComponents:Object={};
        private var doRedraw:Boolean=false;
        private var _width:int=-1;
        private var _height:int=-1;
        private var _avaiableComponentRenderers:Vector.<FormRegisteredComponent>=new Vector.<FormRegisteredComponent>();
        
        public function Form(xml:*,scaleFactor:Number=1){
            if(Capabilities.isDebugger && (Capabilities.os.toLowerCase().indexOf("mac")!=-1 || Capabilities.os.toLowerCase().indexOf("win")!=-1))
                scaleFactor/=2.7;
            //TODO: remove
            scaleFactor=1.4;
            _scaleFactor=scaleFactor;
            _avaiableComponentRenderers.push(new FormRegisteredComponent("button",FormButton));
            _avaiableComponentRenderers.push(new FormRegisteredComponent("space",FormSpace));
            _avaiableComponentRenderers.push(new FormRegisteredComponent("graph",FormGraph));
            super(xml,this);
         
        }

        override public function reload():void{
            registeredComponents={};
            var w:int=_width;
            var h:int=_height;
            style=null;
            super.reload();
            setSize(w,h)
        }
    
        
        public function setSize(width:int,height:int):void{

            _width=width;
            _height=height;

            if(style==null){
                doRedraw=true;
                return;
            }
            style.width=width/_scaleFactor;
            style.height=height/_scaleFactor;
           // _view.scaleX=_scaleFactor;
           // _view.scaleY=_scaleFactor;
            redraw();
        }

        override protected function createView(xml:XMLNode):void{
            super.createView(xml);
            if(doRedraw){
                setSize(_width,_height);
                doRedraw=false;
            }

        }

        public function createComponent(name:String,predefinedStyle:Object=null):FormComponent{
            return new FormComponent(null,this,predefinedStyle);
        }

        public function createComponentFromXML(xml:XML):FormComponent{
            return new FormComponent(new XMLDocument(xml).firstChild,this);
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

        override public function destroy():void{
            super.destroy();
            onDocumentLoaded=null;
        }

        public function get scaleFactor():Number{
            return _scaleFactor;
        }
    }
}