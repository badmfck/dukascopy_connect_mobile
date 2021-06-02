package com.telefision.sys.signals
{
    public class SuperSignal{

        private var disposed:Boolean=false;
        private var busy:Boolean=false;
        private var methods:/*SuperSignalVO*/Array=[];
        private var delays:/*SuperSignalDelaysVO*/Array=[];
        private var invokes:Array=[];
        private var name:String;
        private static var nextID:int=0;

        public function SuperSignal(name:String=null){
            if(name==null)
                name="Signal-"+(nextID++);
            this.name=name;

        }
        
        /**
         * Add listener to signal
         * @param callback function calls when signal goes to invoke
         * @param context - function context (null by deafult)
         * @param id - listener id (null by deafult)
         * @return callback
         */
        public function add(callback:Function,context:Object=null,id:Object=null):Function{
            if(disposed || methods==null)
                return callback;
            // check if callback already exists
            if(methods!=null){
                for each(var value:SuperSignalVO in methods){
                    if(value.callback===callback)
                        return callback;
                }
            }
            var ssvo:SuperSignalVO=new SuperSignalVO(callback,context,id);
            if(busy){
                delays.push(new SuperSignalDelayedVO(ssvo,0));
                return callback;
            }
            methods.push(ssvo);
            return callback;
        }

        /**
         * Invoke signal, pass parameters
         * @param ...rest 
         */
        protected function _invoke(...rest):void{
            if(disposed || methods==null)
                return;
            if(busy){
                invokes.push(rest);
                trace("Signal already invoking "+name);
                return;
            }
            busy=true;
            var l:int=methods.length;
            for(var i:int=0;i<l;i++){
                var ssvo:SuperSignalVO=methods[i];
                if(!ssvo)
                    continue;
                if(!(ssvo.callback is Function) || ssvo==null)
                    continue;
                ssvo.callback.apply(ssvo.context,rest);
            }
            busy=false;

            if(disposed){
                dispose();
                return;
            }

            // add or remove
            if(delays!=null){
                for each(var val:SuperSignalDelayedVO in delays){
                    if(val.side==0)
                        add(val.vo.callback,val.vo.context,val.vo.id);
                    else
                        _remove(val.value,val.key);
                }
                delays=[];
            }

            // delayed invokes
            if(invokes!=null){
                for each(var invokeData:Array in invokes){
                    _invoke.apply(this,invokeData);
                }
                invokes=[];
            }

        }

        /**
         * Remove listener from signal
         * @param ...rest 
         * @return true if remove was successfull
         */
        public function remove(callback:Function):Boolean{
            if(disposed || callback==null)
                return false;
            return _remove(callback,"callback");
        }

        /**
         * Remove all listeners with same context
         * @param context - listener contexts
         * @return true if remove was successfull
         */
        public function clearContext(context:Object):Boolean{
            if(disposed || context==null)
                return false;
            return _remove(context,"context");
        }

        /**
         * Remove all listeners with same id
         * @param id - listener id
         * @return true if remove was successfull
         */
        public function clearID(id:Object):Boolean{
            if(disposed || id==null)
                return false;
            return _remove(id,"id");
        }

        /**
         * Do remove listener from signal by callback or context or id
         * @param value listener identifier
         * @param name listener identifier name
         * @return true if was removed
         */
        private function _remove(value:Object,name:String):Boolean{
            if(disposed)
                return true;

            if(busy){
                delays.push(new SuperSignalDelayedVO(null,1,value,name))
                return true;
            }

            var l:int=methods.length;
            var res:Boolean=false;
            for(var i:int=0;i<l;i++){
                var ssvo:SuperSignalVO=methods[i];
                if(ssvo==null)
                    continue;
                if(name in ssvo && ssvo[name]==value){
                    methods.splice(i,1);
                    if(name==="callback")
                        return true;
                    res=true;
                    l--;
                    i--
                }
            }
            return res;
        }

        public function dispose():void{
            disposed=true;
            if(busy)
                return;
            clear();
            methods=null;
            delays=null;
            invokes=null;
        }

        public function clear():void{
            if(methods!=null){
                for each(var ssvo:SuperSignalVO in methods)
                    ssvo.clear();
                methods=[];
            }
            
            if(invokes!=null)
                invokes=[];
        }
    }
}

class SuperSignalVO{
    public var callback:Function
    public var context:Object
    public var id:Object
    public function SuperSignalVO(callback:Function,context:Object,id:Object){
        this.callback=callback;
        this.context=context;
        this.id=id;
    }
    public function clear():void{
        callback=null;
        context=null;
        id=null;
    }
}

class SuperSignalDelayedVO{
    public var vo:SuperSignalVO;
    public var side:int=0; // 0 - add, 1 - remove
    public var key:String; // key - param name for compare when remove
    public var value:Object; // 0 - param for compare when remove
    public function SuperSignalDelayedVO(vo:SuperSignalVO,side:int,value:Object=null,key:String=null){
        this.vo=vo;
        this.side=side;
        this.value=value;
        this.key=key;
    }
    public function clear():void{
        vo=null;
        side=0;
        key=null;
        value=null;
    }
}