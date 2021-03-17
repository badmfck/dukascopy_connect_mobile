package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BABalanceSection extends Sprite {
		
		private var tfColorSelected:uint = 0x2B5FAB;
		private var tfColorBase:uint = 0x22546B;
		private var tfSizeSelected:int = Config.FINGER_SIZE * .23;
		private var tfSizeBase:int = Config.FINGER_SIZE * .2;
		
		private var tfNumber:TextField;
		private var tfAmount:TextField;
		
		private var trueWidth:int;
		private var trueHeight:int;
		
		public function BABalanceSection() {
			tfNumber = new TextField();
			tfNumber.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, tfColorBase);
			tfNumber.multiline = false;
			tfNumber.wordWrap = false;
			tfNumber.text = "|";
			tfNumber.height = tfNumber.textHeight + 4;
			tfNumber.x = Config.DOUBLE_MARGIN - 2 + Config.FINGER_SIZE * .45;
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
			
			trueHeight = tfAmount.y + tfAmount.height + Config.MARGIN;
		}
		
		public function getHeight():int {
			return trueHeight;
		}
		
		public function setData(data:Object, w:int):void {
			tfNumber.text = data.IBAN;
			if (w < tfNumber.textWidth + 4)
				tfNumber.width = w;
			else
				tfNumber.width = tfNumber.textWidth + 4;
			tfAmount.htmlText = UI.renderCurrency(
				int(data.BALANCE) + ".",
				String((data.BALANCE - int(data.BALANCE)).toFixed(2)).substr(2),
				" " + data.CURRENCY,
				Config.FINGER_SIZE * .25,
				Config.FINGER_SIZE * .19
			);
			tfAmount.width = tfAmount.textWidth + 4;
			
			trueWidth = w;
			
			graphics.clear();
			graphics.beginFill(0, .1);
			graphics.drawRect(0, trueHeight - 1, w, 1);
			graphics.endFill();
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
			return Math.max(tfAmount.width, tfNumber.width);
		}
		
		public function dispose():void {
			clearGraphics();
			if (tfNumber != null)
			{
				UI.destroy(tfNumber);
				tfNumber = null
			}
			
			if (tfAmount != null)
			{
				UI.destroy(tfAmount);
				tfAmount = null
			}
		}
		
		public function clearGraphics():void {
			graphics.clear();
		}
	}
}