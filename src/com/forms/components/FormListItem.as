package com.forms.components{
    
    import flash.xml.XMLNode;
    import com.forms.FormComponent;
    import com.forms.Form;
    
    public class FormListItem extends FormComponent{
        private var userDataHash:String=null;

        public function FormListItem(xml:XMLNode,form:Form){
            super(xml,form);
        }

        override protected function redraw(percentOffsetW:int = -1, percentOffsetH:int = -1,parentValues:Object=null):void{
            super.redraw(percentOffsetW,percentOffsetH,parentValues);
        }

        override public function setupUserValues(data:Object):void{
            if(data==null){
                userDataHash=null;
                super.setupUserValues(data);
                return;
            }

            try{
               userDataHash=JSON.stringify(data);
            }catch(e:Error){
               userDataHash=null;
            }
            super.setupUserValues(data);
        }

        public function activated():void{ }

        public function deactivated():void{}

        public function compareUserValues(data:Object):Boolean{
            if(data==null && userValues==null)
                return true;
            if(data==null && userValues!=null)
                return false;
            if(data!=null && userValues==null)
                return false;

            var hash:String=JSON.stringify(data);
            return hash==userDataHash;
        }
    }
}