package com.forms
{
    import flash.xml.XMLNode;

    public class FormStyle{
       
        public var layout:FormLayout;
        public var width:int=-1;
        public var height:int=-1;
        public var isWidthPrecentage:Boolean=false;
        public var isHeightPercentage:Boolean=false;

        public var background:FormBackground;

        public function FormStyle(xml:XMLNode=null,predefinedStyle:FormStyle=null):void{
            

            if(predefinedStyle!=null)
                layout=predefinedStyle.layout;
            if(xml!=null && xml.attributes!=null && "layout" in xml.attributes && xml.attributes["layout"]!=null){
                layout=new FormLayout(xml.attributes['layout']);
            }else{
                layout=new FormLayout("vertical");
            }
            
            
            background=new FormBackground();

            parseSize(xml);
        }

        private function parseSize(xml:XMLNode):void{
            if(xml==null || xml.attributes==null)
                return;
            var w:String=xml.attributes["width"];
            var h:String=xml.attributes["height"];
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