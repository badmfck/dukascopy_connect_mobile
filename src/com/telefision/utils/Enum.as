package com.telefision.utils
{
    public class Enum{
        private var _value:String;
        public function Enum(value:String):void{
            this._value=value;
        }
        public function toString():String{
            return _value;
        }
        public function get value():String{
            return _value;
        }
    }
}
