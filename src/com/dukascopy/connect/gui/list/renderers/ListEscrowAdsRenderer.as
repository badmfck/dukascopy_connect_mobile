package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsVO;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ListEscrowAdsRenderer extends BaseRenderer implements IListRenderer {
		
		static protected var avatarSize:int = Config.FINGER_SIZE * .4;
		static protected var avatarPosX:int = Config.FINGER_SIZE * .18;
		static protected var avatarPosY:int = Config.FINGER_SIZE * .2;
		
		protected var icon:Bitmap;
		
		protected var format_amount:TextFormat = new TextFormat();
		protected var format_price:TextFormat = new TextFormat();
		protected var format_status:TextFormat = new TextFormat();
		protected var format_time:TextFormat = new TextFormat();
		protected var format6:TextFormat = new TextFormat();
		
		protected var bg:Shape;
		
		protected var textFieldAmount:TextField;
		protected var textFieldPrice:TextField;
		protected var textFieldStatus:TextField;
		protected var tfQuestionTime:TextField;
		
		public function ListEscrowAdsRenderer() {
			initTextFormats();
			
			bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, 0, 1, 1);
				bg.graphics.endFill();
			addChild(bg);
			
			var textPosition:int = int(avatarPosX + avatarSize * 2 + Config.FINGER_SIZE * .28);
			
			textFieldAmount = new TextField();
				textFieldAmount.defaultTextFormat = format_amount;
				textFieldAmount.wordWrap = false;
				textFieldAmount.multiline = false;
				textFieldAmount.x = textPosition;
				textFieldAmount.y = int(Config.FINGER_SIZE * .2);
				textFieldAmount.text = "Pp";
				textFieldAmount.height = textFieldAmount.textHeight + 4;
				textFieldAmount.text = "";;
			addChild(textFieldAmount);
			
			tfQuestionTime = new TextField();
				tfQuestionTime.defaultTextFormat = format_time;
				tfQuestionTime.autoSize = TextFieldAutoSize.LEFT;
				tfQuestionTime.wordWrap = false;
				tfQuestionTime.multiline = false;
				tfQuestionTime.y = int(Config.FINGER_SIZE * .2);
				tfQuestionTime.x = textPosition;
				tfQuestionTime.text = "Pp";
				tfQuestionTime.height = tfQuestionTime.textHeight + 4;
				tfQuestionTime.text = "";
			addChild(tfQuestionTime);
			
			textFieldPrice = new TextField();
				textFieldPrice.defaultTextFormat = format_price;
				textFieldPrice.wordWrap = false;
				textFieldPrice.multiline = false;
				textFieldPrice.text = "Pp";
				textFieldPrice.x = textPosition;
				textFieldPrice.y = int(textFieldAmount.y + FontSize.BODY + Config.FINGER_SIZE * .1);
				textFieldPrice.height = textFieldPrice.textHeight + 4;
				textFieldPrice.text = "";
			addChild(textFieldPrice);
			
			textFieldStatus = new TextField();
				textFieldStatus.defaultTextFormat = format_status;
				textFieldStatus.wordWrap = false;
				textFieldStatus.multiline = false;
				textFieldStatus.text = "Pp";
				textFieldStatus.height = textFieldStatus.textHeight + 4;
				textFieldStatus.text = "";
				textFieldStatus.x = textPosition;
				textFieldStatus.y = int(textFieldPrice.y + FontSize.BODY + Config.FINGER_SIZE * .1);
			addChild(textFieldStatus);
			
			icon = new Bitmap();
			icon.x = avatarPosX;
			icon.y = avatarPosY;
			addChild(icon);
		}
		
		protected function drawIcon(listData:Object):void {
			var itemData:EscrowAdsVO = listData as EscrowAdsVO;
			
			if (itemData.instrument == null)
				return;
			
			var iconClass:Class = UI.getCryptoIconClass(itemData.instrument.code);
			if (iconClass != null) {
				if (icon.bitmapData != null) {
					icon.bitmapData.dispose();
					icon.bitmapData = null;
				}
				
				var iconSource:Sprite = (new iconClass)();
				UI.scaleToFit(iconSource, avatarSize * 2, avatarSize * 2);
				icon.bitmapData = UI.getSnapshot(iconSource);
				iconSource = null;
			}
		}
		
		private function initTextFormats():void {
			format_amount.font = Config.defaultFontName;
			format_amount.color = Style.color(Style.COLOR_TEXT);
			format_amount.size = FontSize.BODY;
			
			format_time.font = Config.defaultFontName;
			format_time.color = Style.color(Style.COLOR_SUBTITLE);
			format_time.size = FontSize.CAPTION_1;
			
			format_status.font = Config.defaultFontName;
			format_status.color = Style.color(Style.COLOR_SUBTITLE);
			format_status.size = FontSize.CAPTION_1;
			format_status.align = TextFormatAlign.LEFT;
			
			format6.font = Config.defaultFontName;
			format6.align = TextFormatAlign.LEFT;
			format6.color = Color.GREEN;
			format6.size = FontSize.CAPTION_1;
			
			format_price.font = Config.defaultFontName;
			format_price.align = TextFormatAlign.LEFT;
			format_price.color = Style.color(Style.COLOR_TEXT);
			format_price.size = FontSize.BODY;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(item:ListItem, width:int):int {
			return int(textFieldStatus.y + textFieldStatus.height + Config.FINGER_SIZE * .2);
		}
		
		public function getView(item:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			textFieldAmount.text = "";
			tfQuestionTime.text = "";
			textFieldStatus.text = "";
			
			bg.width = width;
			bg.height = height;
			bg.visible = !highlight;
			
			var newWidth:int = width - textFieldAmount.x - Config.MARGIN;
			
			var maxTextWidth:int = width - textFieldAmount.x - Config.FINGER_SIZE * .2;
			textFieldAmount.width = maxTextWidth;
			textFieldPrice.width = maxTextWidth;
			textFieldStatus.width = maxTextWidth;
			
			tfQuestionTime.visible = true;
			textFieldPrice.visible = false;
			
			if (isValidData(item.data)) {
				var hitZones:Array;
				
				tfQuestionTime.htmlText = getTimeText(item.data);
				tfQuestionTime.x = int(width - tfQuestionTime.width - Config.FINGER_SIZE_DOT_25 + 2);
				
				textFieldPrice.visible = true;
				textFieldPrice.htmlText = getPrice(item.data);
				textFieldAmount.htmlText = getAmount(item.data);
				textFieldStatus.defaultTextFormat = getStatusFormat(item.data);
				textFieldStatus.text = getStatusText(item.data);
				
				drawIcon(item.data);
			}
			
			item.setHitZones(hitZones);
			
			updateItemAlpha(item.data);
			updateBack(item.data);
			
			return this;
		}
		
		protected function updateBack(listData:Object):void 
		{
			
		}
		
		protected function isValidData(listData:Object):Boolean {
			if (listData != null && "uid" in listData && listData.uid != null && listData.uid != "") {
				return true;
			}
			return false;
		}
		
		protected function updateItemAlpha(listData:Object):void {
			var itemData:EscrowAdsVO = listData as EscrowAdsVO;
			
			if (itemData != null && itemData.isRemoving == true)
				alpha = .5;
			else
				alpha = 1;
		}
		
		protected function getStatusText(listData:Object):String {
			var itemData:EscrowAdsVO = listData as EscrowAdsVO;
			var result:String = "";
			if (itemData.status == EscrowAdsVO.STATUS_RESOLVED || itemData.status == EscrowAdsVO.STATUS_CLOSED) {
				result = Lang.escrow_offer_closed;
			} else {
				result = LangManager.replace(Lang.regExtValue, Lang.escrow_already_participate, String(itemData.answersCount));
				result = LangManager.replace(Lang.regExtValue, result, String(itemData.answersMax));
				if (result == null)
					result = "";
			}
			return result;
		}
		
		protected function getStatusFormat(listData:Object):TextFormat {
			var itemData:EscrowAdsVO = listData as EscrowAdsVO;
			
			if (itemData.mine && itemData.answersCount > 0)
				return format6;
			else
				return format_status;
			
			if (itemData.status == EscrowAdsVO.STATUS_RESOLVED || itemData.status == EscrowAdsVO.STATUS_CLOSED) {
				return format_status;
			}
		}
		
		protected function getPrice(listData:Object):String {
			var itemData:EscrowAdsVO = listData as EscrowAdsVO;
			
			var res:String = "@" + itemData.price + " " + itemData.currency;
			var percent:String = itemData.percent;
			if (percent != null)
				res += ", <font color='#BEBEBE'>MKT " + percent + "</font>";
			return res;
		}
		
		protected function getAmount(listData:Object):String {
			var itemData:EscrowAdsVO = listData as EscrowAdsVO;
			
			var result:String = "";
			if (itemData.side == "buy") {
				result += "<font color='#" + Color.GREEN.toString(16) + "'>" + Lang.BUY.toUpperCase() + " " + itemData.amount + " " + itemData.crypto + "</font>";
			} else {
				result += "<font color='#" + Color.RED.toString(16) + "'>" + Lang.sell.toUpperCase() + " " + itemData.amount + " " + itemData.crypto + "</font>";
			}
			if (itemData.mine == true) {
				result = result + "<font color='#" + Style.color(Style.COLOR_TEXT).toString(16) + "'> (" + Lang.mine.toUpperCase() + ")";
			}
			return result;
		}
		
		protected function getTimeText(listData:Object):String {
			var itemData:EscrowAdsVO = listData as EscrowAdsVO;
			
			var date:Date = new Date(Number(itemData.created * 1000));
			
			var timeValue:String = DateUtils.getComfortDateRepresentationWithMinutes(date);
			var result:String = "";
			if (itemData.side == "buy") {
				result += "<font color='#" + Color.GREEN.toString(16) + "'>" + timeValue + "</font>";
			} else {
				result += "<font color='#" + Color.RED.toString(16) + "'>" + timeValue + "</font>";
			}
			
			return result;
		}
		
		override public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData {
			var h:int = getHeight(listItem, listItem.width);
			getView(listItem, h, listItem.width, false);
			if (isClickable(listItem.data)) {
				var result:HitZoneData = new HitZoneData();
				result.type = HitZoneType.MENU_MIDDLE_ELEMENT;
				result.x = 0;
				result.y = 0;
				result.width = listItem.width;
				result.height = h;
				return result;
			}
			return null;
		}
		
		protected function isClickable(listData:Object):Boolean 
		{
			var itemData:EscrowAdsVO = listData as EscrowAdsVO;
			
			if (itemData != null && itemData.uid == null || itemData.uid == "")
			{
				return true;
			}
			return false;
		}
		
		public function dispose():void {
			format_amount = null;
			format_time = null;
			format_status = null;
			format6 = null;
			format_price = null;
			
			if (textFieldAmount != null)
				UI.destroy(textFieldAmount);
			textFieldAmount = null;
			if (tfQuestionTime != null)
				tfQuestionTime.text = "";
			tfQuestionTime = null;
			if (textFieldStatus)
				textFieldStatus.text = "";
			textFieldStatus = null;
			if (textFieldPrice)
				textFieldPrice.text = "";
			textFieldPrice = null;
			
			UI.destroy(bg);
			bg = null;
			
			graphics.clear();
			
			if (parent) {
				parent.removeChild(this);
			}
			
			UI.destroy(icon);
			icon = null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}