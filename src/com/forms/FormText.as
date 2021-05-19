package com.forms
{
    import flash.xml.XMLNode;
    import flash.text.TextField;

    public class FormText extends FormComponent{

        public function FormText(xml:XMLNode){
            super(xml);
        }
        override protected function createView(xml:XMLNode):void{
            _view=new TextField();
            (_view as TextField).text=xml.nodeValue;
        }
    }
}