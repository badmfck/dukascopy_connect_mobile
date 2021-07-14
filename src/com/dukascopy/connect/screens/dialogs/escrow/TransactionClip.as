package com.dukascopy.connect.screens.dialogs.escrow 
{
	import assets.CopyIcon3;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.components.WhiteToastSmall;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TransactionClip extends Sprite
	{
		private var title:Bitmap;
		private var text:Bitmap;
		private var contentPadding:Number;
		private var copyButton:BitmapButton;
		private var value:String;
		
		public function TransactionClip() 
		{
			title = new Bitmap();
			addChild(title);
			
			text = new Bitmap();
			addChild(text);
			
			copyButton = new BitmapButton();
			copyButton.setStandartButtonParams();
			copyButton.tapCallback = onCopyClick;
			copyButton.disposeBitmapOnDestroy = true;
			copyButton.setDownScale(1);
			copyButton.setOverlay(HitZoneType.CIRCLE);
			copyButton.setOverlayPadding(int(Config.FINGER_SIZE * .3));
			copyButton.setOverflow(Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			addChild(copyButton);
			
			var icon:Sprite = new CopyIcon3();
			var iconSize:int = Config.FINGER_SIZE * .25;
			UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS));
			UI.scaleToFit(icon, iconSize, iconSize);
			copyButton.setBitmapData(UI.getSnapshot(icon), true);
			
			contentPadding = Config.FINGER_SIZE * .25;
		}
		
		private function onCopyClick():void 
		{
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, value);
			ToastMessage.display(Lang.copied);
		}
		
		public function draw(itemWidth:int, titleValue:String, textValue:String):void
		{
			value = textValue;
			if (titleValue != null)
			{
				if (title.bitmapData != null)
				{
					title.bitmapData.dispose();
					title.bitmapData = null;
				}
				title.bitmapData = TextUtils.createTextFieldData(titleValue, itemWidth - contentPadding * 2, 10, true,
																		TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		FontSize.SUBHEAD, true, Style.color(Style.COLOR_SUBTITLE),
																		Style.color(Style.BOTTOM_BAR_COLOR), false);
			}
			else
			{
				ApplicationErrors.add();
			}
			
			if (textValue != null)
			{
				if (text.bitmapData != null)
				{
					text.bitmapData.dispose();
					text.bitmapData = null;
				}
				text.bitmapData = TextUtils.createTextFieldData(textValue, itemWidth - contentPadding * 2 - copyButton.width - contentPadding, 10, true,
																		TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		FontSize.TITLE_2, true, Style.color(Style.COLOR_TEXT),
																		Style.color(Style.BOTTOM_BAR_COLOR), false);
			}
			else
			{
				ApplicationErrors.add();
			}
			
			title.x = contentPadding;
			text.x = contentPadding;
			
			title.y = contentPadding;
			text.y = int(title.y + title.height + contentPadding);
			
			var resultHeight:int = text.y + text.height + contentPadding;
			
			copyButton.x = itemWidth - copyButton.width - contentPadding;
			copyButton.y = int(resultHeight * .5 - copyButton.height * .5);
			
			graphics.clear();
			graphics.beginFill(Style.color(Style.BOTTOM_BAR_COLOR));
			graphics.drawRect(0, 0, itemWidth, resultHeight);
			graphics.endFill();
		}
		
		public function activate():void
		{
			copyButton.activate();
		}
		
		public function deactivate():void
		{
			copyButton.deactivate();
		}
		
		public function dispose():void
		{
			if (title != null)
			{
				UI.destroy(title);
				title = null;
			}
			if (text != null)
			{
				UI.destroy(text);
				text = null;
			}
			if (copyButton != null)
			{
				copyButton.dispose();
				copyButton = null;
			}
		}
	}
}