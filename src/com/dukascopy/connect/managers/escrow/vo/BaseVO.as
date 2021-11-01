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
                var num:Number=parseFloat(val as String);
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

        /**
         * 
         * @param name property name
         * @param format string with format, where: %y - year, %m - month, %d - day, %h - hours, %i - minutes, %s - seconds. if null - return standart date
         * @return 
         */
        public function getFormattedDate(name:String,format:String):String{
            var date:Date=getDate(name);
            if(date==null)
                return "";

            var y:int=date.getFullYear();
            var m:int=date.getMonth()+1;
            var d:int=date.getDate();

            var h:int=date.getHours();
            var i:int=date.getMinutes();
            var s:int=date.getSeconds();

            // TODO: AGO FROM NOW, WEEKDAY NAME, MONTH NAME

            return format.replace("%y",y)
            .replace("%m",leadZero(m))
            .replace("%d",leadZero(d))
            .replace("%h",leadZero(h))
            .replace("%i",leadZero(i))
            .replace("%s",leadZero(s));
        }

        private static function leadZero(val:int):String{
            if(val<10)
                return "0"+val;
            return val+"";
        }

        public function getDate(name:String):Date{
            var val:Object=getObject(name);
            var date:Date;

            if(val is String){
                var t:Number=parseFloat(val+"");
                if(!isNaN(t) && val.length>10){
                    val=t;
                }
            }

            if(val is Number){
                var tms:Number=val as Number;
                if((val+"").length<11){
                    if(tms<0)
                        tms*=-1;
                    tms*=1000;
                }
                date=new Date();
                date.setTime(tms);
                return date;
            }
            
            if(val is String){
                if(val.indexOf("-")!=-1 || val.indexOf(".")!=-1 || val.indexOf(":")!=-1)
                    val=val.replace(/\s/g,"");
                val.split(/[\-\.\:\s]/);
                for(var i:int=0;i<val.length;i++)
                    trace(val[i]);
            }

            return null;
        }

        public function getString(name:String):String{
            var val:Object=getObject(name);
            if(val is String)
                return val as String;
            return val+"";
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
        public function toString():String{
            if(_raw)
                return JSON.stringify(_raw);
            return "no raw data";
        }
    }
}