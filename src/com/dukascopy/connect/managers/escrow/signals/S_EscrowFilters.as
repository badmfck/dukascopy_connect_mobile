package com.dukascopy.connect.managers.escrow.signals
{
	import com.dukascopy.connect.data.escrow.filter.EscrowFilter;
	import com.telefision.sys.signals.SuperSignal;

    public class S_EscrowFilters extends SuperSignal{
        public function S_EscrowFilters(){
            super("S_EscrowFilters")
        }
        public function invoke(filters:Vector.<EscrowFilter>):void{
            _invoke(filters);
        }
    }
}