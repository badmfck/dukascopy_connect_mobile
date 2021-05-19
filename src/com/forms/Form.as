package com.forms
{
    import flash.xml.XMLDocument;
    
    public class Form extends FormComponent{
        public function Form(xml:XML){
            super(new XMLDocument(xml).firstChild);
        }
        
        public function setSize(width:int,height:int):void{
            style.width=width;
            style.height=height;
            redraw();
        }
    }
}