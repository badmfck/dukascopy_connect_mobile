package com.forms
{
    import flash.xml.XMLNode;
    import flash.text.TextField;

    public class FormText extends FormComponent{

        public function FormText(xml:XMLNode){
            super(xml,null);
        }
        override protected function createView(xml:XMLNode):void{
            _view=new TextField();
            var txt:String=xml.nodeValue;
            txt=txt.replace(/^[\s\n\t\r]/gm,"");
            txt=txt.replace(/[\s\n\t\r]$/gm,"");
            txt=txt.replace(/ {2,}/gm,"");
            (_view as TextField).text=txt;
        }
    }
}