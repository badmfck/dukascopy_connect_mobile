package com.forms
{
    public class FormAlign{
        static public const CENTER_CENTER:String="center center"
        static public const TOP_LEFT:String="top left"
        private var _value:String;
        public function FormAlign(align:String){
            _value=align;
        }
        public function toString():String{
            return _value;
        }
        public function get value():String{
            return _value;
        }
    }
}