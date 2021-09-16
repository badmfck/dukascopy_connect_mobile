package com.forms
{
    public class FormAlign{
        static public const CENTER:String="center"
        static public const BEGIN:String="begin"
        static public const END:String="end"
        private var _isSet:Boolean=false;
        private var _value:String;
        public function FormAlign(align:String){
            _value=align;
            _isSet=_value!=null;
            if(align==null)
                _value=FormAlign.BEGIN;
        }
        public function toString():String{
            return _value;
        }
        public function get value():String{
            return _value;
        }
        public function get isSet():Boolean{
            return _isSet;
        }
    }
}