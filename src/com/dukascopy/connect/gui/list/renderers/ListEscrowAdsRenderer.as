package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsVO;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ListEscrowAdsRenderer extends BaseRenderer implements IListRenderer {
		
		static protected var avatarSize:int = Config.FINGER_SIZE * .4;
		static protected var avatarPosX:int = Config.FINGER_SIZE * .18;
		static protected var avatarPosY:int = Config.FINGER_SIZE * .2;
		
		protected var icon911BMD:ImageBitmapData;
		
		protected var format_amount:TextFormat = new TextFormat();
		protected var format_price:TextFormat = new TextFormat();
		protected var format_status:TextFormat = new TextFormat();
		protected var format_time:TextFormat = new TextFormat();
		
		protected var format6:TextFormat = new TextFormat();
		
		protected var bg:Shape;
		protected var avatar:Shape;
		
		protected var textFieldAmount:TextField;
		protected var textFieldPrice:TextField;
		protected var textFieldStatus:TextField;
		protected var tfQuestionTime:TextField;
		
		public function ListEscrowAdsRenderer() {
			
			initTextFormats();
			
			var icon:Sprite;
			if (icon911BMD == null) {
				icon = new SWF911Avatar();
				UI.scaleToFit(icon, avatarSize * 2, avatarSize * 2);
				icon911BMD = UI.getSnapshot(icon, StageQuality.HIGH, "ListConversation.actionAvatar");
				UI.destroy(icon);
				icon = null;
			}
			
			bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, 0, 1, 1);
				bg.graphics.endFill();
			addChild(bg);
			avatar = new Shape();
				avatar.x = avatarPosX;
				avatar.y = avatarPosY;
			addChild(avatar);
			
			var scale:Number = avatarSize * 2 / 100;
			
			var textPosition:int = int(avatar.x + avatarSize * 2 + Config.FINGER_SIZE * .28);
			
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
		}
		
		//6n5dpefg4fv7ebev
		
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
			var itemData:EscrowAdsVO = item.data as EscrowAdsVO;
			
			avatar.graphics.clear();
			avatar.visible = true;
			
			textFieldAmount.text = "";
			tfQuestionTime.text = "";
			textFieldStatus.text = "";
			
			ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, icon911BMD, ImageManager.SCALE_PORPORTIONAL);
			
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
			
			if (itemData.uid != null && itemData.uid != "") {
				var hitZones:Array;
				
				tfQuestionTime.htmlText = getStatusText(itemData, itemData.created);
				tfQuestionTime.x = int(width - tfQuestionTime.width - Config.FINGER_SIZE_DOT_25 + 2);
				
				textFieldPrice.visible = true;
				textFieldPrice.htmlText = getPrice(itemData);
				textFieldAmount.htmlText = getAmount(itemData);
				if (itemData.mine == true) {
					textFieldAmount.htmlText = textFieldAmount.htmlText + " (" + Lang.mine.toUpperCase() + ")";
				}
				
				if (itemData.mine && itemData.answersCount > 0)
					textFieldStatus.defaultTextFormat = format6;
				else
					textFieldStatus.defaultTextFormat = format_status;
				
				if (itemData.status == EscrowAdsVO.STATUS_RESOLVED || itemData.status == EscrowAdsVO.STATUS_CLOSED) {
					textFieldStatus.defaultTextFormat = format_status;
					textFieldStatus.text = Lang.escrow_offer_closed;
				} else {
					var str:String;
					str = LangManager.replace(Lang.regExtValue,Lang.escrow_already_participate, String(itemData.answersCount));
					str = LangManager.replace(Lang.regExtValue,str,String(itemData.answersMax));
					if (str == null)
						str = "";
					textFieldStatus.text = str;
				}
			}
			
			item.setHitZones(hitZones);
			
			if (itemData.isRemoving == true)
				alpha = .5;
			else
				alpha = 1;
			
			return this;
		}
		
		private function getPrice(itemData:EscrowAdsVO):String {
			var res:String = "@" + itemData.price + " " + itemData.currency;
			var percent:String = itemData.percent;
			if (percent != null)
				res += ", <font color='#BEBEBE'>MKT " + percent + "</font>";
			return res;
		}
		
		private function getTime(itemData:EscrowAdsVO, timeValue:String):String {
			var result:String = "";
			if (itemData.side == "buy") {
				result += "<font color='#" + Color.GREEN.toString(16) + "'>" + timeValue + "</font>";
			} else {
				result += "<font color='#" + Color.RED.toString(16) + "'>" + timeValue + "</font>";
			}
			return result;
		}
		
		private function getAmount(itemData:EscrowAdsVO):String {
			var result:String = "";
			if (itemData.side == "buy") {
				result += "<font color='#" + Color.GREEN.toString(16) + "'>" + Lang.BUY.toUpperCase() + " " + itemData.amount + " " + itemData.crypto + "</font>";
			} else {
				result += "<font color='#" + Color.RED.toString(16) + "'>" + Lang.sell.toUpperCase() + " " + itemData.amount + " " + itemData.crypto + "</font>";
			}
			return result;
		}
		
		private function getStatusText(itemData:EscrowAdsVO, timestamp:Number):String {
			var date:Date = new Date(Number(timestamp * 1000));
			return getTime(itemData, DateUtils.getComfortDateRepresentationWithMinutes(date));
		}
		
		override public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData {
			var h:int = getHeight(listItem, listItem.width);
			getView(listItem, h, listItem.width, false);
			if (listItem.data.uid == null || listItem.data.uid == "") {
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
		
		public function dispose():void {
			format_amount = null;
			format_time = null;
			format_status = null;
			format6 = null;
			format_price = null;
			
			graphics.clear();
			
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
			
			UI.destroy(avatar);
			avatar = null;
			
			if (parent) {
				parent.removeChild(this);
			}
			
			icon911BMD.dispose();
			icon911BMD = null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}