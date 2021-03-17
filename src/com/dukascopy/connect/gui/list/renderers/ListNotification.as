package com.dukascopy.connect.gui.list.renderers {
	
	import com.adobe.utils.IntUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.businessListManager.BusinessListManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.vo.BLNotificationVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.EntryPointVO;
	import flash.display.BlendMode;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class ListNotification extends Sprite implements IListRenderer {
		
		private var trueH:int = Config.FINGER_SIZE;
		
		private var bg:Shape;
		private var bgHighlight:Shape;
		private var tfNumber:TextField;
		private var tfTitle:TextField;
		private var tfLastMessage:TextField;
		private var tfStatus:TextField;
		
		private var format:TextFormat = new TextFormat("Tahoma");
		
		private var titleMessageSpace:int = Config.MARGIN * .2;
		
		public function ListNotification() {
				bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGRIUND));
				bg.graphics.drawRect(0, 0, 10, 10);
				bg.graphics.endFill();
				bg.graphics.beginFill(0, .10);
				bg.graphics.drawRect(0, 9, 10, 1);
				bg.scale9Grid = new Rectangle(1, 1, 8, 5);
			addChild(bg);
				bgHighlight = new Shape();
				bgHighlight.graphics.beginFill(0x00a8ff,.2);
				bgHighlight.graphics.drawRect(0, 0, 10, 10);
				bgHighlight.graphics.endFill();
				bgHighlight.graphics.beginFill(0, .10);
				bgHighlight.graphics.drawRect(0, 9, 10, 1);
				bgHighlight.scale9Grid = new Rectangle(1, 1, 8, 5);
				bgHighlight.visible = false;
			addChild(bgHighlight);
				tfNumber = new TextField();
				//tfNumber.border = true;
				tfNumber.wordWrap = false;
				tfNumber.multiline = false;
				format.size = Config.FINGER_SIZE * .2;
				tfNumber.defaultTextFormat = format;
				tfNumber.y = int(Config.MARGIN + Config.FINGER_SIZE * 0.05);
				tfNumber.x = Config.MARGIN * 2;
				tfNumber.autoSize = TextFieldAutoSize.LEFT;
			addChild(tfNumber);
				tfTitle = new TextField();
				//tfTitle.border = true;
				format.size = Config.FINGER_SIZE * .28;
				tfTitle.defaultTextFormat = format;
				tfTitle.x = Config.MARGIN * 2;
				tfTitle.autoSize = TextFieldAutoSize.LEFT;
				tfTitle.wordWrap = true;
				tfTitle.multiline = true;
			addChild(tfTitle);
				tfLastMessage = new TextField();
				//tfLastMessage.embedFonts = false;
				//tfLastMessage.border = true;
				tfLastMessage.x = tfTitle.x;
				format.size = Config.FINGER_SIZE * .2;
				tfLastMessage.defaultTextFormat = format;
				tfLastMessage.autoSize = TextFieldAutoSize.LEFT;
				tfLastMessage.wordWrap = true;
				tfLastMessage.multiline = true;
			addChild(tfLastMessage);
				tfStatus = new TextField();
				//tfStatus.border = true;
				tfStatus.wordWrap = false;
				tfStatus.multiline = false;
				format.size = Config.FINGER_SIZE * .2;
				tfStatus.defaultTextFormat = format;
				tfStatus.y = int(Config.MARGIN + Config.FINGER_SIZE * 0.05);
				tfStatus.autoSize = TextFieldAutoSize.LEFT;
			addChild(tfStatus);
		}
		
		// INITIALIZATION HEIGHT
		public function getHeight(data:ListItem, width:int):int {
			if (data.data is BLNotificationVO)
				return setText(data.data as BLNotificationVO, width);
			return Config.FINGER_SIZE_DOT_75;
		}
		
		private function setText(data:Object, w:int):int {
			if (!(data is BLNotificationVO)) {
				tfTitle.visible = false;
				tfNumber.visible = false;
				tfStatus.visible = false;
				tfLastMessage.alpha = 1;
				tfLastMessage.autoSize = TextFieldAutoSize.NONE;
				tfLastMessage.textColor = 0xFFFFFF;
				tfLastMessage.text = data.title.toUpperCase() + "   " + data.count;
				tfLastMessage.width = w - Config.DOUBLE_MARGIN * 2;
				tfLastMessage.height = tfLastMessage.textHeight + 4;
				tfLastMessage.y = int((Config.FINGER_SIZE_DOT_75 - tfLastMessage.height) * .5);
				tfLastMessage.x = Config.MARGIN * 2;
				return Config.FINGER_SIZE;
			}
			tfTitle.visible = true;
			tfNumber.visible = true;
			tfStatus.visible = true;
			
			var nVO:BLNotificationVO = data as BLNotificationVO;
			if (nVO.isDisposed)
				return 10;
			
			if (nVO.acceptors == null || nVO.acceptors.length == 0) {
				tfNumber.textColor = 0xF74774;
				tfStatus.textColor = 0xDDDDDD;
				tfStatus.text = ListNotification.getDateAfterString(nVO.lastCancelTime);
			} else {
				tfNumber.textColor = 0x38ABD0;
				tfStatus.textColor = 0x38ABD0;
				tfStatus.text = nVO.acceptors.length + "";
			}
			tfStatus.width = tfStatus.textWidth + 4;
			tfStatus.x = w - tfStatus.width - Config.DOUBLE_MARGIN;
			
			tfNumber.text = nVO.pid.toString(16).toUpperCase();
			tfNumber.width = tfNumber.textWidth + 4;
			
			tfTitle.textColor = 0;
			tfTitle.autoSize = TextFieldAutoSize.LEFT;
			tfTitle.y = Config.MARGIN;
			tfTitle.x = Config.DOUBLE_MARGIN * 2 + tfNumber.width;
			var epVO:EntryPointVO  = BusinessListManager.getEntryPointByID(nVO.pointID);
			tfTitle.text = epVO!=null? epVO.short : ""; // a esli null ?
			tfTitle.width = tfStatus.x - tfTitle.x  - Config.DOUBLE_MARGIN;
			if (tfTitle.height > Config.FINGER_SIZE_DOUBLE) {
				tfTitle.autoSize = TextFieldAutoSize.NONE;
				tfTitle.height = Config.FINGER_SIZE_DOUBLE;
			}
			tfLastMessage.x = tfTitle.x;
			tfLastMessage.y = tfTitle.y + tfTitle.height + titleMessageSpace;
			tfLastMessage.autoSize = TextFieldAutoSize.LEFT;
			if (nVO.msg != null)
				tfLastMessage.text = nVO.msg;
			tfLastMessage.width = tfTitle.width;
			if (tfLastMessage.height > Config.FINGER_SIZE_DOUBLE) {
				tfLastMessage.autoSize = TextFieldAutoSize.NONE;
				tfLastMessage.height = Config.FINGER_SIZE_DOUBLE;
			}
			
			tfLastMessage.alpha = (nVO.clientUID == nVO.msgSenderUID) ? 1 : .6;
			if (tfLastMessage.alpha == 1)
				tfLastMessage.textColor = 0xd82e2f;
			else
				tfLastMessage.textColor = 0x444444;
			
			var h:int = tfLastMessage.y + tfLastMessage.height + Config.DOUBLE_MARGIN;
			if (h < Config.FINGER_SIZE)
				h = Config.FINGER_SIZE;
			tfStatus.y = int((h - tfStatus.height) * .5);
			return h;
		}
		
		public function getView(li:ListItem, h:int, w:int, highlight:Boolean = false):IBitmapDrawable {
			bg.width = w;
			bg.height = h;
			bgHighlight.width = w;
			bgHighlight.height = h;
			
			setText(li.data, w);
			
			bg.visible = true;
			bgHighlight.visible = false;
			bg.graphics.clear();
			if (li.data is BLNotificationVO) {
				bg.visible = !highlight;
				bgHighlight.visible = highlight;
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGRIUND));
				bg.graphics.drawRect(0, 0, 10, 10);
				bg.graphics.beginFill(0, .10);
				bg.graphics.drawRect(0, 9, 10, 1);
			} else {
				if (li.data.title.toLowerCase() == "waiting")
					bg.graphics.beginFill(0xF74774);
				else
					bg.graphics.beginFill(0x38ABD0);
				bg.graphics.drawRect(0, 0, 10, 10);
			}
			bg.graphics.endFill();
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
			if (tfNumber != null)
				tfNumber.text = "";
			tfNumber = null;
			if (tfTitle != null)
				tfTitle.text = "";
			tfTitle = null;
			if (tfLastMessage != null)
				tfLastMessage.text = "";
			tfLastMessage = null;
			if (tfStatus != null)
				tfStatus.text = "";
			tfStatus = null;
			format = null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return false;
		}
		
		public static function getDateAfterString(dateTime:Number, milliseconds:Boolean = true):String {
			if (!milliseconds)
				dateTime *= 1000;
			
			var now:Number = new Date().getTime();
			dateTime = now - dateTime;
			
			dateTime = int(dateTime * 0.001);
			
			var sec:int = int(dateTime % 60);
			dateTime = int(dateTime / 60);
			
			var min:int = int(dateTime % 60);
			dateTime = int(dateTime / 60);
			
			var hour:int = int(dateTime % 60);
			dateTime = int(dateTime / 60);
			
			return ((hour < 10) ? "0" : "") + hour + ":" + ((min < 10) ? "0" : "") + min + ":" + ((sec < 10) ? "0" : "") + sec;
		}
	}
}