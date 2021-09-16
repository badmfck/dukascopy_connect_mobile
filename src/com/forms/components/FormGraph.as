package com.forms.components
{
    import com.forms.FormComponent;
    import com.forms.Form;
    import flash.xml.XMLNode;
    import flash.display.Shape;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.text.engine.GraphicElement;
    import com.forms.FormAlign;

    public class FormGraph extends FormComponent{
        private var shapes:Vector.<Shape>=new Vector.<Shape>();
        public function FormGraph(xml:XMLNode,form:Form){
            super(xml,form)
        }

        override protected function createView(xml:XMLNode):void{
            var childs:Array=xml.childNodes;
            for each(var node:XMLNode in childs){
                if(node.nodeType!=1)
                    continue;
                if(node.nodeName=="rect"){
                    drawRect(node.attributes);
                    continue;
                }
                if(node.nodeName=="path")
                    drawPath(node.attributes);
            }
        }

        override protected function redraw(percentOffsetW:int = -1, percentOffsetH:int = -1,parentValues:Object=null):void{
            
            calculateBounds(percentOffsetW,percentOffsetH)
            
            var resize:String="";
            if(bounds.display_width>0 && bounds.display_height>0){
                resize="contain"
            }else if(bounds.display_width<0)
                resize="byW"
            else
                resize="byH";

            var maxW:int=0;
            var maxH:int=0;
            var shape:Shape
            for each(shape in shapes){
                if(shape.parent==null)
                    (_view as DisplayObjectContainer).addChild(shape);

                var tw:int=bounds.display_width;
                var th:int=(shape.height*tw)/shape.width;
                //resize
                if(resize=="contain"){

                    if(th>bounds.display_height){
                        th=bounds.display_height;
                        tw=(shape.width*th)/shape.height;  
                    }

                    shape.width=tw
                    shape.height=th
                }else if(resize=="byH"){
                    if(style.width>0){
                        shape.width=tw
                        shape.height=th
                    }
                }


                if(shape.width>maxW)
                    maxW=shape.width;
                if(shape.height>maxH)
                    maxH=shape.height;
            }
            
            if(bounds.display_width<0)
                bounds.display_width=maxW;

            if(bounds.display_height<0)
                bounds.display_height=maxH;

            bounds.width=bounds.display_width;
            bounds.height=bounds.display_height;

            //align
            for each(shape in shapes){
                if(style.align.toString()==FormAlign.CENTER){
                    shape.x=Math.round((bounds.display_width-shape.width)*.5)
                    shape.y=Math.round((bounds.display_height-shape.height)*.5)
                }
            }
        
            draw();

            
        }

        private function drawRect(attr:Object):void{
            var shape:Shape=new Shape();
            var x:int=getNumber("x",attr);
            var y:int=getNumber("y",attr);
            var width:int=getNumber("width",attr);
            var height:int=getNumber("height",attr);
            
            var fillColor:Object=getHexColor("fill",attr);
            if(fillColor)
                shape.graphics.beginFill(fillColor.color)

            var strokeColor:Object=getHexColor("stroke",attr);
            if(strokeColor)
                shape.graphics.lineStyle(1,strokeColor.color);

            var rx:Number=getNumber("rx",attr);
            var ry:Number=getNumber("ry",attr);
            if(rx!=0 || ry!=0){
                /*if(rx>width*.5)
                    rx=width*.5;*/
                if(rx==0)
                    rx=ry;
                if(ry==0)
                    ry=rx;
                shape.graphics.drawRoundRect(x,y,width,height,rx,ry);
            }else{
                shape.graphics.drawRect(x,y,width,height)
            }
            
            
            shapes.push(shape);
        }

        private function drawPath(attr:Object):void{

        }

        private function getHexColor(name:String,obj:Object):Object{
            var val:Object=null;
            if(obj==null || !(name in obj) || obj[name]==null)
                return val;
            val={};
            val.color=parseColor(obj[name]);
            if(isNaN(val.color))
                val=null;
            return val;
        }
        private function parseColor(clr:String):uint{
            return parseInt("0x"+clr.substr(1));
        }

        private function getNumber(name:String,obj:Object):Number{
            var val:Number=0;
            if(obj==null || !(name in obj) || obj[name]==null)
                return val;
            try{
                val=parseFloat(obj[name]);
            }catch(e:Error){}
            if(isNaN(val))
                return 0;
            return val;
        }


        override public function destroy():void{
            super.destroy();
            shapes=null;
        }
        
    }
}