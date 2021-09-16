package com.forms
{
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.events.Event;
    import flash.utils.setTimeout;
    import flash.system.System;
    import flash.utils.setInterval;

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
            graphics.beginFill(0,.2);
            graphics.drawRect(0,0,50,30);
            tf.textColor=0xFFFFFF;
            alpha=.3;
        }

        private function onTimer():void{
            tf.text=fpsRendered+((stage!=null)?(" of "+stage.frameRate):"");
            fpsRendered=0;
        }

        private function onEnterFrame(e:Event):void{
            fpsRendered++;
        }
    }
}