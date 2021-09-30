package com.forms
{
    public class FormPadding{
        public var top:int;
        public var left:int;
        public var bottom:int;
        public var right:int;
        public function FormPadding(t:int,r:int,b:int,l:int){
            top=t;
            right=r;
            bottom=b;
            left=l;
        }
        public function get isSet():Boolean{
            return top>0 || right>0 || bottom>0 || left > 0
        }
    }
}