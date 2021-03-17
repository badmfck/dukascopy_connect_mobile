package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.vo.EntryPointVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Alexey
	 */
	public class ListPayWalletItemAdvanced extends BaseRenderer implements IListRenderer{
		
	
		
		private var padding:int = Config.FINGER_SIZE * .3;
		
		private var itemHeight:int = Config.FINGER_SIZE * 4;
		
		private var LINE_HEIGHT:int = Config.FINGER_SIZE;
		private var ICON_SIZE:int = Config.FINGER_SIZE*.85+8;
		
		
		private var MARGIN_H:int = Config.FINGER_SIZE * .4;
		private var MARGIN_V:int = Config.FINGER_SIZE * .2;
		private var PADDING_V:int = Config.FINGER_SIZE * .4;
		private var PADDING_H:int = Config.FINGER_SIZE * .4;
		private var WALLET_BG_COLOR:uint = 0xffffff;
		private var WALLET_ACENT_COLOR:uint = AppTheme.GREY_SEMI_LIGHT;
		private var WALLET_CORNER_RADIUS:int = Config.FINGER_SIZE * .3;

		private var flagIcon:Bitmap;

		private var descriptionTextField:TextField;
		private var walletNumberTextField:TextField;
		private var balanceTextField:TextField;
		private var amountTextField:TextField;
	
		
		/**
		 * 
		 */
		public function ListPayWalletItemAdvanced() {			
			descriptionTextField = new TextField();
			walletNumberTextField = new TextField();
			balanceTextField = new TextField();
			amountTextField = new TextField();
			addChild(descriptionTextField);
			addChild(walletNumberTextField);
			addChild(balanceTextField);
			addChild(amountTextField);
			flagIcon = new Bitmap();
			addChild(flagIcon);
			this.mouseChildren = false;
			this.mouseEnabled = false;			
		}
		
		
		
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			return itemHeight;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean=false):IBitmapDrawable {
			var data:Object = li.data;
				
			if (data == null) return this;
			graphics.clear();
			graphics.lineStyle(1, WALLET_ACENT_COLOR);
			graphics.beginFill(WALLET_BG_COLOR);
			graphics.drawRoundRect(MARGIN_H, MARGIN_V, width - MARGIN_H * 2, h - MARGIN_V * 2, WALLET_CORNER_RADIUS);
			graphics.beginFill(WALLET_ACENT_COLOR);
			//graphics.drawCircle(width - MARGIN_H -PADDING_H-ICON_SIZE*.5, MARGIN_V + PADDING_V + ICON_SIZE*.5, ICON_SIZE*.5+4);
			//graphics.drawRect(width-MARGIN_H-ICON_SIZE , MARGIN_V+PADDING_V, ICON_SIZE, ICON_SIZE);
			graphics.endFill();
			
			var walletNumber:String = "";
			var walletNumberFormated:String = "";
			var walletDescription:String = "";
			var walletBalance:String = "";
			var walletCurrency:String = "";
			
			if (data == null) {
				walletNumber = "";
				walletNumberFormated = "";
				walletBalance = "";
				walletCurrency=""
			}else {				
				walletNumber = data.ACCOUNT_NUMBER;
				walletNumberFormated =walletNumber.length>=8? walletNumber.substr(0, 4) + " " + walletNumber.substr(4, 4) + " " + walletNumber.substr(8):"";
				if (data.IBAN != null){
					walletNumberFormated = data.IBAN;
				}
				walletDescription = data.DESCRIPTION;
				walletBalance = data.BALANCE;
				walletCurrency = data.CURRENCY;
			}
			
			// colors
			var balanceColor:uint = AppTheme.GREEN_MEDIUM;
			
			//if (highlight) {
				//graphics.beginFill(AppTheme.GREY_SEMI_LIGHT);
				//graphics.drawRect(0, 0, width, h);
				//graphics.endFill();
				//tfLabel.textColor = 0xFFFFFF;
			//} else {
				//tfLabel.textColor = AppTheme.GREY_MEDIUM;
			//}
			
			var fontSize:Number = Config.FINGER_SIZE_DOT_35;
			var currencyFontSize:Number = Config.FINGER_SIZE_DOT_5;
			var walletNumberFontSize:Number = Config.FINGER_SIZE*.3;
			var walletBalanceFontSize:Number = Config.FINGER_SIZE_DOT_25;
			var max_description_h:int = (h *.5)- MARGIN_V  - PADDING_V  - walletNumberFontSize;
			 
			
			// TODO USE TEXTFIELDS INSTEAD OF UI.renderText
					
			// RENDER DESCRIPTION
			if (walletDescription == null)
				walletDescription = "";
		
			var tf:TextFormat = new TextFormat("Tahoma", fontSize);
			tf.align = TextFormatAlign.LEFT;
			descriptionTextField.multiline = true;
			descriptionTextField.wordWrap = true;
			descriptionTextField.autoSize = TextFieldAutoSize.NONE;
			descriptionTextField.textColor  = AppTheme.GREY_DARK;
			descriptionTextField.defaultTextFormat = tf;
			descriptionTextField.text = walletDescription;
			//descriptionTextField.border = true;
			descriptionTextField.x = MARGIN_H+ PADDING_H;
			descriptionTextField.y = MARGIN_V + PADDING_V;
			descriptionTextField.width = width - PADDING_H * 2 - MARGIN_H * 2 - ICON_SIZE-10;
			descriptionTextField.height = max_description_h;
			
			
			//NUMBER 
			tf.align = TextFormatAlign.LEFT;
			tf.size = walletNumberFontSize;			
			walletNumberTextField.autoSize = TextFieldAutoSize.LEFT;
			walletNumberTextField.multiline = true;
			walletNumberTextField.wordWrap = true;
			walletNumberTextField.textColor = AppTheme.GREY_MEDIUM;
			walletNumberTextField.defaultTextFormat = tf;			
			walletNumberTextField.text = walletNumberFormated;
			//walletNumberTextField.border = true;
			walletNumberTextField.width = width - PADDING_H * 2-MARGIN_H*2; 
			walletNumberTextField.height = walletNumberTextField.textHeight + 4;
			walletNumberTextField.x = MARGIN_H+PADDING_H; 
			walletNumberTextField.y = (h - walletNumberTextField.height) * .5;
			
			
			// RENDER BALANCE  	
			tf.align = TextFormatAlign.LEFT;
			tf.size = walletNumberFontSize;			
			balanceTextField.autoSize = TextFieldAutoSize.LEFT;
			//balanceTextField.border = true;
			balanceTextField.multiline = false;
			balanceTextField.wordWrap = false;
			balanceTextField.textColor = AppTheme.GREY_MEDIUM;
			balanceTextField.defaultTextFormat = tf;			
			balanceTextField.text = Lang.textBalance + ":";
			balanceTextField.width = width * .5;
			balanceTextField.height = balanceTextField.textHeight+4;			
			balanceTextField.x = MARGIN_H+PADDING_H; 
			balanceTextField.y = h - balanceTextField.height -PADDING_V - MARGIN_V;
			
			
			// AMOUNT BALANCE  
			tf.align = TextFormatAlign.RIGHT;
			tf.size = currencyFontSize;			
			amountTextField.autoSize = TextFieldAutoSize.NONE;
			//amountTextField.border = true;
			amountTextField.multiline = false;
			amountTextField.wordWrap = false;
			amountTextField.textColor = balanceColor;
			amountTextField.defaultTextFormat = tf;			
			amountTextField.text = walletBalance+" " + data.CURRENCY;
			amountTextField.width = width - PADDING_H * 2 - MARGIN_H * 2;	
			amountTextField.height = amountTextField.textHeight + 4;		
			amountTextField.x = width-amountTextField.width-MARGIN_H-PADDING_H; 
			amountTextField.y = h - amountTextField.height -PADDING_V - MARGIN_V; 
			
			
			
			// RENDER FLAG 
			// todo maybe render flag the same way like an asset?
			UI.disposeBMD(flagIcon.bitmapData);			
			if(walletCurrency!=""){
				var flagAsset:Sprite = UI.getFlagByCurrency(walletCurrency);			
				flagIcon.bitmapData = UI.renderAsset(flagAsset, ICON_SIZE, ICON_SIZE, false, "ListPayWalletItemAdvanced.flagIcon");
			}
			
			flagIcon.x = width-flagIcon.width - MARGIN_H-PADDING_H;
			flagIcon.y = MARGIN_V+PADDING_V;// (itemHeight - flagIcon.height) * .5;
		
			tf = null;
			return this;
		}
		
		
		
		
		public function dispose():void {
			graphics.clear();
			///trace(this, "dispose  XXXXX");
			UI.destroy(descriptionTextField);
			descriptionTextField = null;
			UI.destroy(walletNumberTextField);
			walletNumberTextField = null;			
			UI.destroy(balanceTextField);
			balanceTextField = null;
			UI.destroy(amountTextField);
			amountTextField = null;			
			UI.destroy(flagIcon);
			flagIcon = null;
	
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}