package com.dukascopy.connect.gui.list.renderers.bankAccountElements {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.IListRenderer;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ListBankBalance extends Sprite implements IListRenderer {
		
		protected const CORNER_RADIUS:int = Config.FINGER_SIZE / 2.5;
		
		private var tfNumber:TextField;
		private var tfAmount:TextField;
		private var tfTime:TextField;
		
		private var trueHeight:int;
		private var xPosition:int = int(Config.FINGER_SIZE * .33) * 2 + Config.DOUBLE_MARGIN + int(int(Config.FINGER_SIZE / 2.5) * .7) + 1;
		private var rightOffset:int;
		
		public function ListBankBalance() {
			tfNumber = new TextField();
			tfNumber.autoSize = TextFieldAutoSize.LEFT;
			tfNumber.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .19, 0x8EA1B3);
			tfNumber.multiline = false;
			tfNumber.wordWrap = false;
			tfNumber.text = "|";
			tfNumber.height = tfNumber.textHeight + 4;
			tfNumber.x = xPosition - 2;
			tfNumber.y = Config.MARGIN;
			addChild(tfNumber);
			
			tfAmount = new TextField();
			tfAmount.autoSize = TextFieldAutoSize.LEFT;
			tfAmount.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .25, 0x22546B);
			tfAmount.multiline = false;
			tfAmount.wordWrap = false;
			tfAmount.text = "|";
			tfAmount.height = tfAmount.textHeight + 4;
			tfAmount.x = tfNumber.x;
			tfAmount.y = int(tfNumber.height + Config.FINGER_SIZE * .02) + Config.MARGIN;
			addChild(tfAmount);
			
			tfTime = new TextField();
			tfTime.autoSize = TextFieldAutoSize.LEFT;
			tfTime.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, 0x373E4E);
			tfTime.multiline = false;
			tfTime.wordWrap = false;
			tfTime.text = "00:00";
			rightOffset = tfTime.textWidth + 4 + int(int(Config.FINGER_SIZE / 2.5) * .7) + Config.MARGIN;
			tfTime.height = tfTime.textHeight + 4;
			addChild(tfTime);
			
			trueHeight = tfAmount.y + tfAmount.height + Config.MARGIN;
			
			tfAmount.y = int((trueHeight - tfAmount.height) * .5);
			tfNumber.y = int(tfAmount.y + (tfAmount.getLineMetrics(0).ascent - tfNumber.getLineMetrics(0).ascent)) - 1;
			
			tfNumber.text = "";
			tfAmount.text = "";
			tfTime.text = "";
		}
		
		public function getHeight(li:ListItem, width:int):int {
			return trueHeight + Config.MARGIN;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			var dt:Date = new Date();
			var dtNumber:int;
			var dtString:String
			
			dtNumber = dt.getHours();
			dtString = (dtNumber < 10) ? "0" + dtNumber + ":" : dtNumber + ":";
			dtNumber = dt.getMinutes();
			dtString += (dtNumber < 10) ? "0" + dtNumber : dtNumber;
			
			tfTime.text = dtString;
			
			tfTime.x = width - tfTime.width - Config.MARGIN;
			tfTime.y = h - tfTime.height - Config.MARGIN + 4;
			
			tfAmount.htmlText = UI.renderCurrency(
				String(int(li.data.BALANCE)) + ".",
				String(int((li.data.BALANCE - int(li.data.BALANCE)) * 100)),
				" " + li.data.CURRENCY,
				Config.FINGER_SIZE * .25,
				Config.FINGER_SIZE * .19
			);
			tfAmount.x = width - rightOffset - tfAmount.textWidth - 4 - Config.MARGIN;
			
			tfNumber.text = li.data.IBAN + ":";
			tfNumber.width = tfNumber.textWidth + 4;
			tfNumber.x = tfAmount.x - tfNumber.width - Config.MARGIN;
			
			drawBG(width, h, li.data.opened, (li.num == 0 || (li.list.getStock()[li.num - 1].renderer is ListBankAccountWallets == false && li.list.getStock()[li.num - 1].renderer is ListBankAccountInvestments == false)));
			
			return this;
		}
		
		private function drawBG(w:int, h:int, isOpened:Boolean, topCorner:Boolean):void {
			graphics.clear();
			graphics.beginFill((isOpened == true) ? 0xE0E8EB : 0xFFFFFF);
			graphics.drawRoundRectComplex(
				xPosition,
				0,
				w - xPosition - rightOffset,
				h - Config.MARGIN,
				(topCorner == true) ? CORNER_RADIUS : 0,
				(topCorner == true) ? CORNER_RADIUS : 0,
				CORNER_RADIUS,
				CORNER_RADIUS
			);
			graphics.endFill();
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
			if (tfTime != null)
			{
				UI.destroy(tfTime);
				tfTime = null;
			}
		}
		
		public function get isTransparent():Boolean {
			return true;
		}

		public function getSelectedHitzone(itemTouchPoint:Point, item:ListItem):HitZoneData{
			return null;
		}
	}
}