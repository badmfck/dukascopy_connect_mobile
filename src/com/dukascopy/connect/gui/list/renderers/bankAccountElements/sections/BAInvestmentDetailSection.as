package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BAInvestmentDetailSection extends Sprite {
		
		private var tfColorSelected:uint = 0x2B5FAB;
		private var tfColorBase:uint = 0x22546B;
		private var tfSizeSelected:int = Config.FINGER_SIZE * .23;
		private var tfSizeBase:int = Config.FINGER_SIZE * .2;
		
		private var tfNumber:TextField;
		private var tfAmount:TextField;
		private var iconTriangle:SWFTriangleRight;
		
		private var trueWidth:int;
		private var trueHeight:int;
		
		public function BAInvestmentDetailSection() {
			iconTriangle = new SWFTriangleRight();
			UI.scaleToFit(iconTriangle, Config.FINGER_SIZE * .15, Config.FINGER_SIZE * .15);
			UI.colorize(iconTriangle, tfColorSelected);
			iconTriangle.x = Config.MARGIN;
			
			tfNumber = new TextField();
			tfNumber.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, tfColorBase);
			tfNumber.multiline = false;
			tfNumber.wordWrap = false;
			tfNumber.text = "|";
			tfNumber.height = tfNumber.textHeight + 4;
			tfNumber.x = iconTriangle.width + Config.DOUBLE_MARGIN - 2;
			tfNumber.y = Config.MARGIN;
			addChild(tfNumber);
			
			tfAmount = new TextField();
			tfAmount.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .25);
			tfAmount.multiline = true;
			tfAmount.wordWrap = true;
			tfAmount.autoSize = TextFieldAutoSize.LEFT;
			tfAmount.text = "|";
			tfAmount.height = tfAmount.textHeight + 4;
			tfAmount.y = int(tfNumber.height + Config.FINGER_SIZE * .02) + Config.MARGIN;
			tfAmount.x = tfNumber.x;
			addChild(tfAmount);
			
			trueHeight = tfAmount.y + tfAmount.height + Config.MARGIN;
			iconTriangle.y = int((trueHeight - iconTriangle.height) * .5);
		}
		
		public function getHeight():int {
			return trueHeight;
		}
		
		public function setData(data:Object, w:int):void {
			tfNumber.text = data.title;
			if (w < tfNumber.textWidth + 4)
				tfNumber.width = w;
			else
				tfNumber.width = tfNumber.textWidth + 4;
			tfAmount.htmlText = UI.renderCurrencyAdvanced(
				data.amount,
				data.currency,
				Config.FINGER_SIZE * .25,
				Config.FINGER_SIZE * .19
			);
			tfAmount.width = w - Config.MARGIN * 2;
			trueWidth = w;
			trueHeight = tfAmount.y + tfAmount.height + Config.MARGIN;
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
			if (tfNumber != null)
			{
				UI.destroy(tfNumber);
				tfNumber = null;
			}
			if (tfAmount != null)
			{
				UI.destroy(tfAmount);
				tfAmount = null;
			}
			if (iconTriangle != null)
			{
				UI.destroy(iconTriangle);
				iconTriangle = null;
			}
		}
		
		public function clearGraphics():void {
			graphics.clear();
		}
	}
}