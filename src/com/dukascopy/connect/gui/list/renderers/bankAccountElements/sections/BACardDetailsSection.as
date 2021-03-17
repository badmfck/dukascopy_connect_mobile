package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.langs.Lang;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BACardDetailsSection extends BACardSection {
		
		private var tfCardHolderLabel:TextField;
		private var tfCardHolder:TextField;
		private var tfCardCVVLabel:TextField;
		private var tfCardCVV:TextField;
		private var tfCardValidLabel:TextField;
		private var tfCardValid:TextField;
		
		private var tfFormat1:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .26, 0x96ADBD);
		private var tfFormat2:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .26, 0x596670);
		
		public function BACardDetailsSection() {
			super();
			
			tfCardHolderLabel = new TextField();
			tfCardHolderLabel.multiline = false;
			tfCardHolderLabel.wordWrap = false;
			tfCardHolderLabel.autoSize = TextFieldAutoSize.LEFT;
			tfCardHolderLabel.defaultTextFormat = tfFormat1;
			addChild(tfCardHolderLabel);
			
			tfCardHolder = new TextField();
			tfCardHolder.multiline = false;
			tfCardHolder.wordWrap = false;
			tfCardHolder.autoSize = TextFieldAutoSize.LEFT;
			tfCardHolder.defaultTextFormat = tfFormat2;
			addChild(tfCardHolder);
			
			tfCardCVVLabel = new TextField();
			tfCardCVVLabel.multiline = false;
			tfCardCVVLabel.wordWrap = false;
			tfCardCVVLabel.autoSize = TextFieldAutoSize.LEFT;
			tfCardCVVLabel.defaultTextFormat = tfFormat1;
			addChild(tfCardCVVLabel);
			
			tfCardCVV = new TextField();
			tfCardCVV.multiline = false;
			tfCardCVV.wordWrap = false;
			tfCardCVV.autoSize = TextFieldAutoSize.LEFT;
			tfCardCVV.defaultTextFormat = tfFormat2;
			addChild(tfCardCVV);
			
			tfCardValidLabel = new TextField();
			tfCardValidLabel.multiline = false;
			tfCardValidLabel.wordWrap = false;
			tfCardValidLabel.autoSize = TextFieldAutoSize.LEFT;
			tfCardValidLabel.defaultTextFormat = tfFormat1;
			addChild(tfCardValidLabel);
			
			tfCardValid = new TextField();
			tfCardValid.multiline = false;
			tfCardValid.wordWrap = false;
			tfCardValid.autoSize = TextFieldAutoSize.LEFT;
			tfCardValid.defaultTextFormat = tfFormat2;
			addChild(tfCardValid);
		}
		
		override public function setData(data:Object, w:int):void {
			super.setData(data, w);
			
			tfNumber.text = data.numberCard.substr(0, 4) + " " + data.numberCard.substr(4, 4) + " " + data.numberCard.substr(8, 4) + " " + data.numberCard.substr(12);
			if (w < tfNumber.textWidth + 4)
				tfNumber.width = w;
			else
				tfNumber.width = tfNumber.textWidth + 4;
			
			if (iconCard != null)
				status.x = tfNumber.x + tfNumber.textWidth + 4 + Config.MARGIN;
			
			var posY:int = int(tfNumber.y + tfNumber.height + Config.FINGER_SIZE * .02) + Config.MARGIN;
			if (data.holder != null) {
				tfCardHolderLabel.text = Lang.holder;
				tfCardHolderLabel.x = tfAmount.x;
				tfCardHolderLabel.y = posY;
				tfCardHolder.text = (data.holder != null) ? data.holder : "---";
				tfCardHolder.x = tfAmount.x;
				tfCardHolder.y = tfCardHolderLabel.y + tfCardHolderLabel.height;
				posY = int(tfCardHolder.y + tfCardHolder.height + Config.FINGER_SIZE * .02) + Config.MARGIN;
			}
			
			tfCardValidLabel.text = Lang.validThru;
			tfCardValidLabel.x = tfAmount.x;
			tfCardValidLabel.y = posY;
			tfCardValid.text = data.valid;
			tfCardValid.x = tfAmount.x;
			tfCardValid.y = tfCardValidLabel.y + tfCardValidLabel.height;
			
			tfCardCVVLabel.text = Lang.CVV;
			tfCardCVVLabel.x = tfAmount.x;
			tfCardCVVLabel.y = int(tfCardValid.y + tfCardValid.height + Config.FINGER_SIZE * .02) + Config.MARGIN;
			tfCardCVV.text = data.cvv;
			tfCardCVV.x = tfAmount.x;
			tfCardCVV.y = tfCardCVVLabel.y + tfCardCVVLabel.height;
			
			tfAmount.y = int(tfCardCVV.y + tfCardCVV.height + Config.FINGER_SIZE * .02) + Config.MARGIN;
			tfType.y = tfAmount.y + tfAmount.getLineMetrics(0).ascent - tfType.getLineMetrics(0).ascent;
			
			trueHeight = tfAmount.y + tfAmount.height + Config.MARGIN;
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			if (tfCardHolderLabel != null)
			{
				UI.destroy(tfCardHolderLabel);
				tfCardHolderLabel = null
			}
			if (tfCardHolder != null)
			{
				UI.destroy(tfCardHolder);
				tfCardHolder = null
			}
			if (tfCardCVVLabel != null)
			{
				UI.destroy(tfCardCVVLabel);
				tfCardCVVLabel = null
			}
			if (tfCardCVV != null)
			{
				UI.destroy(tfCardCVV);
				tfCardCVV = null
			}
			if (tfCardValidLabel != null)
			{
				UI.destroy(tfCardValidLabel);
				tfCardValidLabel = null
			}
			if (tfCardValid != null)
			{
				UI.destroy(tfCardValid);
				tfCardValid = null
			}
			
			tfFormat1 = null;
			tfFormat2 = null;
		}
	}
}