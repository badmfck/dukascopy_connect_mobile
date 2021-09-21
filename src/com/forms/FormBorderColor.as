package com.forms
{
    public class FormBorderColor{
        public var top:uint;
        public var left:uint;
        public var bottom:uint;
        public var right:uint;
        private var _isSet:Boolean;

        public function FormBorderColor(t:String,r:String,b:String,l:String){
            if(t==null && r==null && b==null && l==null){
                return;
            }

            _isSet=true;
            
            top=parseColor(t);
            right=parseColor(r);
            bottom=parseColor(b);
            left=parseColor(l);
        }

        private function parseColor(clr:String):uint{
            var _alpha:Number=1;
            if(clr.length==8){
                // with alpha
                var a:int=parseInt(clr.substr(-2));
                _alpha=255/a;
                clr=clr.substr(0,clr.length-2);
            }
            return parseInt("0x"+clr.substr(1));
        }


        public function get isSet():Boolean{ return _isSet;}
        public function toString():String{
            return "FormBorderColor: top:"+top+", right:"+right+", "+", bottom:"+bottom+", left:"+left;
        }
    }
}