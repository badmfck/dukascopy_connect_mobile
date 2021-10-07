package com.forms
{
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.display.Sprite;
    import com.greensock.TweenMax;
    import com.greensock.easing.Power4;


    public class FormScroller{
        private var target:DisplayObject;
        private var eventTarget:DisplayObject;
        private var mask:DisplayObject;
        private var bounds:FormBounds;
        private var frameAdded:Boolean=false;
        
        private var maxSideOffsetY:int=50;
        private var startMX:int=0;
        private var startMY:int=0;
        private var startX:int=0;
        private var startY:int=0;

        private var tx:int=0;
        private var ty:int=0;
  
        private var movingPhase:String="none"; // none,drag,moving,returning
        private var movingSpeed:Number=0;
        private var defaultFading:Number = .97;
        private var movingFading:Number = defaultFading;
        private var returnY:int=0;
        

        private var speedTimer:Timer;
        private var speedTimerY:int;
        private var speedTimerSY:int;
        private var speedY:int;
        private var speedLastTick:Number=0;

        private var mDown:String=MouseEvent.MOUSE_DOWN;

        public var onMoved:Function;
        
        
        public function FormScroller(eventTarget:DisplayObject,target:DisplayObject,mask:DisplayObject,axis:String){
            this.target=target;
            this.mask=mask;
            this.eventTarget=eventTarget;
            eventTarget.addEventListener(mDown,onMDown)
            maxSideOffsetY=mask.height*.4
        }

        public function setBounds(bounds:FormBounds):void{
            this.bounds=bounds;

            
            if(movingPhase!="none")
                return;
                
            TweenMax.killTweensOf(target);
            TweenMax.to(target,.6,{y:mask.height-bounds.height,roundProps:["y"],ease:Power4.easeOut,onUpdate:function():void{
                if(onMoved!=null)
                    onMoved();
            }});
         
        }

        private function onMDown(e:MouseEvent):void{
            if(eventTarget.stage==null)
                return;
            movingPhase="drag";
            eventTarget.stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove)
            eventTarget.stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp)
            if(!frameAdded){
                eventTarget.addEventListener(Event.ENTER_FRAME,onFrame)
                frameAdded=true;
            }
            TweenMax.killTweensOf(target);
            startX=target.x;
            startY=target.y;
            startMX=eventTarget.mouseX;//*scaleFactor;
            startMY=eventTarget.mouseY;//*scaleFactor;
            speedTimerSY=startMY;//*scaleFactor;
            ty=startY;
            setTimer();
        }

        private function onMouseUp(e:MouseEvent):void{
            eventTarget.stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove)
            eventTarget.stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp)
            ty=startY+(eventTarget.mouseY-startMY);
            movingPhase="moving";
            clearTimer();
            
            var spr:Sprite=new Sprite();
            

            // GOT 58 pixels in 14 secs
            // time 30;

            
            movingSpeed=speedY/30;
            movingFading=defaultFading
        }

        

        private function onMouseMove(e:MouseEvent):void{
            if(eventTarget==null)
                return;
            movingPhase="drag";
            ty=startY+(eventTarget.mouseY-startMY);
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
            speedTimerSY=eventTarget.mouseY;
            speedLastTick=new Date().getTime();
        }

        private function onFrame(e:Event):void{
            if(mask==null){
                eventTarget.removeEventListener(Event.ENTER_FRAME,onFrame);
                frameAdded=false;
                return;
            }
            speedTimerY=speedTimerSY-eventTarget.mouseY;
            var nextY:int=0;

            if(movingPhase=="drag"){
                target.y+=(ty-target.y)*.9;
            }else if(movingPhase=="moving"){
                movingSpeed*=movingFading;
                target.y-=movingSpeed* 10;
                if(target.y>0 && movingSpeed<=0){
                    movingFading*=.5;
                    returnY=0;
                    movingPhase="returning";
                }else if(target.y<=mask.height-bounds.height && movingSpeed>=0){
                    movingFading*=.5;
                    returnY=mask.height-bounds.height;
                    movingPhase="returning"
                }
            }else if(movingPhase=="returning"){
                if(Math.abs(movingSpeed)>0.2){
                    movingSpeed*=movingFading;
                    target.y-=movingSpeed* 10;
                }else{
                    //TweenMax.to(target,.6,{y:returnY,ease:Elastic.easeOut,easeParams:[1,1]});
                    TweenMax.to(target,.6,{y:returnY,ease:Power4.easeOut,onUpdate:function():void{
                         if(onMoved!=null)
                            onMoved();
                    }});
                    movingPhase="none";
                }
            }else if(movingPhase=="none"){
                eventTarget.removeEventListener(Event.ENTER_FRAME,onFrame);
                frameAdded=false;
            }

            target.y=Math.round(target.y);
            if(onMoved!=null)
                onMoved();

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
            movingPhase="none"
            bounds=null;
            onMoved=null;
            TweenMax.killTweensOf(target);
        }
    }
}