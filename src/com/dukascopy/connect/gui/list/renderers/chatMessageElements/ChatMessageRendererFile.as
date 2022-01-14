package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.localFiles.LocalFilesManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererFile extends ChatMessageRendererBase implements IMessageRenderer {
		
		private var fileName:TextField;
		private var textFormat:TextFormat = new TextFormat();
		private var iconContainer:Sprite;
		
		private var vPadding:Number;
		private var hPadding:Number;
		private var trueHeight:uint;
		
		public function ChatMessageRendererFile() {
			super();
			
			var fontSize:int = Math.ceil(Config.FINGER_SIZE * .22);
			if (fontSize < minFontSize)
				fontSize = minFontSize;
			
			vPadding = hPadding = Config.FINGER_SIZE * .2;
			trueHeight = Config.FINGER_SIZE + vPadding * 2;
			
			var bgSize:int = textBoxRadius * 3;
			
			boxBg = new Shape();
			boxBg.graphics.beginFill(COLOR_BG_WHITE, 1);
			boxBg.graphics.drawRoundRect(0, 0, bgSize, bgSize, textBoxRadius, textBoxRadius);
			boxBg.graphics.endFill();
			boxBg.scale9Grid = new Rectangle(textBoxRadius, textBoxRadius, textBoxRadius, textBoxRadius);
			addChild(boxBg);
			
			textFormat.font = Config.defaultFontName;
			textFormat.size = fontSize;
			textFormat.size = Config.FINGER_SIZE * .3;
			textFormat.color = AppTheme.GREY_DARK;
			
			fileName = new TextField();
			fileName.defaultTextFormat = textFormat;
			fileName.wordWrap = true;
			fileName.multiline = true;
			fileName.y = vPadding;
			addChild(fileName);
			
			iconContainer = new Sprite();
			iconContainer.x = hPadding;
			iconContainer.y = vPadding;
			addChild(iconContainer);
		}
		
		public function getContentHeight():Number {
			return boxBg.height;
		}
		
		public function  updateHitzones(itemHitzones:Vector.<HitZoneData>):void {
			if (parent != null)
			{
				var hz:HitZoneData = new HitZoneData();
					hz.type = HitZoneType.BALLOON;
					hz.x = x;
					hz.y = y;
					hz.width = boxBg.width;
					hz.height = boxBg.height;
				itemHitzones.push(hz);
			}
		}
		
		public function getBackColor():Number {
			return ct.color;
		}
		
		public function getWidth():uint {
			return width;
		}
		
		public function getHeight(itemData:ChatMessageVO, targetWidth:int, listItem:ListItem):uint {
			if (itemData == null)
				return 0;
			return trueHeight;
		}
		
		public function draw(messageVO:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null, minWidth:int = -1):void {
			iconContainer.removeChildren();
			
			updateBubbleColors(messageVO);
			
			var fileNameValue:String = messageVO.systemMessageVO.title;
			if (messageVO.systemMessageVO.fileVO != null)
			{
				fileNameValue = messageVO.systemMessageVO.fileVO.title;
			}
			var iconClass:Class = LocalFilesManager.getFileIconClassByName(fileNameValue);
			
			var iconAttachFile:Sprite;
			if (iconClass != null)
				iconAttachFile = new iconClass();
			
			fileName.width = maxWidth - hPadding * 3;
			fileName.text = fileNameValue;
			
			textFormat.color = colorText;
			fileName.setTextFormat(textFormat);
			
			fileName.width = fileName.textWidth + 4;
			fileName.height = Math.min(fileName.textHeight + 4, Config.FINGER_SIZE + vPadding * 2);
			
			if (iconAttachFile) {
				// TODO Переделать на массив иконок и смотреть какая иконка сейчас показывается и не делать iconContainer.removeChildren(); если иконка та же
				var iconSize:int = Config.FINGER_SIZE;
				UI.scaleToFit(iconAttachFile, iconSize, iconSize);
				iconContainer.addChild(iconAttachFile);
				//!TODO: добавить отображение размера файла, не приходит данное поле;
			}
			
			fileName.x = int(iconContainer.width + hPadding * 2);
			
			boxBg.width = int(hPadding * 3 + iconContainer.width + fileName.width);
			boxBg.height = trueHeight;
		}
		
		override public function get width():Number {
			return boxBg.width;
		}
		
		override public function dispose():void {
			UI.destroy(fileName);
			fileName = null;
			if (iconContainer) {
				iconContainer.removeChildren();
				UI.destroy(iconContainer);
			}
			iconContainer = null;
			textFormat = null;
			super.dispose();
		}
		
		public function get animatedZone():AnimatedZoneVO {
			return null;
		}
		
		public function get isReadyToDisplay():Boolean {
			return true;
		}
	}
}