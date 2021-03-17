package com.dukascopy.connect.sys.payments.advancedPayments.vo{
	
	import com.dukascopy.connect.gui.lightbox.LightBoxItemVO;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.vo.ChatMessageVO;
	
	/**
	 * Helper Class that executes Payment Tasks such as:
	 * 		-Pay incomming invoice
	 * 		-Pay Gift
	 *		-Pay Outgoing Money Transaction
	 *
	 * @author Alexey Skuryat
	 *
	 */
	public class PayTaskVO {
		
		// Task Types
		static public const TASK_TYPE_PAY_INVOICE_BY_PHONE:String = "taskTypePayInvoiceByPhone";
		static public const TASK_TYPE_PAY_INVOICE_BY_UID:String = "taskTypePayInvoiceByUID";
		static public const TASK_TYPE_PAY_GIFT_BY_UID:String = "taskTypePayGiftByUID";
		static public const TASK_TYPE_PAY_PUZZLE_BY_UID:String = "taskTypePayPuzzleByUID";
		static public const TASK_TYPE_PAY_MERCH:String = "taskTypePayMerch";
		static public const TASK_TYPE_SELF_TRANSFER:String = "taskTypeSelfTransfer";
		static public const TASK_TYPE_RESERVE_TIPS:String = "taskTypeReserveTips";
		static public const TASK_TYPE_PAY_BY_PHONE:String = "taskTypePayByPhone";
		
		private var _taskType:String;
		
		// title 
		public var customDialogTitle:String = "";
		
		//public var from_account:String;// from account
		public var from_uid:String;
		public var from_phone:String;
		public var from_wallet:String;
		public var to_uid:String;
		public var to_phone:String;
		public var amount:Number;
		public var currency:String;
		
		// Specific params
		public var giftID:String = "";
		public var messageText:String = "";
		public var messageVO:ChatMessageVO;
		public var lightboxVO:LightBoxItemVO; // FOR PUZZLE
		
		// if type by uid better to pass Username so we know to whom we pay 
		public var destinationUserName:String = "";
		
		// Object filled with params depending on task type for further request on PayServer
		private var _requestParamsObject:Object;
		
		// Commision text 
		public var commissionText:String = "";
		
		// Define in  what screen we show invoice 
		public var handleInCustomScreenName:String = "";
		public var to_wallet:String;
		public var updateAccount:Boolean = true;
		public var showNoAccountAlert:Boolean = true;
		public var allowCardPayment:Boolean = false;
		public var purpose:String;
		public var pass:String;
		public var requestClarification:Boolean;
		//public var callback:Function;
		
		public function PayTaskVO(task_type:String) {
			_taskType = task_type;
		}
		
		/**
		 * _requestParamsObject.to_type = "tfuid"; "phone", "wallet", "iban" or "tfuid"
		 * Returns formated request Object
		 * @return
		 */
		public function generateRequestObject():Object {
			_requestParamsObject ||= {};
			_requestParamsObject.amount = amount;
			_requestParamsObject.currency = currency;
			_requestParamsObject.from = from_wallet;
			if (pass != null && pass != "")
			{
				_requestParamsObject.code = pass;
			}
			if (_taskType == TASK_TYPE_SELF_TRANSFER) {
				_requestParamsObject.to = to_wallet;
			//	_requestParamsObject.fromCurrency = currency;
			//	_requestParamsObject.fromAmount = amount;
			} else if (_taskType == TASK_TYPE_PAY_INVOICE_BY_PHONE || _taskType == TASK_TYPE_PAY_BY_PHONE) { // BY PHONE NUMBER
				_requestParamsObject.to_type = "phone";
				_requestParamsObject.to = to_phone;
				_requestParamsObject.message = messageText;
			} else if (_taskType == TASK_TYPE_PAY_GIFT_BY_UID) { // GIFT BY UID
				_requestParamsObject.to_type = "tfuid";
				_requestParamsObject.to = to_uid;
				_requestParamsObject.from_uid = from_uid;
				if (purpose != null)
				{
					_requestParamsObject.clarification = purpose;
				}
				if (messageText != null && messageText != "")
					_requestParamsObject.message = messageText;
				else
					_requestParamsObject.message = "Gift";
			} else if (_taskType == TASK_TYPE_PAY_INVOICE_BY_UID) { // INVOICE PAYMENT BY UID
				_requestParamsObject.to_type = "tfuid";
				if (purpose != null)
				{
					_requestParamsObject.clarification = purpose;
				}
				_requestParamsObject.to = to_uid;
				_requestParamsObject.from_uid = from_uid;
			} else if (_taskType == TASK_TYPE_PAY_PUZZLE_BY_UID) { // PUZZLE BY UID
				_requestParamsObject.to_type = "tfuid";
				_requestParamsObject.to = to_uid;
				_requestParamsObject.from_uid = from_uid;
				_requestParamsObject.message = "Puzzle";
			} else if (_taskType == TASK_TYPE_PAY_MERCH) { // MERCH
				_requestParamsObject.to = "dukascopy";
			} else if (_taskType == TASK_TYPE_RESERVE_TIPS) { // MERCH
				// TODO generate correct merch request object
				_requestParamsObject.to = to_uid;
				_requestParamsObject.to_type = "tfquestion";
				_requestParamsObject.from_uid = Auth.uid;
			}
			return _requestParamsObject;
		}
		
		public function get taskType():String  { return _taskType; }
		
		public function set taskType(value:String):void 
		{
			_taskType = value;
		}
		
		public function toString():String { return UI.tracedObj(this); }
	}
}