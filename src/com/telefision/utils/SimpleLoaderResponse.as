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
        public function toString():String{
            return 'error: '+((_error!=null)?_error:"no error")+"\ndata:"+JSON.stringify(_data,null,"\t\n")+"\nraw:"+_raw
        }
    }
}