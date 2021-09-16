package com.forms
{
    public class FormTextAlign{
        
        private var _isSet:Boolean;
        private var _value:String;
        public function FormTextAlign(val:String){
            _value=val;
            if(_value==null)
                _value="left";
            else
                _isSet=true;
        }
        public function get isSet():Boolean{
            return _isSet;
        }
        public function toString():String{
            return _value;
        }
    }
}