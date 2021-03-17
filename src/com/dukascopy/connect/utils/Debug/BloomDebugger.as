package com.dukascopy.connect.utils.Debug {

    public class BloomDebugger {

        static private var stack:Array=[];
        static private var isStopped:Boolean=false;

        static public function registerCall(method:String):void {
            if(isStopped)
                return;
            stack.push(method);
            if(stack.length>50)
                stack.shift();
        }

        static public function getStack():String{
            var l:int=stack.length;
            var res:String="";
            for(var i:int=0;i<l;i++){
                if(res.length>0)
                    res+="\n";
                res+=stack[i];
            }
            return res;
        }

        static public function stop():void{
            isStopped=true;
        }
        static public function start():void{
            isStopped=false;
            stack=[];
        }

    }

}