package com.dukascopy.connect.vo
{
	import com.dukascopy.connect.managers.escrow.vo.BaseVO;
    public class EscrowDealVO extends BaseVO{
       
        private var raw:Object;
		

        public function get uid():String{ return getString("deal_uid") as String;}
		public function get status():String{return getString("status");}
		public function get instrument():String{return getString("instrument");}
		public function get price():Number{return getNumber("price");}
		public function get currency():String{return getString("mca_ccy");}
		public function get side():String{ return getString("side"); }
		public function get chatUID():String{ return getString("chat_uid"); }
		public function get created():Date{ return getDate("created_at"); }
		public function get amount():Number{ return getNumber("amount"); }
		public function get mca_ccy():String{ return getString("mca_ccy"); }

		public function get cryptoUserUID():String{ return getString("crypto_user_uid"); }
		public function get mcaUserUID():String{ return getString("mca_user_uid"); }
		public function get cryptoTransactionId():String{ return getString("crypto_trn_id"); }
		public function get messageId():Number{ return getNumber("msg_id"); }
		public function get cryptoWallet():String{ return getString("crypto_wallet"); }
		public function get debitAccount():String{ return getString("debit_account"); }

        public function get time():String{ return getFormattedDate("created_at","%h:%i")}
		
        public function EscrowDealVO(raw:Object){
			super(raw);
            update(raw);
        }
		
        public function update(data:Object):void{
            raw=data;
        }
    }
}