package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.Entry;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.CallGetEuroAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.IMessageRenderer;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Sergey Dobarin & David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererAction extends ChatMessageRendererBase implements IMessageRenderer {
		
		protected const bgColor:uint = 0xFFF000;
		protected const textColor:uint = 0x0051CA;
		private const iconSize:int = Config.FINGER_SIZE_DOT_35;
		
		protected var fontSize:int = Math.ceil(Config.FINGER_SIZE * .25);
		
		private var icon:Sprite;
		protected var tf:TextField;
		protected var textFormat:TextFormat;
		protected var textFormat1:TextFormat;
		private var icons:Dictionary = new Dictionary();
		protected var tipsText:TextField;
		
		public function ChatMessageRendererAction() {
			createTextFormat();
			create();
		}
		
		public function getWidth():uint {
			return width;
		}
		
		public function getContentHeight():Number {
			return height;
		}
		
		public function getBackColor():Number {
			return bgColor;
		}
		
		public function updateHitzones(itemHitzones:Array):void { }
		
		private function setIconByClass(iconClass:Class):void {
			if (iconClass == null) {
				removeIcon();
				return;
			}
			if (icon is iconClass)
				return;
			removeIcon();
			icon = icons[iconClass];
			if (icon != null) {
				if (icon.parent == null)
					addChild(icon);
				return;
			}
			icon = new iconClass() as Sprite;
			icon.transform.colorTransform = ct;
			UI.scaleToFit(icon, iconSize, iconSize);
			icon.x = vTextMargin;
			icon.y = vTextMargin;
			addChild(icon);
			icons[iconClass] = icon;
			return;
		}
		
		private function removeIcon():void {
			if (icon != null && icon.parent != null)
				icon.parent.removeChild(icon);
			icon = null;
		}
		
		protected function create():void {
			initBg(bgColor);
			
			if (fontSize < minFontSize)
				fontSize = minFontSize;
			
			tf = new TextField();
			tf.multiline = true;
			tf.wordWrap = true;
			tf.defaultTextFormat = textFormat;
			addChild(tf);
			
			vTextMargin = Math.ceil(Config.FINGER_SIZE * .2);
			
			ct.color = textColor;
			
			tipsText = new TextField();
			tipsText.multiline = false;
			tipsText.wordWrap = false;
			tipsText.defaultTextFormat = textFormat1;
			addChild(tipsText);
		}
		
		protected function createTextFormat():void {
			textFormat = new TextFormat("Tahoma");
			textFormat.align = TextFormatAlign.LEFT;
			textFormat.size = fontSize;
			textFormat.color = textColor;
			textFormat.underline = true;
			
			textFormat1 = new TextFormat("Tahoma");
			textFormat1.align = TextFormatAlign.LEFT;
			textFormat1.size = fontSize * .75;
			textFormat1.color = 0x82088A;
			textFormat1.bold = true;
		}
		
		public function getHeight(itemData:ChatMessageVO, maxWidth:int, listItem:ListItem):uint {
			draw(itemData, maxWidth);
			var additionalHeight:int = 0;
			if (tipsText.visible == true)
				additionalHeight = tipsText.height + vTextMargin;
			return Math.max(tf.textHeight, iconSize) + vTextMargin * 2 + additionalHeight;
		}
		
		public function draw(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null, minWidth:int = -1):void {
			var action:IScreenAction = messageData.action;
			
			setIconByClass(action.getIconClass());
			
			if (icon != null)
				tf.x = int(vTextMargin + icon.x + icon.width);
			else
				tf.x = int(vTextMargin);
			
			tf.width = maxWidth - tf.x - vTextMargin;
			tf.text = action.getData() as String;
			tf.width = tf.textWidth + 5;
			tf.height = tf.textHeight + 4;
			
			if (icon != null) {
				if (tf.textHeight < icon.height) {
					tf.y = int(vTextMargin + (icon.height - tf.textHeight) * .5);
					boxBg.height = icon.height + vTextMargin * 2;
				} else {
					tf.y = int(vTextMargin);
					boxBg.height = tf.textHeight + vTextMargin * 2;
				}
			} else {
				tf.y = int(vTextMargin);
				boxBg.height = tf.y + tf.textHeight + vTextMargin;
			}
			var maxTFWidth:int = tf.width;
			tipsText.visible = false;
			tipsText.text = "";
			
			if (action != null) {
				if (action.getAdditionalData() != null && action.getAdditionalData() is Entry) {
					tipsText.visible = true;
					tipsText.text = (action.getAdditionalData() as Entry).title + " " + (action.getAdditionalData() as Entry).value;
				}
				if (action is CallGetEuroAction) {
					var qVO:QuestionVO = ChatManager.getCurrentChat().getQuestion();
					if (qVO != null) {
						tipsText.visible = true;
						if (tipsText.text != "")
							tipsText.text += "\n";
						if (qVO.status == QuestionsManager.QUESTION_STATUS_RESOLVED || qVO.status == QuestionsManager.QUESTION_STATUS_REMOVED || qVO.status == QuestionsManager.QUESTION_STATUS_ARCHIVED)
							tipsText.text += Lang.textClosed.toUpperCase();
						else {
							var str:String;
							str = LangManager.replace(Lang.regExtValue, Lang.answeringText, String(qVO.answersCount));
							str = LangManager.replace(Lang.regExtValue, str, String(qVO.answersMaxCount));
							tipsText.text += str.toUpperCase();
						}
					}
				}
			}
			if (tipsText.visible == true) {
				tipsText.y = int(tf.y + tf.height + vTextMargin);
				tipsText.x = tf.x;
				tipsText.height = tipsText.textHeight + 4;
				tipsText.width = maxWidth - tipsText.x - vTextMargin;
				boxBg.height += int(tipsText.height + vTextMargin);
				if (tipsText.width > maxTFWidth)
					maxTFWidth = tipsText.width;
			}
			boxBg.width = tf.x + maxTFWidth + vTextMargin; 
		}
		
		override public function dispose():void {
			super.dispose();
			UI.destroy(icon);
			icons = null;
			if (tf != null) {
				tf.text = "";
				if (tf.parent != null)
					tf.parent.removeChild(tf);
			}
			tf = null;
			
			if (tipsText != null) {
				tipsText.text = "";
				if (tipsText.parent != null)
					tipsText.parent.removeChild(tipsText);
			}
			tipsText = null;
			
			textFormat = null;
			textFormat1 = null;
		}
		
		public function get animatedZone():AnimatedZoneVO {
			return null;
		}
		
		public function get isReadyToDisplay():Boolean {
			return true;
		}
	}
}