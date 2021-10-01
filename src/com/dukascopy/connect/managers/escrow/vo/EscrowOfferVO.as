package com.dukascopy.connect.managers.escrow.vo
{
    public class EscrowOfferVO extends BaseVO{

        public function get chat_uid():String{ return getString("chat_uid")};
        public function get crypto_user_uid():String{ return getString("crypto_user_uid")};
        public function get created():Date{ return getDate("created")};
        public function get status():String{ return getString("status")};
        public function get lifeTime():String{ return getString("lifeTime")};
        public function get mca_user_uid():String{ return getString("mca_user_uid")};
        public function get deal_uid():int{ return getInt("deal_uid")};
        public function get id():int{ return getInt("id")};
        public function get msg_id():int{ return getInt("msg_id")};
        public function get offer_id():int{ return getInt("offer_id")};
        
        public var data:Object; // Should be escrowOffer form messages
        
        
        public function EscrowOfferVO(raw:Object){
            super(raw);
            
            if(raw.data is String){
                try{
                    data=JSON.parse(raw.data as String);
                    //TODO: parse to OfferVO
                }catch(e:Error){}
            }
        }
        
    }
}