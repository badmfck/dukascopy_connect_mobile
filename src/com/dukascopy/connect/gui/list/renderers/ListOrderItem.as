package com.dukascopy.connect.gui.list.renderers {
	
	import assets.ButtonChatContent;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.megaText.MegaText;
	import com.dukascopy.connect.sys.applicationShop.Order;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.vo.ChatVO;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class ListOrderItem extends BaseRenderer implements IListRenderer {
		
		static protected var trueHeight:int = Config.FINGER_SIZE * 1.35;
		static protected var avatarSize:int = Config.FINGER_SIZE * .46;
		
		private var bg:Shape;
		private var bgHighlight:Shape;
		private var bgActive:Shape;
		private var avatar:Shape;
		private var avatarWithLetter:Sprite;
		private var avatarWithLetterTF:TextField;
		private var tfTitle:TextField;
		private var tfLastMessage:MegaText; 
		
		private var format1:TextFormat = new TextFormat(Config.defaultFontName);
		private var format2:TextFormat = new TextFormat(Config.defaultFontName);
		private var format3:TextFormat = new TextFormat(Config.defaultFontName);
		private var format4:TextFormat = new TextFormat(Config.defaultFontName);
		
		private var avatarAccount:ImageBitmapData;
		private var avatarEmpty:ImageBitmapData;
		
		private var cachedLastMessageIconSize:int = -1;
		
		private var leftTextAlignX:int;
		private var avatarChat:ImageBitmapData;
		private var outline:Sprite;
		private var headerHeight:int;
		private var tfOrderType:TextField;
		private var tfOrderDuration:TextField;
		
		public function ListOrderItem() {
			headerHeight = Config.FINGER_SIZE * .5;
				bg = new Shape();
				bg.graphics.beginFill(MainColors.WHITE);
				bg.graphics.drawRect(0, 0, 10, trueHeight + headerHeight);
				bg.graphics.endFill();
				bg.graphics.beginFill(0xE7F0FF);
				bg.graphics.drawRect(0, 0, 10, headerHeight);
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
				var circleSize:int = (Config.FINGER_SIZE * .4) * .55;
				avatar = new Shape();
				avatar.x = int(Config.DOUBLE_MARGIN);
			addChild(avatar);
			avatarWithLetter = new Sprite();
				avatarWithLetter.x = avatar.x;
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
			//avatarWithLetter.graphics.drawCircle(avatarSize, avatarSize, avatarSize);				
			UI.drawElipseSquare(avatarWithLetter.graphics, avatarSize*2,avatarSize,AppTheme.GREY_MEDIUM);				
			avatarWithLetter.graphics.endFill();
				avatarWithLetter.visible = false;
			addChild(avatarWithLetter);
			
			var scale:Number = avatarSize * 2 / 100;
			
				tfTitle = new TextField();
				format1.size = Config.FINGER_SIZE * .3;
				format1.align = TextFormatAlign.LEFT;
				format1.color = AppTheme.GREY_DARK;// 0x363E4E;
				tfTitle.defaultTextFormat = format1;
				tfTitle.wordWrap = false;
				tfTitle.multiline = false;
				tfTitle.text = "|";
				tfTitle.text = "";
			addChild(tfTitle);
				tfLastMessage = new MegaText();
				format2.size = Config.FINGER_SIZE * .24;
			addChild(tfLastMessage);
			
			tfOrderType = new TextField();
				format3.size = Config.FINGER_SIZE * .27;
				format3.align = TextFormatAlign.LEFT;
				format3.color = 0x808080;// 0x363E4E;
				tfOrderType.defaultTextFormat = format3;
				tfOrderType.wordWrap = false;
				tfOrderType.multiline = false;
				tfOrderType.text = "|";
				tfOrderType.height = tfOrderType.textHeight + 4;
				tfOrderType.text = "";
			addChild(tfOrderType);
			
			tfOrderDuration = new TextField();
				format4.size = Config.FINGER_SIZE * .24;
				format4.align = TextFormatAlign.LEFT;
				format4.color = 0x808080;// 0x363E4E;
				tfOrderDuration.defaultTextFormat = format4;
				tfOrderDuration.wordWrap = false;
				tfOrderDuration.multiline = false;
				tfOrderDuration.text = "|";
				tfOrderDuration.height = tfOrderDuration.textHeight + 4;
				tfOrderDuration.text = "";
			addChild(tfOrderDuration);
			
			avatarEmpty =  UI.drawAssetToRoundRect(new SWFEmptyAvatar(), avatarSize * 2);
			
			avatarAccount = UI.renderAsset(new SWFAccountAvatar(), avatarSize * 2, avatarSize * 2);
			
			var tmp:Sprite = new ButtonChatContent();
			tmp.width = tmp.height = avatarSize * 2;
			avatarChat = UI.getSnapshot(tmp, StageQuality.HIGH, "avatarChat");
			tmp = null;
			
			avatar.y = int((trueHeight - avatarSize * 2) * .5) + headerHeight;
			avatarWithLetter.y = avatar.y;
			
			leftTextAlignX = avatar.x + avatarSize * 2 + Config.MARGIN;
			
			outline = new Sprite();
			addChild(outline);
		}
		
		// INITIALIZATION HEIGHT
		public function getHeight(data:ListItem, width:int):int {
			if (!(data.data is Order))
				return Config.FINGER_SIZE_DOT_75;
			return Config.FINGER_SIZE*1.85;
		}
		
		private function setText(cVO:ChatVO, w:int, description:String, duration:String):int {
			if (cVO.isDisposed == true)
				return 10;
			var padding:int = Config.DOUBLE_MARGIN;
			var maxFieldWidth:int = w - padding * 3 - avatarSize * 2;
			tfTitle.visible = true;
			tfTitle.x = leftTextAlignX;
			
			tfOrderType.x = avatar.x;
			tfOrderType.y = int(Config.FINGER_SIZE * .06);
			if (description == null)
			{
				description = "";
			}
			tfOrderType.text = description;
			tfOrderType.width = w - padding * 2 - Config.FINGER_SIZE * 2;
			
			if (duration == null)
			{
				duration = "";
			}
			tfOrderDuration.text = duration;
			tfOrderDuration.width = tfOrderDuration.textWidth + 4;
			tfOrderDuration.x = w - tfOrderDuration.width - Config.MARGIN;
			tfOrderDuration.y = int(Config.FINGER_SIZE * .08);
			
			if (cVO.title != null)
				tfTitle.text = cVO.title;
			else{
				if (cVO.getQuestion() != null && cVO.type == ChatRoomType.CHANNEL && cVO.getQuestion().text != null) {
					tfTitle.text = cVO.getQuestion().text;
				}
				else{
					tfTitle.text = "- no title -";
				}
			}
			tfTitle.width = maxFieldWidth;
			tfTitle.height = tfTitle.textHeight + 4;
			
			var message:String = cVO.settings.info;
			// TF LAST MESSAGE ///////////////////////////////////////////////////////////////////////
			tfLastMessage.visible = false;
			if (message != null && message != "") {
				tfLastMessage.visible = true;
				var maxMessageWidth:int = maxFieldWidth;
				tfLastMessage.x = leftTextAlignX;
				tfLastMessage.setText(
					maxMessageWidth, 
					message, 
					//(cVO.unreaded > 0) ? 0xA4AFB9 : (Auth.uid == cVO.messageWriterUID) ? 0xA4AFB9 : 0xA4AFB9, 
					0x8ca7bc, 
					int(format2.size),
					"#FFFFFF",
					1.5,
					cVO.wasSmile
				);
				cVO.wasSmile = tfLastMessage.getWasSmile() ? 2 : 1;
				if (tfLastMessage.getTextField().numLines > 2) {
					tfLastMessage.setText(
						maxMessageWidth, 
						message.substr(0, tfLastMessage.getTextField().getLineLength(0) + tfLastMessage.getTextField().getLineLength(1) - 3) + "...", 
						//(cVO.unreaded > 0) ? 0xA4AFB9 : (Auth.uid == cVO.messageWriterUID) ? 0xA4AFB9 : 0xA4AFB9, 
						0x8ca7bc, 
						int(format2.size),
						"#FFFFFF",
						1.5,
						cVO.wasSmile
					);
				}
			}
			// SET Y /////////////////////////////////////////////////////////////////////////////////
			var inHeight:int;
			if (tfLastMessage.visible == false) {
				tfTitle.y = int((trueHeight - tfTitle.height) * .5) + headerHeight;
				
			} else {
				var minMessageHeight:int = tfLastMessage.height;
				
				tfTitle.y = int(trueHeight - (tfTitle.height + minMessageHeight + Config.MARGIN * .5)) * .5 + headerHeight;
				
				tfLastMessage.y = tfTitle.y + tfTitle.height + Config.MARGIN * .5;
			}
			return 0;
		}
		
		public function getView(li:ListItem, h:int, w:int, highlight:Boolean = false):IBitmapDrawable {
			if (li.data == null || li.data is Order == false) {
				echo("ListOrderItem", "getView", "Data is empty");
				if (bg != null)
					bg.visible = false;
				if (bgHighlight != null)
					bgHighlight.visible = false;
				if (bgActive != null)
					bgActive.visible = false;
				if (tfTitle != null)
					tfTitle.visible = false;
				if (tfLastMessage != null)
					tfLastMessage.visible = false;
				if (avatarWithLetter != null)
					avatarWithLetter.visible = false;
				if (avatar != null)
					avatar.visible = false;
				if (outline != null)
					outline.visible = false;
				return this;
			}
			
			bg.width = w;
		//	bg.height = h;
			
			bgHighlight.width = w;
			bgHighlight.height = h;
			
			bgActive.width = w;
			bgActive.height = h;
			
			bg.visible = false;
			bgHighlight.visible = false;
			bgActive.visible = false;
			
			outline.graphics.clear();
			outline.visible = false;
			
			var order:Order = li.data as Order;
			var cVO:ChatVO = order.product.targetData as ChatVO;
			
			if (highlight == true)
				bgHighlight.visible = true;
			else
				bg.visible = true;
			
			setText(cVO, w, order.getDescription(), order.getExpireTime());
			
			tfLastMessage.render();
			tfLastMessage.getTextField().height += 4;
			
			avatarWithLetter.visible = false;
			avatar.visible = false;
			avatar.graphics.clear();
			
				var a:ImageBitmapData = li.getLoadedImage('avatarURL');
				if (a != null) {
					ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, a, ImageManager.SCALE_PORPORTIONAL);
					avatar.visible = true;
				} else {
					if (cVO.title != null && cVO.title.length > 0 && AppTheme.isLetterSupported(cVO.title.charAt(0))) {
						avatarWithLetterTF.text = String(cVO.title).charAt(0).toUpperCase();
						UI.drawElipseSquare(avatarWithLetter.graphics, avatarSize * 2, avatarSize, AppTheme.getColorFromPallete(String(cVO.title)));	
						avatarWithLetter.visible = true;				
						
					} else if (cVO.type == ChatRoomType.CHANNEL){
						ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarChat, ImageManager.SCALE_PORPORTIONAL);
						avatar.visible = true;
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
			if (tfOrderType != null)
				tfOrderType.text = "";
			tfOrderType = null;
			if (tfOrderDuration != null)
				tfOrderDuration.text = "";
			tfOrderDuration = null;
			if (tfLastMessage != null)
				tfLastMessage.dispose();
			tfLastMessage = null;
			if (avatarWithLetterTF)
				avatarWithLetterTF.text = "";
			avatarWithLetterTF = null;
			if (avatarWithLetter)
				UI.destroy(avatarWithLetter);
			avatarWithLetter = null;
			if (avatar != null)
				UI.destroy(avatar);
			avatar = null;
			if (avatarChat != null)
				avatarChat.dispose();
			avatarChat = null;

			if (avatarAccount != null)
				avatarAccount.dispose();
			avatarAccount = null;

			if (avatarEmpty != null)
				avatarEmpty.dispose();
			avatarEmpty = null;
			
			format1 = null;
			format2 = null;
			format3 = null;
			format4 = null;
			
			if (parent != null)
				parent.removeChild(this);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		
		public function get isTransparent():Boolean {
			return false;
		}
		
		public function updateUnreadMessagesDisplaying():void { }
	}
}