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
            
            // setup layout
            setupLayout();
            setupBackground();
            setupAlign()
            setupPadding();
            parseSize();

            values=null;
        }

        public function setupLayout():void{
            layout=new FormLayout(values.layout!=null && values.layout==="horizontal"?FormLayout.HORIZONTAL:FormLayout.VERTICAL);
        }

        public function setupBackground():void{
            if(values.backgroundColor==null){
                background=new FormBackground(Math.round((Math.random()*0xFFFFFF)),1);
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