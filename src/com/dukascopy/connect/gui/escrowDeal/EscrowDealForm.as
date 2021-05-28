package com.dukascopy.connect.gui.escrowDeal
{
    import flash.filesystem.File;
    import com.forms.Form;

    public class EscrowDealForm{
        private var file:File=File.applicationDirectory.resolvePath("forms"+File.separator+"escrowForm.xml");
        private var form:Form;
        public function EscrowDealForm(){
            
        }
    }
}