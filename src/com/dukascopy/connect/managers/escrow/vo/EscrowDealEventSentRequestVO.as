package com.dukascopy.connect.managers.escrow.vo
{
    import com.dukascopy.connect.data.escrow.EscrowEventType;

    public class EscrowDealEventSentRequestVO{
        
        public var type:EscrowEventType;
        public var dealUID:String;
        public var data:String;
        public var notifyWS:Boolean;

        public function EscrowDealEventSentRequestVO(type:EscrowEventType,dealUID:String,data:String,notifyWS:Boolean){
            this.type=type;
            this.dealUID=dealUID;
            this.data=data;
            this.notifyWS=notifyWS;
        }
    }
}