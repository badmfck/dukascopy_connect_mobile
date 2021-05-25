package com.dukascopy.connect {
import com.telefision.sys.signals.Signal;
import com.dukascopy.connect.managers.escrow.S_EscrowDealCreateRequest;
import com.dukascopy.connect.managers.webview.S_WebViewRequest;
import com.dukascopy.connect.managers.escrow.S_EscrowDealsRequest;
import com.telefision.sys.signals.SuperSignal;

public class GD {
        static public const S_PAYPASS_BACK_CLICK:Signal=new Signal();
        static public const S_SHOW_SYSTEM_TRACE:Signal = new Signal();
		static public const S_REQUEST_SHARE_TEXT:Signal = new Signal();
		static public const S_DEBUG_WS:Signal = new Signal();
		static public const S_LOG_WS:Signal = new Signal();
		static public const S_NET_DEBUG:Signal = new Signal();


		// ESCROW
		static public const S_ESCROW_DEALS_LOADED:Signal=new Signal(); // EscrowDealMap
		static public const S_ESCROW_DEAL_CREATE_REQUEST:S_EscrowDealCreateRequest=new S_EscrowDealCreateRequest();
		static public const S_ESCROW_DEALS_REQUEST:S_EscrowDealsRequest=new S_EscrowDealsRequest();
		static public const S_ESCROW_DEAL_FORM_REQUEST:SuperSignal=new SuperSignal();

		// Web view
		static public const S_WEBVIEW_REQUEST:S_WebViewRequest=new S_WebViewRequest();
    }
}
