package com.dukascopy.connect.managers{

    import com.dukascopy.connect.GD;
    import com.dukascopy.connect.sys.Dispatcher;
    import com.dukascopy.connect.vo.EscrowDealVO;

    public class EscrowDealManager{

        private var escrowDeals:Vector.<EscrowDealVO>=new Vector.<EscrowDealVO>();

        public function EscrowDealManager(){
            loadDeals();
        }

        private function loadDeals():void{
            //TODO: Server method - load deals, fire callback
            trace("LOAD  DEALS")
            
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
          
            }

            GD.S_ESCROW_DEALS_LOADED.invoke([
                new EscrowDealVO({uid:"123"}),
                new EscrowDealVO({uid:"345"}),
                new EscrowDealVO({uid:"567"}),
            ]);
        }

    }

}