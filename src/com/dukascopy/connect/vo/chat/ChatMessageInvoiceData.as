package com.dukascopy.connect.vo.chat {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.type.InvoiceStatus;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.langs.Lang;

	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ChatMessageInvoiceData {
		
		public var amount:Number = 0;
		public var currency:String;
		public var message:String;

		public var fromUserName:String;
		public var fromUserUID:String;
		public var toUserUID:String;
		public var id:String;
		public var purpose:String = "purpose";
		public var toUserName:String;

		public var phone:String = "";
		public var type:String = "invoice";

		public var title:String = "Sent a invoice";
		public var status:int = InvoiceStatus.NEW;
		
		public var showCancel:Boolean = true;
	
		public var forwardedFromUserID:String;
		public var forwardedFromUserName:String;
		public var forwardedMessageDate:String;
		private var _forwardedMessageDateParsed:Date;
		
		public  function getData():Object {
			return DateUtils.getObjectVariableByClass(this);
		}
		
		/*!TODO dummy methods, remove later*/
		public function set forwardedFromChatID(value:String):void{}
		public function set forwardedFromMessageID(value:int):void{}
		public function set toUserID(value:String):void{}
		public function set fromUserID(value:String):void{}
		
		public function equal(value:ChatMessageInvoiceData):Boolean 
		{
			if (!value)
			{
				return false;
			}
			
			var valueObj:Object = DateUtils.getObjectVariableByClass(value);
			for (var key:String in valueObj)
			{
				if (this[key] != valueObj[key])
				{
					return false;
				}
			}
			return true;
		}
		
		public function toJsonString():String
		{
			var res:String = Config.BOUNDS + JSON.stringify(this);
			return res;
		}
		
		public static function createFromObject(object:Object):ChatMessageInvoiceData
		{
			var res:ChatMessageInvoiceData = new ChatMessageInvoiceData();
			
			res.forwardedFromUserID = object.forwardedFromUserID;
			res.forwardedFromUserName = object.forwardedFromUserName;
			res.forwardedMessageDate = object.forwardedMessageDate;
			
			res.amount = object.amount
			res.currency = object.currency;
			res.fromUserName = object.fromUserName;
			res.fromUserUID = object.fromUserUID;
			res.id = object.id;
			res.message = object.message;
			res.phone = object.phone;
			res.status = object.status;
			res.toUserName = object.toUserName;
			res.toUserUID = object.toUserUID;
			res.title = Lang.sendAInvoice;
			res.showCancel = object.showCancel;
			
			return res;
		}
		
		public static function createFromString(jsonString:String):ChatMessageInvoiceData
		{
			var o:Object = JSON.parse(jsonString);
			var res:ChatMessageInvoiceData = createFromObject(o);
			return res;
		}
			
		public static function create(amount:Number,currency:String,message:String,fromUserName:String,fromUserID:String,toUserName:String,toUserID:String,phone:String,status:int,forwardedFromUserID:String=null,forwardedFromUserName:String = null, forwardedMessageDate:String = null, showCancel:Boolean = true):ChatMessageInvoiceData {
			var res:ChatMessageInvoiceData = new ChatMessageInvoiceData();
			
			res.forwardedFromUserID = forwardedFromUserID;
			res.forwardedFromUserName = forwardedFromUserName;
			res.forwardedMessageDate = forwardedMessageDate;
			
			res.amount = amount;
			res.currency = currency;
			res.fromUserName = fromUserName;
			res.fromUserUID = fromUserID;
			res.toUserUID = toUserID;
			res.message = message;
			res.phone = phone;
			res.status = status;
			res.toUserName = toUserName;
			res.showCancel = showCancel;
			
			res.title = Lang.sendAInvoice;
			
			return res;
		}
		
		public function getForwardedMessageDate():Date {
			if (_forwardedMessageDateParsed == null)
				_forwardedMessageDateParsed = DateUtils.fromString(forwardedMessageDate);
			else
				_forwardedMessageDateParsed = new Date();
			return _forwardedMessageDateParsed;
		}
	}
}