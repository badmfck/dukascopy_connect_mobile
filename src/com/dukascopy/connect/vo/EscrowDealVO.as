package com.dukascopy.connect.vo
{
    public class EscrowDealVO{

        private var _uid:String;
        private var _side:String;
        private var _created_at:Number;
        private var _updated_at:Number;
        private var _status:String; // (ENUM created, paid_mca, paid_crypto, completed, claimed, canceled)
        private var _instrument:String; // То чем торгуют
        private var _prim_amount:Number; // кол-во инструмента
        private var _mca_ccy:String;  // чем платят (все валюты в mca, включая сfd и т.п.)
        private var _sec_amount:Number; // стоимость инструмента в ccy
        private var _crypto_user_uid:String; // uid пользователя, продающего крипту
        private var _mca_user_uid:String; // uid пользователя, оплачивающего крипту фиатом
        private var _chat_uid:String; // uid чата в котором две стороны вели предварительные переговоры
        private var _crypto_trn_id:String; // id крипто транзакции
        private var _mca_trn_id:String; // id mca транзакции
        private var _crypto_claim_id:String; // id жалобы от инициатора сделки
        private var _mca_claim_id:String; // id жалобы второй стороны
        private var raw:Object;

        public function EscrowDealVO(data:Object){
            raw=data;
        }

        private function getVal(name:String):Object{
            if(raw==null || name==null)
                return null;
            if(name in raw)
                return raw[name];
            return null;
        }

        public function get uid():String{ return getVal("uid") as String;}
    }
}