package com.forms
{
    import com.dukascopy.connect.sys.calendar.BookedDays;

    public class FormColor{
        private var _isSet:Boolean;
        private var _value:uint;
        private var _alpha:Number=1;
        
        public function FormColor(clr:String){
            if(clr==null){
                _isSet=false;
                return;
            }
            if(clr.length==8){
                // with alpha
                var a:int=parseInt(clr.substr(-2));
                _alpha=255/a;
                clr=clr.substr(0,clr.length-2);
            }
            _value=parseInt("0x"+clr.substr(1));
            _isSet=true;
        }

        public function toString():String{
            return _isSet?_value+", "+_alpha:"not-set";
        }

        public function get color():uint{
            return _value;
        }
        
        public function get alpha():Number{
            return _alpha;
        }

        public function get isSet():Boolean{
            return _isSet;
        } 
    }
}