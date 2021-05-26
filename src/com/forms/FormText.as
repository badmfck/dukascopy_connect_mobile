package com.forms
{
    
    import flash.text.TextField;
    import flash.text.TextFormat;

    public class FormText extends FormComponent{
        private var text:String=""
        public function FormText(txt:String){
            text=txt;
            super(null,null);
            createTF();
        }
        private function createTF():void{
            _view=new TextField();
            var txt:String=text;
            txt=txt.replace(/^[\s\n\t\r]/gm,"");
            txt=txt.replace(/[\s\n\t\r]$/gm,"");
            txt=txt.replace(/ {2,}/gm,"");
            (_view as TextField).text=txt;
            //(_view as TextField).setTextFormat(new TextFormat("Tahoma",12));
        }

        override protected function redraw(percentOffsetW:int = -1, percentOffsetH:int = -1):void{
            
            var tf:TextField=_view as TextField;
            tf.border=true;
            tf.width=tf.textWidth;
            tf.height=tf.textHeight;
            tf.selectable=false;
            tf.mouseEnabled=false;
            tf.mouseWheelEnabled=false;
            tf.tabEnabled=false;
            tf.cacheAsBitmap=true;

            // get color
            var fc:FormColor=getColor();
            var color:uint=0;
            var alpha:Number=1;
            if(fc!=null){
                color=fc.color;
                alpha=fc.alpha;
            }

            // get size
            var fs:FormTextSize=getFontSize();
            var size:int=11;
            if(fs!=null){
                size=fs.size;
            }

            var ta:TextFormat=new TextFormat("Tahoma",size,color);

            tf.setTextFormat(ta);
            
    

            // parent width
            var pW:int=getParentSize("width");
            var elipsis:Boolean=false;
            var textWidth:int=tf.textWidth+4;

            if(pW>0){
                if(textWidth>pW){
                    elipsis=true;
                    tf.width=pW;
                }else
                    tf.width=textWidth;
            }else
                tf.width=textWidth;

            tf.height=tf.textHeight+4;

            bounds.width=tf.width
            bounds.height=tf.height
            bounds.display_width=bounds.width;
            bounds.display_height=bounds.height;
        }
    }
}