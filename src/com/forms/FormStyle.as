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

        public function FormStyle(xml:XMLNode):void{
            // TODO: get from file
            
            
            // layout
            layout=new FormLayout(xml.attributes!=null?xml.attributes["layout"]:null);
            background=new FormBackground();

            

            //TODO: parse width & height
            parseSize(xml);

            /*if(layout.toString()==FormLayout.VERTICAL){
                if(width<0)
                    width=SIZE_MATCH_PARENT;
                if(height<0)
                    height=SIZE_WRAP_CONTENT;
            }else{
                if(width<0)
                    width=SIZE_WRAP_CONTENT;
                if(height<0)
                    height=SIZE_MATCH_PARENT;
            }*/

        }
        private function parseSize(xml:XMLNode):void{
            if(xml.attributes==null)
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