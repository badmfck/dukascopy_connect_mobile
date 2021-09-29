package com.dukascopy.connect.gui.button
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.managers.escrow.vo.CryptoWallet;
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
	 * @author Sergey Dobarin
	 */
	public class WalletButton extends BitmapButton
	{
		private var generatedBitmap:ImageBitmapData;
		
		private var box:Sprite;
		private var label:TextField;
		private var walletName:TextField;
		
		static private var arrowHeight:int;
		static private var arrowCathetus:int;
		
		private var w:int = 0;
		private var h:int = 0;
		
		private var wallet:CryptoWallet;
		
		private var icon:Bitmap;
		
		private var ICON_SIZE:int = Config.FINGER_SIZE * .2;
		private var showArrow:Boolean;
		
		private var underlineColor:Number;
		private var container:Sprite;
		private var textFormatLabel:TextFormat;
		private var textFormatWallet:TextFormat;
		private var accountTitle:Bitmap;
		private var title:String;
		private var data:Object;
		
		public function WalletButton(callBack:Function, data:Object = null, showArrow:Boolean = true, title:String = null)
		{
			super();
			this.underlineColor = underlineColor;
			this.showArrow = showArrow;
			this.title = title;
			
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
			
			textFormatLabel = new TextFormat();
			textFormatLabel.size = FontSize.CAPTION_1;
			textFormatLabel.color = Style.color(Style.COLOR_SUBTITLE);
			textFormatLabel.font = Config.defaultFontName;
			
			textFormatWallet = new TextFormat();
			textFormatWallet.size = FontSize.BODY;
			textFormatWallet.color = Style.color(Style.COLOR_TEXT);
			textFormatWallet.font = Config.defaultFontName;
			
			label = new TextField();
			label.defaultTextFormat = textFormatLabel;
			label.multiline = false;
			label.wordWrap = false;
			label.text = '|`qI';
			label.height = label.textHeight + 4;
			label.text = "";
			
			walletName = new TextField();
			walletName.defaultTextFormat = textFormatWallet;
			walletName.multiline = true;
			walletName.wordWrap = true;
			walletName.text = '|`qI';
			walletName.height = walletName.textHeight + 4;
			walletName.text = "";
			
			box.addChild(label);
			box.addChild(walletName);
			
			icon = new Bitmap();
			box.addChild(icon);
			
			accountTitle = new Bitmap();
			container.addChild(accountTitle);
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
				generatedBitmap = new ImageBitmapData("DDAccountButton.generatedBitmap", w, h + Config.FINGER_SIZE * .4 + FontSize.SUBHEAD + Config.FINGER_SIZE * .07, true, 0);
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
			
			if (title != null)
			{
				drawTitle();
				box.y = int(accountTitle.height + Config.FINGER_SIZE * .07);
			}
			else
			{
				box.y = 0;
			}
			
			
			generatedBitmap.drawWithQuality(container, null, null, null, null, true, StageQuality.BEST);
			
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
			
			UI.safeRemoveChild(label);
			UI.safeRemoveChild(walletName);
			
			label = null;
			walletName = null;
			
			if (box != null)
			{
				box.graphics.clear();
				box = null;
			}
			this.wallet = null;
			if (generatedBitmap != null)
			{
				generatedBitmap.dispose();
				generatedBitmap = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			
			super.dispose();
		}
		
		// value could be object 
		public function setValue(wallet:CryptoWallet):void
		{
			this.wallet = wallet;
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