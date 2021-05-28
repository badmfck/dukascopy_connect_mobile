package com.forms
{
    import flash.xml.XMLNode;
    
    public class FormStyle{
       
        public var layout:FormLayout;
        public var width:int=-1;
        public var height:int=-1;
        public var isWidthPrecentage:Boolean=false;
        public var isHeightPercentage:Boolean=false;
        public var align:FormAlign;
        public var background:FormBackground;
        public var padding:FormPadding;
        public var color:FormColor
        public var fontSize:FormTextSize;
        public var borderRadius:FormBorderRadius;
        public var opacity:Number=1;
        public var xOffset:int=0;
        public var yOffset:int=0;
        public var xOffsetPercents:Boolean=false;
        public var yOffsetPercents:Boolean=false;
        public var overflow:String="none";
        private var values:Object;

        public function FormStyle(xml:XMLNode=null,predefinedStyle:Object=null):void{

            
            var attributes:Object=xml!=null?xml.attributes:null
            this.values={};

            var key:String;
            if(predefinedStyle!=null){
                for(key in predefinedStyle){
                    this.values[key]=predefinedStyle[key]
                }
                if(attributes!=null){
                    for(key in attributes){
                        this.values[key]=attributes[key]
                    }
                }
            }else if(attributes!=null)
                this.values=attributes;

            // normalize attributes
            for(key in this.values){
                var index:int=key.indexOf("-");
                if(index!=-1 && index<key.length-1){
                    var camel:String=key.substr(0,index)+key.substr(index+1,1).toUpperCase()+key.substr(index+2,key.length);
                    this.values[camel]=this.values[key];
                }
            }
            
            // setup layout
            setupLayout();
            setupBackground();
            setupAlign()
            setupPadding();
            setupColor();
            setupFontSize();
            setupOpacity();
            setupBorderRadius();
            setupOffsets();
            setupOverflow();
            parseSize();

            values=null;
        }

        public function setupLayout():void{
            layout=new FormLayout(values.layout!=null && values.layout==="horizontal"?FormLayout.HORIZONTAL:FormLayout.VERTICAL);
        }

        public function setupBackground():void{
            if(values.backgroundColor==null){
                background=new FormBackground(0,0);
                return;
            }

            var color:String=values.backgroundColor;
            if(!color is String)
                return;
            var parsedColor:uint=parseInt("0x"+color.substr(1));
            var alpha:Number=1;
            if(values.backgroundAlpha!=null){
                alpha=parseFloat(values.backgroundAlpha);
                if(alpha>1 || alpha<0)
                    alpha=1;
            }

            background=new FormBackground(parsedColor,alpha);
        }

        private function setupAlign():void{
            var val:String=values['align']
            if(val==null)
                val=FormAlign.TOP_LEFT
            align=new FormAlign(val);
        }

        private function setupPadding():void{
            var pad:String=values['padding'];
            if(pad==null){
                padding=new FormPadding(0,0,0,0);
                return;
            }
            var tmp:Array=pad.split(" ");
            if(tmp.length==4){
                padding=new FormPadding(parseInt(tmp[0]),parseInt(tmp[1]),parseInt(tmp[2]),parseInt(tmp[3]))
                return;
            }else{
                var p:int=parseInt(pad);
                padding=new FormPadding(p,p,p,p);
            }
        }

        private function setupColor():void{
            if('color' in values && values['color']!=null){
                color=new FormColor(values['color']);
                return;
            }
            color=new FormColor(null);
        }

        private function setupFontSize():void{
            if('fontSize' in values && values['fontSize']!=null){
                fontSize=new FormTextSize(values['fontSize']);
                return;
            }
            fontSize=new FormTextSize(null);
        }

        private function setupOpacity():void{
            opacity=1;
            if("opacity" in values && values['opacity']!=null){
                opacity=parseFloat(values['opacity']);
            }
        }

        private function setupBorderRadius():void{
            var val:String=values['borderRadius'];
            if(val==null){
                borderRadius=new FormBorderRadius(0,0,0,0);
                return;
            }
            var tmp:Array=val.split(" ");
            if(tmp.length==4){
                borderRadius=new FormBorderRadius(parseInt(tmp[0]),parseInt(tmp[1]),parseInt(tmp[2]),parseInt(tmp[3]))
                return;
            }else{
                var p:int=parseInt(val);
                borderRadius=new FormBorderRadius(p,p,p,p);
            }
        }

        private function setupOverflow():void{
            if(values['overflow']!=null)
                overflow=values['overflow']
        }


        private function setupOffsets():void{
            xOffset=0;
            yOffset=0;
            xOffsetPercents=false;
            yOffsetPercents=false;
            var val:String
            if(values['xOffset']!=null){
                val=values['xOffset'];
                if(val.indexOf("%")){
                    xOffsetPercents=true;
                    val=val.substr(0,val.length-1);
                }

                xOffset=parseInt(val)
            }
            if(values['yOffset']!=null){
                val=values['yOffset'];
                if(val.indexOf("%")){
                    yOffsetPercents=true;
                    val=val.substr(0,val.length-1);
                }
                yOffset=parseInt(val)
            }
        }

        private function parseSize():void{
            var w:String=values["width"];
            var h:String=values["height"];
            if(w!=null){
                isWidthPrecentage=w.indexOf("%")!=-1;
                width=parseInt(w)
            }
            if(h!=null){
                isHeightPercentage=h.indexOf("%")!=-1;
                height=parseInt(h)
            }
        }
    }
}