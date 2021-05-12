package com.dukascopy.connect.sys{
    
    import flash.events.EventDispatcher;
    
    public class Dispatcher{
        private var target:EventDispatcher=null;
        private var registered:Array=[]; //{event:string,listener:function}

        public function Dispatcher(target:EventDispatcher=null):void{
            setTarget(target);
        }

        public function setTarget(target:EventDispatcher):void{
            this.target=target;
        }

        public function add(event:String,listener:Function,...rest):Function{
            if(target==null){
                trace("ERR: target is null");
                return listener;
            }
            target.addEventListener(event,listener);
            var l:int=registered.length;
            var found:Boolean=false;
            for(var i:int=0;i<l;i++){
                var itm:Object=registered[i];
                if(itm==null)
                    continue;
                if(itm.event==event && itm.listener==listener){
                    found=true;
                    break;
                }
            }
            if(!found)
                registered.push({event:event,listener:listener});
            return listener;
        }

        public function remove(event:String,listener:Function=null):void{
            if(target==null)
                trace("ERR: target is null")
            var l:int=registered.length;
            for(var i:int=0;i<l;i++){
                var itm:Object=registered[i];
                if(itm==null)
                    continue;
                if(listener!=null){
                    if(itm.event==event && itm.listener==listener){
                        registered.splice(i,1);
                        break;
                    }
                }else{
                    if(itm.event==event){
                        listener=itm.listener;
                        registered.splice(i,1);
                        break;
                    }
                }
            }
            target.removeEventListener(event,listener);
        }

        public function removeAll():void{
            if(target==null)
                trace("ERR: target is null");
            var l:int=registered.length;
            for(var i:int=0;i<l;i++){
                var itm:Object=registered[i];
                if(itm==null)
                    continue;
                target.removeEventListener(itm.event,itm.listener);
            }
            registered=[];
        }

        public function clear():void{
            removeAll();
            target=null;
        }

    }
}