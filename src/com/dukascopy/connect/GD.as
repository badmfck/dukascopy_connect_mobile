package com.dukascopy.connect
{
	
	import com.dukascopy.connect.managers.escrow.signals.S_CryptoWalletAdd;
	import com.dukascopy.connect.managers.escrow.signals.S_CryptoWallets;
	import com.dukascopy.connect.managers.escrow.signals.S_EscrowDealCreated;
	import com.telefision.sys.signals.Signal;
	import com.dukascopy.connect.managers.escrow.S_EscrowDealCreateRequest;
	import com.dukascopy.connect.managers.webview.S_WebViewRequest;
	import com.dukascopy.connect.managers.escrow.S_EscrowDealsRequest;
	import com.telefision.sys.signals.SuperSignal;
	import com.dukascopy.connect.managers.escrow.S_EscrowRequestInstruments;
	import com.dukascopy.connect.managers.escrow.S_EscrowInstruments;
	import com.dukascopy.connect.managers.escrow.signals.S_EscrowPrice;
	import com.dukascopy.connect.managers.escrow.signals.S_EscrowManagerAvailable;
	import com.dukascopy.connect.managers.escrow.signals.S_EscrowPricesRequest;
	import com.dukascopy.connect.managers.escrow.signals.S_EscrowMoneyHoldRequest;
	import com.dukascopy.connect.managers.escrow.signals.S_EscrowWalletsRequest;
	import com.dukascopy.connect.managers.escrow.signals.S_EscrowOfferCreateRequest;
	import com.dukascopy.connect.managers.escrow.signals.S_EscrowOffersRequest;
	import com.dukascopy.connect.managers.escrow.signals.S_CryptoWalletAdd;
	
	public class GD
	{
		
		static public const S_STAGE_SIZE_CHANGED:Signal = new Signal("S_STAGE_SIZE_CHANGED");
		static public const S_TOAST:Signal = new Signal("S_TOAST");
		
		static public const S_TIMEZONE_REQUEST:Signal = new Signal("S_TIMEZONE_REQUEST");
		
		static public const S_AUTHORIZED:Signal = new Signal("S_AUTHORIZED");
		static public const S_UNAUTHORIZED:Signal = new Signal("S_UNAUTHORIZED");
		
		static public const S_CONFIG_UPDATED:Signal = new Signal("GD.S_CONFIG_UPDATED");
		
		static public const S_PAYPASS_BACK_CLICK:Signal = new Signal();
		static public const S_SHOW_SYSTEM_TRACE:Signal = new Signal();
		static public const S_REQUEST_SHARE_TEXT:Signal = new Signal();
		static public const S_DEBUG_WS:Signal = new Signal();
		static public const S_LOG_WS:Signal = new Signal();
		static public const S_NET_DEBUG:Signal = new Signal();
		
		static public const S_START_LOAD:Signal = new Signal();
		static public const S_STOP_LOAD:Signal = new Signal();
		
		// ESCROW
		static public const S_ESCROW_MANAGER_AVAILABLE:S_EscrowManagerAvailable = new S_EscrowManagerAvailable(); // EscrowDealMap
		static public const S_ESCROW_DEALS_LOADED:Signal = new Signal();
		static public const S_ESCROW_DEAL_CREATE_REQUEST:S_EscrowDealCreateRequest = new S_EscrowDealCreateRequest();
		static public const S_ESCROW_DEALS_REQUEST:S_EscrowDealsRequest = new S_EscrowDealsRequest();
		static public const S_ESCROW_DEAL_FORM_REQUEST:SuperSignal = new SuperSignal();
		static public const S_ESCROW_MONEY_HOLD_REQUEST:S_EscrowMoneyHoldRequest = new S_EscrowMoneyHoldRequest();
		static public const S_ESCROW_WALLETS_REQUEST:S_EscrowWalletsRequest = new S_EscrowWalletsRequest();
		static public const S_ESCROW_OFFER_CREATE_REQUEST:S_EscrowOfferCreateRequest = new S_EscrowOfferCreateRequest();
		static public const S_ESCROW_DEAL_CREATED:S_EscrowDealCreated = new S_EscrowDealCreated();
		static public const S_ESCROW_DEALS_LOADED_ERROR:Signal = new Signal("S_ESCROW_DEALS_LOADED_ERROR"); // error

		static public const S_ESCROW_OFFERS_REQUEST:S_EscrowOffersRequest = new S_EscrowOffersRequest();
		static public const S_ESCROW_OFFERS_READY:Signal = new Signal("S_ESCROW_OFFERS_READY");
		
		static public const S_ESCROW_INSTRUMENTS_REQUEST:S_EscrowRequestInstruments = new S_EscrowRequestInstruments();
		static public const S_ESCROW_INSTRUMENTS:S_EscrowInstruments = new S_EscrowInstruments();
		static public const S_ESCROW_PRICE:S_EscrowPrice = new S_EscrowPrice();
		static public const S_ESCROW_PRICES_REQUEST:S_EscrowPricesRequest = new S_EscrowPricesRequest();
		
		static public const S_ESCROW_INSTRUMENT_Q_SELECTED:Signal = new Signal("GD.S_ESCROW_INSTRUMENT_Q_SELECTED");
		static public const S_ESCROW_STAT:Signal = new Signal("GD.S_ESCROW_STAT");
		
		static public const S_ESCROW_ADS_CRYPTOS_REQUEST:Signal = new Signal("GD.S_ESCROW_ADS_CRYPTOS_REQUEST");
		static public const S_ESCROW_ADS_INSTRUMENT_SELECTED:Signal = new Signal("GD.S_ESCROW_ADS_INSTRUMENT_SELECTED");
		static public const S_SHOW_ESCROW_ADS:Signal = new Signal("GD.S_SHOW_ESCROW_ADS");
		static public const S_ESCROW_ADS_CRYPTOS:Signal = new Signal("GD.S_ESCROW_ADS_CRYPTOS");
		static public const S_ESCROW_ADS_FILTER_REQUEST:Signal = new Signal("GD.S_ESCROW_ADS_FILTER_REQUEST");
		static public const S_ESCROW_ADS_FILTER_SETTED:Signal = new Signal("GD.S_ESCROW_ADS_FILTER_SETTED");
		static public const S_ESCROW_ADS_REQUEST:Signal = new Signal("GD.S_ESCROW_ADS_REQUEST");
		static public const S_ESCROW_ADS_MINE_REQUEST:Signal = new Signal("GD.S_ESCROW_ADS_MINE_REQUEST");
		static public const S_ESCROW_ADS:Signal = new Signal("GD.S_ESCROW_ADS");
		static public const S_ESCROW_ADS_MINE:Signal = new Signal("GD.S_ESCROW_ADS_MINE");
		static public const S_ESCROW_ADS_REMOVE:Signal = new Signal("GD.S_ESCROW_ADS_REMOVE");
		static public const S_ESCROW_ADS_ANSWERS:Signal = new Signal("GD.S_ESCROW_ADS_ANSWERS");
		static public const S_ESCROW_ADS_ANSWER:Signal = new Signal("GD.S_ESCROW_ADS_ANSWER");
		static public const S_ESCROW_ADS_CREATE:Signal = new Signal("GD.S_ESCROW_ADS_CREATE");
		static public const S_ESCROW_ADS_CREATED:Signal = new Signal("GD.S_ESCROW_ADS_CREATED");
		static public const S_ESCROW_ADS_CREATE_FAIL:Signal = new Signal("GD.S_ESCROW_ADS_FAIL");

		static public const S_IOS_LOCALIZATION_UPDATE:Signal=new Signal("S_IOS_LOCALIZATION_UPDATE");
		
		// Web view
		static public const S_WEBVIEW_REQUEST:S_WebViewRequest = new S_WebViewRequest();
		
		// Bank Cache
		static public const S_BANK_CACHE_CONFIG_REQUEST:Signal = new Signal("GD.S_CONFIG_CACHE_REQUEST");
		static public const S_BANK_CACHE_ACCOUNT_INFO_REQUEST:Signal = new Signal("GD.S_BANK_CACHE_ACCOUNT_INFO_REQUEST");
		static public const S_BANK_CACHE_ACCOUNT_INFO_SAVE:Signal = new Signal("GD.S_BANK_CACHE_ACCOUNT_INFO_SAVE");
		
		static public const S_CRYPTO_WALLET_REQUEST:Signal = new Signal("GD.S_CRYPTO_WALLET_REQUEST");
		static public const S_CRYPTO_WALLETS:S_CryptoWallets = new S_CryptoWallets();
		static public const S_CRYPTO_WALLET_ADD:S_CryptoWalletAdd = new S_CryptoWalletAdd();
	}
}