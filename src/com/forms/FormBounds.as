package com.forms
{
    public class FormBounds{
        public var width:int;
        public var height:int;
        public var display_width:int;
        public var display_height:int;
        public function FormBounds(width:int,height:int){
            this.width=width;
            this.height=height;
        }

        public function toString():String{
            return "FormBounds -> width: "+width+", height: "+height+", displayWidth: "+display_width+", displayHeight: "+display_height
        }
    }
}