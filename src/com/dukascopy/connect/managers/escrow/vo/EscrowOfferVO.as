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
        public function get msg_id():int{ return getInt("msg_id")};
        public function get offer_id():String{ return getString("offer_id")};
        
        public var data:EscrowMessageData; // Should be escrowOffer form messages
        
        
        public function EscrowOfferVO(raw:Object){
            super(raw);
            
			updateMessageData(raw);
        }
		
		private function updateMessageData(raw:Object):void 
		{
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
			else
			{
				if (!("created" in raw))
				{
					raw.created = raw.lifeTime;
				}
				data = new EscrowMessageData(raw);
			}
		}
		
		override public function update(data:Object):void{
            super.update(data);
			updateMessageData(data);
        }
    }
}