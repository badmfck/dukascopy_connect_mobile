package com.telefision.utils
{
 
    public class Map{
        private var valuesMap:Object={}; //{KEY_string, value_index} 
        private var keysMap:Object={}; // {KEY_string, key_index}
        private var values:Vector.<Object>=new Vector.<Object>();
        private var keys:Vector.<String>=new Vector.<String>();
        private var name:String;
        static private var nameID:int=0;
        /**
         * 
         * @param name, optional string, map name.
         */
        public function Map(name:String=null){
            if(name==null)
                name="Map-"+(nameID++);
            this.name=name;
        }

        /**
         * Add value to map
         * @param key 
         * @param value 
         * @return map istance
         */
        protected function add(key:String,value:Object):Map{
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

        /**
         * Get value from map by key
         * @param key 
         * @return value or null if value not exists
         */
        protected function getValue(key:String):Object{
            if(key in valuesMap)
                return values[valuesMap[key]];
            return null;
        }

        /**
         * Create unmutable array with map values
         * @return array with map values
         */
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

        /**
         * Create unmutable array of keys
         * @return array of key values
         */
        public function getKeys():Array{
            var arr:Array=[];
            for each(var value:Object in keys)
                arr.push(value);
            return arr;
        }

        /**
         * Check if key exists in map
         * @param key - string, key to check
         * @return true if key exists
         */
        public function exists(key:String):Boolean{
            return key in valuesMap
        }

        /**
         * Remove element from map by key
         * @param key to remove
         * @return removed object or null if object wasnt found in map
         */
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

        /**
         * Calculate map size
         * @return map size
         */
        public function get size():int{
            return values.length;
        }

    }
}