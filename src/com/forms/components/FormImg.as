package com.forms.components
{
    import com.forms.FormComponent;
    import com.forms.Form;
    import flash.xml.XMLNode;
    import com.forms.FormResourcesLoader;
    import flash.utils.ByteArray;
    import flash.display.Bitmap;
    import flash.display.Loader;
    import com.forms.Dispatcher;
    import flash.events.Event;
    import flash.display.BitmapData;
    import flash.display.StageQuality;
    import flash.geom.Matrix;

    public class FormImg extends FormComponent{

        private var _src:String;
        private var resouceLoader:FormResourcesLoader;
        private var onLoaded:Function;
        private var image:Bitmap;
        private var bmd:BitmapData;
        private var resized:BitmapData;

        public function FormImg(xml:XMLNode,form:Form){
            super(xml,form)
        }

         public function set src(val:String):void{
            if(_src==val)
                return;
            _src=val;
            loadResource();
        }

        public function get src():String{
            return _src;
        }


        override protected function createView(xml:XMLNode):void{
            if(xml.attributes.src){
                _src=xml.attributes.src;
                loadResource();
                return;
            }
        }

        private function loadResource():void{
            var self:FormImg=this;
            if(resouceLoader)
                resouceLoader.stopLoading();
            resouceLoader=new FormResourcesLoader(_src,form.formFile,function(res:ByteArray):void{
                // resource loaded
                createImage(res);
                resizeImage();

                if(onLoaded!=null && onLoaded is Function){
                    if(onLoaded.length==0){
                        onLoaded();
                        return;
                    }else if(onLoaded.length==1){
                        onLoaded(self);
                        return;
                    }
                }

            })
        }

        //TODO: 
        private function createImage(res:ByteArray):void{
            var self:FormImg=this;
            var loader:Loader=new Loader();
            var dis:Dispatcher=new Dispatcher(loader.contentLoaderInfo);
            dis.add(Event.COMPLETE,function(e:Event):void{
                if(loader.content!=null && loader.content is Bitmap){
                    if(bmd!=null)
                        bmd.dispose();
                    bmd=(loader.content as Bitmap).bitmapData;
                    
                    if(image==null){
                        image=new Bitmap();
                        box.addChild(image);
                    }
                    
                    resizeImage();
                    if(onLoaded!=null && onLoaded is Function){
                        if(onLoaded.length==0){
                            onLoaded();
                            return;
                        }else if(onLoaded.length==1){
                            onLoaded(self);
                            return;
                        }
                    }
                }
                dis.clear();
            })
            loader.loadBytes(res);
        }

        override protected function draw():void{
            if(needRedraw)
                resizeImage();
            super.draw();
        }

        private function resizeImage():void{
            if(image==null || bmd==null || bmd.width<1)
                return;
            
            var tw:int=bounds.display_width;
            var th:int=(bmd.height*tw)/bmd.width;
            
            if(th>bounds.display_height){
                th=bounds.display_height;
                tw=(bmd.width*th)/bmd.height;
            }

            if(this.resized!=null && this.resized.width==tw && this.resized.height==th)
                return;
            
            if(this.resized!=null)
                this.resized.dispose();

            if(tw==0 || th==0)
                return;

            this.resized=new BitmapData(tw,th,true,0);
            var m:Matrix=new Matrix();
            m.scale(tw/bmd.width,th/bmd.height)
            this.resized.drawWithQuality(bmd,m,null,null,null,true,StageQuality.BEST);
            image.smoothing=true;
            image.bitmapData=resized;

            image.x=(tw-image.width)*.5;
            image.y=(th-image.height)*.5;
        }


        override public function destroy():void{
            super.destroy();
            if(image!=null && image.bitmapData!=null)
                image.bitmapData.dispose();
            if(resized!=null)
                resized.dispose();
            
        }

    
    }
}