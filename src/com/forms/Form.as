package com.forms
{
    import flash.xml.XMLDocument;
    
    public class Form extends FormComponent{
        private var scaleFactor:int=1;
        private var form:Form;
        private var registeredComponents:Object={}
        public function Form(xml:XML,scaleFactor:int=1){
            this.scaleFactor=scaleFactor;
            super(new XMLDocument(xml).firstChild,form);
        }
        
        public function setSize(width:int,height:int):void{
            style.width=width/scaleFactor;
            style.height=height/scaleFactor;
            _view.scaleX=scaleFactor;
            _view.scaleY=scaleFactor;
            redraw();
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
    }
}