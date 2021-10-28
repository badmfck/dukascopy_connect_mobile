package com.forms
{
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.events.Event;
    import flash.system.System;
    import flash.utils.setInterval;
    import flash.text.TextFieldAutoSize;

    public class FPS extends Sprite{
        private var tf:TextField=new TextField();
        private var fpsRendered:int=0;
        private var counter:int=0;
        public function FPS(){
            addChild(tf);
            addEventListener(Event.ENTER_FRAME,onEnterFrame);
            setInterval(onTimer,1000);
            mouseChildren=false;
            mouseEnabled=false;
            tf.textColor=0xFFFFFF;
            tf.multiline=true;
            tf.autoSize=TextFieldAutoSize.LEFT;
            tf.x=10;
            tf.y=10;
            alpha=1;
           // blendMode=BlendMode.INVERT;
        }

        private function onTimer():void{
            var free:String="available: "+((System.freeMemory/1024)/1024).toFixed(2)+"mb";
            var using:String="using: "+((System.privateMemory/1024)/1024).toFixed(2)+"mb";
            
            tf.text=fpsRendered+((stage!=null)?(" of "+stage.frameRate):"")+"\n"+using+"\n"+free;
            tf.width=tf.textWidth+4;
            tf.height=tf.textHeight+4;
            fpsRendered=0;

            graphics.clear();
            graphics.beginFill(0,.8);
            graphics.drawRect(0,0,tf.width+20,tf.height+20);
        }

        private function onEnterFrame(e:Event):void{
            fpsRendered++;
        }
    }
}