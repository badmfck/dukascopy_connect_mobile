package com.dukascopy.connect.vo.screen {
	
	import com.dukascopy.connect.data.ChatSettingsModel;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.chat.ChatMessageInvoiceData;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ChatScreenData extends ScreenData {
		
		public var type:String;
		public var settings:ChatSettingsModel;
		public var chatUID:String;
		public var usersUIDs:Array;
		public var fxid:uint;
		public var pid:Number;
		public var question:QuestionVO;
		public var chatVO:ChatVO;
		public var unfinishedPayTask:PayTaskVO;
		public var pendingInvoice:ChatMessageInvoiceData;
		public var byPhone:Boolean;
		public var payCard:Boolean = false;
		public var escrow_ad_uid:String;
		
		public function dispose():void {
			chatVO = null;
			question = null;
			unfinishedPayTask = null;
			pid = 0;
			fxid = 0;
			usersUIDs = [];
			chatUID = "";
			settings = null;
			type = "";
			pendingInvoice = null;
			byPhone=false;
		}
	}
}