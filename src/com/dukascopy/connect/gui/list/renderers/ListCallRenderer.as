package com.dukascopy.connect.gui.list.renderers {
	
	import assets.ChatIconGrey;
	import assets.IncomingCallIcon;
	import assets.MissedCallIcon;
	import assets.OutgoingCallIcon;
	import assets.PhoneIconGrey;
	import assets.SupportAvatar;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.CallHistoryType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.CallsHistoryItemVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.connect.vo.users.adds.PhonebookUserVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ListCallRenderer extends BaseRenderer implements IListRenderer {
		
		private var phoneButton:Bitmap;
		private var missedClip:Bitmap;
		private var incomingClip:Bitmap;
		private var outgoingClip:Bitmap;
		private var chatButton:Bitmap;
		private var avatarSupport:Bitmap;
		private var avatarWithLetter:Sprite;
		private var avatarLettertext:TextField;
		protected var avatarSize:int;
		protected var format1:TextFormat = new TextFormat();
		protected var format2:TextFormat = new TextFormat();
		
		protected var titleTextField:TextField;
		protected var callTimeTextField:TextField;
		protected var avatar:Shape;
		protected var avatarEmpty:Bitmap;
		protected var bg:Shape;
		protected var bgHighlight:Shape;
		
		protected var fxnmeY:int;
		protected var onlineMark:Sprite;
		
		public function ListCallRenderer() {
			initTextFormats();
				bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, 0, 10, 10);
				bg.graphics.endFill();
			addChild(bg);
				bgHighlight = new Shape();
				bgHighlight.graphics.beginFill(Style.color(Style.COLOR_LIST_SELECTED), 1);
				bgHighlight.graphics.drawRect(0, 0, 10, 10);
				bgHighlight.graphics.endFill();
				bgHighlight.visible = false;
			addChild(bgHighlight);
				avatarSize = Config.FINGER_SIZE * .39;
				avatarEmpty = new Bitmap();
				avatarEmpty.bitmapData =  UI.drawAssetToRoundRect(new SWFEmptyAvatar(), avatarSize*2);				
				avatarEmpty.x = int(Config.MARGIN * 1.58);
			addChild(avatarEmpty);
				avatar = new Shape();
				avatar.x = avatarEmpty.x;
			addChild(avatar);
			
			avatarSupport = new Bitmap();
			avatarSupport.bitmapData = UI.drawAssetToRoundRect(new SWFSupportAvatar(), avatarSize * 2);
			avatarSupport.x = int(Config.MARGIN * 1.58);
			addChild(avatarSupport);
		
			
			avatarWithLetter = new Sprite();
			avatarLettertext = new TextField();
			avatarWithLetter.addChild(avatarLettertext);
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.color = MainColors.WHITE;
			textFormat.size = Config.FINGER_SIZE*.5;
			textFormat.align = TextFormatAlign.CENTER;
			avatarLettertext.defaultTextFormat = textFormat;
			avatarLettertext.selectable = false;
			avatarLettertext.width = avatarSize * 2;
			avatarLettertext.multiline = false;
			avatarLettertext.text = "A";
			avatarLettertext.height = avatarLettertext.textHeight + 4;
			avatarLettertext.y = int(avatarSize - (avatarLettertext.textHeight + 4) * .5);
			avatarLettertext.text = "";
			avatarWithLetter.graphics.beginFill(AppTheme.GREY_MEDIUM);
			avatarWithLetter.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
			avatarWithLetter.graphics.endFill();
			addChild(avatarWithLetter);
			avatarWithLetter.visible = false;
			avatarWithLetter.x = avatarSupport.x;
			
				titleTextField = new TextField();
				format1.size = Config.FINGER_SIZE * .3;
				titleTextField.defaultTextFormat = format1;
				titleTextField.text = "Pp";
				titleTextField.height = titleTextField.textHeight + 4;
				titleTextField.text = "";
				titleTextField.x = int(avatar.x + avatarSize * 2 + Config.MARGIN * 1.58);
				titleTextField.wordWrap = false;
				titleTextField.multiline = false;
			addChild(titleTextField);
				callTimeTextField = new TextField();
				format1.size = Config.FINGER_SIZE * .24;
				callTimeTextField.defaultTextFormat = format1;
				callTimeTextField.text = "Pp";
				callTimeTextField.height = callTimeTextField.textHeight + 4;
				callTimeTextField.text = "";
				callTimeTextField.x = titleTextField.x + Config.MARGIN * 3;
				fxnmeY = Config.FINGER_SIZE * .55;
				callTimeTextField.wordWrap = false;
				callTimeTextField.multiline = false;
			addChild(callTimeTextField);
				onlineMark = new Sprite();
				onlineMark.visible = false;
			addChild(onlineMark);
			
			format2.size = Config.FINGER_SIZE * .3;
			format2.color = 0x999999;
			
			var phoneIcon:Sprite = new (Style.icon(Style.ICON_MAKE_CALL));
			UI.colorize(phoneIcon, Style.color(Style.ICON_COLOR));
			UI.scaleToFit(phoneIcon, int(Config.FINGER_SIZE * 0.37), int(Config.FINGER_SIZE * 0.37));
			phoneButton = new Bitmap();
			phoneButton.bitmapData = UI.getSnapshot(phoneIcon, StageQuality.HIGH, "ListCallRenderer.phoneButton");
			addChild(phoneButton);
			UI.destroy(phoneIcon);
			phoneIcon = null;
			
			var chatIcon:ChatIconGrey = new ChatIconGrey();
			UI.colorize(chatIcon, Style.color(Style.ICON_COLOR));
			UI.scaleToFit(chatIcon, int(Config.FINGER_SIZE * 0.4), int(Config.FINGER_SIZE * 0.4));
			chatButton = new Bitmap();
			chatButton.bitmapData = UI.getSnapshot(chatIcon, StageQuality.HIGH, "ListCallRenderer.chatButton");
			addChild(chatButton);
			UI.destroy(chatIcon);
			chatIcon = null;
			
			var stateIconSize:int = Config.FINGER_SIZE * 0.25;
			
			var iconMissed:MissedCallIcon = new MissedCallIcon();
			UI.colorize(iconMissed, Style.color(Style.COLOR_SUBTITLE));
			UI.scaleToFit(iconMissed, stateIconSize, stateIconSize);
			missedClip = new Bitmap();
			missedClip.bitmapData = UI.getSnapshot(iconMissed, StageQuality.HIGH, "ListCallRenderer.missedClip");
			addChild(missedClip);
			UI.destroy(iconMissed);
			iconMissed = null;
			
			var iconIncoming:IncomingCallIcon = new IncomingCallIcon();
			UI.scaleToFit(iconIncoming, stateIconSize, stateIconSize);
			incomingClip = new Bitmap();
			UI.colorize(iconIncoming, Style.color(Style.COLOR_SUBTITLE));
			incomingClip.bitmapData = UI.getSnapshot(iconIncoming, StageQuality.HIGH, "ListCallRenderer.incomingClip");
			addChild(incomingClip);
			UI.destroy(iconIncoming);
			iconIncoming = null;
			
			var iconOutgoing:OutgoingCallIcon = new OutgoingCallIcon();
			UI.colorize(iconOutgoing, Style.color(Style.COLOR_SUBTITLE));
			UI.scaleToFit(iconOutgoing, stateIconSize, stateIconSize);
			outgoingClip = new Bitmap();
			outgoingClip.bitmapData = UI.getSnapshot(iconOutgoing, StageQuality.HIGH, "ListCallRenderer.outgoingClip");
			addChild(outgoingClip);
			UI.destroy(iconOutgoing);
			iconOutgoing = null;
			
			missedClip.x = incomingClip.x = outgoingClip.x = titleTextField.x + Config.FINGER_SIZE * .05;
		}
		
		protected function setHitZones(item:ListItem):void 
		{
			var hitZones:Array = new Array();
			
			hitZones.push( { type:HitZoneType.CALL_USER, 
								x:phoneButton.x - Config.FINGER_SIZE * .5, 
								y:phoneButton.y - Config.FINGER_SIZE * .5, 
								width:phoneButton.width + Config.FINGER_SIZE, 
								height:phoneButton.height + Config.FINGER_SIZE } );
			
			if (hitZones.length > 0)
			{
				item.setHitZones(hitZones);
			}
		}
		
		private function initTextFormats():void 
		{
			format1.font = Config.defaultFontName;
			format1.color = Style.color(Style.COLOR_TITLE);
			format2.font = Config.defaultFontName;
		}
		
		private function showOnlineMark(value:Boolean, status:String):void {
			onlineMark.visible = value;
			if (value) {
				drawOnlineStatus(status)
				onlineMark.x = int(avatar.x  + avatarSize * Math.cos(Math.PI/4) + avatarSize - onlineMark.width/2);
				onlineMark.y = int(avatar.y  + avatarSize * Math.sin(Math.PI / 4) + avatarSize - onlineMark.width / 2);
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
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(item:ListItem, width:int):int {
			if (getItemData(item.data) is CallsHistoryItemVO)
				return Config.FINGER_SIZE * 1.1;
			return Config.FINGER_SIZE_DOT_5;
		}
		
		public function getView(item:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable
		{
			avatarWithLetter.visible = false;
			bg.width = width;
			bg.height = height;
			
			bgHighlight.width = width;
			bgHighlight.height = height;
			
			bg.visible = true;
			onlineMark.visible = false;
			
			var itemData:Object = getItemData(item.data);
			
			if (itemData is PhonebookUserVO || itemData is ContactVO)
			{
				avatar.visible = true;
				avatarEmpty.visible = true;
				titleTextField.visible = true;
				callTimeTextField.autoSize = TextFieldAutoSize.LEFT;
			}
			else if (itemData is CallsHistoryItemVO)
			{
				avatar.visible = true;
				avatarEmpty.visible = true;
				titleTextField.visible = true;
				callTimeTextField.visible = false;
				
				if ((itemData as CallsHistoryItemVO).pid > 0)
				{
					phoneButton.visible = false;
					chatButton.visible = true;
				}
				else {
					phoneButton.visible = true;
					chatButton.visible = false;
				}
			}
			
			phoneButton.x = int(width - phoneButton.width - Config.MARGIN * 2);
			phoneButton.y = int(height * .5 - phoneButton.height * .5);
			
			chatButton.x = int(width - chatButton.width - Config.MARGIN * 2);
			chatButton.y = int(height * .5 - chatButton.height * .5);
			
			avatarEmpty.y = int((height - avatarSize * 2) * .5);
			avatarSupport.y = int((height - avatarSize*2)*.5);
			avatarWithLetter.y = avatar.y = avatarEmpty.y;
			
			if (highlight == true)
				bg.visible = false;
			bgHighlight.visible = highlight;
			
			if (itemData is CallsHistoryItemVO)
				item.addImageFieldForLoading("avatarURL");
			
			avatar.visible = false;
			avatarEmpty.visible = false;
			
			avatarSupport.visible = false;
			
			var avatarImage:ImageBitmapData = item.getLoadedImage("avatarURL");
			if (avatarImage != null && avatarImage.isDisposed == false)
			{
				avatar.visible = true;
				avatar.graphics.clear();
				ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarImage, ImageManager.SCALE_PORPORTIONAL);
			}
			else
			{
				if (itemData is CallsHistoryItemVO)
				{
					if ((itemData as CallsHistoryItemVO).pid > 0)
					{
						avatarEmpty.visible = false;
						avatar.visible = false;
						avatar.graphics.clear();
						avatarSupport.visible = true;
					}
					else
					{
						avatar.visible = false;
						avatarEmpty.visible = true;
						
						
						if ("title" in itemData && itemData.title != null && String(itemData.title).length > 0 && AppTheme.isLetterSupported(String(itemData.title).charAt(0)) )
						{
							avatarLettertext.text = String(itemData.title).charAt(0).toUpperCase();
							
							//avatarWithLetter.graphics.clear();
							//avatarWithLetter.graphics.beginFill(AppTheme.getColorFromPallete(String(itemData.title)));
							//avatarWithLetter.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
							//avatarWithLetter.graphics.endFill();
							UI.drawElipseSquare(avatarWithLetter.graphics, avatarSize*2,avatarSize,AppTheme.getColorFromPallete(String(itemData.title)));
						
							avatarEmpty.visible = false;
							avatarWithLetter.visible = true;
							avatar.visible = false;
						}
						else {
							avatar.visible = false;
							avatarEmpty.visible = true;
						}
					}
				}
				else
				{
					//!TODO: ?;
				//	avatar.visible = false;
				//	avatarEmpty.visible = true;
				}
			}
			
			var newWidth:int = width - titleTextField.x - Config.MARGIN;
			
			titleTextField.width = newWidth;
			titleTextField.text = itemData.title;
			
			callTimeTextField.visible = false;
			
			if (itemData is CallsHistoryItemVO)
			{
				checkOnlineStatus((itemData as CallsHistoryItemVO).userUID);
				
				callTimeTextField.visible = true;
				callTimeTextField.width = newWidth;
				
				callTimeTextField.htmlText = getStatusText((itemData as CallsHistoryItemVO).type, (itemData as CallsHistoryItemVO).sTime, (itemData as CallsHistoryItemVO).state);
				titleTextField.y = int((height - (titleTextField.height + callTimeTextField.height)) * .5);
				callTimeTextField.y = int(titleTextField.y + titleTextField.height);
				
				updateCallStatusIcon((itemData as CallsHistoryItemVO).type);
			}
			
			var titleWidth:Number = phoneButton.x - titleTextField.x - Config.MARGIN;
			callTimeTextField.width = titleWidth - Config.MARGIN * 3;
			
			titleTextField.autoSize = TextFieldAutoSize.NONE;
			titleTextField.width = titleWidth;
			TextUtils.truncate(titleTextField);
			
			setHitZones(item);
			
			return this;
		}
		
		private function getStatusText(type:Boolean, timestamp:Number, status:String):String {
			var text:String = "";
			if (type == CallHistoryType.INCOMING) {
				if (status != "missed")
					text += "<font color=\u0022#" + Style.color(Style.COLOR_SUBTITLE).toString(16) + "\u0022>" + Lang.textIncoming + "</font>";
				else
					text += "<font color=\u0022#" + AppTheme.RED_MEDIUM.toString(16) + "\u0022>" + Lang.missedCall + "</font>";
			} else if (type == CallHistoryType.OUTGOING) {
				if (status != "missed")
					text += "<font color=\u0022#" + Style.color(Style.COLOR_SUBTITLE).toString(16) + "\u0022>" + Lang.textOutgoing + "</font>";
				else
					text += "<font color=\u0022#" + AppTheme.RED_MEDIUM.toString(16) + "\u0022>" + Lang.unansweredCall + "</font>";
			}
			var date:Date = new Date(Number(timestamp * 1000));
			text += " " + "<font color=\u0022#" + Style.color(Style.COLOR_SUBTITLE).toString(16) + "\u0022>" + DateUtils.getComfortDateRepresentationWithMinutes(date) + "</font>";
			return text;
		}
		
		private function updateCallStatusIcon(callType:Boolean):void 
		{
			missedClip.y = callTimeTextField.y + callTimeTextField.height * .5 - missedClip.height * .5;
			incomingClip.y = callTimeTextField.y + callTimeTextField.height * .5 - incomingClip.height * .5;
			outgoingClip.y = callTimeTextField.y + callTimeTextField.height * .5 - outgoingClip.height * .5;
			
			missedClip.visible = false;
			incomingClip.visible = false;
			outgoingClip.visible = false;
			
			if (callType == CallHistoryType.INCOMING)
				incomingClip.visible = true;
			else if (callType == CallHistoryType.OUTGOING)
				outgoingClip.visible = true;
		}
		
		//to override;
		protected function getItemData(itemData:Object):Object 
		{
			return itemData;
		}
		
		protected function checkOnlineStatus(uid:String):void {
			var onlineStatus:OnlineStatus = UsersManager.isOnline(uid);
			if (onlineStatus != null)
				showOnlineMark(onlineStatus.online, onlineStatus.status);
		}
		
		public function dispose():void {
			if (phoneButton != null)
				UI.destroy(phoneButton);
			phoneButton = null;
			
			if (missedClip != null)
				UI.destroy(missedClip);
			missedClip = null;
			
			if (incomingClip != null)
				UI.destroy(incomingClip);
			incomingClip = null;
			
			if (outgoingClip != null)
				UI.destroy(outgoingClip);
			outgoingClip = null;
			
			if (chatButton)
			{
				UI.destroy(chatButton);
				chatButton = null;
			}
			
			if (avatarLettertext) {
				avatarLettertext.text = "";
				avatarLettertext = null;
			}
			
			if (avatarWithLetter)
			{
				UI.destroy(avatarWithLetter);
				avatarWithLetter = null;
			}
			
			format1 = null;
			format2 = null;
			
			graphics.clear();
			if (titleTextField != null)
				titleTextField.text = "";
			titleTextField = null;
			if (callTimeTextField != null)
				callTimeTextField.text = "";
			callTimeTextField = null;
			if (avatar != null)
				avatar.graphics.clear();
			UI.destroy(avatar);
			UI.destroy(bgHighlight);
			avatar = null;
			if (avatarEmpty != null)
				UI.destroy(avatarEmpty);
			avatarEmpty = null;
			if (bg != null)
				bg.graphics.clear();
			UI.destroy(bg);
			bg = null;
			
			if (onlineMark != null)
				onlineMark.graphics.clear();
			UI.destroy(onlineMark);
			onlineMark = null;
			
			if (avatarSupport)
			{
				UI.destroy(avatarSupport);
				avatarSupport = null;
			}
			
			if (parent)
			{
				parent.removeChild(this);
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}