package com.forms.components
{
    import com.forms.FormComponent;
    import com.forms.Form;
    import flash.xml.XMLNode;
    import com.forms.FormResourcesLoader;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import com.forms.FormBitmapData;

    public class FormImg extends FormComponent{

        private var _src:String;
        private var resouceLoader:FormResourcesLoader;
        private var onLoaded:Function;
        private var image:Bitmap;
        private var resized:FormBitmapData;
        private var bmd:BitmapData; //pointer to bitmapData in cache

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

            resouceLoader=new FormResourcesLoader(_src,form.formFile,function(res:Object):void{
                // resource loaded
                createImage(res);
                
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
        private function createImage(res:Object):void{
            if(!res is BitmapData){
                trace("Error! Wrong bitmap data");
                return;
            }
            bmd=res as BitmapData;
            var self:FormImg=this;
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

        override protected function draw():void{
            if(needRedraw)
                resizeImage();
            super.draw();
        }

        private function resizeImage():void{
            if(image==null || bmd==null || bmd.width<1)
                return;
            
            //var rebuildFromRoot:Boolean=false;
            if(bounds==null){
                /*bounds=new FormBounds(bmd.width,bmd.height);
                bounds.display_height=bounds.height;
                bounds.display_width=bounds.width;
                rebuildFromRoot=true;*/
                trace("Warning -> Image has no width & height");
                return;
            }

            var tw:int=bounds.display_width;
            var th:int=(bmd.height*tw)/bmd.width;
            var resize:String="contain"; // cover/ scale
            if(attributes && "resize" in attributes)
                resize=attributes.resize.toLowerCase()

            if(resize=="cover"){
                if(th<bounds.display_height){
                    th=bounds.display_height;
                    tw=(bmd.width*th)/bmd.height;
                }
            }else if(resize="scale"){
                tw=bounds.display_width;
                th=bounds.display_height;
            }else/*contain*/{
                
                if(th>bounds.display_height){
                    th=bounds.display_height;
                    tw=(bmd.width*th)/bmd.height;
                }
            }
            
            if(this.resized!=null && this.resized.width==tw && this.resized.height==th)
                return;
            
            if(this.resized!=null){
                this.resized.dispose();
                image.bitmapData=null;
            }

            if(tw==0 || th==0)
                return;

            this.resized=new FormBitmapData(bmd,_src,tw,th,bounds.display_width,bounds.display_height,true,0);
            
            image.smoothing=true;
            image.bitmapData=resized.bitmapData;

            //image.x=(tw-image.width)*.5;
            //image.y=(th-image.height)*.5;
            
        }


        override public function destroy():void{
            super.destroy();
            if(image!=null)
                image.bitmapData=null;
            if(resized!=null)
                resized.dispose();
        }
    }
}