package com.dukascopy.connect.sys.usersManager.paidBan 
{
	import com.dukascopy.connect.gui.components.BanStatusClip;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.greensock.TweenMax;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PaidBanNotification 
	{
		private var currentBanData:UserBan911VO;
		private var lastShowTime:Number;
		private var newNotificationTimeout:Number = 10;
		private var avatarLoadStart:Boolean;
		private var banDataLoading:Boolean;
		
		public function PaidBanNotification() {
			UsersManager.S_USERS_FULL_DATA.add(onUsersLoaded);
			PaidBan.S_USER_BAN_UPDATED.add(onBanDataUpdated);
		}
		
		private function onBanDataUpdated(userUID:String):void {
			if (currentBanData != null && currentBanData.user_uid == userUID && currentBanData.fullData == true && banDataLoading) {
				banDataLoading = false;
				loadUserData();
			}
		}
		
		private function onUsersLoaded():void {
			if (currentBanData != null && currentBanData.user != null && currentBanData.user.getDisplayName() != null && avatarLoadStart == false && currentBanData.fullData == true) {
				loadUserAvatar();
			}
		}
		
		public function newBan(banData:UserBan911VO):void {
			if (canShowNotification()) {
				currentBanData = banData;
				loadBanData();
			}
		}
		
		private function loadBanData():void {
			banDataLoading = true;
			if (currentBanData != null) {
				if (currentBanData.fullData) {
					loadUserData();
				}
				else {
					if (currentBanData.user == null) {
						currentBanData.user = UsersManager.getUserByBanObject(currentBanData);
						currentBanData.user.incUseCounter();
					}
					PaidBan.getBanFullData(currentBanData.id);
				}
			}
			else {
				lastShowTime = NaN;
			}
		}
		
		private function loadUserData():void {
			if (currentBanData != null) {
				if (currentBanData.user == null) {
					currentBanData.user = UsersManager.getUserByBanObject(currentBanData);
				}
				if (currentBanData.user.getDisplayName() != null) {
					loadUserAvatar();
				}
			}
			else {
				lastShowTime = NaN;
			}
		}
		
		private function loadUserAvatar():void {
			if (currentBanData != null && currentBanData.user != null) {
				avatarLoadStart = true;
				
				if (currentBanData.user.getAvatarURL() != null) {
					var path:String = currentBanData.user.getAvatarURLProfile(BanStatusClip.avatarSize * 2);
				
					var avatar:ImageBitmapData = ImageManager.getImageFromCache(path);
					if (avatar != null){
						dispatchShow();
					}
					else {
						ImageManager.loadImage(path, onAvatarLoaded);
					}
				}
				else {
					dispatchShow();
				}
			}
			else {
				lastShowTime = NaN;
			}
		}
		
		private function onAvatarLoaded(url:String, bmd:ImageBitmapData, success:Boolean):void {
			dispatchShow();
		}
		
		private function dispatchShow():void {
			if (currentBanData != null) {
				PaidBan.S_SHOW_BAN_NOTIFICATION.invoke(currentBanData);
				TweenMax.killDelayedCallsTo(clearCurrent);
				TweenMax.delayedCall(newNotificationTimeout, clearCurrent);
			}
		}
		
		private function clearCurrent():void {
			currentBanData = null;
			avatarLoadStart = false;
			banDataLoading = false;
		}
		
		private function canShowNotification():Boolean {
			if (currentBanData == null) {
				return true;
			}
			return false;
		}
	}
}