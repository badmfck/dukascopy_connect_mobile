package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.BankBotChatScreen;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BAInvestmentSection extends Sprite {
		
		private var tfColorSelected:uint = 0x2B5FAB;
		private var tfColorBase:uint = 0x22546B;
		private var tfSizeSelected:int = Config.FINGER_SIZE * .23;
		private var tfSizeBase:int = Config.FINGER_SIZE * .2;
		
		private var tfNumber:TextField;
		private var tfAmount:TextField;
		private var tfAmountInCurrency:TextField;
		private var iconTriangle:Bitmap;
		private var iconTriangleIcon:SWFTriangleGreen;
		
		private var trueWidth:int;
		private var trueHeight:int;
		public var isTotal:Boolean = false;
		public var isLast:Boolean = false;
		public var data:Object;
		private var _isDisposed:Boolean = false;
		
		private var flagIcon:Bitmap;
		private var ICON_SIZE:int = Config.FINGER_SIZE * .45;
		
		public function BAInvestmentSection() {
			iconTriangleIcon = new SWFTriangleGreen();
			var asset:BitmapData = UI.drawAssetToRoundRect(iconTriangleIcon, Config.FINGER_SIZE_DOT_5, true, "BAInvestmentSectoin.swissIcon");
			iconTriangle = new Bitmap(asset);
			iconTriangle.x = -Config.FINGER_SIZE_DOT_25;
			
			tfNumber = new TextField();
			tfNumber.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, tfColorBase);
			tfNumber.multiline = false;
			tfNumber.wordWrap = false;
			tfNumber.text = "|";
			tfNumber.height = tfNumber.textHeight + 4;
			tfNumber.x = Config.FINGER_SIZE_DOT_25 + Config.DOUBLE_MARGIN - 2;
			tfNumber.y = Config.MARGIN;
			addChild(tfNumber);
			
			tfAmount = new TextField();
			tfAmount.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .25);
			tfAmount.multiline = false;
			tfAmount.wordWrap = false;
			tfAmount.text = "|";
			tfAmount.height = tfAmount.textHeight + 4;
			tfAmount.y = int(tfNumber.height + Config.FINGER_SIZE * .02) + Config.MARGIN;
			tfAmount.x = tfNumber.x;
			addChild(tfAmount);
			
			tfAmountInCurrency = new TextField();
			tfAmountInCurrency.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .25);
			tfAmountInCurrency.multiline = false;
			tfAmountInCurrency.wordWrap = false;
			tfAmountInCurrency.autoSize = TextFieldAutoSize.LEFT;
			tfAmountInCurrency.text = "|";
			tfAmountInCurrency.height = tfAmount.textHeight + 4;
			tfAmountInCurrency.y = tfAmount.y + tfAmount.height;// int(tfNumber.height + Config.FINGER_SIZE * .06) + Config.MARGIN;
			tfAmountInCurrency.x = tfNumber.x;
			addChild(tfAmountInCurrency);
			
			flagIcon = new Bitmap();
			addChild(flagIcon);
			
			trueHeight = Config.FINGER_SIZE * .15 + Config.FINGER_SIZE * .5 + Config.MARGIN * 4;
			
			iconTriangle.y = int((trueHeight - iconTriangle.height) * .5);
		}
		
		public function getHeight():int {
			return trueHeight;
		}
		
		public function setData(data:Object, w:int):void {
			if (_isDisposed) return;
			this.data = data;
			var leftX:int =  Config.FINGER_SIZE_DOT_25 + Config.DOUBLE_MARGIN - 2;		
			
			var investmentName:String = Lang.investmentsTitles[data.INSTRUMENT];
			tfNumber.text = (!investmentName) ? ((data.type == "total") ? data.ACCOUNT_NUMBER : data.INSTRUMENT) : investmentName; // data.ACCOUNT_NUMBER;
			
			
			if (MobileGui.stage.stageWidth <= 640){	
				leftX = Config.FINGER_SIZE_DOT_25 + Config.MARGIN*.5;
			}else{
				leftX = Config.FINGER_SIZE_DOT_25 + Config.DOUBLE_MARGIN - 2;
			}
			
			tfNumber.x = leftX;
			
			if (w < tfNumber.textWidth + 4)
				tfNumber.width = w;
			else
				tfNumber.width = tfNumber.textWidth + 4;
			
			tfAmount.htmlText = UI.renderCurrencyAdvanced(
				data.BALANCE,
				data.INSTRUMENT,
				Config.FINGER_SIZE * .25,
				Config.FINGER_SIZE * .19
			);
			tfAmount.width = tfAmount.textWidth + 4;
			
			var stickToLeft:Boolean = false;
			if (BankManager.getIsInvestmentHistory() == true && BankManager.getHistoryAccount() == data.INSTRUMENT && MobileGui.centerScreen.currentScreenClass != BankBotChatScreen) {
				tfAmount.textColor = tfColorSelected;
				if (iconTriangle != null && iconTriangle.parent == null){
					addChild(iconTriangle);
					stickToLeft = true;
				}
			} else {
				tfAmount.textColor = 0;
				if (iconTriangle != null && iconTriangle.parent != null)
					removeChild(iconTriangle);
			}
			if (data.CONSOLIDATE_BALANCE != null) {
				tfAmountInCurrency.htmlText = UI.renderCurrencyAdvanced(
					data.CONSOLIDATE_BALANCE,
					data.CONSOLIDATE_CURRENCY,
					Config.FINGER_SIZE * .25,
					Config.FINGER_SIZE * .19
				);			
				
				tfNumber.y = Config.MARGIN;
				tfAmount.y = trueHeight * .5 - tfAmount.height * .5 - 2;
				
				tfAmountInCurrency.y = trueHeight - tfAmountInCurrency.height - Config.MARGIN;
			} else {
				tfNumber.y = Config.MARGIN;
				tfAmount.y = int(tfNumber.height + Config.FINGER_SIZE * .02) + Config.MARGIN * 2;
				tfAmountInCurrency.text = "";
			}
			UI.disposeBMD(flagIcon.bitmapData);			
			if (data.INSTRUMENT != "" && data.type != "total") {
				flagIcon.visible = true;
				var flagAsset:Sprite = UI.getInvestIconByInstrument(data.INSTRUMENT);
				flagIcon.bitmapData = UI.renderAsset(flagAsset, ICON_SIZE, ICON_SIZE, false, "BAInvestmentSection.flagIcon");
				flagAsset = null;
				if (data.CONSOLIDATE_BALANCE != null) {
					flagIcon.y = tfAmount.y + tfAmount.height - ICON_SIZE * .5 - Config.FINGER_SIZE * .025 ;
				} else {
					tfAmount.width = w - Config.DOUBLE_MARGIN * 4 - ICON_SIZE;
					tfAmount.htmlText = UI.renderCurrency(
						Lang.approveTerms,
						"",
						" ",
						Config.FINGER_SIZE * .25,
						Config.FINGER_SIZE * .19
					);		
					flagIcon.y = tfAmount.y + tfAmount.height - ICON_SIZE - Config.FINGER_SIZE * .025 ;
				}
				flagIcon.x = leftX;
				tfAmount.x = leftX + Config.FINGER_SIZE * .5;
				tfAmountInCurrency.x = leftX + Config.FINGER_SIZE * .5;
			} else {
				flagIcon.visible = false;
				tfAmount.x = leftX;
				tfAmountInCurrency.x = leftX;
			}
			
			graphics.clear();
			graphics.beginFill(0, .1);
			graphics.drawRect(0, trueHeight - 1, w, 1);
			graphics.endFill();
			
			trueWidth = w;
		}
		
		public function getAmountAscent():int {
			return tfAmount.getLineMetrics(0).ascent;
		}
		
		public function getAmountHeight():int {
			return tfAmount.height;
		}
		
		public function getWidth():int {
			return trueWidth;
		}
		
		public function getTrueWidth():int {
			if (_isDisposed)
				return 1;
			return Math.max(tfAmount.width, tfNumber.width);
		}
		
		public function dispose():void {
			if (_isDisposed)
				return;
			_isDisposed = true;
			graphics.clear();
			UI.destroy(tfNumber);
			UI.destroy(tfAmount)
			UI.destroy(tfAmountInCurrency);
			UI.destroy(iconTriangle);
			UI.destroy(iconTriangleIcon);
			UI.destroy(flagIcon);
			tfAmount = null;
			tfAmountInCurrency = null;
			tfAmountInCurrency = null;
			tfNumber = null;
			iconTriangleIcon = null;
			flagIcon = null;
		}
		
		public function clearGraphics():void {
			graphics.clear();
		}
		
		public function getData():Object {
			return data;
		}
	}
}