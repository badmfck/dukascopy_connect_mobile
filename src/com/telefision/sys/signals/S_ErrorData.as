package com.telefision.sys.signals
{
    import com.dukascopy.connect.data.ErrorData;

    public class S_ErrorData extends SuperSignal{
        public function S_ErrorData(){
            super("S_ErrorData");
        }   
        public function invoke(data:ErrorData):void{
            _invoke(data);
        }
    }
}