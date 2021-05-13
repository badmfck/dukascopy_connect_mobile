package com.telefision.utils
{
    public class Map{
        private var keys:Object={}; //{string, int}
        private var values:Vector.<Object>=new Vector.<Object>();
        public function Map(){

        }

        public function setValue(key:String,value:Object):Map{
            var index:int=-1;
            if(key in keys && keys[key]>-1)
                index=keys[key];

            if(index>-1){
                values[index]=value;
                return this;
            }

            keys[key]=values.push(value)-1;

            return this;
        }

        /*public function getValue(key:String):Object{
            
        }*/
    }
}