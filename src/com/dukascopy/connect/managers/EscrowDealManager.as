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
            GD.S_ESCROW_DEALS_LOADED.invoke([
                new EscrowDealVO({uid:"123"}),
                new EscrowDealVO({uid:"345"}),
                new EscrowDealVO({uid:"567"}),
            ]);

        }
    }

}