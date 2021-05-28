package com.telefision.utils.maps
{
    import com.telefision.utils.Map;
    import com.dukascopy.connect.vo.EscrowDealVO;

    public class EscrowDealMap extends Map{
        public function addDeal(key:String,deal:EscrowDealVO):EscrowDealMap{
            add(key,deal);
            return this;
        }
        public function getDeal(key:String):EscrowDealVO{
            return getValue(key) as EscrowDealVO;
        }
    }
}