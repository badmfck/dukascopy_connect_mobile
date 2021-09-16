package com.forms.components{

    import com.forms.FormComponent;
    import flash.xml.XMLNode;
    import com.forms.Form;

    public class FormBottomOffset extends FormComponent{
        public function FormBottomOffset(xml:XMLNode,form:Form){
            var size:int=form.bottomOffset;
            super(xml,form,{
                height:size+""
            })
        }
    }
}