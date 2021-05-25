package com.forms
{
    public class FormRegisteredComponent{
        private var _name:String;
        private var cls:Class;
        public function FormRegisteredComponent(name:String,_class:Class):void{
            _name=name;
            cls=_class;
        }

        public function get name():String{
            return _name;
        }
        public function get _class():Class{
            return cls;
        }
    }
}