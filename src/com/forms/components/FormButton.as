package com.forms.components
{
    import com.forms.FormComponent;
    import flash.xml.XMLNode;
    import com.forms.Form;
    import com.forms.FormStyle;

    public class FormButton extends FormComponent{
        public function FormButton(xml:XMLNode,form:Form){
            predefinedStyle=new FormStyle();
            predefinedStyle.background.color=0xFF0000;
            super(xml,form);
        }

        override protected function draw():void{
            super.draw();
        }
    }
}