package com.forms
{
    import flash.xml.XMLNode;
    import flash.text.engine.FontWeight;
    import com.dukascopy.connect.sys.calendar.BookedDays;
    
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
        public var fontFace:FormFontFace;
        public var fontWeight:FormFontWeight;
        public var textAlign:FormTextAlign;
        public var textTransform:FormTextTransform;
        public var border:FormBorder;
        public var borderRadius:FormBorderRadius;
        public var borderColor:FormBorderColor;
        public var opacity:Number=1;
        public var xOffset:int=0;
        public var yOffset:int=0;
        public var xOffsetPercents:Boolean=false;
        public var yOffsetPercents:Boolean=false;
        public var asBitmap:Boolean=false;
        public var overflow:String="none";
        public var position:String="block";
        public var distributeChilds:FormDistributeChilds;
        public var boxShadow:FormBoxShadow;

        private var values:Object;
        private var runtimeStyles:Object;
        


        public function FormStyle(xml:XMLNode,predefinedStyle:Object,component:FormComponent):void{

            
            var attributes:Object=xml!=null?xml.attributes:null
            this.values={};
            

            var key:String;
            var key2:String;
            var additionalObject:Array;
  
            if(predefinedStyle!=null){
                for(key in predefinedStyle){
                    if(key.indexOf("__")==0){
                        if(    (key=="__first" && component.isFirst)
                            || (key=="__last" && component.isLast)
                            || isStyled(key,attributes)
                        ){
                            if(additionalObject==null)
                                additionalObject=[];
                            additionalObject.push(key);
                        }
                        continue;
                    }
                    this.values[key]=predefinedStyle[key]
                }

                if(additionalObject!=null){
                    for each(key in additionalObject){
                        for(key2 in predefinedStyle[key]){
                            this.values[key2]=predefinedStyle[key][key2]
                        }
                    }
                    additionalObject=null;
                }

                if(attributes!=null){
                    for(key in attributes){
                        this.values[key]=attributes[key]
                    }
                }
                
            }else if(attributes!=null)
                this.values=attributes;

            normalizeAttributes(this.values)

            // setup layout
            setupStyles();

            //values=null;
        }

        static private function isStyled(key:String,attribues:Object):Boolean{
            return attribues != null && "styled" in attribues && key.substr(2) == attribues['styled'];
        }

        public static function normalizeAttributes(val:Object):Object{
            // normalize attributes
            for(var key:String in val){
                var index:int=key.indexOf("-");
                if(index!=-1 && index<key.length-1){
                    var camel:String=key.substr(0,index)+key.substr(index+1,1).toUpperCase()+key.substr(index+2,key.length);
                    val[camel]=val[key];
                }
            }
            return val;
        }

        private function setupStyles():void{
            setupLayout();
            setupBackground();
            setupAlign()
            setupPadding();
            setupColor();
            setupFontSize();
            setupTextAlign();
            setupFontFace();
            setupFontWeight();
            setupOpacity();
            setupBorderRadius();
            setupOffsets();
            setupOverflow();
            setupPosition();
            setupDistributeChilds();
            setupAsBitmap()
            setupBoxShadow();
            setupTextTransform();
            setupFormBorderColor();
            setupFormBorder();
            parseSize();
        }

        public function setStyle(style:Object):void{
            runtimeStyles=style;
            setupStyles();
        }

      
        public function setupLayout():void{
            layout=new FormLayout(values.layout!=null && values.layout==="horizontal"?FormLayout.HORIZONTAL:FormLayout.VERTICAL);
        }

        private function setupPosition():void{
            position=values.position?values.position:"block";
        }

        

        private function setupDistributeChilds():void{
            distributeChilds=new FormDistributeChilds(values.distributeChilds);
        }

        public function setupBackground():void{
            if(values.backgroundColor==null && (runtimeStyles==null || runtimeStyles.backgroundColor==null)){
                background=new FormBackground(0,0);
                return;
            }

            var color:String=values.backgroundColor;

            if(runtimeStyles && runtimeStyles.backgroundColor)
                color=runtimeStyles.backgroundColor;

            if(!color is String)
                return;
            var parsedColor:uint=parseInt("0x"+color.substr(1));
            var alpha:Number=1;
            if(values.backgroundAlpha!=null){
                alpha=parseFloat(values.backgroundAlpha);
                if(alpha>1 || alpha<0)
                    alpha=1;
            }

            if(runtimeStyles && runtimeStyles.backgroundAlpha){
                alpha=parseFloat(runtimeStyles.backgroundAlpha);
                if(alpha>1 || alpha<0)
                    alpha=1;
            }


            background=new FormBackground(parsedColor,alpha);

            
        }

        private function setupAlign():void{
            var val:String=values['align']
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

        private function setupBoxShadow():void{
             var bs:String=values['boxShadow'];
            if(bs==null){
                boxShadow=null;
                return;
            }
            var tmp:Array=bs.split(" ");
            if(tmp.length==2){
                boxShadow=new FormBoxShadow(parseInt(tmp[0]),parseInt(tmp[1]));
                return;
            }else{
                var p:int=parseInt(bs);
                if(!isNaN(p))
                    boxShadow=new FormBoxShadow(p);
                else
                    boxShadow=null;
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

        private function setupTextAlign():void{
            if('textAlign' in values && values['textAlign']!=null){
                textAlign=new FormTextAlign(values['textAlign']);
                return;
            }
            textAlign=new FormTextAlign(null);
        }

        private function setupFontFace():void{
            if('fontFace' in values && values['fontFace']!=null){
                fontFace=new FormFontFace(values['fontFace']);
                return;
            }
            fontFace=new FormFontFace(null);
        }


          public function setupTextTransform():void{
            
            if('textTransform' in values && values['textTransform']!=null){
                textTransform=new FormTextTransform(values['textTransform']);
                return;
            }
            textTransform=new FormTextTransform(null);
        }

        private function setupFontWeight():void{
            if('fontWeight' in values && values['fontWeight']!=null){
                fontWeight=new FormFontWeight(values['fontWeight']);
                return;
            }
            fontWeight=new FormFontWeight(null);
        }

        private function setupAsBitmap():void{
            asBitmap=false;
            if("asBitmap" in values && values['asBitmap']!=null){
                asBitmap=(values['asBitmap']+"").toLowerCase()=="true";
            }
        }
        private function setupOpacity():void{
            opacity=1;
            if("opacity" in values && values['opacity']!=null){
                opacity=parseFloat(values['opacity']);
            }
            if(runtimeStyles && runtimeStyles.opacity!=null)
                opacity=parseFloat(runtimeStyles['opacity']);
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

        private function setupFormBorderColor():void{
            var val:String=values['borderColor'];
            if(val==null){
                borderColor=new FormBorderColor(-1,-1,-1,-1,false);
                return;
            }
            var tmp:Array=val.split(" ");
            if(tmp.length==4){
                borderColor=new FormBorderColor(parseInt(tmp[0]),parseInt(tmp[1]),parseInt(tmp[2]),parseInt(tmp[3]))
                return;
            }else{
                var p:int=parseInt(val);
                borderColor=new FormBorderColor(p,p,p,p);
            }
        }

        private function setupFormBorder():void{
            var val:String=values['border'];
            if(val==null){
                border=new FormBorder(0,0,0,0);
                return;
            }
            var tmp:Array=val.split(" ");
            if(tmp.length==4){
                border=new FormBorder(parseInt(tmp[0]),parseInt(tmp[1]),parseInt(tmp[2]),parseInt(tmp[3]))
                return;
            }else{
                var p:int=parseInt(val);
                border=new FormBorder(p,p,p,p);
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
                if(val.indexOf("%")>-1){
                    xOffsetPercents=true;
                    val=val.substr(0,val.length-1);
                }

                xOffset=parseInt(val)
            }
            if(values['yOffset']!=null){
                val=values['yOffset'];
                if(val.indexOf("%")>-1){
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