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
                align:FormAlign.CENTER,
                padding:"10",
                borderRadius:"10",
                __first:{
                    backgroundColor:"#00FFAA"
                },
                __last:{
                    backgroundColor:"#AA00CC"
                }
            });
            (_view as Sprite).buttonMode=true;
        }

        override protected function draw():void{
            super.draw();
        }
    }
}