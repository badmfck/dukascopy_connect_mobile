package com.dukascopy.connect.vo 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	public class InvoiceVO extends Object 
	{		
		private var _amount:Number;
		public function get amount():Number{ return _amount; }
		public function set amount(value:Number):void{ _amount = value; }
		
		private var _currency:String;
		public function get currency():String{ return _currency; }
		public function set currency(value:String):void{ _currency = value; }
		
		private var _message:String;
		public function get message():String{ return _message; }
		public function set message(value:String):void{ _message = value; }
		
		private var _id:int;
		public function get id():int{ return _id; }
		public function set id(value:int):void{ _id = value; }
		
		private var _fromUserName:String;
		public function get fromUserName():String{ return _fromUserName; }
		public function set fromUserName(value:String):void{ _fromUserName = value; }
		
		private var _fromUserUID:String;
		public function get fromUserUID():String{ return _fromUserUID; }
		public function set fromUserUID(value:String):void{ _fromUserUID = value; }
		
		private var _toUserUID:String;
		public function get toUserUID():String{ return _toUserUID; }
		public function set toUserUID(value:String):void{ _toUserUID = value; }
		
		private var _toUserName:String;
		public function get toUserName():String{ return _toUserName; }
		public function set toUserName(value:String):void{ _toUserName = value; }
		
		private var _phone:String;
		public function get phone():String{ return _phone; }
		public function set phone(value:String):void{ _phone = value; }
		
		public const type:String = ChatMessageType.INVOICE;
		
		private var _status:int;
		public function get status():int{ return _status; }
		public function set status(value:int):void{ _status = value; }
		
		private var _title:String;
		public function get title():String{ return _title; }
		public function set title(value:String):void{ _title = value; }
		
		private var _forwardedFromUserID:String;
		public function get forwardedFromUserID():String{ return _forwardedFromUserID; }
		public function set forwardedFromUserID(value:String):void{ _forwardedFromUserID = value; }
		
		private var _forwardedFromChatID:String;
		public function get forwardedFromChatID():String{ return _forwardedFromChatID; }
		public function set forwardedFromChatID(value:String):void{ _forwardedFromChatID = value; }
		
		private var _forwardedFromMessageID:int;
		public function get forwardedFromMessageID():int{ return _forwardedFromMessageID; }
		public function set forwardedFromMessageID(value:int):void{ _forwardedFromMessageID = value; }
		
		public function toJsonString():String
		{
			var res:String = Config.BOUNDS + JSON.stringify(this);
			return res;
		}
		
		
		public static function createFromObject(object:Object):InvoiceVO
		{
			var res:InvoiceVO = new InvoiceVO();
			
			res.forwardedFromChatID = object.forwardedFromChatID;
			res.forwardedFromMessageID = object.forwardedFromMessageID;
			res.forwardedFromUserID = object.forwardedFromUserID;
			
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
			return res;
		}
		
		public static function createFromString(jsonString:String):InvoiceVO
		{
			var o:Object = JSON.parse(jsonString);
			var res:InvoiceVO = createFromObject(o);
			return res;
		}
			
		public static function create(amount:Number,currency:String,message:String,id:int,fromUserName:String,fromUserID:String,toUserName:String,toUserID:String,phone:String,status:int,forwardedFromUserID:String=null,forwardedFromChatID:String=null,forwardedFromMessageID:int = -1):InvoiceVO
		{
			var res:InvoiceVO = new InvoiceVO();
			
			res.forwardedFromChatID = forwardedFromChatID;
			res.forwardedFromMessageID = forwardedFromMessageID;
			res.forwardedFromUserID = forwardedFromUserID;
			
			res.amount = amount;
			res.currency = currency;
			res.fromUserName = fromUserName;
			res.fromUserUID = fromUserID;
			res.toUserUID = toUserID;
			res.id = id;
			res.message = message;
			res.phone = phone;
			res.status = status;
			res.toUserName = toUserName;
						
			res.title = Lang.sendAInvoice;
			
			return res;
		}
	}
}