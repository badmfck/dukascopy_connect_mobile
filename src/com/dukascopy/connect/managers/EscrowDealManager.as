package com.dukascopy.connect.managers{

    import com.dukascopy.connect.GD;
    import com.dukascopy.connect.sys.Dispatcher;
    import com.dukascopy.connect.vo.EscrowDealVO;
    import com.telefision.utils.maps.EscrowDealMap;
    

    public class EscrowDealManager{

        private var escrowDeals:EscrowDealMap=new EscrowDealMap();

        public function EscrowDealManager(){
            loadDeals();

            GD.S_ESCROW_DEAL_CREATE_REQUEST.add(onEscrowDealCreateRequest);
        }

        private function onEscrowDealCreateRequest(req:EscrowDealCreateRequest):void{
            
        }

        /**
         * Load active deals
         */
        private function loadDeals():void{
            //TODO: Server method - load deals, fire callback
            
            // TEMP DATA
            var data:Object=[
                {
                    uid:"abc1"
                },
                {
                    uid:"cde2"
                },
                {
                    uid:"efg3"
                }
            ]
            onDealsLoaded(data);
        }

        private function onDealsLoaded(data:Object):void{
            
            // DATA MUST BE ARRAY!
            if(data==null || !(data is Array))
                return;

            var l:int=(data as Array).length;

            for(var i:int=0;i<l;i++){
                var deal:Object=data[i];
                if(!('uid' in deal) || deal.uid==null)
                    continue;
                var dealVO:EscrowDealVO=escrowDeals.getDeal(deal.uid);
                if(dealVO==null)
                    dealVO=new EscrowDealVO(deal);
                dealVO.update(deal);
                escrowDeals.addDeal(deal.uid,dealVO);
            }

            GD.S_ESCROW_DEALS_LOADED.invoke(escrowDeals);
        }

    }

}