package com.dukascopy.connect.data {
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ReferralProgramData {
		
		public var code:String = "--- ---";
		public var loaded:Boolean = false;
		public var money:Number = 0;
		public var totalCompleted:int = 0;
		public var invites:Vector.<ReferralProgramInviteData> = new Vector.<ReferralProgramInviteData>();
		public var lastLoadTime:Number = NaN;
		public var totalInvites:int;
		
		public function ReferralProgramData() { }
	}
}