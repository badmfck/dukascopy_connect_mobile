package com.forms
{
    
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldAutoSize;
    import flash.text.AntiAliasType;

    public class FormTextArea extends FormComponent{
        private var text:String=""
        private var parsed:String="";
        private var currentValues:Object;
        public function FormTextArea(){
            super(null,null);
        }
    }
}