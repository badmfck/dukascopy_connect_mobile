package com.dukascopy.connect.managers.escrow.vo{
    
    public class EscrowPrice{
        public var name:String;
        public var value:Number;
        public function EscrowPrice(name:String,value:Number){
            this.name=name;
            this.value=value;
        }
        public function toString():String{
            return this.name+": "+this.value;
        }
    }
}