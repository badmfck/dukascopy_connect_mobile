package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TransactionData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import fl.motion.Color;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class PendingTransactionsRenderer extends BaseRenderer implements IListRenderer {
		
		private var date:Date;
		
		protected var textFormat:TextFormat = new TextFormat();
		protected var textFormatAmount:TextFormat = new TextFormat();
		protected var textFormatSubtitle:TextFormat = new TextFormat();
		
		protected var text:TextField;
		protected var amount:TextField;
		protected var subtitle:TextField;
		protected var bg:Shape;
		protected var bgHighlight:Shape;
		
		public function PendingTransactionsRenderer(){
			bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, 0, 10, 10);
				bg.graphics.endFill();
				bg.graphics.beginFill(0x66A5E3, .20);
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
				
				text = new TextField();
				textFormat.font = Config.defaultFontName;
				textFormat.color = 0x4C5762;
				textFormat.size = Config.FINGER_SIZE * .26;
				text.defaultTextFormat = textFormat;
				text.text = "Pp";
				text.height = text.textHeight + 4;
				text.text = "";
				text.x = Config.DIALOG_MARGIN;
				text.wordWrap = false;
				text.y = Config.MARGIN * 1.5;
				text.multiline = false;
			addChild(text);
			
			amount = new TextField();
				textFormatAmount.font = Config.defaultFontName;
				textFormatAmount.color = 0xE07800;
				textFormatAmount.size = Config.FINGER_SIZE * .33;
				amount.defaultTextFormat = textFormatAmount;
				amount.text = "Pp";
				amount.height = amount.textHeight + 4;
				amount.text = "";
				amount.x = Config.DIALOG_MARGIN;
				amount.wordWrap = false;
				amount.y = Config.MARGIN * 1.5;
				amount.multiline = false;
			addChild(amount);
			
			amount.x = Config.DIALOG_MARGIN;
			amount.y = int(Config.FINGER_SIZE * .5 - amount.height * .5);
			
			text.x = Config.DIALOG_MARGIN;
			text.y = int(Config.FINGER_SIZE * .5 - amount.height * .5);
			
			date = new Date();
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			return setText(data, width);
		}
		
		private function setText(data:ListItem, width:int):int 
		{
			var item:TransactionData = data.data as TransactionData;
			
			if (item != null)
			{
				var textWidth:int;
				
				var currency:String = item.currency;
				if (Lang[currency] != null)
				{
					currency = Lang[currency];
				}
				amount.width = width;
				amount.text = item.amount + " " + currency;
				amount.width = amount.textWidth + 4;
				amount.height = amount.textHeight + 4;
				amount.width = amount.textWidth + 4;
				
				textWidth = width - amount.x - amount.width;
				
				text.width = width;
				date.setTime(item.expire * 1000);
				text.text = Lang.expire + ": " + DateUtils.getTimeString(date);
				text.height = text.textHeight + 4;
				text.width = text.textWidth + 4;
				text.x = int(width - Config.DIALOG_MARGIN - text.width);
			}
			return Config.FINGER_SIZE;
		}
		
		public function getView(data:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			setText(data, width);
			
			bg.width = width;
			bg.height = height;
			
			bgHighlight.width = width;
			bgHighlight.height = height;
			
			bg.visible = !highlight;
			bgHighlight.visible = highlight;
			
			return this;
		}
		
		public function dispose():void {
			graphics.clear();
			textFormat = null;
			if (text != null)
				UI.destroy(text);
			text = null;
			if (amount != null)
				UI.destroy(amount);
			amount = null;
			if (bg != null)
				bg.graphics.clear();
			bg = null;
			if (bgHighlight != null)
				bgHighlight.graphics.clear();
			bgHighlight = null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}