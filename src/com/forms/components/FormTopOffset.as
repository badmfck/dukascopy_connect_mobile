package com.forms.components
{
    import com.forms.FormComponent;
    import flash.xml.XMLNode;
    import com.forms.Form;

    public class FormTopOffset extends FormComponent{
        public function FormTopOffset(xml:XMLNode,form:Form){
            var size:int=form.topOffset;
            super(xml,form,{
                height:size+""
            })
        }
    }
}