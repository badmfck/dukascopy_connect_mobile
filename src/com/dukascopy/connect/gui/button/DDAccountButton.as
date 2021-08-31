package com.dukascopy.connect.gui.button
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.uiFactory.UIFactory;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class DDAccountButton extends BitmapButton
	{
		private var generatedBitmap:ImageBitmapData;
		
		//private var value:String = "Choose...";
		
		private var box:Sprite;
		private var tf:TextField;
		private var tfRight:TextField;
		private var walletName:TextField;
		
		static private var arrowHeight:int;
		static private var arrowCathetus:int;
		
		private var w:int = 0;
		private var h:int = 0;
		
		private var data:Object;
		private var defaultLabel:String = "";
		
		private var icon:Bitmap;
		
		private var ICON_SIZE:int = Config.FINGER_SIZE * .5;
		private var showArrow:Boolean;
		private var ammountColor:Number;
		
		private var description:Bitmap;
		private var accountTitle:Bitmap;
		private var isInvestment:Boolean;
		private var underlineColor:Number;
		private var title:String;
		private var container:Sprite;
		private var textFormatLabel:TextFormat;
		private var textFormatPlaceholder:TextFormat;
		
		public function DDAccountButton(callBack:Function, data:Object = null/*, defaultLabel:String = ""*/, showArrow:Boolean = true, ammountColor:Number=-1, underlineColor:Number = NaN, title:String = null)
		{
			super();
			this.ammountColor = ammountColor;
			this.underlineColor = underlineColor;
			this.showArrow = showArrow;
			this.title = title;
			/*this.defaultLabel = defaultLabel == ""? Lang.textChoose+"..." : defaultLabel;*/
			updateDefaultLabel();
			
			underlineColor = Style.color(Style.CONTROL_INACTIVE);
			
			this.data = data;
			
			setStandartButtonParams();
			setDownScale(1);
			setOverlay(HitZoneType.MENU_MIDDLE_ELEMENT);
			
			usePreventOnDown = true;
			cancelOnVerticalMovement = true;
			tapCallback = callBack;
			
			container = new Sprite();
			
			box = new Sprite();
			container.addChild(box);
			tf = UIFactory.createTextField();
			tf.textColor = Style.color(Style.COLOR_SUBTITLE);
			//tf.border = true;
			
			textFormatLabel = new TextFormat();
			textFormatLabel.size = FontSize.CAPTION_1;
			textFormatLabel.color = Style.color(Style.COLOR_SUBTITLE);
			textFormatLabel.font = Config.defaultFontName;
			
			textFormatPlaceholder = new TextFormat();
			textFormatPlaceholder.size = FontSize.BODY;
			textFormatPlaceholder.color = Style.color(Style.COLOR_TEXT);
			textFormatPlaceholder.font = Config.defaultFontName;
			
			tf = new TextField();
			tf.defaultTextFormat = textFormatLabel;
			tf.multiline = false;
			tf.wordWrap = false;
			tf.text = '|`qI';
			tf.height = tf.textHeight + 4;
			tf.text = "";
			
			tfRight = UIFactory.createTextField();
			tfRight.autoSize = TextFieldAutoSize.RIGHT;
			tfRight.defaultTextFormat.align = TextFormatAlign.RIGHT;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.size = FontSize.SUBHEAD;
			textFormat.color = Style.color(Style.COLOR_TEXT);
			textFormat.font = Config.defaultFontName;
			
			walletName = new TextField();
			walletName.defaultTextFormat = textFormat;
			walletName.textColor = Style.color(Style.COLOR_TEXT);
			walletName.multiline = false;
			walletName.wordWrap = false;
			walletName.text = '|`qI';
			walletName.height = walletName.textHeight + 4;
			walletName.text = "";
			
			//tfRight.border = true;
			box.addChild(tf);
			box.addChild(tfRight);
			box.addChild(walletName);
			
			icon = new Bitmap();
			box.addChild(icon);
			
			accountTitle = new Bitmap();
			container.addChild(accountTitle);
			
			description = new Bitmap();
			box.addChild(description);
		//	drawDescription();
		}
		
		public function drawDescription():void
		{
			if (description.bitmapData != null)
			{
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			description.bitmapData = TextUtils.createTextFieldData(Lang.amountAvaliable, w, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															FontSize.CAPTION_1, false, Style.color(Style.COLOR_SUBTITLE), 
															Style.color(Style.COLOR_BACKGROUND), false, true);
		}
		
		public function drawTitle():void
		{
			if (accountTitle.bitmapData != null)
			{
				accountTitle.bitmapData.dispose();
				accountTitle.bitmapData = null;
			}
			accountTitle.bitmapData = TextUtils.createTextFieldData(title, w, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															FontSize.SUBHEAD, false, Style.color(Style.COLOR_SUBTITLE), 
															Style.color(Style.COLOR_BACKGROUND), false, true);
		}
		
		public function updateDefaultLabel():void
		{
			this.defaultLabel = Lang.textChoose + "...";
			setSize(w, h);
		}
		
		public function setSize(w:int, h:int):void
		{
			if (w < 1 || h < 1)
				return;
			
			this.w = w;
			this.h = h;
			
			if (generatedBitmap != null)
			{
				if (generatedBitmap.height != h || generatedBitmap.width != w)
				{
					generatedBitmap.dispose();
					generatedBitmap = null;
				}
			}
			
			if (generatedBitmap == null)
			{
				generatedBitmap = new ImageBitmapData("DDAccountButton.generatedBitmap", w, h + Config.FINGER_SIZE * .4 + FontSize.SUBHEAD + Config.FINGER_SIZE*.07, true, 0);
			}
			else
			{
				generatedBitmap.fillRect(generatedBitmap.rect, 0);
			}
			
			var lineColor:Number;
			var lineThickness:int = Style.getLineThickness();
			
				box.graphics.clear();
				box.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND), 0);
				box.graphics.drawRect(1, 1, w, h);
				box.graphics.lineStyle(lineThickness, getUnderlineColor());
				box.graphics.moveTo(0, h - lineThickness / 2);
				box.graphics.lineTo(w, h - lineThickness / 2);
				box.graphics.lineStyle();
			
			
			// arrow
		//	var xOffset:int = w - Config.MARGIN;
			var xOffset:int = w - 0;
			if (showArrow == true) {
				arrowHeight = h * 0.15;
				arrowCathetus = h * 0.12;
				box.graphics.beginFill(Style.color(Style.COLOR_SUBTITLE));
				box.graphics.moveTo(xOffset, int((h - arrowHeight) * .5));
				box.graphics.lineTo(xOffset - arrowCathetus, int((h + arrowHeight) * .5));
				box.graphics.lineTo(xOffset - arrowCathetus * 2, int((h - arrowHeight) * .5));
				box.graphics.lineTo(xOffset, int((h - arrowHeight) * .5));
				box.graphics.endFill();
			}
			
			
			// Render Based on data 
		//	tf.x = (w - xOffset);
			tf.x = 0;
			drawDescription();
			if (title != null)
			{
				drawTitle();
				box.y = int(accountTitle.height + Config.FINGER_SIZE * .07);
			}
			else
			{
				box.y = 0;
			}
			
			if (data == null)
			{
				tfRight.text = "";
				// render default label
				tf.text = defaultLabel;
				tf.width = w - arrowHeight * 2 - Config.DOUBLE_MARGIN;
				tf.y = (h - tf.height) * .5;
				
				description.x = int(w - description.width);
				description.y = int(tf.y + tf.height + Config.FINGER_SIZE * .3);
				if (icon.bitmapData != null)
				{
					icon.bitmapData.dispose();
					icon.bitmapData = null;
				}
				
				tf.setTextFormat(textFormatPlaceholder);
				tf.width = tf.textWidth + 4;
				tf.height = tf.textHeight + 4;
				
				generatedBitmap.drawWithQuality(container, null, null, null, null, true, StageQuality.BEST);
			}
			else if (data is String)
			{
				
				tfRight.text = "";
				// render single text line 	
				tf.text = data as String;
				tf.width = xOffset - arrowHeight * 2 - (w - xOffset) * 2;
				tf.y = (h - tf.height) * .5;
				
				description.visible = false;
				description.x = int(w - description.width);
				description.y = int(tf.y + tf.height + Config.FINGER_SIZE * .3);
				
				tf.setTextFormat(textFormatPlaceholder);
				tf.width = tf.textWidth + 4;
				tf.height = tf.textHeight + 4;
				
				generatedBitmap.drawWithQuality(container, null, null, null, null, true, StageQuality.BEST);
			}
			else if (data is Object)
			{
				tf.textColor = Style.color(Style.COLOR_SUBTITLE);
				// render item by type
				
				// data.BALANCE
				// data.ACCOUNT_NUMBER
				// data.CURRENCY
				//"<font color="#a89433" size="10">street</font>,
				var baseSize:Number = FontSize.AMOUNT;
				var captionSize:Number = Config.FINGER_SIZE * 0.28;
				
				var balanceLeft:String;
				var balanceRight:String;
				
				var currency:String = "";
				var currencyOrigin:String = "";
				if ("CURRENCY" in data)
				{
					currencyOrigin = data.CURRENCY;
					currency = data.CURRENCY;
				}
				else if ("COIN" in data)
				{
					currencyOrigin = data.COIN;
					var value:String = data.COIN;
					if (Lang[value] != null)
					{
						value = Lang[value];
					}
					currency = value;
				}
				else if ("INSTRUMENT" in data)
				{
					isInvestment = true;
					currencyOrigin = data.INSTRUMENT;
					var instrumentValue:String = data.INSTRUMENT;
					if (Lang[instrumentValue] != null)
					{
						instrumentValue = Lang[instrumentValue];
					}
					currency = instrumentValue;
				}
				
				var balance:Number = 0;
				var reserved:Number = 0;
				
				if ("BALANCE" in data && data.BALANCE != null)
				{
					balance = parseFloat(data.BALANCE);
				}
				if ("RESERVED" in data && data.RESERVED != null)
				{
					reserved = parseFloat(data.RESERVED);
				}
				var resultSum:Number = balance - reserved;
				
				if (resultSum == Math.round(resultSum))
				{
					balanceLeft = resultSum.toString();
					balanceRight = "";
				}
				else
				{
					var decimals:int = 2;
					if (PayManager.systemOptions != null && PayManager.systemOptions.currencyDecimalRules != null && !isNaN(PayManager.systemOptions.currencyDecimalRules[currencyOrigin]))
					{
						decimals = PayManager.systemOptions.currencyDecimalRules[currencyOrigin];
					}
					var balanceString:String = resultSum.toFixed(decimals);
					balanceLeft = balanceString.substring(0, balanceString.indexOf("."));
					balanceRight = balanceString.substr(balanceString.indexOf(".") + 1);
				}
				
				var accountNumber:String;
				
				if ("ACCOUNT_NUMBER" in data)
				{
					accountNumber = data.ACCOUNT_NUMBER;
				}else if ("ADDRESS" in data)
				{
					isInvestment = true;
					currencyOrigin = TypeCurrency.BLOCKCHAIN;
					accountNumber = data.ADDRESS;
				}
				
				//var formatedAccountNumber:String = (this.w < 380)?accountNumber.substr(0, 4) + "…" + accountNumber.substr(8):accountNumber.substr(0, 4) + " " + accountNumber.substr(4, 4) + " " + accountNumber.substr(8);
				
				var formatedAccountNumber:String;
				/*if (accountNumber != null && accountNumber.length > 3)
				{
					if (accountNumber.length == 12)
					{
						formatedAccountNumber = "… " + accountNumber.substr(8);
					}
					else
					{
						formatedAccountNumber = "… " + accountNumber.substr(accountNumber.length - 4);
					}
				}
				else{
					formatedAccountNumber = accountNumber;
				}*/
				formatedAccountNumber = accountNumber;
				
				if (data.IBAN != null && !("TYPE" in data && data.TYPE != null && Lang.otherAccTypes[data.TYPE] != null)){
					accountNumber = data.IBAN;
				//	formatedAccountNumber = accountNumber.substr(0, 4) +"…"+ accountNumber.substr(accountNumber.length-4,4);
					formatedAccountNumber = accountNumber;
				}else{
					/*if (accountNumber != null && accountNumber.length > 3)
					{
						if (accountNumber.length == 12)
						{
							formatedAccountNumber = "… " + accountNumber.substr(8);
						}
						else
						{
							formatedAccountNumber = "… " + accountNumber.substr(accountNumber.length - 4);
						}
					}*/
				}
				
				tf.text = formatedAccountNumber;
				
				var color:String;
				
				color = "#" + Style.color(Style.COLOR_TEXT).toString(16);
				
				if (showArrow == false)
				{
					color = "#" + Style.color(Style.COLOR_SUBTITLE).toString(16);
				}
				
				if (balanceLeft)
				{
					/*if (ammountColor >-1)
						color ="#"+ammountColor.toString(16);*/
					
					var resultBalance:String = "<font color='" + color + "' size='" + baseSize + "'>" + balanceLeft + "</font>";
					if (balanceRight != null && balanceRight != "")
					{
						resultBalance += "<font color='" + color + "' size='" + baseSize + "'>.</font>" + "<font color='" + color + "' size='" + captionSize + "'>" + balanceRight + "</font>";
					}
					resultBalance += "  " + "<font color='" + color + "'>" + currency + "</font>";
					
					tfRight.htmlText = resultBalance;
				}
				else{
					tfRight.htmlText = "";
				}
				//tfRight.width = this.w * .4;
			//	tfRight.x = this.w - (tfRight.width) - Config.MARGIN - Config.MARGIN * 3 * (showArrow?1:0);
				tfRight.x = this.w - (tfRight.width) - 0 - Config.MARGIN * 2 * (showArrow?1:0);
				tfRight.y = (h - tfRight.height) * .5;
				
				if (data as String != ""){
					var iconAsset:Sprite = UI.getFlagByCurrency(currencyOrigin);
					if (isInvestment == true)
					{
						iconAsset = UI.getInvestIconByInstrument(currencyOrigin);
					}
					if (icon.bitmapData != null)
					{
						icon.bitmapData.dispose();
						icon.bitmapData = null;
					}
					icon.bitmapData = UI.renderAsset(iconAsset, ICON_SIZE, ICON_SIZE, false, "DDAccountButton.icon");
					tf.x = int(ICON_SIZE + Config.FINGER_SIZE * .15);
					tf.width = tfRight.x - ICON_SIZE - Config.FINGER_SIZE * .15;
				}
				else{
					tf.x = int(ICON_SIZE + Config.FINGER_SIZE * .15);
				}
				
				tf.setTextFormat(textFormatLabel);
				tf.width = tf.textWidth + 4;
				tf.height = tf.textHeight + 4;
				tf.y = (h - tf.height) * .5;
				
				resize(tf, tfRight.x - Config.FINGER_SIZE * .15);
				
				icon.x = 0;
				icon.y = int(h * .5 - ICON_SIZE * .5);
				
				description.visible = true;
				description.x = int(w - description.width);
				description.y = int(tf.y + tf.height + Config.FINGER_SIZE * .3);
				
				if ("TYPE" in data && data.TYPE != null && Lang.otherAccTypes[data.TYPE] != null)
				{
					walletName.text = Lang.otherAccTypes[data.TYPE];
					walletName.y = Math.round(h * .5 - walletName.height - Config.FINGER_SIZE * .01);
					tf.y = Math.round(h * .5 + Config.FINGER_SIZE * .01);
					walletName.x = tf.x;
					
					walletName.width = tfRight.x - Config.FINGER_SIZE * .15 - walletName.x;
				}
				else
				{
					walletName.text = "";
				}
				generatedBitmap.drawWithQuality(container, null, null, null, null, true, StageQuality.BEST);
			}
			
			//generatedBitmap.drawWithQuality(box, null, null, null, null, true, StageQuality.BEST);
			setBitmapData(generatedBitmap);
		}
		
		private function resize(tf:TextField, position:Number):void 
		{
			if (tf.text != null && tf.text.length > 5)
			{
				if (tf.x + tf.width > position)
				{
					tf.text = tf.text.substr(0, tf.text.length - 3) + "..";
					tf.width = tf.textWidth + 4;
					
					resize(tf, position);
				}
			}
		}
		
		private function getUnderlineColor():uint
		{
			var color:Number = Style.color(Style.CONTROL_INACTIVE);
			
			if (!isNaN(underlineColor))
			{
				color = underlineColor;
			}
			return color;
		}
		
		override public function dispose():void
		{
			UI.destroy(icon);
			icon = null;
			
			UI.safeRemoveChild(tf);
			UI.safeRemoveChild(tfRight);
			UI.safeRemoveChild(walletName);
			tf = null;
			tfRight = null;
			walletName = null;
			if (box != null)
			{
				box.graphics.clear();
				box = null;
			}
			this.data = null;
			if (generatedBitmap != null)
			{
				generatedBitmap.dispose();
				generatedBitmap = null;
			}
			if (description != null)
			{
				UI.destroy(description);
				description = null;
			}
			if (accountTitle != null)
			{
				UI.destroy(accountTitle);
				accountTitle = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			
			super.dispose();
		}
		
		// value could be object 
		public function setValue(data:Object = null):void
		{
			this.data = data;
			setSize(w, h);
		}
		
		public function getHeight():int 
		{
			if (box != null)
			{
				return box.y + box.height;
			}
			return height;
		}
		
		public function invalid():void
		{
			UI.colorize(this, 0xCD3F43);
		}
		
		public function valid():void
		{
			transform.colorTransform = new ColorTransform();
		}
	}
}