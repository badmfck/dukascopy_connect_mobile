package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.promoEvent.PromoEventWinner;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * @author Sergey Dobarin. Telefision AG.
	 */
	
	public class ListPromoEventWinner extends BaseRenderer implements IListRenderer {
		
		private var time:flash.text.TextField;
		private var value:flash.text.TextField;
		private var user:flash.text.TextField;
		private var date:Date;
		
		protected var bg:Shape;
		protected var bgHighlight:Shape;
		protected var textFormatTitle:TextFormat = new TextFormat();
		protected var textFormatValue:TextFormat = new TextFormat();
		protected var textFormatUser:TextFormat = new TextFormat();
		
		
		public function ListPromoEventWinner() {
			
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
			
			textFormatTitle.font = Config.defaultFontName;
			textFormatTitle.size = Config.FINGER_SIZE * .24;
			textFormatTitle.color = AppTheme.GREY_DARK;
			
			textFormatValue.font = Config.defaultFontName;
			textFormatValue.size = Config.FINGER_SIZE * .24;
			textFormatValue.color = AppTheme.GREEN_MEDIUM;
			
			textFormatUser.font = Config.defaultFontName;
			textFormatUser.size = Config.FINGER_SIZE * .24;
			textFormatUser.color = AppTheme.GREY_DARK;
			
			time = new TextField();
			time.defaultTextFormat = textFormatTitle;
			time.text = "Pp";
			time.height = time.textHeight + 4;
			time.text = "";
			time.wordWrap = false;
			time.multiline = false;
			addChild(time);
			
			user = new TextField();
			user.defaultTextFormat = textFormatUser;
			user.text = "Pp";
			user.height = user.textHeight + 4;
			user.text = "";
			user.wordWrap = false;
			user.multiline = false;
			addChild(user);
			
			value = new TextField();
			value.defaultTextFormat = textFormatValue;
			value.text = "Pp";
			value.height = value.textHeight + 4;
			value.text = "";
			value.wordWrap = false;
			value.multiline = false;
			addChild(value);
			
			time.y = user.y = value.y = Config.MARGIN;
			time.x = Config.MARGIN;
			user.x = Config.FINGER_SIZE * 1.5;
			
			date = new Date();
		}
		
		public function getHeight(item:ListItem, width:int):int {
			if (item.data is String)
				return Config.FINGER_SIZE_DOT_5;
			return Config.FINGER_SIZE * .6;
		}
		
		public function getView(item:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			bg.width = width;
			bg.height = height;
			
			bgHighlight.width = width;
			bgHighlight.height = height;
			
			bg.visible = !highlight;
			bgHighlight.visible = highlight;
			
			var itemData:PromoEventWinner = item.data as PromoEventWinner;
			
			var currency:String;
			if (itemData.currency == TypeCurrency.EUR)
			{
				currency = "€";
			}
			else{
				currency = itemData.currency;
			}
			
			date.setTime(itemData.win_time*1000);
			time.text = DateUtils.getComfortDateRepresentationOnlyDate(date);
			time.width = time.textWidth + 10;
			
			var userName:String;
			if (itemData.user != null && itemData.user.getDisplayName() != null)
			{
				userName = itemData.user.getDisplayName();
			}
			else
			{
				userName = Lang.user;
			}
			if (itemData.user != null && itemData.user.uid == Auth.uid)
			{
				userName += " (" + Lang.me + ")";
			}
			user.text = userName;
			user.width = user.textWidth + 10;
			
			if (itemData.amount == 0)
			{
				value.text = Lang.iphoneX;
			}
			else{
				value.text = itemData.amount + currency;
			}
			value.width = value.textWidth + 10;
			value.x = width - value.width - Config.MARGIN;
			
			return this;
		}
		
		public function dispose():void {
			UI.destroy(bg);
			bg = null;
			UI.destroy(bgHighlight);
			
			UI.destroy(time);
			UI.destroy(user);
			UI.destroy(value);
			
			time = null;
			user = null;
			value = null;
			
			bgHighlight = null;
			UI.destroy(this);
			
			textFormatTitle = null;
			textFormatValue = null;
			textFormatUser = null;
		}
		
		public function get isTransparent():Boolean {
			return true;
		}
	}
}