package com.forms
{
    import flash.utils.ByteArray;
    import flash.filesystem.File;
    import flash.filesystem.FileStream;
    import flash.filesystem.FileMode;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;

    public class FormResourcesLoader{
        
        private static const cache:Array=[];
        private static const pendingResources:Array=[];

        public function FormResourcesLoader(url:String,formFile:File,callback/*ByteArray*/:Function){
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
            pendingResources.push(pe);

            if(url.indexOf("http")==0){
                // TODO: REMOTE LOADING
                loadRemoteFile(url);
                return;
            }

            loadLocalFile(url,formFile);
            
        }

        private function loadRemoteFile(url:String):void{
            var ur:URLRequest=new URLRequest(url);
            ur.method=URLRequestMethod.GET;
            var ul:URLLoader=new URLLoader(ur);
            ul.dataFormat=URLLoaderDataFormat.BINARY;
            var dis:Dispatcher=new Dispatcher(ul);

            dis.add(Event.COMPLETE,function(e:Event):void{
                dis.clear();
                if(ul.data is ByteArray){
                    var c:Cache=new Cache(url,ul.data as ByteArray);
                    cache.push(c);
                    fireCallback(url,ul.data);
                    return;
                }
                fireCallback(url,null);
            });

            dis.add(IOErrorEvent.IO_ERROR,function(e:Event):void{
                dis.clear();
                fireCallback(url,null);
            });

            dis.add(SecurityErrorEvent.SECURITY_ERROR,function(e:Event):void{
                dis.clear();
                fireCallback(url,null);
            });

        }

        private function loadLocalFile(url:String,formFile:File):void{
            // local loading
            var f:File=formFile==null?File.applicationDirectory.resolvePath(url):formFile.parent.resolvePath(url);
            if(!f.exists || f.isDirectory){
                fireCallback(url,null);
                return;
            }
            var fs:FileStream=new FileStream()
            var dis:Dispatcher=new Dispatcher(fs);

            dis.add(Event.COMPLETE,function(e:Event):void{
                var ba:ByteArray=new ByteArray();
                fs.readBytes(ba,0,f.size);
                var c:Cache=new Cache(url,ba);
                cache.push(c);
                fireCallback(url,ba);;
                fs.close();
                dis.clear()
            });

            dis.add(IOErrorEvent.IO_ERROR,function(e:Event):void{
                fs.close();
                dis.clear();
                fireCallback(url,null);
            });

            dis.add(SecurityErrorEvent.SECURITY_ERROR,function(e:Event):void{
                fs.close();
                dis.clear();
                fireCallback(url,null);
            });

            fs.openAsync(f,FileMode.READ);
        }

        private function fireCallback(url:String,ba:ByteArray):void{
            var l:int=pendingResources.length;
            for(var i:int=0;i<l;i++){
                var pr:PendingResource=pendingResources[i];
                if(pr.url==url){
                    pr.fireCallback(ba);
                    pendingResources.removeAt(i);
                    break;
                }
            }
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

    public function fireCallback(ba:ByteArray):void{
        if(callbacks==null)
            return;

        for each(var f:Function in callbacks)
            f(ba);
        
        url=null;
        callbacks=null;
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