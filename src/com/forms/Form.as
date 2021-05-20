package com.forms
{
    import flash.xml.XMLDocument;
    
    public class Form extends FormComponent{
        private var scaleFactor:int=1;
        public function Form(xml:XML,scaleFactor:int=1){
            this.scaleFactor=scaleFactor;
            super(new XMLDocument(xml).firstChild);
        }
        
        public function setSize(width:int,height:int):void{
            style.width=width;
            style.height=height;
            redraw();
        }
    }
}