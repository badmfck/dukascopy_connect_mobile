package com.dukascopy.connect.gui.components
{
	import assets.NextArrowIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.paidBan.PaidBanReasons;
	import com.dukascopy.connect.gui.chat.CircleAvatar;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.tapper.TapperInstance;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class BanStatusClip extends Sprite
	{
		private var background:Sprite;
		private var titleClip:Bitmap;
		private var subtitleClip:Bitmap;
		private var maskClip:Sprite;
		private var contentClip:Sprite;
		
		private var itemWidth:int = -1;
		private var itemHeight:int = -1;
		private var showTime:Number = 1.5;
		private var animationTime:Number = 0.5;
		private var constructed:Boolean;
		private var avatar:CircleAvatar;
		private var iconNext:NextArrowIcon;
		private var data:UserBan911VO;
		private var tapper:TapperInstance;
		
		public static var avatarSize:int;
		
		public function BanStatusClip()
		{
			
		}
		
		private function construct():void {
			constructed = true;
			
			avatarSize = Config.FINGER_SIZE*.4;
			
			contentClip = new Sprite();
			addChild(contentClip);
			
			maskClip = new Sprite();
			maskClip.graphics.beginFill(AppTheme.GREY_DARK);
			maskClip.graphics.drawRect(0, 0, 10, 10);
			maskClip.graphics.endFill();
			addChild(maskClip);
			
			background = new Sprite();
			background.graphics.beginFill(0x6E92AF);
			background.graphics.drawRect(0, 0, 10, 10);
			background.graphics.endFill();
			contentClip.addChild(background);
			
			titleClip = new Bitmap();
			contentClip.addChild(titleClip);
			
			subtitleClip = new Bitmap();
			contentClip.addChild(subtitleClip);
			
			avatar = new CircleAvatar();
			contentClip.addChild(avatar);
			
			contentClip.mask = maskClip;
			
			visible = false;
			
			avatar.x = int(Config.FINGER_SIZE * .23);
			
			iconNext = new NextArrowIcon();
			contentClip.addChild(iconNext);
			UI.scaleToFit(iconNext, Config.FINGER_SIZE * .34, Config.FINGER_SIZE * .34);
			iconNext.alpha = 0.5;
		}
		
		public function destroy():void {
			if (contentClip != null) {
				TweenMax.killTweensOf(contentClip);
			}
			
			UI.destroy(background);
			background = null;
			
			UI.destroy(titleClip);
			titleClip = null;
			
			UI.destroy(contentClip);
			contentClip = null;
			
			UI.destroy(maskClip);
			maskClip = null;
		}
		
		public function show(value:UserBan911VO):void {
			this.data = value;
			if (constructed == false) {
				construct();
			}
			visible = true;
			avatar.setData(value.user, avatarSize, false, false);
			
			var bannedText:String;
			if (value.days == 1) {
				bannedText = Lang.bannedForDays_1;
			}
			else if (value.days < 5) {
				bannedText = Lang.bannedForDays_2_4;
			}
			else {
				bannedText = Lang.bannedForDays_5_7;
			}
			
			bannedText = LangManager.replace(Lang.regExtValue, bannedText, String(value.days));
			
			var titleText:String = "<font color='#FFFFFF' size='" + Config.FINGER_SIZE * 0.28 + "'>" + value.user.getDisplayName() + " </font><font color='#C5D3DF' size='" + Config.FINGER_SIZE * 0.28 + "'>" + bannedText + "</font>";
			setTitle(titleText);
			setSubtitle('"' + PaidBanReasons.getReason(value.reason) + '"');
			
			var vPadding:int = Config.FINGER_SIZE * .08;
			titleClip.y = int(itemHeight * .5 - (titleClip.height + subtitleClip.height + vPadding) * .5);
			subtitleClip.y = int(titleClip.y + titleClip.height + vPadding);
			animateShow();
			
			PointerManager.addTap(this, opemProfile);
		}
		
		private function opemProfile(e:Event = null):void {
			if (data != null && data.user != null && data.user.getDisplayName() != null && data.user.uid != Auth.uid) {
				MobileGui.changeMainScreen(UserProfileScreen, {data: data.user, 
																backScreen:MobileGui.centerScreen.currentScreenClass, 
																backScreenData:data});
			}
		}
		
		private function animateShow():void {
			TweenMax.to(contentClip, animationTime, { y: -itemHeight, onComplete:onShown } );
		}
		
		private function onShown():void {
		//	tapper = new TapperInstance(MobileGui.stage, this, null, [itemWidth, itemHeight]);
		//	tapper.setSwipeCallBack(onSwipe);
		//	tapper.setBounds([itemWidth, itemHeight]);
		//	tapper.activate();
			
			TweenMax.delayedCall(3, hideAnyway);
		}
		
		private function onSwipe(speed:Number):void {
			
		}
		
		private function hideAnyway():void {
			PointerManager.removeTap(this, opemProfile);
			TweenMax.to(contentClip, animationTime, { y:0, onComplete:onHided } );
		}
		
		private function onHided():void {
			visible = false;
		}
		
		public function setSize(width:int):void {
			itemWidth = width;
			itemHeight = Config.FINGER_SIZE * 1;
			
			update();
		}
		
		public function activate():void {
			PaidBan.S_SHOW_BAN_NOTIFICATION.add(show);
		}
		
		public function deactivate():void {
			PaidBan.S_SHOW_BAN_NOTIFICATION.remove(show);
		}
		
		public function dispose():void {
			data = null;
			
			if (background != null) {
				UI.destroy(background);
				background = null;
			}
			
			if (titleClip != null) {
				UI.destroy(titleClip);
				titleClip = null;
			}
			
			if (subtitleClip != null) {
				UI.destroy(subtitleClip);
				subtitleClip = null;
			}
			
			if (maskClip != null) {
				UI.destroy(maskClip);
				maskClip = null;
			}
			
			if (contentClip != null) {
				UI.destroy(contentClip);
				contentClip = null;
			}
			
			if (iconNext != null) {
				UI.destroy(iconNext);
				iconNext = null;
			}
			
			if (avatar != null) {
				avatar.dispose();
				avatar = null;
			}
			
			if (tapper != null) {
				tapper.dispose();
				tapper = null;
			}
		}
		
		private function update():void {
			if (constructed == false) {
				construct();
			}
			if (itemWidth == -1 || itemHeight == -1) {
				return;
			}
			
			if (background != null)	{
				background.width = itemWidth;
				background.height = itemHeight;
			}
			
			if (maskClip != null) {
				maskClip.width = itemWidth;
				maskClip.height = itemHeight;
				
				maskClip.y = -itemHeight;
			}
			avatar.y = int(itemHeight * .5 - avatarSize);
			iconNext.x = int(itemWidth - iconNext.width - Config.FINGER_SIZE * .2);
			iconNext.y = int(itemHeight * .5 - iconNext.height * .5);
		}
		
		private function setTitle(value:String):void {
			if (value != null && titleClip != null)	{
				if (titleClip.bitmapData != null) {
					titleClip.bitmapData.dispose();
					titleClip.bitmapData = null;
				}
				
				titleClip.bitmapData = TextUtils.createTextFieldData(
														value, 
														itemWidth - avatarSize - Config.MARGIN*4 - Config.FINGER_SIZE*.2, 
														10, 
														false, 
														TextFormatAlign.CENTER, 
														TextFieldAutoSize.LEFT, 
														Config.FINGER_SIZE * .28, 
														false, 
														0xFFFFFF, 
														0x6E92AF, false, true);
				
				titleClip.x = int(avatar.x + avatarSize * 2 + Config.MARGIN * 1.6);
			}
		}
		
		private function setSubtitle(value:String):void {
			if (value != null && subtitleClip != null) {
				if (subtitleClip.bitmapData != null) {
					subtitleClip.bitmapData.dispose();
					subtitleClip.bitmapData = null;
				}
				
				subtitleClip.bitmapData = TextUtils.createTextFieldData(
														value, 
														itemWidth - avatarSize - Config.MARGIN*4 - Config.FINGER_SIZE*.2, 
														10, 
														false, 
														TextFormatAlign.CENTER, 
														TextFieldAutoSize.LEFT, 
														Config.FINGER_SIZE * .24, 
														false, 
														0xC5D3DF, 
														0x6E92AF, false);
				
				subtitleClip.x = int(avatar.x + avatarSize * 2 + Config.MARGIN * 1.6);
			}
		}
	}
}