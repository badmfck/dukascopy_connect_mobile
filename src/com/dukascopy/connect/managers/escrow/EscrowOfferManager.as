package com.dukascopy.connect.managers.escrow
{
    import com.dukascopy.connect.GD;
    import com.dukascopy.connect.managers.escrow.vo.EscrowOfferVO;

    public class EscrowOfferManager{
        public function EscrowOfferManager(){
            GD.S_ESCROW_OFFER_CREATE_REQUEST.add(onEscrowOfferCreateRequest,this);
        }   

        private function onEscrowOfferCreateRequest(escrowOfferVO:EscrowOfferVO):void{

        }
    }
}