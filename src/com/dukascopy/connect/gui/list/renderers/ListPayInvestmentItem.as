package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import com.dukascopy.connect.sys.payments.PayInvestmentsManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.EntryPointVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
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
	public class ListPayInvestmentItem extends BaseRenderer implements IListRenderer{
		
	
		
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
		private var investmentAccountNumberTextField:TextField;
		private var balanceTextField:TextField;
		private var amountTextField:TextField;
		
		private var hamburgerMenu:Bitmap;
		
	
		
		/**
		 * 
		 */
		public function ListPayInvestmentItem() {			
			descriptionTextField = new TextField();
			investmentAccountNumberTextField = new TextField();
			balanceTextField = new TextField();
			amountTextField = new TextField();
			addChild(descriptionTextField);
			addChild(investmentAccountNumberTextField);
			addChild(balanceTextField);
			addChild(amountTextField);
			flagIcon = new Bitmap();
			addChild(flagIcon);
			this.mouseChildren = false;
			this.mouseEnabled = false;	
			
			hamburgerMenu = new Bitmap();
			addChild(hamburgerMenu);
			var asset:DisplayObject = new SWFHamburgerIcon();
			UI.colorize(asset, AppTheme.GREY_MEDIUM);
			hamburgerMenu.bitmapData = UI.renderAsset(asset,Config.FINGER_SIZE_DOT_5,Config.FINGER_SIZE_DOT_5,"ListPayInvestmentItem.HamburgerMenu");
		}
		
		
		
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			if (data.data != null && 'itype' in data.data && data.data.itype == 'stats'){
				return Config.FINGER_SIZE*1.5;
			}
			return itemHeight;
		}
		
		
		
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean=false):IBitmapDrawable {
			var data:Object = li.data;
				
			if (data == null) return this;
			
			// Reset all stuff 
			graphics.clear();

			
				
					
			flagIcon.visible = false;
			hamburgerMenu.visible = false;
			descriptionTextField.text = "";
			investmentAccountNumberTextField.text = "";
			balanceTextField.text = "";
			amountTextField.text = "";
			
					
			
					
			if (data != null && 'itype' in data && data.itype == 'stats'){
						
	
				renderStatsView(li, h, width, highlight);
				
			}else {
				flagIcon.visible = true;
				hamburgerMenu.visible = true;			
				renderInvestmentView(li, h, width, highlight);
					
					
			}
			

			
			return this;
		}
		
		
		
		
		
		private function renderInvestmentView(li:ListItem, h:int, width:int, highlight:Boolean=false):void
		{
			var data:Object = li.data;
				
			graphics.lineStyle(1, WALLET_ACENT_COLOR);
			graphics.beginFill(WALLET_BG_COLOR);
			graphics.drawRoundRect(MARGIN_H, MARGIN_V, width - MARGIN_H * 2, h - MARGIN_V * 2, WALLET_CORNER_RADIUS);
			graphics.beginFill(WALLET_ACENT_COLOR);			
			graphics.endFill();
			
			var investmentAccountNumber:String = "";
			var investmentAccountNumberFormated:String = "";
			var investmentDescription:String = "";
			var investmentBalance:String = "";
			var investmentCurrency:String = "";			
			var consolidateCurrency:String = "";
			var consolidateBalance:String = "";
			
			
			investmentAccountNumber = data.ACCOUNT_NUMBER;
			investmentAccountNumberFormated = investmentAccountNumber.length==12? investmentAccountNumber.substr(0, 4) + " " + investmentAccountNumber.substr(4, 4) + " " + investmentAccountNumber.substr(8):investmentAccountNumber;
			investmentDescription = PayInvestmentsManager.getInvestmentNameByInstrument(data.INSTRUMENT);
			investmentBalance = data.BALANCE;
			investmentCurrency = CurrencyHelpers.getCurrencyByKey(data.INSTRUMENT);
			consolidateCurrency = data.CONSOLIDATE_CURRENCY;
			consolidateBalance = data.CONSOLIDATE_BALANCE;
			
			
			
			// colors
			var balanceColor:uint = AppTheme.GREEN_MEDIUM;
			if (consolidateBalance == "0.00"){
				balanceColor = AppTheme.GREY_MEDIUM;
			}
			var fontSize:Number = Config.FINGER_SIZE_DOT_35;
			var currencyFontSize:Number = Config.FINGER_SIZE_DOT_5;
			var investmentAccountNumberFontSize:Number = Config.FINGER_SIZE*.3;
			var investmentBalanceFontSize:Number = Config.FINGER_SIZE_DOT_25;
			var max_description_h:int = (h *.5)- MARGIN_V  - PADDING_V  - investmentAccountNumberFontSize;
			 
			
			// TODO USE TEXTFIELDS INSTEAD OF UI.renderText
					
			// RENDER DESCRIPTION
			if (investmentDescription == null)
				investmentDescription = "";
		
			var tf:TextFormat = new TextFormat("Tahoma", fontSize);
			
			tf.align = TextFormatAlign.LEFT;
			descriptionTextField.multiline = true;
			descriptionTextField.wordWrap = true;
			descriptionTextField.autoSize = TextFieldAutoSize.NONE;
			descriptionTextField.textColor  = AppTheme.GREY_DARK;
			descriptionTextField.defaultTextFormat = tf;
			descriptionTextField.text = investmentDescription;
			//descriptionTextField.border = true;
			descriptionTextField.x = MARGIN_H+ PADDING_H;
			descriptionTextField.y = MARGIN_V + PADDING_V;
			descriptionTextField.width = width - PADDING_H * 2 - MARGIN_H * 2 - ICON_SIZE-10;
			descriptionTextField.height = max_description_h;
			
			//NUMBER 
			tf.align = TextFormatAlign.RIGHT;
			tf.size = investmentAccountNumberFontSize;			
			investmentAccountNumberTextField.autoSize = TextFieldAutoSize.RIGHT;
			investmentAccountNumberTextField.multiline = true;
			investmentAccountNumberTextField.wordWrap = true;
			investmentAccountNumberTextField.textColor = AppTheme.GREY_MEDIUM;
			investmentAccountNumberTextField.defaultTextFormat = tf;			
			investmentAccountNumberTextField.text = investmentAccountNumberFormated;
			//investmentAccountNumberTextField.border = true;
			investmentAccountNumberTextField.width = width - PADDING_H * 2-MARGIN_H*2; 
			investmentAccountNumberTextField.height = investmentAccountNumberTextField.textHeight + 4;
			investmentAccountNumberTextField.x = MARGIN_H+PADDING_H; 
			investmentAccountNumberTextField.y = (h - investmentAccountNumberTextField.height) * .5;
			
			
			// RENDER BALANCE  	
			tf.align = TextFormatAlign.RIGHT;
			tf.size = investmentAccountNumberFontSize;			
			balanceTextField.autoSize = TextFieldAutoSize.NONE;
			//balanceTextField.border = true;
			balanceTextField.multiline = false;
			balanceTextField.wordWrap = false;
			balanceTextField.textColor = AppTheme.GREY_MEDIUM;
			balanceTextField.defaultTextFormat = tf;			
			balanceTextField.text = consolidateBalance +" "+ CurrencyHelpers.getCurrencyByKey(consolidateCurrency);// Lang.textBalance + ":";
			//balanceTextField.htmlText = UI.renderCurrency(consolidateBalance,consolidateCurrency," ",investmentAccountNumberFontSize,investmentAccountNumberFontSize*.8);// Lang.textBalance + ":";
			balanceTextField.width = width - PADDING_H * 2 - MARGIN_H * 2;
			balanceTextField.height = balanceTextField.textHeight+4;			
			balanceTextField.x = width-balanceTextField.width - MARGIN_H-PADDING_H; 
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
			//amountTextField.text = investmentBalance+" " + investmentCurrency;// data.CURRENCY;
			amountTextField.htmlText = UI.renderCurrency(investmentBalance," "+investmentCurrency,"",currencyFontSize,currencyFontSize*.7);// data.CURRENCY;
			amountTextField.width = width - PADDING_H * 2 - MARGIN_H * 2;	
			amountTextField.height = amountTextField.textHeight + 4;		
			amountTextField.x = width - amountTextField.width - MARGIN_H - PADDING_H; 
			amountTextField.y = h - amountTextField.height -PADDING_V - MARGIN_V- balanceTextField.height; 
			
			
			

			UI.disposeBMD(flagIcon.bitmapData);			
			if(data.INSTRUMENT!=""){
				var flagAsset:Sprite = UI.getInvestIconByInstrument(data.INSTRUMENT);			
				flagIcon.bitmapData = UI.renderAsset(flagAsset, ICON_SIZE, ICON_SIZE, false, "ListPayWalletItemAdvanced.flagIcon");
				flagAsset = null;
			}
			
			flagIcon.x = width-flagIcon.width - MARGIN_H-PADDING_H;
			flagIcon.y = MARGIN_V+PADDING_V;// (itemHeight - flagIcon.height) * .5;
		
			// menu button 
			hamburgerMenu.x = MARGIN_H+PADDING_H;
			hamburgerMenu.y = h - hamburgerMenu.height -PADDING_V - MARGIN_V;
			
			tf = null;
			
			var hitZones:Vector.<HitZoneData> = new Vector.<HitZoneData>();
			
			var hz:HitZoneData = new HitZoneData();
			hz.type = HitZoneType.INVESTMENT_MENU;
			hz.x = hamburgerMenu.x-PADDING_H;
			hz.y = hamburgerMenu.y - PADDING_V;
			hz.width = hamburgerMenu.width + PADDING_H * 2;
			hz.height = hamburgerMenu.height + PADDING_V * 2;
			
			hitZones.push(hz);
			
			li.setHitZones(hitZones);
		}
		
		private function renderStatsView(li:ListItem, h:int, width:int, highlight:Boolean=false):void
		{
			var data:Object = li.data;
			
			//graphics.lineStyle(1, WALLET_ACENT_COLOR);
			//graphics.beginFill(WALLET_BG_COLOR);
			//graphics.drawRoundRect(MARGIN_H, MARGIN_V, width - MARGIN_H * 2, h - MARGIN_V * 2,0);
			//graphics.beginFill(WALLET_ACENT_COLOR);			
			//graphics.endFill();
			//
			
			var tf:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE_DOT_25);
			var investmentAccountNumberFontSize:Number = Config.FINGER_SIZE * .3;
				
			tf.align = TextFormatAlign.LEFT;
			
			// Title
			descriptionTextField.multiline = true;
			descriptionTextField.wordWrap = true;
			descriptionTextField.autoSize = TextFieldAutoSize.LEFT;
			descriptionTextField.textColor  = AppTheme.GREY_DARK;
			descriptionTextField.defaultTextFormat = tf;
			descriptionTextField.text = data.title;
			//descriptionTextField.border = true;
			descriptionTextField.x = MARGIN_H+ PADDING_H;
			descriptionTextField.y = MARGIN_V+Config.MARGIN;// + PADDING_V;
			descriptionTextField.width = width - PADDING_H * 2 - MARGIN_H * 2;
			//descriptionTextField.height = max_description_h;
			
			//  BALANCE  	
			tf.align = TextFormatAlign.LEFT;
			tf.size = investmentAccountNumberFontSize;			
			balanceTextField.autoSize = TextFieldAutoSize.NONE;
			//balanceTextField.border = true;
			balanceTextField.multiline = false;
			balanceTextField.wordWrap = false;
			balanceTextField.textColor = AppTheme.GREY_MEDIUM;
			balanceTextField.defaultTextFormat = tf;			
			//balanceTextField.text = consolidateBalance +" "+ CurrencyHelpers.getCurrencyByKey(consolidateCurrency);// Lang.textBalance + ":";
			balanceTextField.width = width - PADDING_H * 2 - MARGIN_H * 2;
			balanceTextField.height = Config.FINGER_SIZE;		
			//
			//balanceTextField.x = width - balanceTextField.width - MARGIN_H - PADDING_H; 			
			//balanceTextField.y = h - balanceTextField.height -PADDING_V - MARGIN_V;
				var balance:String = data.balance;
				var currency:String = data.currency;
				
				
				
			// Format AMOUNT =============================
				var balanceColorString:String = "#77c043";
				if (balance.charAt(0) == "-") {
					balanceColorString = "#cd3f43";			
				}	
				var dotIndex:int = balance.indexOf(".");
				var leftNum:String = "";
				var rightNum:String = "";
				var stringAmount:String = "";
				if (dotIndex != -1){
					leftNum = balance.substring(0, dotIndex);
					if (leftNum == ""){
						leftNum = "0";
					}
					// trim to fixed 
					var numDecimals:int = CurrencyHelpers.getMaxDecimalCount(currency);
					rightNum = balance.substring(dotIndex + 1, dotIndex+1+numDecimals) + " " + CurrencyHelpers.getCurrencyByKey(currency);
					//rightNum = balance.substring(dotIndex + 1, balance.length) + " " + CurrencyHelpers.getCurrencyByKey(currency);
					stringAmount = UI.getCurrencyTextHTML(leftNum + ".", rightNum, Config.FINGER_SIZE*.42, Config.FINGER_SIZE*.3,balanceColorString,balanceColorString);
				}else{						
					if(CurrencyHelpers.getMaxDecimalCount(currency)>0){
						leftNum = balance+".";
						rightNum = CurrencyHelpers.getZerosForCurrency(currency) +" "+ CurrencyHelpers.getCurrencyByKey(currency);
					}else{
						leftNum = balance;
						rightNum = " " +CurrencyHelpers.getCurrencyByKey(currency);
					}					
					stringAmount = UI.getCurrencyTextHTML(leftNum + "", rightNum, Config.FINGER_SIZE * .42, Config.FINGER_SIZE*.3, balanceColorString, balanceColorString);
				}
				// END Format Amount ========================
					
			//tfInteger.border = true;
			balanceTextField.htmlText = stringAmount;
			balanceTextField.x = MARGIN_H + PADDING_H;
			balanceTextField.y = descriptionTextField.y + descriptionTextField.height;// MARGIN_V + Config.MARGIN +Config.FINGER_SIZE_DOT_35;
				

			
			
		}
		
		
		
		
		
		
		
		
		public function dispose():void {
			graphics.clear();
			UI.destroy(hamburgerMenu);
			hamburgerMenu = null;
			
			///trace(this, "dispose  XXXXX");
			UI.destroy(descriptionTextField);
			descriptionTextField = null;
			UI.destroy(investmentAccountNumberTextField);
			investmentAccountNumberTextField = null;			
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