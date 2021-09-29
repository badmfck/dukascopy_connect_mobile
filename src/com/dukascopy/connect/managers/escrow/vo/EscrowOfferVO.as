package com.dukascopy.connect.managers.escrow.vo
{
    public class EscrowOfferVO{



        public var chat_uid:String;
        public var created:String;//"2021-09-09 15:05:32"
        public var crypto_user_uid:String;//"WLDNWrWbWoIxIbWI"
        public var data:Object;
        /*"
            {
                "chatUID":"WIWvWeIrWcWJIsWa",
                "price":0.67,
                "amount":2000,
                "instrument":"DCO",
                "debit_account":"315493309787",
                "side":"buy",
                "mca_ccy":"EUR",
                "offer_id":"03wLNxTkU",
                "type":"typeCp2pOffer",
                "crypto_user_uid":"WLDNWrWbWoIxIbWI",
                "mca_user_uid":"WdW6DJWbW3IsIb",
                "payment":{"account_from":{"id":3367,"phone":"37125914896","wallet":null,"iban":null,"payScore":null,"payScoreDetails":null},
                "account_id_from":3367,
                "account_id_to":1487,
                "account_to":{"id":1487,"phone":"79998181810","wallet":null,"iban":null,"payScore":null,"payScoreDetails":null},
                "operation_uid":"0a3TFeCl",
                "origin_id":"03wLNxTkU",
                "penalty_amount":-13.4,
                "penalty_currency":"EUR",
                "price":0.67,
                "primary_amount":2000,
                "primary_currency":
                "DCO",
                "refundable_fee_amount":-40.2,
                "refundable_fee_currency":"EUR",
                "secondary_amount":1340,
                "secondary_currency":"EUR",
                "transfer_fee_amount":-40.2,
                "transfer_fee_currency":"EUR"}
                }"*/
        public var deal_uid:int
        public var id:int
        public var lifeTime:String;
        public var mca_user_uid:String;
        public var msg_id:int
        public var offer_id:int
        public var status:String

        private var raw:Object;


        public function EscrowOfferVO(raw:Object){
            this.raw=raw;
            for(var i:String in raw)
                if(i in this)
                    this[i]=raw[i];

            if(data is String){
                try{
                    data=JSON.parse(data as String);
                }catch(e:Error){}
            }
        }
    }
}