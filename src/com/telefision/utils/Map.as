package com.telefision.utils
{
    public class Map{
        private var valuesMap:Object={}; //{KEY_string, value_index} 
        private var keysMap:Object={}; // {KEY_string, key_index}
        private var values:Vector.<Object>=new Vector.<Object>();
        private var keys:Vector.<String>=new Vector.<String>();
        private var name:String;
        static private var nameID:int=0;
        public function Map(name:String=null){
            if(name!=null)
                this.name=name;
            else
                this.name="MAP-"+(nameID++);
        }

        public function setValue(key:String,value:Object):Map{
            var valIndex:int=-1;
            if(key in valuesMap)
                valIndex=valuesMap[key];
            
            // UPDATE VALUE
            if(valIndex>-1){
                values[valIndex]=value;
                return this;
            }
            
            // SET VALUE
            valuesMap[key]=values.push(value)-1;
            keysMap[key]=keys.push(key)-1;
            
            return this;
        }

        public function getValue(key:String):Object{
            if(key in valuesMap)
                return values[valuesMap[key]];
            return null;
        }

        public function getValues():Array{
            var arr:Array=[];
            for each(var value:Object in values)
                arr.push(value);
            return arr;

        }

        /**
         * Iterate over map,
         * callback function calls on each item and must return true or false, 
         * if false - foreach will break
         * @param callback - function(key:Stirng,value:Object):Boolean
         */
        public function foreach(callback:Function):void{
            var l:int=values.length;
            for(var i:int=0;i<l;i++){
                var val:Object=values[i];
                var key:String=keys[i];
                var doBreak:Boolean=callback(key,val);
                if(doBreak)
                    break;
            }
        }

        public function getKeys():Array{
            var arr:Array=[];
            for each(var value:Object in keys)
                arr.push(value);
            return arr;
        }

        public function remove(key:String):Object{
            if(key in valuesMap){
                var index:int=valuesMap[key];
                var keyIndex:int=keysMap[key];
                var obj:Object=values[index];
                values.splice(index,1);
                keys.splice(keyIndex,1);
                valuesMap[key]=null;
                keysMap[key]=null;
                delete valuesMap[key];
                delete keysMap[key];
                return obj;
            }
            return null;
        }

        public function get size():int{
            return values.length;
        }

    }
}