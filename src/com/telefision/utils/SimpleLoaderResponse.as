package com.telefision.utils
{
    public class SimpleLoaderResponse{
        private var _raw:String=null;
        private var _error:String=null;
        private var _data:Object=null;
        private var parsed:Boolean=false;
        public function SimpleLoaderResponse(data:String,error:String):void{
            _raw=data;
            _error=error;
            if(_raw!=null){
                try{
                    _data=JSON.parse(_raw);
                }catch(e:Error){
                    trace(e.message);
                }
            }
            if(_data!=null){
                parsed=true;
                if("status" in _data){
                    if(_data.status.error){
                        if(_data.status.errorMsg!=null)
                            _error=_data.status.errorMsg;
                        else
                            _error="Server error"
                    }
                }
                if("data" in _data){
                    _data=_data.data;
                }else{
                    _data=null;
                }
            }
        }
        public function get data():Object{
            return _data;
        }
        public function get error():String{
            return _error;
        }
        public function get raw():String{
            return _raw;
        }

        public function toString():String{
            var dta:String="";
            try{
                dta=JSON.stringify(_data,null,"\t\n");
            }catch(e:Error){
                dta="Can't parse JSON: "+e.message;
            }
            return 'error: '+((_error!=null)?_error:"no error")+"\ndata:"+dta+"\nraw:"+_raw
        }
    }
}