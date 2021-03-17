package com.dukascopy.connect.gui.list.renderers {
	
	import assets.Event_type_1_image;
	import assets.Event_type_2_image;
	import assets.Event_type_3_image;
	import assets.Event_type_4_image;
	import assets.PromoNew;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.promoEvent.PromoEvent;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * @author Sergey Dobarin. Telefision AG.
	 */
	
	public class ListPromoEvent extends BaseRenderer implements IListRenderer {
		
		private var padding:int;
		private var backImageType_1:Event_type_1_image;
		private var backImageType_2:Event_type_2_image;
		private var backImageType_3:Event_type_3_image;
		private var backImageType_4:Event_type_4_image;
		private var backImageType_7:Event_type_7_image;
		private var backImageType_5:Event_type_5_image;
		private var backImageType_6:Event_type_6_image;
		private var backImageType_8:Event_type_8_image;
		
		private var title:flash.text.TextField;
		private var value:flash.text.TextField;
		private var backImageNew:assets.PromoNew;
		private var buttonText:flash.text.TextField;
		private var buttonOutline:flash.display.Sprite;
		
		
		static protected var initialized:Boolean = false;
		
		protected var bg:Shape;
		protected var bgHighlight:Shape;
		protected var textFormatTitle:TextFormat = new TextFormat();
		protected var textFormatValue1:TextFormat = new TextFormat();
		protected var textFormatValue2:TextFormat = new TextFormat();
		protected var textFormatButton:TextFormat = new TextFormat();
		
		public function ListPromoEvent() {
			
			padding = Config.MARGIN;
			
			bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, 0, 1, 1);
				bg.graphics.endFill();
			addChild(bg);
			bgHighlight = new Shape();
				bgHighlight.graphics.beginFill(Style.color(Style.COLOR_LIST_SELECTED), 1);
				bgHighlight.graphics.drawRect(0, 0, 1, 1);
				bgHighlight.graphics.endFill();
				bgHighlight.visible = false;
			addChild(bgHighlight);
			
			backImageType_1 = new Event_type_1_image();
			backImageType_2 = new Event_type_2_image();
			backImageType_3 = new Event_type_3_image();
			backImageType_4 = new Event_type_4_image();
			backImageType_5 = new Event_type_5_image();
			backImageType_6 = new Event_type_6_image();
			backImageType_7 = new Event_type_7_image();
			backImageType_8 = new Event_type_8_image();
			backImageNew = new PromoNew();
			
			addChild(backImageType_1);
			addChild(backImageType_2);
			addChild(backImageType_3);
			addChild(backImageType_4);
			addChild(backImageType_5);
			addChild(backImageType_6);
			addChild(backImageType_7);
			addChild(backImageType_8);
			addChild(backImageNew);
			
			backImageType_1.x = padding;
			backImageType_2.x = padding;
			backImageType_3.x = padding;
			backImageType_4.x = padding;
			backImageType_5.x = padding;
			backImageType_6.x = padding;
			backImageType_7.x = padding;
			backImageType_8.x = padding;
			backImageNew.x = padding;
			
			backImageType_1.y = padding;
			backImageType_2.y = padding;
			backImageType_3.y = padding;
			backImageType_4.y = padding;
			backImageType_5.y = padding;
			backImageType_6.y = padding;
			backImageType_7.y = padding;
			backImageType_8.y = padding;
			backImageNew.y = padding;
			
			textFormatTitle.font = Config.defaultFontName;
			textFormatTitle.size = Config.FINGER_SIZE * .3;
			textFormatTitle.color = AppTheme.WHITE;
			
			textFormatValue2.font = Config.defaultFontName;
			textFormatValue2.size = Config.FINGER_SIZE * .7;
			textFormatValue2.color = AppTheme.WHITE;
			
			textFormatButton.font = Config.defaultFontName;
			textFormatButton.size = Config.FINGER_SIZE * .26;
			textFormatButton.color = AppTheme.WHITE;
			
			textFormatValue1.font = Config.defaultFontName;
			textFormatValue1.size = Config.FINGER_SIZE * 1.3;
		//	textFormatValue1.bold = true;
			textFormatValue1.color = AppTheme.WHITE;
			
			title = new TextField();
			title.defaultTextFormat = textFormatTitle;
			title.text = "Pp";
			title.height = title.textHeight + 4;
			title.text = "";
			title.wordWrap = true;
			title.multiline = true;
			addChild(title);
			
			value = new TextField();
			value.defaultTextFormat = textFormatValue1;
			value.text = "Pp";
			value.height = value.textHeight + 4;
			value.text = "";
			value.wordWrap = false;
			value.multiline = false;
			addChild(value);
			
			buttonText = new TextField();
			buttonText.defaultTextFormat = textFormatButton;
			buttonText.text = "Pp";
			buttonText.height = buttonText.textHeight + 4;
			buttonText.text = "";
			buttonText.wordWrap = false;
			buttonText.multiline = false;
			addChild(buttonText);
			
			buttonOutline = new Sprite();
			addChild(buttonOutline);
		}
		
		public function getHeight(item:ListItem, width:int):int {
			if (item.data is String)
				return Config.FINGER_SIZE_DOT_5;
			if (item.num == 0)
			{
				return int(width * 170 / 350) - padding;
			}
			return int(width * 170 / 350);
		}
		
		public function getView(item:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			bg.width = width;
			bg.height = height;
			
			bgHighlight.width = width;
			bgHighlight.height = height;
			
			bg.visible = !highlight;
			bgHighlight.visible = highlight;
			
			var itemData:PromoEvent = item.data as PromoEvent;
			
			backImageType_1.visible = false;
			backImageType_2.visible = false;
			backImageType_3.visible = false;
			backImageType_4.visible = false;
			backImageType_5.visible = false;
			backImageType_6.visible = false;
			backImageType_7.visible = false;
			backImageType_8.visible = false;
			backImageNew.visible = false;
			
			backImageType_1.width = width - padding * 2;
			backImageType_2.width = width - padding * 2;
			backImageType_3.width = width - padding * 2;
			backImageType_4.width = width - padding * 2;
			backImageType_5.width = width - padding * 2;
			backImageType_6.width = width - padding * 2;
			backImageType_7.width = width - padding * 2;
			backImageType_8.width = width - padding * 2;
			backImageNew.width = width - padding * 2;
			
			backImageType_1.scaleY = backImageType_1.scaleX;
			backImageType_2.scaleY = backImageType_2.scaleX;
			backImageType_3.scaleY = backImageType_3.scaleX;
			backImageType_4.scaleY = backImageType_4.scaleX;
			backImageType_5.scaleY = backImageType_5.scaleX;
			backImageType_6.scaleY = backImageType_6.scaleX;
			backImageType_7.scaleY = backImageType_7.scaleX;
			backImageType_8.scaleY = backImageType_8.scaleX;
			backImageNew.scaleY = backImageType_2.scaleX;
			
			if (itemData.type == PromoEvent.TYPE_NEW_EVENT_SOON)
			{
				title.visible = true;
				value.visible = false;
				
				title.text = Lang.newEventSoon;
			}
			else if (itemData.type == PromoEvent.TYPE_MONEY)
			{
				title.visible = true;
				value.visible = true;
				title.text = itemData.getDescription();
				var currency:String;
				if (itemData.currency == TypeCurrency.EUR)
				{
					currency = "€";
				}
				else if (itemData.currency == "DUK")
				{
					currency = " DUK+";
				}
				else{
					currency = itemData.currency;
				}
				value.text = itemData.amount + currency;
			}
			else if (itemData.type == PromoEvent.TYPE_IPHONE)
			{
				title.visible = true;
				value.visible = true;
				title.text = itemData.getDescription();
				value.text = Lang.iphoneX;
			}
			
			textFormatValue1.size = Config.FINGER_SIZE;
			value.setTextFormat(textFormatValue1);
			
			if (itemData.image == PromoEvent.IMAGE_TYPE_1 || itemData.image == PromoEvent.IMAGE_TYPE_3 || 
				itemData.image == PromoEvent.IMAGE_TYPE_5 || itemData.image == PromoEvent.IMAGE_TYPE_6 || itemData.image == PromoEvent.IMAGE_TYPE_9 || 
				itemData.image == PromoEvent.IMAGE_TYPE_8)
			{
				value.setTextFormat(textFormatValue1);
			}
			else if (itemData.image == PromoEvent.IMAGE_TYPE_2 || itemData.image == PromoEvent.IMAGE_TYPE_4)
			{
				value.setTextFormat(textFormatValue2);
			}
			
			if (itemData.type == PromoEvent.TYPE_NEW_EVENT_SOON)
			{
				backImageNew.visible = true;
			}
			else if (itemData.image == PromoEvent.IMAGE_TYPE_1)
			{
				backImageType_1.visible = true;
			}
			else if (itemData.image == PromoEvent.IMAGE_TYPE_2)
			{
				backImageType_2.visible = true;
			}
			else if (itemData.image == PromoEvent.IMAGE_TYPE_3)
			{
				backImageType_3.visible = true;
			}
			else if (itemData.image == PromoEvent.IMAGE_TYPE_4)
			{
				backImageType_4.visible = true;
			}
			else if (itemData.image == PromoEvent.IMAGE_TYPE_5)
			{
				backImageType_5.visible = true;
			}
			else if (itemData.image == PromoEvent.IMAGE_TYPE_6)
			{
				backImageType_6.visible = true;
			}
			else if (itemData.image == PromoEvent.IMAGE_TYPE_8)
			{
				backImageType_7.visible = true;
			}
			else if (itemData.image == PromoEvent.IMAGE_TYPE_9)
			{
				backImageType_8.visible = true;
			}
			
			title.width = width;
			value.width = width;
			
			var maxWidth:int = width * .5;
			if (itemData.type == PromoEvent.TYPE_NEW_EVENT_SOON)
			{
				maxWidth = width * .4;
			}
			
			title.y = int(Config.FINGER_SIZE * .3);
			
			if (itemData.image == PromoEvent.IMAGE_TYPE_2 || itemData.image == PromoEvent.IMAGE_TYPE_4 || itemData.image == PromoEvent.IMAGE_TYPE_8)
			{
				title.y = int(Config.FINGER_SIZE * .8);
			}
			
			title.width = Math.min(maxWidth, title.textWidth + 10);
			title.width = title.textWidth + 10;
			
			value.width = value.textWidth + 4;
			
			title.height = title.textHeight + 4;
			value.height = value.textHeight + 4;
			
			var maxValueWidth:int = width * .37;
			var maxValueHeight:int = height - Config.FINGER_SIZE - title.y - title.height;
			
			var k:Number = Math.max(value.width / maxValueWidth, value.height / maxValueHeight);
			
			
			textFormatValue1.size = value.height / k;
			value.setTextFormat(textFormatValue1);
			value.width = value.textWidth + 4;
			value.height = value.textHeight + 4;
			
			value.y = int(title.y + title.height - Config.FINGER_SIZE * .1);
			
			if (itemData.image == PromoEvent.IMAGE_TYPE_1 || itemData.image == PromoEvent.IMAGE_TYPE_3 || itemData.image == PromoEvent.IMAGE_TYPE_5 || 
				itemData.image == PromoEvent.IMAGE_TYPE_6 || itemData.image == PromoEvent.IMAGE_TYPE_8 || itemData.image == PromoEvent.IMAGE_TYPE_9)
			{
				var xPos:int = width - Math.max(title.width, value.width) - Config.FINGER_SIZE * .4;
				title.x = width - title.width - Config.MARGIN * 2;
				value.x = width - value.width - Config.FINGER_SIZE * .4;
			}
			else if (itemData.image == PromoEvent.IMAGE_TYPE_2 || itemData.image == PromoEvent.IMAGE_TYPE_4)
			{
				title.x = int(Config.FINGER_SIZE * .4);
				value.x = int(Config.FINGER_SIZE * .4);
			}
			if (itemData.type == PromoEvent.TYPE_NEW_EVENT_SOON)
			{
				title.x = int(Config.FINGER_SIZE * .3);
			}
			
		//	value.y = int(title.y + title.height - Config.FINGER_SIZE * .1);
			
		//	itemData.participant = false;
			if (itemData.type == PromoEvent.TYPE_NEW_EVENT_SOON)
			{
				buttonOutline.visible = false;
				buttonText.visible = false;
			}
			else
			{
				buttonOutline.visible = true;
				buttonText.visible = true;
				buttonText.text = Lang.win;
				buttonText.width = buttonText.textWidth + 4;
				buttonOutline.graphics.clear();
				buttonOutline.graphics.lineStyle(1, 0xFFFFFF, 1, true);
				var hPadding:int = Config.FINGER_SIZE * .35;
				var vPadding:int = Config.FINGER_SIZE * .1;
				buttonOutline.graphics.drawRoundRect(0, 0, buttonText.width + hPadding * 2, buttonText.height + vPadding * 2, Config.FINGER_SIZE * .14, Config.FINGER_SIZE * .14);
				buttonOutline.graphics.endFill();
				
				if (itemData.image == PromoEvent.IMAGE_TYPE_1 || itemData.image == PromoEvent.IMAGE_TYPE_3 || itemData.image == PromoEvent.IMAGE_TYPE_5 || 
					itemData.image == PromoEvent.IMAGE_TYPE_6 || itemData.image == PromoEvent.IMAGE_TYPE_8 || itemData.image == PromoEvent.IMAGE_TYPE_9)
				{
					buttonOutline.x = int(width - buttonOutline.width - Config.DIALOG_MARGIN);
				}
				else if (itemData.image == PromoEvent.IMAGE_TYPE_2 || itemData.image == PromoEvent.IMAGE_TYPE_4)
				{
					buttonOutline.x = int(Config.DIALOG_MARGIN);
				}
				
				buttonOutline.y = int(height - buttonOutline.height - Config.MARGIN * 1.6);
				
				buttonText.x = int(buttonOutline.x + hPadding);
				buttonText.y = int(buttonOutline.y + vPadding);
			}
			
			return this;
		}
		
		public function dispose():void {
			UI.destroy(bg);
			bg = null;
			UI.destroy(bgHighlight);
			
			UI.destroy(backImageType_1);
			UI.destroy(backImageType_2);
			UI.destroy(backImageType_3);
			UI.destroy(backImageType_4);
			UI.destroy(backImageType_5);
			UI.destroy(backImageType_6);
			UI.destroy(backImageNew);
			UI.destroy(title);
			UI.destroy(value);
			UI.destroy(buttonText);
			UI.destroy(buttonOutline);
			
			backImageType_1 = null;
			backImageType_2 = null;
			backImageType_3 = null;
			backImageType_4 = null;
			backImageNew = null;
			title = null;
			value = null;
			buttonText = null;
			buttonOutline = null;
			
			bgHighlight = null;
			UI.destroy(this);
			
			textFormatTitle = null;
			textFormatValue1 = null;
			textFormatValue2 = null;
		}
		
		public function get isTransparent():Boolean {
			return true;
		}
	}
}