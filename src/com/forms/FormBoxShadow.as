package com.forms
{
    import flash.filters.BitmapFilterQuality;
    import flash.filters.DropShadowFilter;

    public class FormBoxShadow{
        private var _value:DropShadowFilter;
        public function FormBoxShadow(blurX:int,blurY:int=-1){
            if(blurY==-1)
                blurY=blurX;
            var dist:Number=4;
            var angle:Number=90;
            var color:uint=0x0;
            var alpha:Number=.5;
            var inner:Boolean=false;

            _value=new DropShadowFilter(dist,angle,color,alpha,blurX,blurY,1,BitmapFilterQuality.HIGH,inner);
        }
        public function get value():DropShadowFilter{
            return _value;
        }
    }
}