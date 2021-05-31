package com.dukascopy.connect.managers.escrow{

    public class EscrowInstrument{
        
        private var _name:String;
        private var _wallet:String;
        private var _price:Number; //ASK
        private var _code:String;
        private var precision:int=2;
        
        public function EscrowInstrument(name:String,wallet:String,precision:*,code:String,price:Number){
            _name=name;
            _wallet=wallet;
            _code=code;
            if(precision is String){
                var p:int=-1;
                try{
                    p=parseInt(precision)
                }catch(e:Error){}
                if(p!=-1)
                    this.precision=p;
            }else if(!isNaN(precision))
                this.precision=precision;
            if(!updatePrice(price))
                price=0;
        }

        public function get name():String{
            return _name;
        };

        public function get wallet():String{
            return _wallet;
        }

        public function get code():String{
            return _code;
        }

        public function get price():Number{
            return _price;
        }

        public function get isLinked():Boolean{
            return _wallet!=null;
        }

        public function updatePrice(val:*):Boolean{
            var p:Number=-1;
            if(val is String){
                try{
                    p=parseFloat(val);
                }catch(e:Error){
                    return false;
                }
            }else if(!isNaN(val))
                p=val;

            if(isNaN(p) || p==-1)
                return false;

            if(p==_price)
                return false;

            _price=parseFloat(p.toFixed(precision));
            return true;
        }

        public function toString():String{
            return name+" ("+code+") at "+price+" (precision: "+precision+"), wallet: "+((wallet!=null)?wallet:"No linked wallet");
        }
    }
}