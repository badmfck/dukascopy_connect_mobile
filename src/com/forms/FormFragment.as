package com.forms
{
    public class FormFragment extends Form{
        public function FormFragment(container:FormComponent,xml:XML,additionalComponents:Vector.<FormRegisteredComponent>=null){
            super(xml,additionalComponents);
            setSize(container.getBounds().display_width,container.getBounds().display_height);
            
        }
    }
}