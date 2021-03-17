package com.dukascopy.connect.sys.usersManager {
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class OnlineStatus {
		
		static public const STATUS_OFFLINE:String = "offline";
		static public const STATUS_ONLINE:String = "online";
		static public const STATUS_AWAY:String = "away";
		static public const STATUS_DND:String = "dnd";
		
		public var uid:String;
		public var online:Boolean;
		public var web:int;
		public var desk:int;
		public var mob:int;
		public var status:String;
		
		public var wasSend:Boolean = false;
		
		public function OnlineStatus(uid:String, online:Boolean, web:int, desk:int, mob:int, status:String = STATUS_OFFLINE) {
			this.mob = mob;
			this.desk = desk;
			this.web = web;
			this.online = online;
			this.uid = uid;
			this.status = status;
		}
	}
}