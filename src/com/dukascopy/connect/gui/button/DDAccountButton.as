package com.dukascopy.connect.gui.button
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
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
		private var isInvestment:Boolean;
		private var underlineColor:Number;
		
		public function DDAccountButton(callBack:Function, data:Object = null/*, defaultLabel:String = ""*/, showArrow:Boolean = true, ammountColor:Number=-1, underlineColor:Number = NaN)
		{
			super();
			this.ammountColor = ammountColor;
			this.underlineColor = underlineColor;
			this.showArrow = showArrow;
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
			
			box = new Sprite();
			tf = UIFactory.createTextField();
			tf.textColor = Style.color(Style.COLOR_SUBTITLE);
			//tf.border = true;
			
			tfRight = UIFactory.createTextField();
			tfRight.autoSize = TextFieldAutoSize.RIGHT;
			tfRight.defaultTextFormat.align = TextFormatAlign.RIGHT;
			
			//tfRight.border = true;
			box.addChild(tf);
			box.addChild(tfRight);
			
			icon = new Bitmap();
			box.addChild(icon);
			
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
				generatedBitmap = new ImageBitmapData("DDAccountButton.generatedBitmap", w, h + Config.FINGER_SIZE * .4, true, 0);
			}
			else
			{
				generatedBitmap.fillRect(generatedBitmap.rect, 0);
			}
			
			var lineColor:Number;
			var lineThickness:int = int(Math.max(1, Config.FINGER_SIZE * .03));
			
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
				box.graphics.beginFill(Style.color(Style.COLOR_TEXT));
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
			
			if (data == null)
			{
				tf.textColor = Style.color(Style.COLOR_TEXT);
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
				generatedBitmap.drawWithQuality(box, null, null, null, null, true, StageQuality.BEST);
			}
			else if (data is String)
			{
				tf.textColor = Style.color(Style.COLOR_TEXT);
				tfRight.text = "";
				// render single text line 	
				tf.text = data as String;
				tf.width = xOffset - arrowHeight * 2 - (w - xOffset) * 2;
				tf.y = (h - tf.height) * .5;
				
				description.visible = false;
				description.x = int(w - description.width);
				description.y = int(tf.y + tf.height + Config.FINGER_SIZE * .3);
				
				generatedBitmap.drawWithQuality(box, null, null, null, null, true, StageQuality.BEST);
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
				
				var balance:String;
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
				
				if ("BALANCE" in data && data.BALANCE != null)
				{
					balance = data.BALANCE;
					if ("RESERVED" in data)
					{
						balance = (parseFloat(data.BALANCE) - parseFloat(data.RESERVED)).toFixed(4);
					}
					if (balance != null && balance.indexOf(".") == -1)
					{
						balanceLeft = balance;
						balanceRight = "";
					}
					else
					{
						balanceLeft = balance.substring(0, balance.indexOf("."));
						balanceRight = balance.substr(balance.indexOf(".") + 1);
					}
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
				if (accountNumber != null && accountNumber.length > 3)
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
				}
				
				if (data.IBAN != null){
					accountNumber  = data.IBAN;
					formatedAccountNumber = accountNumber.substr(0, 4) +"…"+ accountNumber.substr(accountNumber.length-4,4);
				}else{
					if (accountNumber != null && accountNumber.length > 3)
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
					tf.x = ICON_SIZE + Config.DOUBLE_MARGIN;
					tf.width = tfRight.x - ICON_SIZE-Config.DOUBLE_MARGIN;
				}
				else{
					tf.x = ICON_SIZE + Config.DOUBLE_MARGIN;
				}
				
				icon.x = 0;
				icon.y = h * .5 - ICON_SIZE * .5;
				
				description.visible = true;
				description.x = int(w - description.width);
				description.y = int(tf.y + tf.height + Config.FINGER_SIZE * .3);
				
				generatedBitmap.drawWithQuality(box, null, null, null, null, true, StageQuality.BEST);
			}
			
			//generatedBitmap.drawWithQuality(box, null, null, null, null, true, StageQuality.BEST);
			
			setBitmapData(generatedBitmap);
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
			tf = null;
			tfRight = null;
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