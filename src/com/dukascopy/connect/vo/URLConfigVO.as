package com.dukascopy.connect.vo{

    public class URLConfigVO{
        private var _DCCAPI_URL:String;
        private var _WSS_URL:String;
        private var _SCHEME:String;
        private var _PLATFORM:String;
        public function get DCCAPI_URL():String{ return _DCCAPI_URL;};
        public function get WSS_URL():String{ return _WSS_URL;};
        public function get SCHEME():String{ return _SCHEME;};
        public function get PLATFORM():String{ return _PLATFORM;};


        public function URLConfigVO(data:Object){
            // SETUP
            if("DCCAPI_URL" in data)
                _DCCAPI_URL=data['DCCAPI_URL'];

            if("WSS_URL" in data)
                _WSS_URL=data['WSS_URL'];

            if("SCHEME" in data)
                _SCHEME=data['SCHEME'];

            if("PLATFORM" in data)
                _PLATFORM=data['PLATFORM'];
        }
    }
}