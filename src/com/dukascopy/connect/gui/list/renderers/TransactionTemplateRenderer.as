package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
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
	
	public class TransactionTemplateRenderer extends BaseRenderer implements IListRenderer {
		private var contentPadding:int;
		
		protected var textFormat:TextFormat = new TextFormat();
		protected var textFormatAmount:TextFormat = new TextFormat();
		protected var textFormatSubtitle:TextFormat = new TextFormat();
		
		protected var text:TextField;
		protected var amount:TextField;
		protected var subtitle:TextField;
		protected var bg:Shape;
		
		public function TransactionTemplateRenderer(){
			
			contentPadding = Config.FINGER_SIZE * .3;
			
			bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, 0, 10, 10);
				bg.graphics.endFill();
				bg.graphics.beginFill(0x66A5E3, .20);
				bg.graphics.drawRect(0, 9, 10, 1);
				bg.scale9Grid = new Rectangle(1, 1, 8, 5);
			addChild(bg);
				
				text = new TextField();
				textFormat.font = Config.defaultFontName;
				textFormat.color = Style.color(Style.COLOR_TEXT);
				textFormat.size = FontSize.BODY;
				text.defaultTextFormat = textFormat;
				text.text = "Pp";
				text.height = text.textHeight + 4;
				text.text = "";
				text.x = contentPadding;
				text.wordWrap = true;
				text.y = Config.MARGIN * 1.5;
				text.multiline = true;
			addChild(text);
			
			amount = new TextField();
				textFormatAmount.font = Config.defaultFontName;
				textFormatAmount.color = Color.BLUE;
				textFormatAmount.size = FontSize.BODY;
				amount.defaultTextFormat = textFormatAmount;
				amount.text = "Pp";
				amount.height = amount.textHeight + 4;
				amount.text = "";
				amount.x = contentPadding;
				amount.wordWrap = false;
				amount.y = Config.MARGIN * 1.5;
				amount.multiline = false;
			addChild(amount);
			
			subtitle = new TextField();
				textFormatSubtitle.font = Config.defaultFontName;
				textFormatSubtitle.color = Style.color(Style.COLOR_SUBTITLE);
				textFormatSubtitle.size = FontSize.SUBHEAD;
				subtitle.defaultTextFormat = textFormatSubtitle;
				subtitle.text = "Pp";
				subtitle.height = subtitle.textHeight + 4;
				subtitle.text = "";
				subtitle.x = contentPadding;
				subtitle.wordWrap = false;
				subtitle.y = Config.MARGIN * 1.5;
				subtitle.multiline = false;
			addChild(subtitle);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			return setText(data, width);
		}
		
		private function setText(data:ListItem, width:int):int 
		{
			if (data.data != null)
			{
				var textWidth:int;
				
				if ("amount" in data.data && "currency" in data.data && data.data.amount != null)
				{
					var currency:String = data.data.currency;
					if (Lang[currency] != null)
					{
						currency = Lang[currency];
					}
					amount.width = width;
					amount.text = data.data.amount + " " + currency;
					amount.width = amount.textWidth + 4;
					amount.height = amount.textHeight + 4;
					amount.x = width - amount.width - contentPadding;
				}
				else
				{
					amount.text = "";
				}
				
				var position:int = 0;
				if ("name" in data.data && data.data.name != null)
				{
					textWidth = width - text.x - contentPadding;
					if (amount.text != "")
					{
						textWidth -= amount.width - Config.MARGIN;
					}
					text.width = textWidth;
					text.text = data.data.name;
					text.height = text.textHeight + 4;
					position += text.y + text.height + Config.MARGIN * 0.5;
				}
				else
				{
					text.text = "";
				}
				
				var comment:String;
				if ("userUid" in data.data && data.data.userUid != null && 
					data.data.userUid is String && (data.data.userUid as String).length > 0)
				{
					if ((data.data.userUid as String).charAt(0) == "+")
					{
						comment = Lang.moneyTransferToPhone + " " + data.data.userUid;
					}
					else
					{
						var user:UserVO = UsersManager.getUserByUID(data.data.userUid);
						if (user != null)
						{
							comment = Lang.moneyTransferToContact + " " + user.getDisplayName();
						}
					}
				}
				
				if (comment != null)
				{
					subtitle.y = position;
					textWidth = width - subtitle.x - contentPadding;
					subtitle.width = textWidth;
					subtitle.text = comment;
					subtitle.height = subtitle.textHeight + 4;
					position += subtitle.height;
				}
				else
				{
					subtitle.text = "";
				}
				
				position += Config.MARGIN;
				
				return position;
			}
			return Config.FINGER_SIZE;
		}
		
		public function getView(data:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			setText(data, width);
			
			bg.width = width;
			bg.height = height;
			
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
			if (subtitle != null)
				UI.destroy(subtitle);
			subtitle = null;
			if (bg != null)
				bg.graphics.clear();
			bg = null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}