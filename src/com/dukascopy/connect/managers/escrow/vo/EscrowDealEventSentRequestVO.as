package com.dukascopy.connect.managers.escrow.vo
{
    import com.dukascopy.connect.data.escrow.EscrowEventType;

    public class EscrowDealEventSentRequestVO{
        
        public var type:EscrowEventType;
        public var dealUID:String;
        public var notifyWS:Boolean;

        public function EscrowDealEventSentRequestVO(type:EscrowEventType,dealUID:String,notifyWS:Boolean){
            this.type=type;
            this.dealUID=dealUID;
            this.notifyWS=notifyWS;
        }
    }
}