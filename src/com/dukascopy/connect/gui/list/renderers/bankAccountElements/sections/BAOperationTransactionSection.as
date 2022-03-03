package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.BankBotChatScreen;
	import com.dukascopy.connect.sys.bankManager.BankBotController;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BAOperationTransactionSection extends Sprite {
		
		protected const ICON_SIZE:int = Config.FINGER_SIZE * .45;
		protected const COLOR_PLUS:String = "#4FB048";
		protected const COLOR_MINUS:String = "#AD4742";
		
		protected var textFormatLabel:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .19, 0x777777);
		
		protected var tfTime:TextField;
		protected var tfAccount:TextField;
		protected var tfType:TextField;
		protected var tfAmount:TextField;
		protected var tfBalance:TextField;
		protected var flagIcon:Bitmap;
		
		protected var data:Object;
		
		protected var trueWidth:int;
		protected var trueHeight:int;
		
		public function BAOperationTransactionSection() {
			flagIcon = new Bitmap();
			addChild(flagIcon);
			
			tfAccount = new TextField();
			tfAccount.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .24, 0x065FD4, null, null, null, null, null, TextFormatAlign.CENTER);
			tfAccount.multiline = true;
			tfAccount.wordWrap = true;
			tfAccount.text = "|";
			tfAccount.y = ICON_SIZE + Config.DOUBLE_MARGIN;
			addChild(tfAccount);
			
			tfTime = new TextField();
			tfTime.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .24);
			tfTime.multiline = true;
			tfTime.wordWrap = true;
			tfTime.text = "|";
			addChild(tfTime);
			
			tfType = new TextField();
			tfType.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .24);
			tfType.multiline = true;
			tfType.wordWrap = true;
			tfType.text = "|";
			addChild(tfType);
			
			tfAmount = new TextField();
			tfAmount.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .24);
			tfAmount.multiline = true;
			tfAmount.wordWrap = true;
			tfAmount.text = "|";
			addChild(tfAmount);
			
			tfBalance = new TextField();
			tfBalance.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .24);
			tfBalance.multiline = true;
			tfBalance.wordWrap = true;
			tfBalance.text = "|";
			addChild(tfBalance);
		}
		
		public function getHeight():int {
			return trueHeight;
		}
		
		public function setData(data:Object, w:int):void {
			this.data = data;
			
			UI.disposeBMD(flagIcon.bitmapData);
			flagIcon.visible = true;
			var flagAsset:Sprite;
			flagAsset = UI.getFlagByCurrency(data.CURRENCY);
			if (flagAsset is SWFFlagNONE)
				flagAsset = UI.getInvestIconByInstrument(data.CURRENCY);
			flagIcon.bitmapData = UI.renderAsset(flagAsset, ICON_SIZE, ICON_SIZE, false, "BACryptoRDSection.flagIcon");
			flagAsset = null;
			flagIcon.y = Config.MARGIN;
			flagIcon.x = int((w - ICON_SIZE) * .5);
			
			var trueW:int = w - Config.DOUBLE_MARGIN;
			
			tfAccount.text = getAccountDisplayName(("IBAN" in data && data.IBAN != null) ? data.IBAN : data.ACCOUNT_NUMBER);
			tfAccount.width = trueW;
			tfAccount.height = tfAccount.textHeight + 4;
			
			var trueH:int = tfAccount.y + tfAccount.height + Config.MARGIN;
			
			if ("TS" in data == true && isNaN(Number(data.TS)) == false) {
				var dt:Date = new Date();
				dt.setTime(Number(data.TS) * 1000);
				tfTime.text = Lang.textTime + "\n" + DateUtils.getTimeString(dt, false, 0, false, ".", true);
			}
			tfTime.setTextFormat(textFormatLabel, 0, Lang.textTime.length);
			tfTime.width = trueW;
			tfTime.height = tfTime.textHeight + 4;
			tfTime.y = trueH;
			
			trueH = tfTime.y + tfTime.height;
			
			tfType.text = Lang.textType + "\n" + data.TYPE;
			tfType.setTextFormat(textFormatLabel, 0, Lang.textType.length);
			tfType.width = trueW;
			tfType.height = tfTime.textHeight + 4;
			tfType.y = trueH;
			
			trueH = tfType.y + tfType.height;
			
			var maxDecimalCount:int = CurrencyHelpers.getMaxDecimalCount(data.CURRENCY);
			var amountStr:String = Number(data.AMOUNT) + "";
			var amountParts:Array = amountStr.split(".");
			if (amountParts.length == 2) {
				if (maxDecimalCount == 0)
					amountParts.pop();
				amountParts[1] = amountParts[1].substr(0, maxDecimalCount);
			}
			tfAmount.htmlText = Lang.amount + "\n" + UI.renderCurrency(
				amountParts[0] + ((amountParts.length == 2) ? "." : ""),
				((amountParts.length == 2) ? amountParts[1] : ""),
				CurrencyHelpers.getCurrencyByKey(data.CURRENCY),
				Config.FINGER_SIZE * .25,
				Config.FINGER_SIZE * .19,
				((amountParts[0].charAt(0) == "-") ? COLOR_MINUS : COLOR_PLUS)
			);
			tfAmount.setTextFormat(textFormatLabel, 0, Lang.amount.length);
			tfAmount.width = trueW;
			tfAmount.height = tfAmount.textHeight + 4;
			tfAmount.y = trueH;
			
			trueH = tfAmount.y + tfAmount.height;
			
			amountStr = Number(data.BALANCE) + "";
			amountParts = amountStr.split(".");
			if (amountParts.length == 2) {
				amountParts[1] = amountParts[1].substr(0, 4)
			}
			tfBalance.htmlText = Lang.textBalance + "\n" + UI.renderCurrency(
				amountParts[0] + ((amountParts.length == 2) ? "." : ""),
				((amountParts.length == 2) ? amountParts[1] : ""),
				CurrencyHelpers.getCurrencyByKey(data.CURRENCY),
				Config.FINGER_SIZE * .25,
				Config.FINGER_SIZE * .19
			);
			tfBalance.setTextFormat(textFormatLabel, 0, Lang.textBalance.length);
			tfBalance.width = trueW;
			tfBalance.height = tfBalance.textHeight + 4;
			tfBalance.y = trueH;
			
			trueH = tfBalance.y + tfBalance.height + Config.MARGIN;
			trueHeight = trueH;
			
			tfTime.x = Config.MARGIN;
			tfAccount.x = tfTime.x;
			tfType.x = tfTime.x;
			tfAmount.x = tfTime.x;
			tfBalance.x = tfTime.x;
			
			trueWidth = w;
			
			graphics.clear();
			graphics.beginFill(0, .1);
			graphics.drawRect(0, trueHeight - 1, w, 1);
			graphics.endFill();
		}
		
		private function getAccountDisplayName(acc:String):String {
			var res:String = "";
			var index:int = 4;
			while (index < acc.length) {
				res += acc.substring(index - 4, index) + " ";
				index += 4;
			}
			res += acc.substring(index - 4);
			return res;
		}
		
		/*public function getAmountAscent():int {
			return tfAmount.getLineMetrics(0).ascent;
		}
		
		public function getAmountHeight():int {
			return tfAmount.height;
		}*/
		
		public function getWidth():int {
			return trueWidth;
		}
		
		public function getTrueWidth():int {
			return Math.max(tfTime.width, tfAccount.width, tfType.width, tfAmount.width, tfBalance.width);
		}
		
		public function dispose():void {
			if (flagIcon != null)
				UI.disposeBMD(flagIcon.bitmapData);
			flagIcon = null;
			if (tfTime != null)
				UI.destroy(tfTime);
			tfTime = null;
			if (tfAccount != null)
				UI.destroy(tfAccount);
			tfAccount = null;
			if (tfType != null)
				UI.destroy(tfType);
			tfType = null;
			if (tfAmount != null)
				UI.destroy(tfAmount);
			tfAmount = null;
			if (tfBalance != null)
				UI.destroy(tfBalance);
			tfBalance = null;
			data = null;
		}
		
		public function clearGraphics():void {
			graphics.clear();
			if ("type" in data && data.type == "total") {
				graphics.beginFill(0x8F8F8F, 1);
				graphics.drawRect(0, 0, trueWidth, 1);
				graphics.endFill();
			}
		}
	}
}