package com.dukascopy.connect.vo{

    public class URLConfigVO{
        private var _DCCAPI_URL:String;
        public function get DCCAPI_URL():String{ return _DCCAPI_URL;};


        public function URLConfigVO(data:Object){
            // SETUP
            if("DCCAPI_URL" in data)
                _DCCAPI_URL=data['DCCAPI_URL'];
        }
    }
}