package com.dukascopy.connect.managers.escrow.vo
{
    public class BaseVO{

        protected var _raw:Object;
        
        public function BaseVO(raw:Object){
            this._raw=raw;
        }

        public function getInt(name:String):int{
            var val:Object=getObject(name);
            if(val==null)
                return 0
            if(val is String){
                var num:int=parseInt(val as String);
                if(isNaN(num))
                    return 0;
                return num;
            }
            if(val is Number)
                return int(val);
            if(val is Boolean)
                return val?1:0;
            return 0;
        }

        public function getNumber(name:String):Number{
            var val:Object=getObject(name);
            if(val==null)
                return 0
            if(val is String){
                var num:int=parseFloat(val as String);
                if(isNaN(num))
                    return 0;
                return num;
            }
            if(val is Number)
                return val as Number;
            if(val is Boolean)
                return val?1:0;
            return 0;
        }

        public function getBool(name:String):Boolean{
            var val:Object=getObject(name);
            if(val==null)
                return false;
            if(val is Boolean)
                return val;
            if(val is Number)
                return val>0;
            if(val is String){
                return (val as String).toLowerCase()=="true";
            }
            return false;
        }

        public function getArray(name:String):Array{
            var val:Object=getObject(name);
            if(val!=null && val is Array)
                return val as Array;
            return null;
        }

        public function exists(name:String):Boolean{
            return getObject(name)!=null;
        }


        public function getObject(name:String):Object{
            if(name==null)
                return null;
            if(_raw==null)
                return null;
            if(!(name in _raw))
                return null;
            return _raw[name]
        }

        public function dispose():void{
            _raw=null;
        }
    }
}