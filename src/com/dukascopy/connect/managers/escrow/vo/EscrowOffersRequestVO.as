package com.dukascopy.connect.managers.escrow.vo
{
    public class EscrowOffersRequestVO{

        public static const SIDE_BUY:String="buy";
        public static const SIDE_SELL:String="sell";

        public static const STATUS_CREATED:String="offer_created";

        public var force:Boolean;
        public var callback:Function;
        public var status:String;
        public var side:String;
        public function EscrowOffersRequestVO(side:String=null,status:String=null,force:Boolean=false,callback:Function=null){
            this.force=force;
            this.callback=callback;
            this.status=status;
            this.side=side;
        }
    }
}