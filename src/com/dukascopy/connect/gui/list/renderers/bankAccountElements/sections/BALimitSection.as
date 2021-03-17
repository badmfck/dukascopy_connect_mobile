package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.payments.vo.AccountLimit;
	import com.dukascopy.connect.sys.payments.vo.AccountLimitVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BALimitSection extends Sprite {
		
		private var tfColorSelected:uint = 0x2B5FAB;
		private var tfColorBase:uint = 0x22546B;
		private var tfSizeSelected:int = Config.FINGER_SIZE * .23;
		private var tfSizeBase:int = Config.FINGER_SIZE * .2;
		
		private var tfAmountLabel:TextField;
		private var tfAmount:TextField;
		private var tfAmountMaxLabel:TextField;
		private var tfAmountMax:TextField;
		
		private var trueWidth:int;
		private var trueHeight:int;
		
		private var additionalHeight:int;
		
		public function BALimitSection() {
			tfAmountLabel = new TextField();
			tfAmountLabel.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, tfColorBase);
			tfAmountLabel.multiline = true;
			tfAmountLabel.wordWrap = true;
			tfAmountLabel.y = Config.MARGIN;
			tfAmountLabel.x = Config.FINGER_SIZE_DOT_25;
			addChild(tfAmountLabel);
			
			tfAmount = new TextField();
			tfAmount.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2);
			tfAmount.multiline = true;
			tfAmount.wordWrap = true;
			tfAmount.x = Config.FINGER_SIZE_DOT_25;
			addChild(tfAmount);
			
			tfAmountMaxLabel = new TextField();
			tfAmountMaxLabel.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, tfColorBase);
			tfAmountMaxLabel.x = Config.FINGER_SIZE_DOT_25;
			addChild(tfAmountMaxLabel);
			
			tfAmountMax = new TextField();
			tfAmountMax.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2);
			tfAmountMax.x = Config.FINGER_SIZE_DOT_25;
			addChild(tfAmountMax);
		}
		
		public function getHeight():int {
			return trueHeight;
		}
		
		public function getAdditionalHeight():int {
			return additionalHeight;
		}
		
		public function setData(data:AccountLimitVO, w:int):void {
			tfAmountLabel.text = AccountLimit.getLimitBotLabelsByType(data.type);
			tfAmountLabel.width = w - tfAmountLabel.x * 2;
			tfAmountLabel.width = tfAmountLabel.textWidth + 5;
			tfAmountLabel.height = int(tfAmountLabel.textHeight + 5);
			
			if (isNaN(data.maxLimit) == true) {
				tfAmount.htmlText = "<font size='" + Config.FINGER_SIZE * .25 + "'>" + data.currency + "</font>";
			} else {
				tfAmount.htmlText = UI.renderCurrencyAdvanced(
					data.maxLimit,
					data.currency,
					Config.FINGER_SIZE * .25,
					Config.FINGER_SIZE * .19
				);
			}
			tfAmount.y = tfAmountLabel.y + tfAmountLabel.height;
			tfAmount.width = w - tfAmount.x * 2;
			tfAmount.width = tfAmount.textWidth + 5;
			tfAmount.height = int(tfAmount.textHeight + 5);
			
			trueWidth = w;
			
			if (isNaN(data.current) == false) {
				tfAmountMaxLabel.text = Lang.used;
				tfAmountMaxLabel.y = tfAmount.y + tfAmount.height + Config.MARGIN;
				tfAmountMaxLabel.width = int(Math.min(tfAmountMaxLabel.textWidth + 5, w - tfAmountMaxLabel.x * 2));
				tfAmountMaxLabel.height = int(tfAmountMaxLabel.textHeight + 5);
				
				tfAmountMax.htmlText = UI.renderCurrency(
					String(int(data.current)) + ".",
					String(int((data.current - int(data.current)) * 100)),
					" " + data.currency,
					Config.FINGER_SIZE * .25,
					Config.FINGER_SIZE * .19
				);
				tfAmountMax.y = tfAmountMaxLabel.y + tfAmountMaxLabel.height;
				tfAmountMax.width = int(Math.max(tfAmountMax.textWidth + 5, w - tfAmountMax.x * 2));
				tfAmountMax.height = int(tfAmountMax.textHeight + 5);
				
				trueHeight = tfAmountMax.y + tfAmountMax.height + Config.MARGIN;
			} else {
				trueHeight = tfAmount.y + tfAmount.height + Config.MARGIN;
			}
			
			graphics.clear();
			graphics.beginFill(0, .1);
			graphics.drawRect(0, trueHeight - 1, w, 1);
			graphics.endFill();
			
			if (data.marginBottom == true)
				additionalHeight = Config.MARGIN;
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
			return Math.max(tfAmount.width, tfAmountMax.width);
		}
		
		public function dispose():void {
			if (tfAmountLabel != null)
			{
				UI.destroy(tfAmountLabel);
				tfAmountLabel = null;
			}
			if (tfAmount != null)
			{
				UI.destroy(tfAmount);
				tfAmount = null;
			}
			if (tfAmountMaxLabel != null)
			{
				UI.destroy(tfAmountMaxLabel);
				tfAmountMaxLabel = null;
			}
			if (tfAmountMax != null)
			{
				UI.destroy(tfAmountMax);
				tfAmountMax = null;
			}
		}
		
		public function clearGraphics():void {
			graphics.clear();
		}
	}
}