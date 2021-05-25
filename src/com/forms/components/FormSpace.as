package com.forms.components
{
    import com.forms.FormComponent;
    import flash.xml.XMLNode;
    import com.forms.Form;

    public class FormSpace extends FormComponent{
        public function FormSpace(xml:XMLNode,form:Form){
            var size:int=xml.attributes!=null && "size" in xml.attributes?parseInt(xml.attributes.size):10;
            super(xml,form,{
                width:size+"",
                height:size+""
            })
        }
    }
}