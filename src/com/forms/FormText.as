package com.forms
{
    
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormatAlign;
    import flash.text.engine.FontWeight;
    import flash.text.AntiAliasType;

    public class FormText extends FormComponent{
        private var text:String=""
        private var parsed:String="";
        private var currentValues:Object;
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
            parsed=txt;
            _nodeName="text";
            _nodeType=3;
            //(_view as TextField).setTextFormat(new TextFormat("Tahoma",12));
        }

        public function get textContent():String{
            return parsed;
        }

        override public function set textContent(val:String):void{
            text=val;
        }

        override protected function redraw(percentOffsetW:int = -1, percentOffsetH:int = -1,parentValues:Object=null):void{
      
            //TODO: analyze, parent values && parent bounds, if they are the same, skip redraw

            var fontOptions:FormFontOptions=getFontOptions();
            var fontFace:String="Tahoma";
            var fontWeight:String="regular";
            var textTransform:String="";
            var tf:TextField=_view as TextField;
            tf.border=Form.debug;
            tf.width=0;//Math.ceil(tf.textWidth);
            tf.height=0;//Math.ceil(tf.textHeight);
            tf.selectable=false;
            tf.mouseEnabled=false;
            tf.mouseWheelEnabled=false;
            tf.tabEnabled=false;
            tf.cacheAsBitmap=true;
            tf.multiline=true;
            tf.wordWrap=true;
            tf.autoSize=TextFieldAutoSize.LEFT

            if(fontOptions.fontFace && fontOptions.fontFace.isSet && fontOptions.fontFace.toString().length>0){
                tf.embedFonts=true;
                tf.antiAliasType=AntiAliasType.ADVANCED;
                fontFace=fontOptions.fontFace.toString();
            }
            if(fontOptions.fontWeight && fontOptions.fontWeight.isSet && fontOptions.fontWeight.toString().length>0){
                fontWeight=fontOptions.fontWeight.toString();
            }
            if(fontOptions.textTransform && fontOptions.textTransform.isSet && fontOptions.textTransform.toString().length>0){
                textTransform=fontOptions.textTransform.toString()
            }

            //tf.width=2000;

            // setup text
            var textToSet:String=parsed;
           

            if(parentValues && parsed.indexOf("${")>=-1){
                var vals:Object=parentValues;
                if(parentValues is String || parentValues is Number || parentValues is Boolean)
                    vals={value:parentValues};
                textToSet=textToSet.replace(/\$\{[a-zA-Z0-9_\.]+\}/gi,
                    function(found:String,index:int,fulltext:String):String{
                        found=found.substr(2,found.length-3);
                        var tmp:Array=found.split(".");
                        if(tmp.length==0)
                            tmp=[found];
                        var obj:Object=vals;
                        for(var i:int=0;i<tmp.length;i++){
                            if(tmp[i] in obj)
                                obj=obj[tmp[i]]
                            else{
                                return "${"+found+"}"
                            }
                        }
                        if(obj==null)
                            return "";
                        return obj+"";
                    }
                );
            }
            
            if(textTransform && textTransform=="uppercase")
                textToSet=textToSet.toUpperCase();
            tf.text=textToSet;

            // get color
            var fc:FormColor=getColor();
            var color:uint=0;
            var alpha:Number=1;
            if(fc!=null){
                color=fc.color;
                alpha=fc.alpha;
            }

            // get size
            
            var fs:FormTextSize=fontOptions.fontSize;
            var size:int=11;
            if(fs!=null){
                size=fs.size;
            }

            var ta:TextFormat=new TextFormat(fontFace,size,color,fontWeight=="bold");

            if(fontOptions.textAlign && fontOptions.textAlign.isSet)
                ta.align=fontOptions.textAlign.toString();
                

            tf.setTextFormat(ta);


            // parent width
            var pW:int=getParentSize("width");
               
            var elipsis:Boolean=false;
            var textWidth:int=Math.ceil(tf.textWidth+5);

            if(pW>0){
                pW-=getParentPaddingOffset("width");
                if(textWidth>pW){
                    elipsis=true;
                    tf.width=pW;
                }else{
                    tf.width=pW;//textWidth;
                }
            }else
                tf.width=textWidth;

            tf.height=tf.textHeight+4;

            bounds.width=tf.width
            bounds.height=tf.height
            bounds.display_width=bounds.width;
            bounds.display_height=bounds.height;

            currentValues=parentValues;

        }
    }
}