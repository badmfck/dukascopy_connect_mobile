package com.forms
{
    public class FormTextSize{
        
        private var _isSet:Boolean;
        private var _value:int;
        
        public function FormTextSize(val:String){
            if(val==null){
                _isSet=false;
                return;
            }
            _value=parseInt(val);
            _isSet=true;
        }

        public function toString():String{
            return _isSet?_value+"":"not-set";
        }

        public function get size():uint{
            return _value;
        }

        public function get isSet():Boolean{
            return _isSet;
        } 
    }
}