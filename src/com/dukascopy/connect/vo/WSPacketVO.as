package com.dukascopy.connect.vo
{
    import com.dukascopy.connect.managers.escrow.vo.BaseVO;

    public class WSPacketVO extends BaseVO{

        public function get method():String{ return getString("method");}
        public function get action():String{ return getString("action");}
        public function get data():Object{ return getObject("data");}

        public function WSPacketVO(raw:Object):void{
            super(raw);
        }
    }
}