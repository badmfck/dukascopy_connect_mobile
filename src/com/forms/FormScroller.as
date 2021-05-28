package com.forms
{
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.display.Sprite;

    public class FormScroller{
        private var target:DisplayObject;
        private var eventTarget:DisplayObject;
        private var mask:DisplayObject;
        private var bounds:FormBounds;
        private var frameAdded:Boolean=false;
        private var moving:Boolean=false;
        private var maxSideOffsetY:int=50;
        private var startMX:int=0;
        private var startMY:int=0;
        private var startX:int=0;
        private var startY:int=0;

        private var tx:int=0;
        private var ty:int=0;

        private var speedTimer:Timer;
        private var speedTimerY:int;
        private var speedTimerSY:int;
        private var speedY:int;
        private var speedLastTick:Number=0;

        private var mDown:String=MouseEvent.MOUSE_DOWN;
        private var scaleFactor:Number=1;
        
        public function FormScroller(eventTarget:DisplayObject,target:DisplayObject,mask:DisplayObject,axis:String,scaleFactor:Number){
            this.target=target;
            this.mask=mask;
            this.eventTarget=eventTarget;
            this.scaleFactor=scaleFactor;
            eventTarget.addEventListener(mDown,onMDown)
            maxSideOffsetY=mask.height*.4
        }

        public function setBounds(bounds:FormBounds):void{
            this.bounds=bounds;
        }

        private function onMDown(e:MouseEvent):void{
            if(eventTarget.stage==null)
                return;
            eventTarget.stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove)
            eventTarget.stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp)
            if(!frameAdded){
                eventTarget.addEventListener(Event.ENTER_FRAME,onFrame)
                frameAdded=true;
            }
            startX=target.x;
            startY=target.y;
            startMX=target.stage.mouseX;//*scaleFactor;
            startMY=target.stage.mouseY;//*scaleFactor;
            speedTimerSY=eventTarget.stage.mouseY;//*scaleFactor;
            setTimer();
        }

        private function onMouseUp(e:MouseEvent):void{
            eventTarget.stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove)
            eventTarget.stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp)
            moving=false;
            clearTimer();
            
            var spr:Sprite=new Sprite();
            

            trace(">"+speedY,new Date().getTime()-speedLastTick);
        }

        private function onMouseMove(e:MouseEvent):void{
            moving=true;
            target.y=startY+(target.stage.mouseY-startMY);
        }

        private function setTimer():void{
            if(speedTimer!=null)
                clearTimer();
            
            speedTimer=new Timer(20,0)
            speedTimer.addEventListener(TimerEvent.TIMER,onSpeedTimer)
            speedLastTick=new Date().getTime();
            speedTimer.start();

        }

        private function clearTimer():void{
            if(speedTimer==null)
                return;
            speedTimer.stop();
            speedTimer.removeEventListener(TimerEvent.TIMER,onSpeedTimer);
            speedTimer=null;
        }

        private function onSpeedTimer(e:TimerEvent=null):void{
            if(target.stage==null)
                return;
            speedY=speedTimerY; // set pixels passed
            speedTimerSY=eventTarget.stage.mouseY;
            speedLastTick=new Date().getTime();
        }

        private function onFrame(e:Event):void{
            speedTimerY=speedTimerSY-eventTarget.stage.mouseY;
        }

        public function dispose():void{
            
            if(eventTarget){
                eventTarget.removeEventListener(Event.ENTER_FRAME,onFrame)
                eventTarget.removeEventListener(mDown,onMDown)
                if(eventTarget.stage!=null){
                    eventTarget.stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove)
                    eventTarget.stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp)
                }
            }
            clearTimer();
            frameAdded=false;
            eventTarget=null;
            target=null;
            mask=null;
            moving=false
            bounds=null;
        }
    }
}