package com.dukascopy.connect.managers.escrow
{
    import com.dukascopy.connect.GD;

    public class EscrowOfferManager{
        public function EscrowOfferManager(){
            GD.S_ESCROW_OFFER_CREATE_REQUEST.add(onEscrowOfferCreateRequest,this);

            //EscrowMessageData
        }   

        private function onEscrowOfferCreateRequest(escrowOfferVO:*):void{

        }
    }
}