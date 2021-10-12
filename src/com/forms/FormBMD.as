package com.forms
{
    import flash.display.BitmapData;

    public class FormBMD extends BitmapData{
        private var uses:int=0;
        public function FormBMD(width:int,height:int,transparent:Boolean=true,fillColor:uint=0){
            super(width,height,transparent,fillColor);
        }
        override public function dispose():void{
            uses--;
            if(uses==0)
                super.dispose();
        }
    }
}