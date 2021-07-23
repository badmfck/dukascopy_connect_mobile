package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.QuestionAdditionalMessagesType;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererAdditionalQuestionsSettings extends ChatMessageRendererAction implements IMessageRenderer {
		
		private var line:Shape;
		private var bird:Shape;
		
		private var currentMessage:ChatMessageVO;
		
		public function ChatMessageRendererAdditionalQuestionsSettings() {
			super();
		}
		
		override protected function createTextFormat():void {
			super.createTextFormat();
			textFormat.underline = false;
			
			textFormat1.size = fontSize * 1.33;
			textFormat1.bold = false;
		}
		
		override protected function create():void {
			super.create();
			tf.x = vTextMargin;
			tipsText.x = vTextMargin;
			
			line = new Shape()
			line.graphics.beginFill(0xDDE8F2);
			line.graphics.drawRect(0, 0, 1, 1);
			line.graphics.endFill();
			line.x = vTextMargin;
			line.height = Math.ceil(Config.FINGER_SIZE * .02);
			addChild(line);
			
			bird = new Shape()
			bird.graphics.beginFill(0x7E95A8);
			bird.graphics.lineTo(Config.FINGER_SIZE * .12, 0);
			bird.graphics.lineTo(Config.FINGER_SIZE * .06, Config.FINGER_SIZE * .08);
			bird.graphics.lineTo(0, 0);
			bird.graphics.endFill();
			addChild(bird);
		}
		
		private function getBodyText(itemData:ChatMessageVO):String {
			var res:String = itemData.systemMessageVO.text;
			switch(itemData.systemMessageVO.method) {
				case ChatSystemMsgVO.METHOD_LOCAL_SIDE:
					if (QuestionsManager.getCurrentQuestion() != null && QuestionsManager.getCurrentQuestion().subtype != null) {
						var side:Object = QuestionsManager.getSide(QuestionsManager.getCurrentQuestion().subtype);
						if (side != null)
							res = side.label;
					}
					break;
				case ChatSystemMsgVO.METHOD_LOCAL_CRYPTO:
					if (QuestionsManager.getCurrentQuestion() != null && QuestionsManager.getCurrentQuestion().instrument != null)
						res = QuestionsManager.getCurrentQuestion().instrument.name + " (" + QuestionsManager.getCurrentQuestion().instrument.code + ")";
					break;
				case ChatSystemMsgVO.METHOD_LOCAL_CRYPTO_AMOUNT:
					if (QuestionsManager.getCurrentQuestion() != null && QuestionsManager.getCurrentQuestion().cryptoAmount != null)
						res = QuestionsManager.getCurrentQuestion().cryptoAmount;
					break;
				case ChatSystemMsgVO.METHOD_LOCAL_CURRENCY:
					if (QuestionsManager.getCurrentQuestion() != null && QuestionsManager.getCurrentQuestion().priceCurrency != null)
						res = QuestionsManager.getCurrentQuestion().priceCurrency;
					break;
				case ChatSystemMsgVO.METHOD_LOCAL_PRICE:
					if (QuestionsManager.getCurrentQuestion() != null && QuestionsManager.getCurrentQuestion().price != null)
						res = QuestionsManager.getCurrentQuestion().price;
						if (res.charAt(res.length -1) == "%") {
							res += " " + Lang.tenderPricePercent;
							if (res.charAt(0) != "-")
								res = "+" + res;
						} else {
							res += " " + QuestionsManager.getCurrentQuestion().priceCurrency;
						}
					break;
				default:
					break;
			}
			return res;
		}
		
		override public function getHeight(itemData:ChatMessageVO, maxWidth:int, listItem:ListItem):uint {
			draw(itemData, maxWidth, listItem);
			return boxBg.y + boxBg.height;
		}
		
		override public function draw(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null, minWidth:int = -1):void {
			currentMessage = messageData;
			
			tf.width = maxWidth - vTextMargin * 2;
			tf.text = messageData.systemMessageVO.title;
			tf.width = Math.min(tf.width, tf.textWidth + 5);
			tf.height = tf.textHeight + 4;
			
			var roundedTop:Boolean = true;
			var roundedBottom:Boolean = true;
			var cmVO:ChatMessageVO;
			if (listItem != null) {
				if (listItem.num != 0) {
					cmVO = listItem.list.data[listItem.num - 1];
					tf.y = vTextMargin;
					if (cmVO.typeEnum == ChatSystemMsgVO.TYPE_LOCAL_QUESTION) {
						tf.y = 0;
						roundedTop = false;
					}
				}
				if (listItem.list.data.length > listItem.num + 1) {
					cmVO = listItem.list.data[listItem.num + 1];
					if (cmVO != null && cmVO.crypted == true)
						cmVO.decrypt(null);
					if (cmVO.typeEnum == ChatSystemMsgVO.TYPE_LOCAL_QUESTION)
						roundedBottom = false;
				}
			}
			
			getIcon(messageData);
			
			tipsText.width = maxWidth - vTextMargin * 2;
			tipsText.text = getBodyText(messageData);
			tipsText.width = Math.min(tipsText.width, tipsText.textWidth + 5);
			tipsText.height = tipsText.textHeight + 4;
			if (icon == null) {
				tipsText.y = tf.y + tf.height;
				tipsText.x = hTextMargin;
				line.y = tipsText.y + tipsText.height;
			} else {
				tipsText.y = icon.y + int((icon.height - tipsText.height) * .5) + 2;
				tipsText.x = icon.x + icon.width + hTextMargin;
				line.y = icon.y + icon.height + hTextMargin;
			}
			
			line.width = maxWidth - vTextMargin * 2;
			
			if (messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_SIDE ||
				messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_CRYPTO ||
				messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_CURRENCY) {
					bird.visible = true;
					bird.x = line.x + line.width - bird.width;
					bird.y = tipsText.y + int((tipsText.height - bird.height) * .5);
			} else {
				bird.visible = false;
			}
			
			setTextColors(messageData);
			
			initBg(0xFFFFFF, roundedTop, roundedBottom);
			boxBg.width = maxWidth;
			boxBg.height = line.y + line.height + vTextMargin;
		}
		
		private function getIcon(messageData:ChatMessageVO):void {
			if (icon != null && icon.parent != null)
				icon.parent.removeChild(icon);
			icon = null;
			if (messageData.systemMessageVO == null)
				return;
			if (messageData.systemMessageVO.method != ChatSystemMsgVO.METHOD_LOCAL_CRYPTO)
				return;
			if (QuestionsManager.getCurrentQuestion().instrument == null)
				return;
			icon = UI.getInvestIconByInstrument(QuestionsManager.getCurrentQuestion().instrument.code);
			if (icon != null) {
				UI.scaleToFit(icon, iconSize * 1.5, iconSize * 1.5);
				icon.y = int(tf.y + tf.height + hTextMargin * .5 - 2);
				icon.x = hTextMargin + 2;
				addChild(icon);
			}
		}
		
		private function setTextColors(messageData:ChatMessageVO):void {
			textFormat.color = COLOR_TEXT_SELECTOR_TITLE;
			textFormat1.color = COLOR_TEXT_SELECTOR_VALUE;
			textFormat1.size = fontSize * 1.33;
			if (QuestionsManager.getCurrentQuestion() == null) {
				tf.setTextFormat(textFormat);
				tipsText.setTextFormat(textFormat1);
				return;
			}
			if (messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_SIDE) {
				if (QuestionsManager.getCurrentQuestion().subtype != null) {
					textFormat.color = COLOR_TEXT_SELECTOR_TITLE_SELECTED;
					textFormat1.color = COLOR_TEXT_SELECTOR_VALUE_SELECTED;
				}
			} else if (messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_CRYPTO) {
				if (QuestionsManager.getCurrentQuestion().instrument != null) {
					textFormat.color = COLOR_TEXT_SELECTOR_TITLE_SELECTED;
					textFormat1.color = COLOR_TEXT_SELECTOR_VALUE_SELECTED;
					textFormat1.size = fontSize * 1.10;
				}
			} else if (messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_CRYPTO_AMOUNT) {
				if (QuestionsManager.getCurrentQuestion().cryptoAmount != null) {
					textFormat.color = COLOR_TEXT_SELECTOR_TITLE_SELECTED;
					textFormat1.color = COLOR_TEXT_SELECTOR_VALUE_SELECTED;
				}
			} else if (messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_CURRENCY) {
				if (QuestionsManager.getCurrentQuestion().priceCurrency != null) {
					textFormat.color = COLOR_TEXT_SELECTOR_TITLE_SELECTED;
					textFormat1.color = COLOR_TEXT_SELECTOR_VALUE_SELECTED;
				}
			} else if (messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_PRICE) {
				if (QuestionsManager.getCurrentQuestion().price != null) {
					textFormat.color = COLOR_TEXT_SELECTOR_TITLE_SELECTED;
					textFormat1.color = COLOR_TEXT_SELECTOR_VALUE_SELECTED;
				}
			}
			tf.setTextFormat(textFormat);
			tipsText.setTextFormat(textFormat1);
		}
		
		override public function updateHitzones(itemHitzones:Array):void {
			itemHitzones.push( { type:HitZoneType.BALLOON, x:x , y:y, width: boxBg.width, height: boxBg.height } );
		}
		
		override public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData {
			var result:HitZoneData = new HitZoneData();
			var roundedTop:Boolean = true;
			var roundedBottom:Boolean = true;
			var cmVO:ChatMessageVO;
			if (listItem != null) {
				if (listItem.num != 0) {
					cmVO = listItem.list.data[listItem.num - 1];
					if (cmVO.typeEnum == ChatSystemMsgVO.TYPE_LOCAL_QUESTION)
						roundedTop = false;
				}
				if (listItem.list.data.length > listItem.num + 1) {
					cmVO = listItem.list.data[listItem.num + 1];
					if (cmVO != null && cmVO.crypted == true)
						cmVO.decrypt(null);
					if (cmVO.typeEnum == ChatSystemMsgVO.TYPE_LOCAL_QUESTION)
						roundedBottom = false;
				}
			}
			if (roundedTop && roundedBottom)
				result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
			else if (roundedTop)
				result.type = HitZoneType.MENU_FIRST_ELEMENT;
			else if (roundedBottom)
				result.type = HitZoneType.MENU_LAST_ELEMENT;
			else
				result.type = HitZoneType.MENU_MIDDLE_ELEMENT;
			result.x = x;
			result.y = y;
			result.width = getWidth();
			result.height = getContentHeight();
			result.radius = textBoxRadius;
			return result;
		}
		
		override public function dispose():void {
			super.dispose();
			currentMessage = null;
			if (line != null) {
				if (line.parent != null)
					line.parent.removeChild(line);
				line.graphics.clear();
			}
			line = null;
		}
		
		override public function getSmallGap(listItem:ListItem):int {
			if (listItem != null) {
				if (listItem.num != 0) {
					var cmVO:ChatMessageVO;
					if (listItem.num - 1 >= 0)
						cmVO = listItem.list.data[listItem.num - 1];
					if (cmVO != null && cmVO.crypted == true)
						cmVO.decrypt(null);
					if (cmVO == null || cmVO.typeEnum != ChatSystemMsgVO.TYPE_LOCAL_QUESTION)
						return super.getSmallGap(listItem);
				}
			}
			return 0;
		}
	}
}