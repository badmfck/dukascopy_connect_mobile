package com.dukascopy.connect.gui.list.renderers {
	
	import assets.IconMark;
	import assets.SupportAvatar;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.button.InviteContactButton;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.uiFactory.UIFactory;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.connect.vo.DepartmentVO;
	import com.dukascopy.connect.vo.EntryPointVO;
	import com.dukascopy.connect.vo.users.adds.MemberVO;
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
//	import fonts.RobotoFont;
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class ListPhones extends Sprite implements IListRenderer
	{
		private var avatarSupport:Bitmap;
		private var avatarWithLetter:Sprite;
		private var avatarLettertext:TextField;
		protected var avatarSize:int;
		protected var format1:TextFormat = new TextFormat();
		protected var format2:TextFormat = new TextFormat();
		
		protected var nme:TextField;
		protected var fxnme:TextField;
		protected var avatar:Shape;
		protected var avatarEmpty:Shape;
		protected var bg:Shape;
		protected var bgHighlight:Shape;
		
		protected var fxnmeY:int;
		protected var iconInSystem:IconLogoCircle;
		protected var onlineMark:Sprite;
		protected var inviteButton:InviteContactButton;
		protected var alreadyInvited:BitmapButton;
		protected var tfInvited:TextField;
		
		public function ListPhones()
		{
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
			
				avatarSize = Config.FINGER_SIZE * .4;
				
				avatarEmpty = new Shape();
				ImageManager.drawGraphicCircleImage(avatarEmpty.graphics, 
													avatarSize, 
													avatarSize, 
													avatarSize, 
													UI.getEmptyAvatarBitmapData(avatarSize * 2, avatarSize * 2), 
													ImageManager.SCALE_PORPORTIONAL);
				avatarEmpty.x = int(Config.MARGIN * 1.58);
			addChild(avatarEmpty);
			
			avatarWithLetter = new Sprite();
			avatarLettertext = new TextField();
			avatarWithLetter.addChild(avatarLettertext);
		//	avatarLettertext.embedFonts = true;
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
		//	textFormat.font = (new RobotoFont()).fontName;
			textFormat.color = MainColors.WHITE;
			textFormat.size = Config.FINGER_SIZE*.36;
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
			
			avatarSupport = new Bitmap();
			//var supportIcon:SupportAvatar = new SupportAvatar();
			//UI.scaleToFit(supportIcon, avatarSize*2, avatarSize*2);
			//avatarSupport.bitmapData = UI.getSnapshot(supportIcon, StageQuality.HIGH, "ListPhones.avatarSupport");
			avatarSupport.bitmapData = UI.drawAssetToRoundRect(new SWFSupportAvatar(), avatarSize * 2);
			avatarSupport.x = int(Config.MARGIN * 1.58);
			addChild(avatarSupport);
			UI.destroy(supportIcon);
			supportIcon = null;
			
				avatar = new Shape();
				avatarWithLetter.x = avatar.x = avatarEmpty.x;
			addChild(avatar);
			
				nme = new TextField();
				format1.size = Config.FINGER_SIZE * .3;
				nme.defaultTextFormat = format1;
				nme.text = "Pp";
				nme.height = nme.textHeight + 4;
				nme.text = "";
				nme.x = int(avatar.x + avatarSize * 2 + Config.MARGIN * 1.58);
				nme.wordWrap = false;
				nme.multiline = false;
			addChild(nme);
			
				fxnme = new TextField();
				format1.size = Config.FINGER_SIZE * .24;
				fxnme.defaultTextFormat = format1;
				fxnme.text = "Pp";
				fxnme.height = fxnme.textHeight + 4;
				fxnme.text = "";
				fxnme.x = nme.x;
				fxnmeY = Config.FINGER_SIZE * .55;
				fxnme.wordWrap = false;
				fxnme.multiline = false;
			addChild(fxnme);
			
			onlineMark = new Sprite();
				onlineMark.graphics.beginFill(0xf9fbf6);
				onlineMark.graphics.drawCircle(Config.FINGER_SIZE * .46 / 4.2, Config.FINGER_SIZE * .46 / 4.2, Config.FINGER_SIZE * .46 / 4.2);
				onlineMark.graphics.endFill();
				onlineMark.graphics.beginFill(0x88c927);
				onlineMark.graphics.drawCircle(Config.FINGER_SIZE * .46/4.2, Config.FINGER_SIZE * .46/4.2, Config.FINGER_SIZE * .46/5.9);
				onlineMark.graphics.endFill();
				onlineMark.visible = false;
			addChild(onlineMark);
			
			inviteButton = new InviteContactButton(null, (Lang.textInvite + "!"));
			inviteButton.setOverflow(Config.MARGIN, Config.MARGIN, Config.MARGIN, Config.MARGIN);
			inviteButton.draw();
			inviteButton.visible = false;
			addChild(inviteButton);
			
			createAlreadyInvitedClip();
			
			iconInSystem = new IconLogoCircle();
			iconInSystem.width = Config.FINGER_SIZE * 0.28;
			iconInSystem.height = Config.FINGER_SIZE * 0.28;
			iconInSystem.visible = false;
			addChild(iconInSystem);
			
			format2.size = Config.FINGER_SIZE * .3;
			format2.color = 0x999999;
		}
		
		protected function createAlreadyInvitedClip():void 
		{
			alreadyInvited = new BitmapButton();
			addChild(alreadyInvited);
			
			var box:Sprite = new Sprite();
			var tf:TextField = UIFactory.createTextField(Config.FINGER_SIZE*.2);
			tf.textColor = MainColors.GREEN;
			box.addChild(tf);
			
			var icon:IconMark = new IconMark();
			box.addChild(icon);
			icon.x = int(Config.MARGIN*.8);
			icon.height = Config.FINGER_SIZE*.25;
			icon.scaleX = icon.scaleY;
			var mainHeight:int = Config.MARGIN * 2.8;
			icon.y = int((mainHeight - icon.height) * .5);
			
			tf.text = Lang.textInvited;
			tf.x = int(Config.MARGIN*.9 + icon.x + icon.width);
			tf.y = int((mainHeight - tf.height) * .5);
			tf.autoSize = TextFieldAutoSize.LEFT;
			var mainWidth:int = int(icon.width + tf.width + Config.MARGIN*2.5);
			
			box.graphics.clear();
			box.graphics.lineStyle(1, MainColors.GREEN, 1, true);
			box.graphics.beginFill(MainColors.WHITE, 1);
			box.graphics.drawRoundRect(0, 0, mainWidth, mainHeight - 1, Config.MARGIN*1.1, Config.MARGIN*1.1);
			box.graphics.endFill();
			
			alreadyInvited.setBitmapData(UI.getSnapshot(box, StageQuality.HIGH, "ListPhones.AlreadyInvitedBox"));
			alreadyInvited.setOverflow(Config.MARGIN, Config.MARGIN, Config.MARGIN, Config.MARGIN);
			
			UI.destroy(tf);
			UI.destroy(icon);
			UI.destroy(box);
			
			tf = null;
			box = null;
			icon = null;
		}
		
		protected function setHitZones(item:ListItem):void 
		{
			var hitZones:Array = new Array();
			var itemData:Object = getItemData(item.data);
			if (itemData is PhonebookUserVO)
			{
				if (itemData.uid == null || itemData.uid == "" || itemData.uid == "0")
				{
					if (!(itemData as PhonebookUserVO).invited)
					{
						hitZones.push( { type:HitZoneType.INVITE_BUTTON, x:inviteButton.x, y:inviteButton.y, width:inviteButton.getWidth(), height:inviteButton.getHeight() } );
					}
					else {
						hitZones.push( { type:HitZoneType.INVITE_BUTTON, x:alreadyInvited.x, y:alreadyInvited.y, width:alreadyInvited.width, height:alreadyInvited.height } );
					}
				}
			}
			
			if (hitZones.length > 0)
			{
				item.setHitZones(hitZones);
			}
		}
		
		private function initTextFormats():void 
		{
			format1.font = Config.defaultFontName;
			format2.font = Config.defaultFontName;
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
		
		private function showOnlineMark(value:Boolean, status:String):void {
			onlineMark.visible = value;
			if (value) {
				drawOnlineStatus(status);
				onlineMark.x = int(avatar.x  + avatarSize * Math.cos(Math.PI/4) + avatarSize - onlineMark.width/2);
				onlineMark.y = int(avatar.y  + avatarSize * Math.sin(Math.PI / 4) + avatarSize - onlineMark.width / 2);
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(item:ListItem, width:int):int {
			if (getItemData(item.data) is PhonebookUserVO || 
				getItemData(item.data) is ContactVO ||
				getItemData(item.data) is EntryPointVO ||
				getItemData(item.data) is MemberVO)
				return Config.FINGER_SIZE;
			return Config.FINGER_SIZE_DOT_5;
		}
		
		public function getView(item:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable
		{
			bg.width = width;
			bg.height = height;
			
			bgHighlight.width = width;
			bgHighlight.height = height;
			
			inviteButton.visible = false;
			bg.visible = true;
			alreadyInvited.visible = false;
			onlineMark.visible = false;
			avatarSupport.visible = false;
			avatarWithLetter.visible = false;
			
			var itemData:Object = getItemData(item.data);
			
			if (itemData is PhonebookUserVO || itemData is ContactVO)
			{
				avatar.visible = true;
				avatarEmpty.visible = true;
				nme.visible = true;
				fxnme.autoSize = TextFieldAutoSize.LEFT;
			}
			else if (itemData is EntryPointVO || itemData is MemberVO)
			{
				avatar.visible = true;
				avatarEmpty.visible = true;
				nme.visible = true;
				iconInSystem.visible = false;
				fxnme.visible = false;
			}
			else
			{
				iconInSystem.visible = false;
				fxnme.visible = true;
				fxnme.width = Config.MARGIN * 1.58*2;
				fxnme.autoSize = TextFieldAutoSize.LEFT;
				fxnme.text = itemData as String;
				fxnme.setTextFormat(format2);
				fxnme.y = int((height - fxnme.height) * .5);
				avatar.visible = false;
				avatarEmpty.visible = false;
				nme.visible = false;
				return this;
			}
			
			avatarEmpty.y = int((height - avatarSize*2)*.5);
			avatarWithLetter.y = avatar.y = avatarEmpty.y;
			avatarSupport.y = avatarEmpty.y;
			
			if (highlight == true)
				bg.visible = false;
			bgHighlight.visible = highlight;
			
			if (("uid" in itemData && itemData.uid != "") || itemData is EntryPointVO)
				item.addImageFieldForLoading("avatarURL");
			
			avatar.visible = false;
			avatarEmpty.visible = false;
			
			var avatarImage:ImageBitmapData = item.getLoadedImage("avatarURL");
			if (avatarImage != null && avatarImage.isDisposed == false)
			{
				avatar.visible = true;
				avatar.graphics.clear();
				ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarImage, ImageManager.SCALE_PORPORTIONAL);
			}
			else
			{
				if (itemData is EntryPointVO)
				{
					if ((itemData as EntryPointVO).avatar && (itemData as EntryPointVO).avatar != "")
					{
						
					}
					
					avatarSupport.visible = true;
				}
				else {
					if (("action" in itemData) && itemData.action != null)
					{
						var avatarIcon:Sprite = new ((itemData.action as IScreenAction).getIconClass())();
						if (avatarIcon)
						{
							UI.scaleToFit(avatarIcon, avatarSize*2, avatarSize*2);
						}
						avatar.visible = true;
						ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, UI.getSnapshot(avatarIcon, StageQuality.HIGH, "ListPhones.customActionAvatar"), ImageManager.SCALE_PORPORTIONAL);
					}
					else if ("name" in itemData && itemData.name != null && String(itemData.name).length > 0 && AppTheme.isLetterSupported(String(itemData.name).charAt(0)))
					{
						avatarLettertext.text = String(itemData.name).charAt(0).toUpperCase();
						
						avatarWithLetter.graphics.clear();
						avatarWithLetter.graphics.beginFill(AppTheme.getColorFromPallete(String(itemData.name)));
						avatarWithLetter.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
						avatarWithLetter.graphics.endFill();
						
						avatarWithLetter.visible = true;
						avatarEmpty.visible = false;
					}
					else
					{
						avatarEmpty.visible = true;
					}
				}
			}
			
			var newWidth:int = width - nme.x - Config.MARGIN;
			
			nme.width = newWidth;
			nme.text = itemData.name;
			
			nme.y = int((height - nme.height)*.5);
			
			fxnme.visible = false;
			if (itemData is PhonebookUserVO)
			{
				if ((itemData as PhonebookUserVO).uid)
				{
					checkOnlineStatus((itemData as PhonebookUserVO).uid);
				}
				
				//!TODO: old code. is it possible to have fxID in PhonebookUserVO?
				if (itemData.fxID != 0) {
					fxnme.visible = true;
					fxnme.width = newWidth;
					fxnme.textColor = MainColors.RED;
					fxnme.text = itemData.fxName;
					nme.y = int((height - (nme.height + fxnme.height)) * .5);
					fxnme.y = int(nme.y + nme.height);
				}
				
				if (itemData.uid == null || itemData.uid == "" || itemData.uid == "0")
				{
					if ((itemData as PhonebookUserVO).invited)
					{
						showInvitedMark(width, height);
					}
					else
					{
						showInviteButton(width, height);
					}
				}
			}
			else if (itemData is MemberVO){
				
				if ((itemData as MemberVO).userUID)
				{
					checkOnlineStatus((itemData as MemberVO).userUID);
				}
				
				if (itemData.name != itemData.fxName){
					fxnme.visible = true;
					fxnme.width = newWidth;
					fxnme.textColor = MainColors.RED;
					var depVO:DepartmentVO=itemData.getDepartment();
					fxnme.text = (((depVO != null)?depVO.short + ", ":"") + itemData.city).toUpperCase();
					nme.y = int((height - (nme.height + fxnme.height)) * .5);
					fxnme.y = int(nme.y + nme.height);
				}	
			}
			else if (itemData is ContactVO ) {
				if ((itemData as ContactVO).uid)
				{
					checkOnlineStatus((itemData as ContactVO).uid);
				}
				
				if (itemData.name != itemData.fxName){
					fxnme.visible = true;
					fxnme.width = newWidth;
					fxnme.textColor = MainColors.RED;
					fxnme.text = itemData.fxName;
					nme.y = int((height - (nme.height + fxnme.height)) * .5);
					fxnme.y = int(nme.y + nme.height);
				}
			}
			else if (itemData is EntryPointVO)
			{
				nme.y = int((height - (nme.height)) * .5);
			}
			
			if("uid" in itemData && itemData.uid != null && itemData.uid != "" && itemData.uid != "0")
			{
				iconInSystem.visible = true;
				iconInSystem.x = int(width - iconInSystem.width - Config.MARGIN);
				iconInSystem.y = int((height - iconInSystem.height) * .5);
				nme.textColor = MainColors.DARK_BLUE;
			}
			else
			{
				iconInSystem.visible = false;
				if (itemData is EntryPointVO)
				{
					nme.textColor = MainColors.DARK_BLUE;
				}
				else {
					nme.textColor = MainColors.GREY;
				}
			}
			
			var titleWidth:Number = width - nme.x - Config.MARGIN;
			if (inviteButton.visible)
			{
				titleWidth -= inviteButton.width + Config.MARGIN;
			}
			else if (alreadyInvited.visible)
			{
				titleWidth -= alreadyInvited.width + Config.MARGIN;
			}
			else if (iconInSystem.visible)
			{
				titleWidth -= iconInSystem.width + Config.MARGIN;
			}
			
			nme.autoSize = TextFieldAutoSize.NONE;
			nme.width = titleWidth;
			TextUtils.truncate(nme);
			
			setHitZones(item);
			
			return this;
		}
		
		protected function getItemData(itemData:Object):Object 
		{
			return itemData;
		}
		
		private function showInvitedMark(itemWidth:int, itemHeight:int):void 
		{
			alreadyInvited.visible = true;
			alreadyInvited.x = int(itemWidth - alreadyInvited.width - Config.MARGIN);
			alreadyInvited.y = int((itemHeight - alreadyInvited.height) * .5);
		}
		
		protected function showInviteButton(itemWidth:int, itemHeight:int):void 
		{
			inviteButton.visible = true;
			inviteButton.x = int(itemWidth - inviteButton.width - Config.MARGIN);
			inviteButton.y = int((itemHeight - inviteButton.height) * .5);
		}
		
		protected function checkOnlineStatus(uid:String):void {
			var onlineStatus:OnlineStatus = UsersManager.isOnline(uid);
			if (onlineStatus != null)
				showOnlineMark(onlineStatus.online, onlineStatus.status);
		}
		
		public function dispose():void {
			format1 = null;
			format2 = null;
			graphics.clear();
			if (nme != null)
				nme.text = "";
			nme = null;
			if (fxnme != null)
				fxnme.text = "";
			fxnme = null;
			if (tfInvited != null)
				tfInvited.text = "";
			tfInvited = null;
			if (avatar != null)
				avatar.graphics.clear();
			UI.destroy(avatar);
			UI.destroy(bgHighlight);
			avatar = null;
			if (avatarEmpty != null)
				avatarEmpty.graphics.clear();
			UI.destroy(avatarEmpty);
			avatarEmpty = null;
			if (bg != null)
				bg.graphics.clear();
			UI.destroy(bg);
			bg = null;
			if (avatarSupport) {
				UI.destroy(avatarSupport);
				avatarSupport = null;
			}
			if (avatarLettertext) {
				avatarLettertext.text = "";
				avatarLettertext = null;
			}
			if (avatarWithLetter) {
				UI.destroy(avatarWithLetter);
				avatarWithLetter = null;
			}
			if (alreadyInvited != null) {
				alreadyInvited.dispose();	
				UI.destroy(alreadyInvited);
			}
			alreadyInvited = null;
			if (onlineMark != null)
				onlineMark.graphics.clear();
			UI.destroy(onlineMark);
			onlineMark = null;
			if (inviteButton != null)
				inviteButton.dispose();
			inviteButton = null;
			UI.destroy(iconInSystem);
			iconInSystem = null;
			if (parent) {
				parent.removeChild(this);
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}