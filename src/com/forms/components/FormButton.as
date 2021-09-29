package com.forms.components
{
    import com.forms.FormComponent;
    import flash.xml.XMLNode;
    import com.forms.Form;
    import com.forms.FormStyle;
    import com.forms.FormAlign;
    import flash.display.Sprite;

    public class FormButton extends FormComponent{
        public function FormButton(xml:XMLNode,form:Form){
            super(xml,form,{
                backgroundColor:"#FFCC00",
                textAlign:"center",
                padding:"10",
                borderRadius:"10"
            });
            (_view as Sprite).buttonMode=true;
        }

        override protected function draw():void{
            super.draw();
        }
    }
}