package com.forms
{
    import flash.display.BitmapData;
    import flash.display.StageQuality;
    import flash.geom.Matrix;

    public class FormBitmapData{
        static private var bitmaps:/*StoredBitmap*/Array=[];

        private var _bitmapData:BitmapData;
        private var hash:String;
        private var _width:int;
        private var _height:int;
        private var displayWidth:int;
        private var displayHeight:int;

        public function FormBitmapData(source:BitmapData,id:String,width:int,height:int,displayWidth:int,displayHeight:int,transparent:Boolean=true,fill:uint=0x0){
            _height=height;
            _width=width;
            this.displayWidth=displayWidth;
            this.displayHeight=displayHeight;
            hash=id+"_"+width+"_"+height+"_"+displayWidth+" "+displayHeight;
            var stored:StoredBitmap=findBitmap(hash);
            if(!stored){
                stored=new StoredBitmap(resize(source,width,height,transparent,fill),hash);
                bitmaps.push(stored);
            }
            stored.uses++;
            _bitmapData=stored.bitmapData;
        }

        public function get bitmapData():BitmapData{
            return _bitmapData;
        }

        public function get width():int{
            return _width;
        }

        public function get height():int{
            return _height;
        }

        private function findBitmap(hash:String):StoredBitmap{
            for each(var sb:StoredBitmap in bitmaps){
                if(sb.hash==hash)
                    return sb;
            }
            return null;
        }

        private function resize(src:BitmapData,width:int,height:int,transparent:Boolean=true,fill:uint=0x0):BitmapData{
            var bmd:BitmapData=new BitmapData(displayWidth,displayHeight,transparent,fill)
            var m:Matrix=new Matrix();
            m.scale(width/src.width,height/src.height);
            
            m.translate(Math.round((displayWidth-width)*.5),Math.round((displayHeight-height)*.5));
            bmd.drawWithQuality(src,m,null,null,null,true,StageQuality.BEST);
            return bmd;
        }

        public function dispose(allInstances:Boolean=false):void{
            var l:int=0;
            for (var i:int=0;i<l;i++){
                var sb:StoredBitmap=bitmaps[i];
                if(sb.hash==hash){
                    sb.uses--;
                    if(allInstances)
                        sb.uses=0;
                    if(sb.uses<1){
                        if(sb.bitmapData!=null)
                            sb.bitmapData.dispose();
                        sb.bitmapData=null;
                        sb.hash=null;
                        bitmaps.removeAt(i);
                    }
                    break;
                }
            }
        }
    }
}

import flash.display.BitmapData;

class StoredBitmap{
    public var bitmapData:BitmapData;
    public var hash:String;
    public var uses:int=0;
    public function StoredBitmap(bmd:BitmapData,hash:String){
        this.bitmapData=bmd;
        this.hash=hash;
    }
}