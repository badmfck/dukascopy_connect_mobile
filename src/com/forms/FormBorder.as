package com.forms
{
    public class FormBorder{
        public var top:uint;
        public var left:uint;
        public var bottom:uint;
        public var right:uint;
        public function FormBorder(t:uint,r:uint,b:uint,l:uint){
            top=t;
            right=r;
            bottom=b;
            left=l;
        }
        public function toString():String{
            return "FormBorder: top:"+top+", right:"+right+", "+", bottom:"+bottom+", left:"+left;
        }
    }
}