package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.BankBotChatScreen;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.langs.Lang;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BACryptoDealSection extends BAWalletSection {
		
		private var tfAmountTotal:TextField;
		
		private var iconType:Shape;
		private var iconStatus:Shape;
		
		public function BACryptoDealSection() {
			super();
			
			tfAmount.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2);
			tfAmount.y = tfNumber.y;
			
			tfAmountTotal = new TextField();
			tfAmountTotal.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, tfColorBase);
			tfAmountTotal.multiline = false;
			tfAmountTotal.wordWrap = false;
			tfAmountTotal.text = "|";
			tfAmountTotal.height = tfAmountTotal.textHeight + 4;
			tfAmountTotal.y = int(tfNumber.height + Config.FINGER_SIZE * .12) + Config.MARGIN;
			tfAmountTotal.x = tfNumber.x;
			addChild(tfAmountTotal);
			
			trueHeight = tfAmountTotal.y + tfAmountTotal.height + Config.MARGIN * 2;
		}
		
		override public function setData(data:Object, w:int):void {
			this.data = data;
			var side:String;
			if (data.side == "BUY")
				side = Lang.BUY;
			else
				side = Lang.sell;
			tfNumber.text = side + " " + parseFloat((Number(data.quantity)).toFixed(4)).toString() + " DUK+";
			var leftX:int =  Config.FINGER_SIZE_DOT_25 + Config.DOUBLE_MARGIN - 2;
			if (MobileGui.stage.stageWidth <= 640)
				leftX = Config.FINGER_SIZE_DOT_25 + Config.MARGIN*.5;
			else
				leftX = Config.FINGER_SIZE_DOT_25 + Config.DOUBLE_MARGIN - 2;
			tfNumber.x = leftX;
			if (w < tfNumber.textWidth + 4)
				tfNumber.width = w;
			else
				tfNumber.width = tfNumber.textWidth + 4;
			tfAmount.text = "@ " + data.price + " " + data.currency;
			tfAmount.width = tfAmount.textWidth + 4;
			tfAmount.x = w - tfAmount.width - tfNumber.x;
			
			tfAmountTotal.text = (Number(data.quantity) * Number(data.price)).toFixed(2) + " " + data.currency;
			tfAmountTotal.width = tfAmountTotal.textWidth + 4;
			tfAmountTotal.x = tfNumber.x;
			
			trueWidth = w;
			graphics.clear();
			graphics.beginFill(0, .1);
			graphics.drawRect(0, trueHeight - 1, w, 1);
			graphics.endFill();
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			if (tfAmountTotal != null)
			{
				UI.destroy(tfAmountTotal);
				tfAmountTotal = null
			}
			if (iconType != null)
			{
				UI.destroy(iconType);
				iconType = null
			}
			if (iconStatus != null)
			{
				UI.destroy(iconStatus);
				iconStatus = null
			}
		}
	}
}