package com.dukascopy.connect {
import com.telefision.sys.signals.Signal;

public class GD {
        static public const S_PAYPASS_BACK_CLICK:Signal=new Signal();
        static public const S_SHOW_SYSTEM_TRACE:Signal = new Signal();
		static public const S_REQUEST_SHARE_TEXT:Signal = new Signal();
		static public const S_DEBUG_WS:Signal = new Signal();
		static public const S_LOG_WS:Signal = new Signal();
		static public const S_NET_DEBUG:Signal = new Signal();


		// ESCROW
		static public const S_ESCROW_DEALS_LOADED:Signal=new Signal(); // EscrowDealVO[] fires when all active escrow deals loaded from server
    }
}
