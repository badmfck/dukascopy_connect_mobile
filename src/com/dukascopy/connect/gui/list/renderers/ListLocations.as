package com.dukascopy.connect.gui.list.renderers {
	
	import assets.DesktopOnlineButton;
	import assets.IconOnlineStatusWeb;
	import assets.MobileOnlineButton;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.location.UserGeoposition;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.type.UserStatusType;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatUserlistModel;
	import com.dukascopy.langs.Lang;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * @author Sergey Dobarin. Telefision AG.
	 */
	
	public class ListLocations extends BaseRenderer implements IListRenderer {
		
		
		static protected var initialized:Boolean = false;
		
		protected var avatarSize:int;
		protected var avatarX:int;
		protected var avatarY:int;
		protected var onlineIndicatorOutR:int;
		protected var onlineIndicatorInR:int;
		protected var onlineIndicatorX:int;
		protected var onlineIndicatorY:int;
		protected var iconSize:int;
		protected var leftOffset:int;
		
		protected var nameEmpty:Sprite;
		protected var bg:Shape;
		protected var bgHighlight:Shape;
		protected var avatar:Shape;
		protected var avatarEmpty:Shape;
		protected var avatarWithLetter:Sprite;
		protected var avatarLettertext:TextField;
		protected var onlineMark:Shape;
		protected var nme:TextField;
		protected var statusText:TextField;
		protected var timeText:TextField;
		
		protected var textFormat1:TextFormat = new TextFormat();
		protected var textFormat2:TextFormat = new TextFormat();
		protected var textFormat3:TextFormat = new TextFormat();
		protected var textFormat4:TextFormat = new TextFormat();
		protected var textFormat5:TextFormat = new TextFormat();
		
		public function ListLocations() {
			if (initialized == false) {
				initialized = true;
				avatarSize = Config.FINGER_SIZE * .4;
				leftOffset = Config.MARGIN * 1.58;
				avatarX = leftOffset;
				avatarY = (Config.FINGER_SIZE - avatarSize * 2) * .5;
				onlineIndicatorOutR = Config.FINGER_SIZE * .11;
				onlineIndicatorInR = Config.FINGER_SIZE * .08;
				onlineIndicatorX = avatarX + avatarSize * Math.cos(Math.PI / 4) + avatarSize - onlineIndicatorOutR;
				onlineIndicatorY = avatarY + avatarSize * Math.sin(Math.PI / 4) + avatarSize - onlineIndicatorOutR;
				iconSize = Config.FINGER_SIZE * .35;
			}
			
			initTextFormats();
			
			bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, 0, 1, 1);
				bg.graphics.endFill();
			addChild(bg);
			bgHighlight = new Shape();
				bgHighlight.graphics.beginFill(Style.color(Style.COLOR_LIST_SELECTED), 1);
				bgHighlight.graphics.drawRect(0, 0, 1, 1);
				bgHighlight.graphics.endFill();
				bgHighlight.visible = false;
			addChild(bgHighlight);
			avatar = new Shape();
				avatar.x = avatarX;
				avatar.y = avatarY;
			addChild(avatar);
			avatarEmpty = new Shape();
				avatarEmpty.graphics.beginFill(0xEEEEEE);
				avatarEmpty.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
				avatarEmpty.graphics.lineStyle(Config.FINGER_SIZE * .05, 0xFFFFFF);
			//	avatarEmpty.graphics.moveTo(0, 0);
			//	avatarEmpty.graphics.lineTo(avatarEmpty.width, avatarEmpty.height);
				avatarEmpty.x = avatarX;
				avatarEmpty.y = avatarY;
			addChild(avatarEmpty);
			avatarWithLetter = new Sprite();
				//avatarWithLetter.graphics.beginFill(AppTheme.GREY_MEDIUM);
				//avatarWithLetter.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
				//avatarWithLetter.graphics.endFill();
				UI.drawElipseSquare(avatarWithLetter.graphics, avatarSize*2,avatarSize,AppTheme.GREY_MEDIUM);
				avatarWithLetter.visible = false;
				avatarWithLetter.x = avatarX;
				avatarWithLetter.y = avatarY;
				avatarLettertext = new TextField();
					avatarLettertext.defaultTextFormat = textFormat5;
					avatarLettertext.selectable = false;
					avatarLettertext.width = avatarSize * 2;
					avatarLettertext.multiline = false;
					avatarLettertext.text = "A";
					avatarLettertext.height = avatarLettertext.textHeight + 4;
					avatarLettertext.y = int(avatarSize - (avatarLettertext.textHeight + 4) * .5);
					avatarLettertext.text = "";
				avatarWithLetter.addChild(avatarLettertext);
			addChild(avatarWithLetter);
			nme = new TextField();
				nme.defaultTextFormat = textFormat4;
				nme.text = "Pp";
				nme.height = nme.textHeight + 4;
				nme.text = "";
				nme.wordWrap = false;
				nme.multiline = false;
				nme.x = leftOffset + avatarX + avatarSize * 2;
			addChild(nme);
			statusText = new TextField();
				statusText.defaultTextFormat = textFormat2;
				statusText.text = "Pp";
				statusText.height = statusText.textHeight + 4;
				statusText.text = "";
				statusText.x = nme.x;
				statusText.wordWrap = false;
				statusText.multiline = false;
			addChild(statusText);
			timeText = new TextField();
				timeText.defaultTextFormat = textFormat2;
				timeText.text = "Pp";
				timeText.height = timeText.textHeight + 4;
				timeText.text = "";
				timeText.x = nme.x;
				timeText.wordWrap = false;
				timeText.multiline = false;
			addChild(timeText);
			onlineMark = new Shape();
				onlineMark.x = onlineIndicatorX;
				onlineMark.y = onlineIndicatorY;
				onlineMark.visible = false;
			addChild(onlineMark);
			
			nameEmpty = new Sprite();
				nameEmpty.graphics.lineStyle(Config.FINGER_SIZE * .3, 0xEEEEEE);
			//	nameEmpty.graphics.moveTo(0, 0);
				nameEmpty.graphics.lineTo(Config.FINGER_SIZE*3, 0);
				nameEmpty.x = nme.x + Config.FINGER_SIZE * .15;
			addChild(nameEmpty);
		}
		
		protected function initTextFormats():void {
			textFormat1.font = Config.defaultFontName;
			textFormat1.size = Config.FINGER_SIZE * .3;
			textFormat1.color = AppTheme.GREY_MEDIUM;
			
			textFormat2.font = Config.defaultFontName;
			textFormat2.size = Config.FINGER_SIZE * .24;
			textFormat2.color = AppTheme.GREY_MEDIUM;
			
			textFormat3.font = Config.defaultFontName;
			textFormat3.size = Config.FINGER_SIZE * .26;
			textFormat3.color = AppTheme.GREY_MEDIUM;
			
			textFormat4.font = Config.defaultFontName;
			textFormat4.size = Config.FINGER_SIZE * .3;
			textFormat4.color = AppTheme.GREY_DARK;
			
			textFormat5.font = Config.defaultFontName;
			textFormat5.color = MainColors.WHITE;
			textFormat5.size = avatarSize * 1.4;
			textFormat5.align = TextFormatAlign.CENTER;
		}
		
		public function getHeight(item:ListItem, width:int):int {
			if (item.data is String)
				return Config.FINGER_SIZE_DOT_5;
			return Config.FINGER_SIZE;
		}
		
		public function getView(item:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			bg.width = width;
			bg.height = height;
			
			nameEmpty.visible = false;
			
			if (item.data is String) {
				avatar.visible = false;
				avatarEmpty.visible = false;
				avatarWithLetter.visible = false;
				nme.visible = false;
				bgHighlight.visible = false;
				onlineMark.visible = false;
				
				bg.visible = true;
				statusText.visible = true;
				
				statusText.text = item.data as String;
				statusText.setTextFormat(textFormat3);
				statusText.y = int((height - statusText.height) * .5);
				statusText.x = avatarX;
				statusText.width = width - avatarX * 2;
				
				return this;
			}
			
			bgHighlight.width = width;
			bgHighlight.height = height;
			
			bg.visible = !highlight;
			bgHighlight.visible = highlight;
			
			avatar.visible = false;
			avatarEmpty.visible = false;
			avatarWithLetter.visible = false;
			nme.visible = false;
			
			var itemData:UserGeoposition = item.data as UserGeoposition;
			
			if (itemData.userVO != null)
			{
				item.addImageFieldForLoading("avatarURL");
				var avatarImage:ImageBitmapData = item.getLoadedImage("avatarURL");
				var userNameText:String = itemData.userVO.getDisplayName();
				if (avatarImage != null && avatarImage.isDisposed == false) {
					avatar.visible = true;
					avatar.graphics.clear();
					ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarImage, ImageManager.SCALE_PORPORTIONAL);
				} else if (userNameText != null && userNameText.length > 0 && AppTheme.isLetterSupported(userNameText.charAt(0)) ) {
					avatarLettertext.text = userNameText.charAt(0).toUpperCase();
					//avatarWithLetter.graphics.clear();
					//avatarWithLetter.graphics.beginFill(AppTheme.getColorFromPallete(userNameText));
					//avatarWithLetter.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
					//avatarWithLetter.graphics.endFill();
					UI.drawElipseSquare(avatarWithLetter.graphics, avatarSize*2,avatarSize,AppTheme.getColorFromPallete(userNameText));		
					avatarWithLetter.visible = true;
				} else {
					avatarEmpty.visible = true;
				}
				nme.setTextFormat(textFormat4);
			}
			else{
				avatarEmpty.visible = true;
			}
			
			var timeValue:String = DateUtils.getComfortTimeRepresentationSmall((new Date()).getTime() - itemData.ctime * 1000);
			if (timeValue == "")
			{
				timeValue = Lang.now;
			}
			else{
				timeValue = timeValue + Lang.ago;
			}
			
			timeText.text = timeValue;
			timeText.width = timeText.textWidth + 4;
			timeText.x = width - timeText.width - Config.MARGIN;
			timeText.y = Config.MARGIN;
			statusText.setTextFormat(textFormat2);
			
			var trueWidth:int = checkOnlineStatus(itemData, width);
			nme.visible = true;
			nme.width = statusText.width = trueWidth - nme.x - Config.MARGIN;
			if (itemData.userVO != null && userNameText != null)
			{
				nme.text = userNameText;
				TextUtils.truncate(nme);
			}
			else{
				nme.text = "";
				nameEmpty.visible = true;
				nameEmpty.graphics.clear();
				nameEmpty.graphics.lineStyle(Config.FINGER_SIZE * .3, 0xEEEEEE);
				nameEmpty.graphics.moveTo(0, 0);
				nameEmpty.graphics.lineTo(Math.min(Config.FINGER_SIZE * 3, width - nameEmpty.x - timeText.width - Config.MARGIN * 3), 0);
			}
			
			nme.y = int((height - (nme.height + statusText.height)) * .5);
			nameEmpty.y = nme.y + Config.FINGER_SIZE * .15 + 4,
			statusText.x = nme.x;
			statusText.y = int(nme.y + nme.height);
			
			return this;
		}
		
		protected function setSubtitleText(data:UserGeoposition, statusOnline:Boolean):void {
			if (data.uid == Auth.uid) {
				statusText.text = "";
				return;
			}
			if (!isNaN(data.distance))
			{
				statusText.text = TextUtils.getReadableDistance(data.distance);
			}
			else{
				statusText.text = "";
			}
		}
		
		private function drawOnlineStatus(status:String):void {
			onlineMark.graphics.clear();
			var mainColor:uint = MainColors.GREEN_LIGHT;
			if (status == OnlineStatus.STATUS_AWAY)
				mainColor = MainColors.YELLOW_LIGHT;
			if (status == OnlineStatus.STATUS_DND)
				mainColor = MainColors.RED_LIGHT;
			onlineMark.graphics.beginFill(MainColors.WHITE);
			onlineMark.graphics.drawCircle(avatarSize / 4.2, avatarSize / 4.2, avatarSize / 4.2);
			onlineMark.graphics.endFill();
			onlineMark.graphics.beginFill(mainColor);
			onlineMark.graphics.drawCircle(avatarSize / 4.2, avatarSize / 4.2, avatarSize / 5.9);
			onlineMark.graphics.endFill();
		}
		
		protected function checkOnlineStatus(itemData:UserGeoposition, itemWidth:int):int {
			var onlineStatus:OnlineStatus = UsersManager.isOnline(itemData.uid);
			if (!onlineStatus) {
				setSubtitleText(itemData, "");
				onlineMark.visible = false;
				return itemWidth;
			}
			if (onlineStatus.online == true)
				drawOnlineStatus(onlineStatus.status);
			onlineMark.visible = onlineStatus.online;
			var position:int = itemWidth - Config.MARGIN * 1.58;
			
			setSubtitleText(itemData, onlineStatus.online);
			return position;
		}
		
		public function dispose():void {
			UI.destroy(bg);
			bg = null;
			UI.destroy(bgHighlight);
			bgHighlight = null;
			UI.destroy(avatar);
			avatar = null;
			UI.destroy(avatarEmpty);
			avatarEmpty = null;
			UI.destroy(avatarWithLetter);
			avatarWithLetter = null;
			UI.destroy(avatarLettertext);
			avatarLettertext = null;
			UI.destroy(onlineMark);
			onlineMark = null;
			UI.destroy(nme);
			nme = null;
			UI.destroy(statusText);
			statusText = null;
			UI.destroy(timeText);
			timeText = null;
			UI.destroy(nameEmpty);
			nameEmpty = null;
			UI.destroy(this);
			
			textFormat1 = null;
			textFormat2 = null;
			textFormat3 = null;
			textFormat4 = null;
			textFormat5 = null;
			
			initialized = false;
		}
		
		public function get isTransparent():Boolean {
			return true;
		}
	}
}