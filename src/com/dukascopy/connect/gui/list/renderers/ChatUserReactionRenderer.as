package com.dukascopy.connect.gui.list.renderers {
	
	import assets.HeartFill;
	import assets.IconGroupChat;
	import assets.IconInvoice;
	import assets.IconSendFiles;
	import assets.MicGreyIcon;
	import assets.OwnerIcon;
	import assets.PlusAvatar;
	import assets.SettingsMaskIcon;
	import assets.SupportAvatar;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.megaText.MegaText;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.ColorUtils;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.chat.QuestionUserReactions;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import fl.motion.Color;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ChatUserReactionRenderer extends BaseRenderer implements IListRenderer {
		
		static protected var trueHeight:int = Config.FINGER_SIZE * 1.3;
		static protected var avatarSize:int = Config.FINGER_SIZE * .46;
		static protected var onlineStatusROut:int = avatarSize * .22;
		static protected var onlineStatusRIn:int = onlineStatusROut * .8;
		
		private var bg:Shape;
		private var bgHighlight:Shape;
		private var bgActive:Shape;
		private var avatar:Shape;
		private var avatarWithLetter:Sprite;
		private var avatarWithLetterTF:TextField;
		private var tfTitle:TextField;
		private var tfSubtitle:TextField;
		private var onlineMark:Sprite;
		
		private var format1:TextFormat = new TextFormat(Config.defaultFontName);
		private var format2:TextFormat = new TextFormat(Config.defaultFontName);
		private var format3:TextFormat = new TextFormat(Config.defaultFontName);
		private var format4:TextFormat = new TextFormat(Config.defaultFontName);
		
		private var avatarSupport:ImageBitmapData;
		private var avatarIncognito:ImageBitmapData;
		private var avatarEmpty:ImageBitmapData;
		
		private var cachedLastMessageIconSize:int = -1;
		
		private var leftTextAlignX:int;
		private var tfLikesMine:TextField;
		private var tfLikesAll:TextField;
		private var heart1:HeartFill;
		private var heart2:HeartFill;
		protected var colorGrey:Number = 0xA5AFB8;
		protected var colorRed:Number = 0xcd3f43;// 0xDA2627;
		protected var colorMine:Number = 0xcd3f43;// 0xDA2627;
		protected var colorAll:Number = 0xcd3f43;// 0xDA2627;
		
		public function ChatUserReactionRenderer() {
			initColors();
			initTextFormats();
			
				bg = new Shape();
				bg.graphics.beginFill(MainColors.WHITE);
				bg.graphics.drawRect(0, 0, 1, 1);
				bg.graphics.endFill();
			addChild(bg);
				bgHighlight = new Shape();
				bgHighlight.graphics.beginFill(Style.color(Style.COLOR_LIST_SELECTED), 1);
				bgHighlight.graphics.drawRect(0, 0, 1, 1);
				bgHighlight.graphics.endFill();
			addChild(bgHighlight);
				bgActive = new Shape();
				bgActive.graphics.beginFill(0xF4F4F4);
				bgActive.graphics.drawRect(0, 0, 1, 1);
				bgActive.graphics.endFill();
			addChild(bgActive);
			
			avatarWithLetter = new Sprite();
				avatarWithLetter.x = int(Config.MARGIN * 1.58);
			avatarWithLetterTF = new TextField();
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.color = MainColors.WHITE;
			textFormat.size = Config.FINGER_SIZE*.5;
			textFormat.align = TextFormatAlign.CENTER;
			avatarWithLetterTF.defaultTextFormat = textFormat;
			avatarWithLetterTF.selectable = false;
			avatarWithLetterTF.width = avatarSize * 2;
			avatarWithLetterTF.multiline = false;
			avatarWithLetterTF.text = "|";
			avatarWithLetterTF.height = avatarWithLetterTF.textHeight + 4;
			avatarWithLetterTF.y = int(avatarSize - (avatarWithLetterTF.textHeight + 4) * .5);
			avatarWithLetterTF.text = "";
				avatarWithLetter.addChild(avatarWithLetterTF);
			avatarWithLetter.graphics.beginFill(AppTheme.GREY_MEDIUM);
			avatarWithLetter.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
			avatarWithLetter.graphics.endFill();
				avatarWithLetter.visible = false;
			addChild(avatarWithLetter);
			
				tfTitle = new TextField();
				tfTitle.defaultTextFormat = format1;
				tfTitle.wordWrap = false;
				tfTitle.multiline = false;
				tfTitle.text = "|";
			addChild(tfTitle);
				
				tfSubtitle = new TextField();
				tfSubtitle.defaultTextFormat = format2;
				tfSubtitle.wordWrap = false;
				tfSubtitle.multiline = false;
				tfSubtitle.text = "|";
			addChild(tfSubtitle);
			avatarEmpty = UI.getEmptyAvatarBitmapData(avatarSize * 2, avatarSize * 2);
			
			var supportIcon:SupportAvatar = new SupportAvatar();
			UI.scaleToFit(supportIcon, avatarSize*2, avatarSize*2);
			avatarSupport = UI.getSnapshot(supportIcon, StageQuality.HIGH, "ListConversation.avatarSupport");
			UI.destroy(supportIcon);
			supportIcon = null;
			
			var avatarIcon:SettingsMaskIcon = new SettingsMaskIcon();
			var ct:ColorTransform = new ColorTransform();
				ct.color = 0xFFFFFF;
			avatarIcon.transform.colorTransform = ct;
			UI.scaleToFit(avatarIcon, avatarSize * 1.4, avatarSize * 1.4);
			avatarIncognito = UI.getSnapshot(avatarIcon, StageQuality.HIGH, "ListConversation.avatarIncognito");
			UI.destroy(avatarIcon);
			avatarIcon = null;
			
			avatar = new Shape();
				avatar.x = int(Config.MARGIN * 1.56);
			addChild(avatar);
			
			onlineMark = new Sprite();
				onlineMark.x = int(avatar.x  + avatarSize * Math.cos(32 * Math.PI / 180) + avatarSize - onlineStatusROut);
				onlineMark.visible = false;
			addChild(onlineMark);
			
			avatar.y = int((trueHeight - avatarSize * 2) * .5);
			avatarWithLetter.y = avatar.y;
			onlineMark.y = int(avatar.y  + avatarSize * Math.sin(32 * Math.PI / 180) + avatarSize - onlineStatusROut);
			
			leftTextAlignX = avatar.x + avatarSize * 2 + Config.MARGIN;
			
			heart1 = new HeartFill();
			heart2 = new HeartFill();
			
			var color1:Color = new Color();
			color1.color = colorAll;
			
			var color2:Color = new Color();
			color2.color = colorMine;
			
			heart1.transform.colorTransform = color1;
			heart2.transform.colorTransform = color2;
			
			UI.scaleToFit(heart1, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			UI.scaleToFit(heart2, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			
			addChild(heart1);
			addChild(heart2);
			
			
			tfLikesMine = new TextField();
				tfLikesMine.defaultTextFormat = format3;
				tfLikesMine.wordWrap = false;
				tfLikesMine.multiline = false;
				tfLikesMine.text = "|";
				tfLikesMine.height = tfLikesMine.textHeight + 4;
			addChild(tfLikesMine);
			
			tfLikesAll = new TextField();
				
				tfLikesAll.defaultTextFormat = format4;
				tfLikesAll.wordWrap = false;
				tfLikesAll.multiline = false;
				tfLikesAll.text = "|";
				tfLikesAll.height = tfLikesAll.textHeight + 4;
			addChild(tfLikesAll);
		}
		
		protected function initColors():void 
		{
			colorMine = colorRed;
			colorAll = colorGrey;
		}
		
		private function initTextFormats():void 
		{
			format1.size = Config.FINGER_SIZE * .3;
			format1.align = TextFormatAlign.LEFT;
			format1.color = 0x3F4754;
			
			format2.size = Config.FINGER_SIZE * .26;
			format2.align = TextFormatAlign.LEFT;
			format2.color = colorGrey;
			
			format3.size = Config.FINGER_SIZE * .3;
			format3.align = TextFormatAlign.LEFT;
			format3.color = colorMine;
			
			format4.size = Config.FINGER_SIZE * .3;
			format4.align = TextFormatAlign.LEFT;
			format4.color = colorAll;
		}
		
		private function drawOnlineStatus(status:String):void {
			onlineMark.graphics.clear();
			var mainColor:uint = MainColors.GREEN_LIGHT;
			if (status == OnlineStatus.STATUS_AWAY)
				mainColor = MainColors.YELLOW_LIGHT;
			if (status == OnlineStatus.STATUS_DND)
				mainColor = MainColors.RED_LIGHT;
			onlineMark.graphics.beginFill(MainColors.WHITE);
			onlineMark.graphics.drawCircle(onlineStatusROut, onlineStatusROut, onlineStatusROut);
			onlineMark.graphics.endFill();
			onlineMark.graphics.beginFill(mainColor);
			onlineMark.graphics.drawCircle(onlineStatusROut, onlineStatusROut, onlineStatusRIn);
			onlineMark.graphics.endFill();
		}
		
		// INITIALIZATION HEIGHT
		public function getHeight(data:ListItem, width:int):int {
			if (!(data.data is QuestionUserReactions))
				return Config.FINGER_SIZE_DOT_75;
			return trueHeight;
		}
		
		private function setText(reaction:QuestionUserReactions, w:int):int {
			tfLikesMine.text = reaction.mine.toString();
			tfLikesAll.text = reaction.all.toString();
			
			tfLikesMine.width = tfLikesMine.textWidth + 4;
			tfLikesAll.width = tfLikesAll.textWidth + 4;
			
			tfLikesMine.y = int(trueHeight * .5 - tfLikesMine.height * .5);
			tfLikesAll.y = int(trueHeight * .5 - tfLikesAll.height * .5);
			
			heart1.x = int(width - heart1.width - Config.DOUBLE_MARGIN);
			tfLikesAll.x = int(heart1.x - tfLikesAll.width - Config.MARGIN * .4);
			heart1.y = heart2.y = int(trueHeight * .5 - heart1.height * .5);
			
			heart2.x = int(width - Config.FINGER_SIZE * 1.7);
			tfLikesMine.x = int(heart2.x - tfLikesMine.width - Config.MARGIN * .4);
			
			var maxFieldWidth:int = heart2.x - Config.MARGIN;
			var maxTitleWidth:int = maxFieldWidth;
			tfTitle.visible = true;
			tfTitle.x = Config.DOUBLE_MARGIN * 1.5 + avatarSize * 2;
			
			var userName:String;
			if (reaction.secretMode == true) {
				userName = Lang.secretTitle;
			}
			else {
				userName = reaction.username;
			}
			
			tfTitle.text = userName;
			tfTitle.width = maxTitleWidth;
			tfTitle.height = tfTitle.textHeight + 4;
			
			tfSubtitle.x = tfTitle.x;
			tfSubtitle.text = reaction.totalMessages.toString() + " " + Lang.messages;
			tfSubtitle.width = maxTitleWidth;
			
			tfTitle.y = Config.MARGIN;
			tfSubtitle.y = Config.FINGER_SIZE*.6;
			
			return 0;
		}
		
		private function showOnlineMark(value:Boolean, status:String):void {
			drawOnlineStatus(status);
			onlineMark.visible = value;
		}
		
		public function getView(li:ListItem, h:int, w:int, highlight:Boolean = false):IBitmapDrawable {
			if (li.data == null || li.data is QuestionUserReactions == false) {
				echo("ListConversation", "getView", "Data is empty");
				if (bg != null)
					bg.visible = false;
				if (bgHighlight != null)
					bgHighlight.visible = false;
				if (tfTitle != null)
					tfTitle.visible = false;
				if (onlineMark != null)
					onlineMark.visible = false;
				if (avatarWithLetter != null)
					avatarWithLetter.visible = false;
				if (avatar != null)
					avatar.visible = false;
				return this;
			}
			
			bg.width = w;
			bg.height = h;
			
			bgHighlight.width = w;
			bgHighlight.height = h;
			
			bg.visible = false;
			bgHighlight.visible = false;
			
			var reaction:QuestionUserReactions = li.data as QuestionUserReactions;
			
			if (highlight == true)
				bgHighlight.visible = true;
			else
				bg.visible = true;
			
			setText(reaction, w);
			
			var userAvatar:Boolean;
			
			if (reaction != null && reaction.secretMode == true) {
				avatar.graphics.beginFill(AppTheme.GREY_MEDIUM);
				avatar.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
				avatar.graphics.endFill();
				ImageManager.drawGraphicImage(
					avatar.graphics,
					int(avatarSize - avatarIncognito.width * .5),
					int(avatarSize - avatarIncognito.height * .5),
					avatarIncognito.width,
					avatarIncognito.height,
					avatarIncognito,
					ImageManager.SCALE_PORPORTIONAL
				);
				avatar.visible = true;
			} else {
				var a:ImageBitmapData = li.getLoadedImage('avatar');
				if (a != null) {
					ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, a, ImageManager.SCALE_PORPORTIONAL);
					avatar.visible = true;
				} else {
					avatar.visible = false;
					if (reaction.username != null && reaction.username.length > 0 && AppTheme.isLetterSupported(reaction.username.charAt(0))) {
						avatarWithLetterTF.text = String(reaction.username).charAt(0).toUpperCase();
						avatarWithLetter.graphics.clear();
						avatarWithLetter.graphics.beginFill(AppTheme.getColorFromPallete(String(reaction.username)));
						avatarWithLetter.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
						avatarWithLetter.graphics.endFill();
						avatarWithLetter.visible = true;
					}
				}
			}
			
			return this;
		}
		
		public function dispose():void {
			graphics.clear();
			
			if (bg != null)
				bg.graphics.clear();
			bg = null;
			if (bgHighlight != null)
				bgHighlight.graphics.clear();
			bgHighlight = null;
			if (bgActive != null)
				bgActive.graphics.clear();
			bgActive = null;
			if (tfTitle != null)
				tfTitle.text = "";
			tfTitle = null;
			
			if (onlineMark != null)
				UI.destroy(onlineMark);
			onlineMark = null;
			if (avatarWithLetterTF)
				avatarWithLetterTF.text = "";
			avatarWithLetterTF = null;
			if (avatarWithLetter)
				UI.destroy(avatarWithLetter);
			avatarWithLetter = null;
			if (avatar != null)
				UI.destroy(avatar);
			avatar = null;
			if (avatarSupport != null)
				avatarSupport.dispose();
			avatarSupport = null;
			if (avatarIncognito != null)
				avatarIncognito.dispose();
			avatarIncognito = null;
			if (avatarEmpty != null)
				avatarEmpty.dispose();
			avatarEmpty = null;
			if (tfLikesAll != null)
				UI.destroy(tfLikesAll);
			tfLikesAll = null;
			if (tfLikesMine != null)
				UI.destroy(tfLikesMine);
			tfLikesMine = null;
			
			format1 = null;
			format2 = null;
			
			if (parent != null)
				parent.removeChild(this);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		
		public function get isTransparent():Boolean {
			return false;
		}
	}
}