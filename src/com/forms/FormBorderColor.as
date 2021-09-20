package com.forms
{
    public class FormBorderColor{
        public var top:uint;
        public var left:uint;
        public var bottom:uint;
        public var right:uint;
        private var _isSet:Boolean;
        
        public function FormBorderColor(t:uint,r:uint,b:uint,l:uint,isSet:Boolean=true){
            if(!isSet)
                return;
            _isSet=true;
            top=t;
            right=r;
            bottom=b;
            left=l;
        }

        public function get isSet():Boolean{ return _isSet;}
        public function toString():String{
            return "FormBorderColor: top:"+top+", right:"+right+", "+", bottom:"+bottom+", left:"+left;
        }
    }
}