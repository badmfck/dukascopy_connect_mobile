package com.forms
{
    public class FormFontFace{
        private var _isSet:Boolean=false;
        private var _val:String;
        public function FormFontFace(val:String){
            _val=val;
            if(_val==null)
                _val="";
            else
                _isSet=true;
        }
        public function get isSet():Boolean{
            return _isSet;
        }
        public function toString():String{
            return _val;
        }
    }
}