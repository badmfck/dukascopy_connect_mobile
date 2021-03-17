package com.dukascopy.connect.vo.users.adds 
{
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class UserBan911VO 
	{
		private var expired:Number;
		public var user:UserVO;
		public var incognito:Boolean = false;
		public var reason:int = -1;
		public var customResonText:String;
		public var id:Number;
		public var amount:int;
		public var canceled:Number;
		public var created:Number;
		public var days:int;
		public var payer_uid:String;
		public var status:String;
		public var updated:Number;
		public var user_uid:String;
		public var avatar:String;
		public var name:String;
		
		public var fullData:Boolean = false;
		public var payer:UserVO;
		public var payHash:String;
		public var reqID:int;
		public var payer_Name:String;
		public var payer_Avatar:String;
		
		public function UserBan911VO() {
			
		}
		
		public function dispose():void {
			
			//!TODO: очистка и заполнение;
			payer = null;
			
			if (user != null){
			//	user.dispose();
			}
		//	user = null;
		}
		
		public function update(banData:UserBan911VO):void {
			if (fullData == false && banData != null) {
				if (banData.incognito){
					incognito = banData.incognito;
				}
				if (banData.reason != 0 && banData.reason != -1) {
					reason = banData.reason;
				}
				if (banData.customResonText) {
					customResonText = banData.customResonText;
				}
				id = banData.id;
				if (banData.amount != 0) {
					amount = banData.amount;
				}
				if (!isNaN(banData.canceled)) {
					canceled = banData.canceled;
				}
				if (!isNaN(banData.created)) {
					created = banData.created;
				}
				if (banData.days != 0) {
					days = banData.days;
				}
				if (banData.payer_Name != null) {
					payer_Name = banData.payer_Name;
				}
				if (banData.payer_Avatar != null) {
					payer_Name = banData.payer_Avatar;
				}
				if (banData.payer_uid != null) {
					payer_uid = banData.payer_uid;
				}
				if (banData.status != null) {
					status = banData.status;
				}
				if (!isNaN(banData.updated)) {
					updated = banData.updated;
				}
				if (banData.user_uid != null) {
					user_uid = banData.user_uid;
				}
				fullData = banData.fullData;
				if (banData.avatar) {
					avatar = banData.avatar;
				}
				if (banData.name) {
					name = banData.name;
				}
				
				if (banData.payer != null) {
					payer = banData.payer;
				}
				
				if (incognito == true) {
					payer_Avatar = LocalAvatars.SECRET;
					payer_Name = Lang.textIncognito;
				}
			}
		}
		
		public function isExpired():Boolean {
			if (expired == 1){
				return true;
			}
			if (!isNaN(canceled)) {
				var date:Date = new Date();
				var difference:Number = canceled * 1000 - date.getTime();
				if (difference < 0) {
					expired = 1;
				}
				return difference < 0;
			}
			return false;
		}
		
		public function get avatarURL():String {
			if (user != null) {
				return user.getAvatarURL();
			}
			return null;
		}
		
		public function get payerName():String {
			if (payer != null) {
				return payer.getDisplayName();
			}
			return null;
		}
	}
}