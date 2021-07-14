package com.dukascopy.connect.screens.dialogs.escrow 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class AlertTextArea extends Sprite
	{
		private var itemWidth:int;
		private var text:String;
		private var link:String;
		private var field:Bitmap;
		private var textPadding:Number;
		private var textPaddingV:Number;
		private var alertArrow:LinkIcon3;
		
		public function AlertTextArea() 
		{
			field = new Bitmap();
			addChild(field);
				
			alertArrow = new LinkIcon3();
			UI.colorize(alertArrow, Color.RED);
			UI.scaleToFit(alertArrow, int(Config.FINGER_SIZE * .26), int(Config.FINGER_SIZE * .26));
			addChild(alertArrow);
						
			textPadding = Config.FINGER_SIZE * .22;
			textPaddingV = Config.FINGER_SIZE * .22;
		}
		
		public function activate():void 
		{
			PointerManager.addTap(this, openLink);
		}
		
		public function deactivate():void 
		{
			PointerManager.removeTap(this, openLink);
		}
		
		public function dispose():void 
		{
			if (field != null)
			{
				UI.destroy(field);
				field = null;
			}
			if (alertArrow != null)
			{
				UI.destroy(alertArrow);
				alertArrow = null;
			}
		}
		
		public function draw(itemWidth:int, text:String, link:String):void 
		{
			this.itemWidth = itemWidth;
			this.text = text;
			this.link = link;
			
			drawText();
			position();
			drawBack();
			
			if (link == null)
			{
				alertArrow.visible = false;
			}
			else
			{
				alertArrow.visible = true;
			}
		}
		
		private function drawBack():void 
		{
			graphics.clear();
			graphics.beginFill(Style.color(Style.COLOR_RED_LIGHT), 0.1);
			graphics.drawRect(0, 0, itemWidth, field.height + textPaddingV * 2);
			graphics.endFill();
		}
		
		private function position():void 
		{
			field.x  = textPadding;
			field.y  = textPaddingV;
			
			alertArrow.x = int(itemWidth - textPadding - alertArrow.width);
			alertArrow.y = int(field.y + field.height * .5 - alertArrow.height * .5);
		}
		
		private function drawText():void 
		{
			if (field.bitmapData != null)
			{
				field.bitmapData.dispose();
				field.bitmapData = null;
			}
			
			if (text != null)
			{
				var textWidth:int = itemWidth - textPadding * 2;
				if (link != null)
				{
					textWidth -= textPadding + alertArrow.width;
				}
				field.bitmapData = TextUtils.createTextFieldData(text, textWidth, 10, true,
																		TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		FontSize.SUBHEAD, true, Style.color(Style.COLOR_TEXT_RED_DARK),
																		Style.color(Style.COLOR_RED_LIGHT), false);
			}
			else
			{
				ApplicationErrors.add();
			}
			
		}
		
		private function openLink(event:Event):void 
		{
			if (link != null)
			{
				navigateToURL(new URLRequest(link));
			}
		}
	}
}