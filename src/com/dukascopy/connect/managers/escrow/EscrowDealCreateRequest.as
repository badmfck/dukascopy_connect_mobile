package com.dukascopy.connect.managers.escrow
{
    

    public class EscrowDealCreateRequest{

        private var _chatUID:String;
        private var _instrument:String; //- название инструмента (btc, eth, etc)
        private var _prim_amount:Number;// - кол-во инструмента (0.00521)
        private var _mca_ccy:String;// - mca валюта за которую покупают инструмент (EUR)
        private var _sec_amount:Number;// - стоимость, которую платят за инструмент (1023.12)
        private var _side:EscrowDealSide;// - сторона на которой выступает инициатор сделки

        public function get chatUID():String{return _chatUID}
        public function get instrument():String{return _instrument}
        public function get prim_amount():Number{return _prim_amount}
        public function get sec_amount():Number{return _sec_amount}
        public function get mca_ccy():String{return mca_ccy}
        public function get side():EscrowDealSide{return _side}

        public function EscrowDealCreateRequest(chatUID:String=null,instrument:String=null,primAmount:Number=0,mcaCcy:String=null,secAmount:Number=0,side:EscrowDealSide=null){
            this._chatUID=chatUID;
            this._instrument=instrument;
            this._prim_amount=primAmount;
            this._sec_amount=secAmount;
            this._mca_ccy=mcaCcy;
            this._side=side;
        }

        public function setChatUID(val:String):EscrowDealCreateRequest{
            this._chatUID=val;
            return this;
        }
        public function setInstrument(val:String):EscrowDealCreateRequest{
            this._instrument=val
            return this;
        }

        public function setPrimAmount(val:Number):EscrowDealCreateRequest{
            this._prim_amount=val
            return this;
        }

        public function setMcaCcy(val:String):EscrowDealCreateRequest{
            this._mca_ccy=val;
            return this;
        }
        
        public function setSecAmount(val:Number):EscrowDealCreateRequest{
            this._sec_amount=val;
            return this;
        }

        public function setSide(val:EscrowDealSide):EscrowDealCreateRequest{
            this._side=val;
            return this;
        }
        
        public function toObject():Object{
            return {
                chatUID:_chatUID,
                instrument:_instrument,
                prim_amount:_prim_amount,
                mca_ccy:_mca_ccy,
                sec_amount:_sec_amount,
                side:_side.value
            }
        }

        public function toString():String{
            return JSON.stringify(toObject());
        }
    }
}