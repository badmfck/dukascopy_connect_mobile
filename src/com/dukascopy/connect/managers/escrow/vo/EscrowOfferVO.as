package com.dukascopy.connect.managers.escrow.vo
{
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
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
        
        public var data:EscrowMessageData; // Should be escrowOffer form messages
        
        
        public function EscrowOfferVO(raw:Object){
            super(raw);
            
			var messageRaw:Object;
            if(raw.data is String){
                try{
                    messageRaw = JSON.parse(raw.data as String);
                }catch(e:Error){}
            }
			if (messageRaw != null)
			{
				data = new EscrowMessageData(messageRaw);
				data.setStatus(status);
			}
        }
        
    }
}