package com.dukascopy.connect.vo.chat 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.callManager.CallManager;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CallMessageVO 
	{
		private var type:String;
		public var caller:String;
		public var callerName:String;
		public var callerAvatar:String;
		public var calle:String;
		public var calleName:String;
		public var calleAvatar:String;
		public var vidid:Boolean;
		static public const VIDID_CALL:String = "vididCall";
		static public const VIDID_START:String = "vididStart";
		static public const VIDID_FAIL:String = "vididFail";
		static public const VIDID_COMLETE:String = "vididComlete";
		public var vididType:String;
		
		public function CallMessageVO(rawData:Object = null) {
			if (rawData != null) {
				parse(rawData);
			}
		}
		
		public function get textSmall():String 
		{
			return Lang.textCall;
		}
		
		public function getText():String 
		{
			if (vidid == true)
			{
				if (vididType == VIDID_CALL)
				{
					return Lang.callFromVidid;
				}
				else if (vididType == VIDID_START)
				{
					return Lang.videoidentificationStart;
				}
				else if (vididType == VIDID_FAIL)
				{
					return Lang.videoidentificationFail;
				}
				else if (vididType == VIDID_COMLETE)
				{
					return Lang.videoidentificationComplete;
				}
			}
			
			var userName:String;
			var text:String;
			if (caller == Auth.uid)
			{
				if (type == CallManager.STATUS_CANCELED_BY_SELF || type == CallManager.STATUS_BUSY || type == CallManager.STATUS_REJECTED)
				{
					text = Lang.userDidnotAnswer;
				}
				else if (type == CallManager.STATUS_PLACED)
				{
					text = Lang.youCalledUser;
				}
				else
				{
					text = Lang.youCalledUser;
				}
				
				userName = calleName;
			}
			else
			{
				if (type == CallManager.STATUS_CANCELED_BY_SELF || type == CallManager.STATUS_BUSY || type == CallManager.STATUS_REJECTED)
				{
					text = Lang.youMessedCall;
				}
				else if (type == CallManager.STATUS_PLACED)
				{
					text = Lang.userCalledYou;
				}
				else
				{
					text = Lang.userCalledYou;
				}
				
				userName = callerName;
			}
			
			text = text.replace(Lang.regExtValue, userName);
			return text;
		}
		
		public function getColor(currentBackColor:Number):Number 
		{
			if (vidid)
			{
				if (vididType == VIDID_START)
				{
					return Color.BLUE_DARK;
				}
				else if (vididType == VIDID_FAIL)
				{
					return Color.RED_DARK;
				}
				else if (vididType == VIDID_COMLETE)
				{
					return Color.GREEN_DARK;
				}
			}
			return currentBackColor;
		}
		
		public function get avatarForChat():String
		{
			if (caller == Auth.uid)
			{
				return calleAvatar;
			}
			else
			{
				return callerAvatar;
			}
		}
		
		private function parse(rawData:Object):void {
			if (rawData != null) {
				
				if ("type" in rawData && rawData.type != null) {
					type = rawData.type;
				}
				if ("caller" in rawData && rawData.caller != null) {
					caller = rawData.caller;
				}
				if ("callerName" in rawData && rawData.callerName != null) {
					callerName = rawData.callerName;
				}
				if ("callerAvatar" in rawData && rawData.callerAvatar != null) {
					callerAvatar = rawData.callerAvatar;
				}
				if ("calle" in rawData && rawData.calle != null) {
					calle = rawData.calle;
				}
				if ("calleName" in rawData && rawData.calleName != null) {
					calleName = rawData.calleName;
				}
				if ("calleAvatar" in rawData && rawData.calleAvatar != null) {
					calleAvatar = rawData.calleAvatar;
				}
			}
		}
	}
}