package com.forms.components
{
    import com.forms.FormComponent;
    import flash.xml.XMLNode;
    import com.forms.Form;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.display.DisplayObjectContainer;
    import com.forms.FormTextSize;
    import flash.text.TextFormat;
    import com.forms.FormColor;

    public class FormInput extends FormComponent{
        private var tf:TextField;
        
        public function FormInput(xml:XMLNode,form:Form){
            super(xml,form,{
                backgroundColor:"#CCCCCC",
                padding:"10",
                borderRadius:"2",
                borderSize:"1",
                borderColor:"#000000",
                height:30,
                fontSize:12
            });
            enableChilds=false;
            createTF()
        }
        
        private function createTF():void{
            tf=new TextField();
            tf.border=true;
            tf.width=100;
            tf.height=30;
            tf.type=TextFieldType.INPUT;
            if(box.parent==null)
                (_view as DisplayObjectContainer).addChild(box);
            box.addChild(tf);
        }

        override protected function redraw(percentOffsetW:int = -1, percentOffsetH:int = -1):void{
            calculateBounds(percentOffsetW,percentOffsetH);
             // get size
            var fs:FormTextSize=getFontSize();
            var size:int=11;
            if(fs!=null){
                size=fs.size;
            }
            
            var fc:FormColor=getColor();
            var color:uint=0;
            var alpha:Number=1;

            if(fc!=null){
                color=fc.color;
                alpha=fc.alpha;
            }

            var ta:TextFormat=new TextFormat("Tahoma",size,color);
            tf.setTextFormat(ta);
            tf.width=bounds.display_width;
            tf.height=bounds.display_height;
            tf.setTextFormat(ta);
        }

        override protected function draw():void{
            super.draw();
            
        }

    }
}