package com.dukascopy.connect.gui.chat 
{
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CircleAvatar extends Sprite
	{
		private var _isDisposed:Boolean;
		private var avatarSize:int;
		private var avatarBD:ImageBitmapData;
		private var secret:Boolean;
		private var user:UserVO;
		private var jailClip:Sprite;
		private var animate:Boolean;
		private var showJail:Boolean;
		private var extensions:Vector.<Bitmap>;
		
		protected var missDCIcon:Sprite;
		protected var ratingIcon:MovieClip;
		protected var toadIcon:Sprite;
		
		public function CircleAvatar(animate:Boolean = false) {
			this.animate = animate;
			if (animate == true){
				alpha = 0;
			}
		}
		
		public function setData(user:UserVO, avatarSize:int, secret:Boolean = false, showJail:Boolean = true, customLink:String = null):void {
			this.user = user;
			this.secret = secret;
			this.avatarSize = avatarSize;
			this.showJail = showJail;
			var avatar:ImageBitmapData;
			if (secret == true) {
				avatar = LocalAvatars.getAvatar(LocalAvatars.SECRET, avatarSize * 2);
				avatar.isAsset = true;
				onAvatarLoaded("", avatar, true);
			}
			else
			{
				var path:String;
				if (customLink == null && user != null)
				{
					path = user.getAvatarURL();
				}
				else{
					path = customLink;
				}
				
				avatar = ImageManager.getImageFromCache(path);
				if (avatar != null){
					avatar.incUseCount("CircleAvatar");
				}
				if (avatar == null) {
					if (user != null)
					{
						avatar = ImageManager.getImageFromCache(user.avatarURL);
						if (avatar != null)
						{
							animate = false;
							onAvatarLoaded(user.avatarURL, avatar, true);
						}
					}
					
					ImageManager.loadImage(path, onAvatarLoaded);
				}
				else {
					animate = false;
					onAvatarLoaded(path, avatar, true);
				}
			}
			
			checkElements();
			checkExtensions();
		}
		
		private function checkElements():void 
		{
			var scale:Number = avatarSize * 2 / 100;
			
			if (user == null)
			{
				return;
			}
			
			
			if (UsersManager.checkForToad(user.uid) == true)
			{
				toadIcon = new SWFFrog();
				toadIcon.scaleX = toadIcon.scaleY = scale;
				toadIcon.x = avatarSize;
				toadIcon.y = avatarSize;
				toadIcon.mouseEnabled = false;
				addChild(toadIcon);
			}
			else if (user != null && user.missDC == true)
			{
				missDCIcon = new SWFCrownIcon();
				missDCIcon.scaleX = missDCIcon.scaleY = scale;
				missDCIcon.x = avatarSize;
				missDCIcon.y = avatarSize;
				missDCIcon.mouseEnabled = false;
				addChild(missDCIcon);
			}
			
			if (user != null && "payRating" in user && user.payRating != 0)
			{
				ratingIcon = new SWFRatingStars_mc();
				ratingIcon.scaleX = ratingIcon.scaleY = scale;
				ratingIcon.x = avatarSize;
				ratingIcon.y = avatarSize;
				addChild(ratingIcon);
				ratingIcon.gotoAndStop(user.payRating);
				ratingIcon.mouseEnabled = false;
			}
		}
		
		private function checkExtensions():void 
		{
			if (user != null && user.gifts != null && !user.gifts.empty())
			{
				extensions = new Vector.<Bitmap>();
				var l:int = user.gifts.length;
				var item:Bitmap;
				var sourceClass:Class;
				var source:Sprite;
				var itemSize:int = avatarSize * 1.3;
				
				
				
			//	for (var i:int = 0; i < l; i++) 
			//	{
					sourceClass = user.gifts.items[l - 1].getImage();
					if (sourceClass != null)
					{
						source = new sourceClass() as Sprite;
						UI.scaleToFit(source, itemSize, itemSize);
						
						item = new Bitmap();
						item.bitmapData = UI.getSnapshot(source, StageQuality.HIGH, "CircleAvatar.extension");
						
						addChild(item);
						item.x = avatarSize * 2.2 - item.width;
						item.y = avatarSize * 2.1 - item.height;
						
						extensions.push(item);
						
						//!TODO:;
					//	break;
					}
			//	}
			}
		}
		
		public function update():void {
			if (user != null && user.ban911VO != null) {
				addJail();
			}
			else {
				removeJail();
			}
		}
		
		private function removeJail():void {
			if (jailClip != null) {
				removeChild(jailClip);
				UI.destroy(jailClip);
				jailClip = null;
			}
		}
		
		private function onAvatarLoaded(url:String, bmd:ImageBitmapData, success:Boolean):void {
			if (_isDisposed == true)
				return;
			if (success == true) {
				if (avatarBD == bmd)
					return;
				avatarBD = bmd;
				if (avatarBD == null)
					return;
			}
			else {
				avatarBD = UI.getEmptyAvatarBitmapData(avatarSize * 2, avatarSize * 2);
			}
			graphics.clear();
			ImageManager.drawGraphicCircleImage(graphics, avatarSize, avatarSize, avatarSize, avatarBD, ImageManager.SCALE_INNER_PROP);
			
			if (animate == true){
				TweenMax.to(this, 0.5, { alpha:1, delay:1 } );
			}
			else
			{
				alpha = 1;
			}
			
			if (user != null && user.ban911VO != null) {
				addJail();
			}
		}
		
		private function addJail():void {
			if (!showJail)
				return;
			
			if (jailClip == null) {
				jailClip = new (Style.icon(Style.ICON_JAILED));
				UI.colorize(jailClip, Style.color(Style.COLOR_BACKGROUND));
				addChild(jailClip);
			}
			
			UI.scaleToFit(jailClip, Math.ceil(avatarSize * 2), Math.ceil(avatarSize * 2));
			jailClip.x = avatarSize;
			jailClip.y = avatarSize;
		}
		
		public function dispose():void {
			TweenMax.killTweensOf(this);
			user = null;
			_isDisposed = true;
			if (avatarBD != null) {
				avatarBD.dispose();
				avatarBD = null;
			}
			if (jailClip != null) {
				UI.destroy(jailClip);
				jailClip = null;
			}
			if (missDCIcon != null) {
				UI.destroy(missDCIcon);
				missDCIcon = null;
			}
			if (ratingIcon != null) {
				UI.destroy(ratingIcon);
				ratingIcon = null;
			}
			if (toadIcon != null) {
				UI.destroy(toadIcon);
				toadIcon = null;
			}
			
			if (extensions != null)
			{
				var l:int = extensions.length;
				for (var i:int = 0; i < l; i++) 
				{
					UI.destroy(extensions[i]);
				}
				extensions = null;
			}
			
			graphics.clear();
		}
	}
}