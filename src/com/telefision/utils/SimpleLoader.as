package com.telefision.utils
{
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLVariables;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequestMethod;
    import flash.events.HTTPStatusEvent;
    import flash.net.URLRequestHeader;
    import flash.net.URLRequestDefaults;

    public class SimpleLoader{

        // BASE
        static private var base:String="qIWDHpg9FCzUAQNJ8XfML0yORZeY5B4PT7anmkjGE1bv6dxoh3lrS2tVwiscKu";
        static public function getNumberByBase(baseString:String):Number{
            var m:int=baseString.length-1;
            var res:Number=0;
            var pow:Number=0;
            while (m > -1)
                res += base.indexOf(baseString.charAt(m--)) * Math.pow(62, (pow++));
            return res;
        }
        static public function getBaseNumber(sourceNumber:Number):String {
            if (isNaN(sourceNumber))
                return'';
            var r:int = sourceNumber % 62;
            var result:String='';
            if (sourceNumber-r == 0)
                result = base.charAt(r);
                    else
                        result = getBaseNumber((sourceNumber-r)/62 )+''+base.charAt(r);
            return result;
	    }
        static public function pack(text:String,key:String):String{
            if (text == null)
                return "";
            if (key == null)
                return "NO KEY!";
            var keyLen:int = key.length;
            var encoded:String = '';
            var m:int=0;
            var n:int = 0;
            while (n < text.length) {
                var chr:String = getBaseNumber(text.charCodeAt(n++) + key.charCodeAt(m));
                if (chr.length == 1)
                    chr = '.' + chr;
                if (chr.length == 3)
                    encoded += '-' + chr;
                else
                    encoded += chr;
                m++;
                if (m == keyLen)
                    m = 0;
            }
            return encoded;
        }
        static public function unpack(str:String, key:String):String {
            if (key == null || key.length==0)
                return str;
            var keyLen:int = key.length;
            var strLen:int = str.length;
            if (strLen % 2 != 0)
                return str;
            var m:int = 0;
            var n:int = 0;
            var decoded:String = "";
            var i:String;
            var mStep:int;
            var code:int;
            while (m < strLen) {
                mStep = 2;
                if (str.charAt(m) == '-') {
                    i = str.charAt(m + 1) + '' + str.charAt(m + 2) + '' + str.charAt(m + 3);
                    mStep = 4;
                } else {
                    i = str.charAt(m) + '' + str.charAt(m + 1);
                    if (str.charAt(m) == '.')
                        i = str.charAt(m + 1);
                }
                code = getNumberByBase(i) - key.charCodeAt(n);
                decoded += String.fromCharCode(code);
                n++;
                if (n == keyLen)
                    n = 0;
                m += mStep;
            }
            return decoded;
        }

        // LOADER

        public static var URL_DEFAULT:String=null;

        private var loader:URLLoader;
        private var url:String;
        private var callback:Function;
        private var request:String;
        private var status:int;
        private var id:int;
        private var debug:String;
        static private var nextID:int=0;

        /**
         * Create Simple loader, send http request to url with data
         * @param url - http request end point
         * @param data - data to send
         * @param callback - function with 2 params (data,error)
         * @param method - HTTP method, post,get,etc...
         * @param cdata - Boolean, if true, will be packet to cdata
         */
        public function SimpleLoader(data:Object,callback:Function,url:String=null,method:String=URLRequestMethod.POST,cdata:Boolean=true,headers:Vector.<URLRequestHeader>=null){
            
            URLRequestDefaults.userAgent="DukascopyConnect";
            var ts:Number=new Date().getTime();
            if(url==null)
                url=URL_DEFAULT;

            if(url==null){
                trace("ERROR! Can't start loader with no URL!");
                return;
            }
            loader=new URLLoader()
            this.url=url;
            this.callback=callback;
            id=nextID++;
            
            
            var ur:URLRequest=new URLRequest(url);
            var uv:URLVariables = new URLVariables();
            var uh:Array=[];
            if(headers!=null){
                for each(var h:URLRequestHeader in headers)
                    uh.push(h);
            }
            ur.method=method;

            trace("HTTP CALL "+id);
            


            // get key            
            debug="------------------\nHTTP "+method.toUpperCase()+" REQUEST "+id+"\nURL: "+url+"\n";
            for(var dbg:String in data){
                var val:String=data[dbg];
                if(val==null)
                    continue;
                if(dbg.toLowerCase().indexOf("pass")==0)
                    val="*****";
                if(val.length>60)
                    val=val.substr(50)+"... total("+val.length+")";
                debug+="\t"+dbg+": "+val+"\n";
            }

            // set data
            if(cdata){
                var k:String="";
                for(var i:int=0;i<32;i++)
                    k+=String.fromCharCode(Math.round(Math.random()*60+33))
                var key:String=pack(k,Math.random()*10000+new Date().getTime()+"").substr(32);
			    uv['cdata'] = key + '' + pack(JSON.stringify(data),key);
                if(uv['cdata'].length<512){
                    debug+="\tcdata: "+uv['cdata']+"\n"
                }else{
                    debug+="\tcdata: bytes: "+uv['cdata'].length+"\n";
                }
            }else{
                for(var n:String in data)
                    uv[n]=data[n];
            }

            debug+="\nREQUEST HEADERS:"
            for each (var hh:URLRequestHeader in uh){
                debug+="\n\t"+hh.name+": "+hh.value;
            }
            debug+="\n------------------";
            debug+="\nREQUEST TIME:"
            debug+="\n\tms: "+((new Date().getTime()-ts));
            debug+="\n------------------";

            loader.addEventListener(Event.COMPLETE, onComplete);
            loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
            loader.dataFormat=URLLoaderDataFormat.TEXT
            var vars:URLVariables=new URLVariables();
            vars['cdata']=uv['cdata'];
			ur.data=uv;
            loader.load(ur);
        }

        private function onComplete(e:Event):void{
            finish(loader.data)
        }

        private function onIOError(e:IOErrorEvent):void{
            finish(null,e.text)
        }

        private function onHTTPStatus(e:HTTPStatusEvent):void{
            status=e.status;
        }

        private function onSecurityError(e:SecurityErrorEvent):void{
            finish(null,e.text)
        }

        private function finish(data:String,error:String=null):void{
            debug+="\nHTTP STATUS: "+status
            if(error){
                debug+="\nERROR: "+error;
                debug+="\n------------------";
                trace(debug)
                if(callback!=null)
                    callback(new SimpleLoaderResponse(null,error));
                callback=null;
                return;
            }

            debug+="\n\t"+data;
            debug+="\n------------------";
            trace(debug)
            if(callback!=null)
                callback(new SimpleLoaderResponse(data,null));
            callback=null;
        }
    }
}
