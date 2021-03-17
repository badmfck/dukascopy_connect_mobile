package com.dukascopy.connect.gui.button 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.payments.card.CardCommon;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class DDCardButtonExtended extends DDCardButton
	{
		private var tfColorBase:uint = 0x22546B;
		private var tfSizeBase:int = Config.FINGER_SIZE * .24;
		private var cardIconVisa:Sprite;
		private var cardIconVisaE:Sprite;
		private var cardIconMaster:Sprite;
		private var cardIconMaestro:Sprite;
		private var cardIconAmex:Sprite;
		private var iconCard:Sprite;
		
		public function DDCardButtonExtended(callBack:Function,data:Object=null/*, defaultLabel:String = ""*/){
			super(callBack, data);
		}
		
		override public function setValue(data:Object = null):void {
			if (iconCard != null && contains(iconCard))
			{
				removeChild(iconCard);
			}
			iconCard = null;
			super.setValue(data);
		}
		
		override protected function setAccountNumberText():void 
		{
			if (data is Object)
			{
				var cardNumber:String;
				
				if ("masked" in data && data.masked != null)
				{
					cardNumber = data.masked.substr(0, 4) + " " + data.masked.substr(4, 4) + " " + data.masked.substr(8, 4) + " " + data.masked.substr(12);
				}
				else{
					cardNumber = data.number;
				}
				
				
				tf.text = (data.ordered == true) ? Lang.textOrdered + " " + cardNumber : cardNumber;
				var textFormat:TextFormat = new TextFormat("Tahoma", tfSizeBase, tfColorBase);
				tf.setTextFormat(textFormat);
				tf.height = tf.textHeight + 4;
				tf.y = int(tfRight.y + tfRight.height - tf.height);
				
				var fitHeight:int = tf.height;
				
				var target:String;
				if ("masked" in data && data.masked != null)
				{
					target = data.masked;
				}
				else{
					target = data.number;
				}
				
				var ctype:String = CardCommon.getCardTypeByNumber(target);
				switch (ctype) {
					case CardCommon.TYPE_VISA: {
						if (cardIconVisa == null)
							cardIconVisa = CardCommon.getCardIconByType(ctype);
						iconCard = cardIconVisa;
						fitHeight = tf.textHeight * .8;
						break;
					}
					case CardCommon.TYPE_VISA_ELECTRON: {
						if (cardIconVisaE == null)
							cardIconVisaE = CardCommon.getCardIconByType(ctype);
						iconCard = cardIconVisaE;
						break;
					}
					case CardCommon.TYPE_MASTERCARD: {
						if (cardIconMaster == null)
							cardIconMaster = CardCommon.getCardIconByType(ctype);
						iconCard = cardIconMaster;
						break;
					}
					case CardCommon.TYPE_MAESTRO: {
						if (cardIconMaestro == null)
							cardIconMaestro = CardCommon.getCardIconByType(ctype);
						iconCard = cardIconMaestro;
						break;
					}
					case CardCommon.TYPE_AMEX: {
						if (cardIconAmex == null)
							cardIconAmex = CardCommon.getCardIconByType(ctype);
						iconCard = cardIconAmex;
						break;
					}
				}
				var numberX:int = 0;
				if (iconCard != null) {
					UI.scaleToFit(iconCard, Config.FINGER_SIZE, fitHeight);
					var line:TextLineMetrics = tf.getLineMetrics(0);
					iconCard.y = int(tf.y + tf.height - line.descent - iconCard.height - 2);
					iconCard.x = 0;
					addChild(iconCard);
					numberX = iconCard.x + iconCard.width + Config.MARGIN - 2;
				}
				tf.x = numberX;
			}
			else{
				super.setAccountNumberText();
			}
		}
		
		override public function dispose():void
		{
			cardIconVisa = null;
			cardIconVisaE = null;
			cardIconMaster = null;
			cardIconMaestro = null;
			cardIconAmex = null;
			iconCard = null;
			
			super.dispose();
		}
	}
}