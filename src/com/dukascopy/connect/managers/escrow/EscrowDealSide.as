package com.dukascopy.connect.managers.escrow
{
    import com.telefision.utils.Enum;
    public class EscrowDealSide extends Enum{
        static public function get BUY():EscrowDealSide{
            return new EscrowDealSide(new Instancer(),"buy");
        }
        static public function get SELL():EscrowDealSide{
            return new EscrowDealSide(new Instancer(),"sell");
        }
        public function EscrowDealSide(instancer:Instancer,side:String):void{
            super(side)
        }
    }
}

class Instancer{
    public function Instancer(){}
}