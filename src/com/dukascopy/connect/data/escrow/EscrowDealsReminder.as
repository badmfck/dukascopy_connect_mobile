package com.dukascopy.connect.data.escrow
{

    import com.forms.Form;
    import com.forms.components.FormList;
    import flash.filesystem.File;
    import flash.display.Sprite;
    import com.telefision.utils.maps.EscrowDealMap;
    import com.dukascopy.connect.GD;
    import com.forms.components.FormListItem;

    public class EscrowDealsReminder{
        private var _view:Sprite;
        private var formReady:Boolean=false;
        private var requestDealsCalled:Boolean=false;
        private var form:Form;
        private var width:int=-1;
        private var height:int=-1;
        public function get view():Sprite{return _view;}

        public function EscrowDealsReminder(){
            
            form=new Form(File.applicationDirectory.resolvePath("forms"+File.separator+"escrowDeals.xml"));
		    var list:FormList;
            _view=form.view as Sprite;
			form.onDocumentLoaded=function():void{
				list=form.getComponentByID("deals") as FormList;
				GD.S_ESCROW_DEALS_LOADED.add(function(deals:EscrowDealMap):void{
					if(list!=null)
						list.setData(deals.getValues());
				})
                list.onItemBeforeDraw=function(li:FormListItem):void{

                };
				formReady=true;
                if(width>0 && height>0)
                    form.setSize(width,height);
                if(requestDealsCalled)
                    requestDeals();
			};
    
        }

        public function setSize(width:int,height:int):void{
            this.width=width;
            this.height=height;
            if(formReady && form!=null)
                form.setSize(width,height);
        }
        
        public function requestDeals():void{
            requestDealsCalled=false;
            if(formReady){
                GD.S_ESCROW_DEALS_REQUEST.invoke();
                return;
            }
            requestDealsCalled=true;
        }
        

        public function dispose():void{
            if(form!=null)
                form.destroy();
        }
    }
}