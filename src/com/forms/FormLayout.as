package com.forms{
    public class FormLayout{
        static public const HORIZONTAL:String="horizontal";
        static public const VERTICAL:String="vertical";
        private var _val:String;
        private var _axis:String;
        private var _side:String;
        private var _oppositeAxis:String;
        private var _oppositeSide:String;

        public function get axis():String{
            return _axis;
        }
        public function get side():String{
            return _side;
        }
        public function get oppositeAxis():String{
            return _oppositeAxis;
        }
        public function get oppositeSide():String{
            return _oppositeSide;
        }

        public function FormLayout(layoutString:String=null){
            _val=VERTICAL;
            _axis="y";
            _side="height"
            _oppositeAxis="x"
            _oppositeSide="width"
            if(layoutString!=null && layoutString.toLowerCase().indexOf("horiz")==0){
                _val=HORIZONTAL;
                _axis="x";
                _side="width"
                _oppositeAxis="y"
                _oppositeSide="height"
            }
        }
        public function toString():String{
            return _val;
        }
    }
}