package com.dukascopy.connect.screens.payments 
{
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.telefision.sys.signals.Signal;
	/**
	 * ...
	 * @author Alexey Skuryat

	 */
	public class PayCardsManager 
	{
		/**
		 * counter for unique callID's
		 */ 
		private static  var c:int = 1; 
		private static var isInited:Boolean = false;

		private static var _dukascopyCards:Array = [];
		private static var _cardOrders:Array = [];
		private static var _linkedCards:Array = [];
			
		private static var _isLoadingDukascopyCards:Boolean = false;			
		private static var _isLoadingLinkedCards:Boolean = false;
		private static var _isLoadedDukascopyCards:Boolean = false; // at least one respond was sucessfull
		private static var _isLoadedLinkedCards:Boolean = false; 
		
		private static var _hadLinkedCardsRespond:Boolean = false;
		private static var _hadDukascopyCardsRespond:Boolean = false;
		
		private static var _lastCallID_DC:String = "-1";
		private static var _lastCallID_LC:String = "-1";
		static private var _hadDukascopyCardsRespondError:Boolean;
		static private var _hadLinkedCardsRespondError:Boolean;
		
		// Signal for fire update loading state for Dukascopy cards and Linked Cards
		public static var S_LOADING_STATE_CHANGED:Signal = new Signal("PayManager.S_LOADING_STATE_CHANGED");
		
		
		
		public function PayCardsManager() {	}
		
		//////////////////////////////////////////////////////////////////////
		//// INIT  
		//////////////////////////////////////////////////////////////////////
		
		private static function init():void	{
			if (isInited) return;
			isInited = true;
			Auth.S_NEED_AUTHORIZATION.add(onAuthNeeded);
		}
		
		static private function onAuthNeeded():void {			
			reset();
		}
		
		//////////////////////////////////////////////////////////////////////
		//// GETTERS  
		//////////////////////////////////////////////////////////////////////
		
		public static function getDukascopyCardsData(statusFilter:String = ""):Array{ 
			if(statusFilter ==""){
				return	_dukascopyCards;
			}else{
				var result:Array = [];
				var cardItem:Object;
				var searchedStatus:String =  statusFilter.toLowerCase();
				
				for (var i:int = 0; i < _dukascopyCards.length; i++) {
					cardItem = _dukascopyCards[i];
					if (cardItem != null &&  "status_name" in cardItem && searchedStatus == (cardItem.status_name as String).toLowerCase()){
						result.push(cardItem);
					}
				}	
				return result;
			}
		}		
		public static function getLinkedCardsData(statusFilter:String = ""):Array{	
			if(statusFilter ==""){
				return	_linkedCards;
			}else{
				var result:Array = [];
				var cardItem:Object;
				var searchedStatus:String =  statusFilter.toLowerCase();
				
				for (var i:int = 0; i < _linkedCards.length; i++) {
					cardItem = _linkedCards[i];
					if (cardItem != null && "status" in cardItem && searchedStatus == (cardItem.status as String).toLowerCase()){
						result.push(cardItem);
					}
				}	
				return result;
			}
			
		}		
		static public function getCardOrders():Array {	return _cardOrders;}
		
		
		
		
		
		
		//////////////////////////////////////////////////////////////////////
		//// LOADING STATES MANAGMENT 
		//////////////////////////////////////////////////////////////////////
		
		static public function get isLoadingDukascopyCards():Boolean {	return _isLoadingDukascopyCards;}
		static public function set isLoadingDukascopyCards(value:Boolean):void 	{
			if (value == _isLoadingDukascopyCards) return;
			_isLoadingDukascopyCards = value;
			S_LOADING_STATE_CHANGED.invoke();			
		}
		
		static public function get isLoadingLinkedCards():Boolean {	return _isLoadingLinkedCards;	}		
		static public function set isLoadingLinkedCards(value:Boolean):void {
			if (value == _isLoadingLinkedCards) return;
			_isLoadingLinkedCards = value;
			S_LOADING_STATE_CHANGED.invoke();
		}
		
		static public function get isLoadedLinkedCards():Boolean {	return _isLoadedLinkedCards;	}		
		static public function get isLoadedDukascopyCards():Boolean 	{		return _isLoadedDukascopyCards;	}
		
		static public function get hadLinkedCardsRespond():Boolean {	return _hadLinkedCardsRespond;}
		
		static public function get hadDukascopyCardsRespond():Boolean {	return _hadDukascopyCardsRespond;	}
		
		static public function get hadDukascopyCardsRespondError():Boolean 
		{
			return _hadDukascopyCardsRespondError;
		}
		
		static public function get hadLinkedCardsRespondError():Boolean 
		{
			return _hadLinkedCardsRespondError;
		}
		
		
		
		
		
				
		
		/////////////////////////////////////////////////////////
		// SIMULATE LOAD CALL AGAIN  IF WE HAD SAME Call ID 
		//////////////////////////////////////////////////////////
		
		public static function onCallAgain(data:Object):void
		{
			//trace("On Call Again " + data);
			if (data != null && data.callID != null && data.callID!= "-1"){
				
				if (data.callID == _lastCallID_DC){	// simulate loading state for Dukascopy Cards				
					isLoadingDukascopyCards = true;
				}
				
				if (data.callID == _lastCallID_LC){	// simulate loading state for Linked Cards  				
					isLoadingLinkedCards = true;
				}		
				
			}			
		}
		
		
		
		//////////////////////////////////////////////////////////////////////
		//// DUKASCOPY CARDS 
		//////////////////////////////////////////////////////////////////////
		public static function loadDukascopyCards(customCallID:String="", extra:Boolean = false):void
		{
			init();
			isLoadingDukascopyCards = true;
			_lastCallID_DC = customCallID!="" ? customCallID : generateCallID("_DC_CARDS");			
			PayManager.S_DUKASCOPY_CARDS_RESPOND.add(onDukascopyCardsLoaded);
			PayManager.callGetCards(_lastCallID_DC, extra);
		}
		
		public static function onDukascopyCardsLoaded(respond:PayRespond):void {
			if (_lastCallID_DC == respond.savedRequestData.callID){							
				if (respond.error == false){						
					_dukascopyCards = respond.data.cards as Array;		
					_cardOrders = respond.data.orders as Array;		
					_isLoadedDukascopyCards = true;
					_hadDukascopyCardsRespond = true;
					_hadDukascopyCardsRespondError = false;
					// card_oreders added as well
					// last DC cards load was sucessfull 
					//trace("Dukascopy cards loaded " + _dukascopyCards);
				}else{
					// last DC cards load wasn't sucessfull
					_hadDukascopyCardsRespondError = true;
				}
				isLoadingDukascopyCards = false;
			}
		}
		
		
		
		
		

		
		
		
		//////////////////////////////////////////////////////////////////////
		//// LINKED CARDS 
		//////////////////////////////////////////////////////////////////////
		public static function loadLinkedCards(customCallID:String=""):void
		{			
			init();
			isLoadingLinkedCards = true;
			_lastCallID_LC = customCallID != "" ? customCallID : generateCallID("_LINKED_CARDS");	
			PayManager.S_DUKASCOPY_LINKED_CARDS_RESPOND.add(onLinkedCardsLoaded);
			PayManager.callGetMoneyCards(_lastCallID_LC);	
		}
		
		
		public static function onLinkedCardsLoaded(respond:PayRespond):void {
			if (_lastCallID_LC == respond.savedRequestData.callID){				
				if (respond.error == false){						
					_linkedCards = respond.data as Array;
					_isLoadedLinkedCards = true;
					_hadLinkedCardsRespond  = true;
					_hadLinkedCardsRespondError = false;
					//trace("Linked cards loaded " + _linkedCards);
					// last Linked cards load was sucessfull
				}else{
					// last Linked cards load wasn't sucessfull
					
					_hadLinkedCardsRespondError = true;
				}
				isLoadingLinkedCards = false;				
			}
		}
		
		public static function hasDukascopyCardWithCurrency(currency:String):Boolean {
			if (_dukascopyCards.length > 0){
				var currentCurrency:String = "";
				for (var i:int = 0; i < _dukascopyCards.length; i++) {
					currentCurrency = _dukascopyCards[i].currency;
					if (currentCurrency == currency){
						return true;
					}
				}
				return false;
			}else{
				return false;
			}
		}
	
		//DEPRECATED!!!!!!!!!!!!!!!
		//DEPRECATED!!!!!!!!!!!!!!!
		//DEPRECATED!!!!!!!!!!!!!!!
		//DEPRECATED!!!!!!!!!!!!!!!
		//DEPRECATED!!!!!!!!!!!!!!!
		//
		// linked cards without currency
		//
		/*public static function hasLinkedCardWithCurrency(currency:String):Boolean {
			if (_linkedCards.length > 0) {
				var currentCurrency:String = "";
				for (var i:int = 0; i < _linkedCards.length; i++) {
					currentCurrency = _linkedCards[i].ccy;
					if (currentCurrency == currency){
						return true;
					}
				}
				return false;
			} else
				return false;
		}*/
		
		//////////////////////////////////////////////////////////////////////
		//// UTILS ...ETC. 
		//////////////////////////////////////////////////////////////////////
		
		private static function generateCallID(prefix:String):String {c++;return c +""+ prefix as String;}
		
		public static function reset():void {
			_lastCallID_DC = "-1";
			_lastCallID_LC = "-1";
			if (_dukascopyCards != null)
				_dukascopyCards.length = 0;
			if (_cardOrders != null)
				_cardOrders.length = 0;
			if (_linkedCards != null)
				_linkedCards.length = 0;
			_isLoadingDukascopyCards = false;
			_isLoadingLinkedCards = false;
			_hadLinkedCardsRespond = false;
			_hadDukascopyCardsRespond = false;				 
			_hadDukascopyCardsRespondError = false;
			_hadLinkedCardsRespondError = false;
		}
	}
}