package com.dukascopy.connect.managers.webview
{
    import com.telefision.sys.signals.SuperSignal;

    public class S_WebViewRequest extends SuperSignal{
        public function S_WebViewRequest(){
            super("S_WebViewRequest");
        }
        public function invoke(req:WebViewRequest):void{
            
        }
    }
}