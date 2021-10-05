package com.forms
{
    import flash.utils.ByteArray;
    import flash.filesystem.File;

    public class FormResourcesLoader{
        
        private static const cache:Array=[];
        private static const pendingResources:Array=[];

        public function FormResourcesLoader(url:String,callback/*ByteArray*/:Function){
            var pe:PendingResource=getPendingResource(url);
            if(pe!=null){
                pe.addCallback(callback);
                return;
            }

            var c:Cache=getCache(url);
            if(c!=null){
                callback(c.bytes);
                return;
            }

            pe=new PendingResource(url);
            pe.addCallback(callback);

            if(url.indexOf("http")==0){
                // TODO: REMOTE LOADING
                return;
            }

            // local loading
            var f:File=File.applicationDirectory.resolvePath(url);
            trace(f.nativePath);
        }

        public function getPendingResource(url:String):PendingResource{
            for each(var pr:PendingResource in pendingResources){
                if(pr.url==url)
                    return pr;
            }
            return null;
        }

        public function getCache(url:String):Cache{
            for each(var c:Cache in cache){
                if(c.url==url)
                    return c;
            }
            return null;
        }
    }
}


import flash.utils.ByteArray;

class PendingResource{
    public var url:String;
    public var callbacks:Vector.<Function>=new <Function>[];

    public function PendingResource(url:String){
        this.url=url;
    }

    public function addCallback(cb:Function):void{
        for each(var f:Function in callbacks){
            if(f==cb)
                return;
        }
        callbacks.push(cb)
    }
}

class Cache{
    public var url:String;
    public var bytes:ByteArray;
    public function Cache(url:String,bytes:ByteArray){
        this.url=url;
        this.bytes=bytes;
    }
}