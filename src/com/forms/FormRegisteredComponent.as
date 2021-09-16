package com.forms
{
    public class FormRegisteredComponent{
        private var _name:String;
        private var cls:Class;
        private var xml:XML;
        public function FormRegisteredComponent(name:String,_class:Class,xml:XML=null):void{
            if(xml){
                this.xml=xml;
                return;
            }
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