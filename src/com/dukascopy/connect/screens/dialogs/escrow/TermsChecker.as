package com.dukascopy.connect.screens.dialogs.escrow 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
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
	public class TermsChecker extends Sprite
	{
		private var control:Toggle;
		private var text:Bitmap;
		private var back:Sprite;
		private var onChange:Function;
		private var itemWidth:int;
		private var textValue:String;
		private var link:String;
		
		public function TermsChecker(onChange:Function) 
		{
			this.onChange = onChange;
			createClips();
		}
		
		private function createClips():void 
		{
			back = new Sprite();
			addChild(back);
			
			control = new Toggle(onChangeCall);
			addChild(control);
			
			text = new Bitmap();
			addChild(text);
		}
		
		private function onChangeCall():void 
		{
			if (onChange != null)
			{
				onChange();
			}
		}
		
		public function draw(itemWidth:int, textValue:String, link:String):void
		{
			this.itemWidth = itemWidth;
			this.textValue = textValue;
			this.link = link;
			
			if (text.bitmapData != null)
			{
				text.bitmapData.dispose();
				text.bitmapData = null;
			}
			
			text.bitmapData = TextUtils.createTextFieldData(textValue, itemWidth - control.getWidth() - Config.FINGER_SIZE * .15, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false, true);
			
			text.x = int(control.getWidth() + Config.FINGER_SIZE * .25);
			back.graphics.clear();
			back.graphics.beginFill(0, 0);
			back.graphics.drawRect(0, 0, text.width, text.height);
			back.graphics.endFill();
			back.x = text.x;
			back.y = text.y;
			control.y = int(text.height * .5 - control.getHeight() * .5);
		}
		
		public function activate():void
		{
			control.activate();
			PointerManager.addTap(back, openLink);
		}
		
		private function openLink(e:Event):void 
		{
			if (link != null)
			{
				navigateToURL(new URLRequest(link));
			}
		}
		
		public function deactivate():void
		{
			control.deactivate();
			PointerManager.removeTap(back, openLink);
		}
		
		public function dispose():void
		{
			onChange = null;
			
			if (control != null)
			{
				control.dispose();
				control = null;
			}
			if (text != null)
			{
				UI.destroy(text);
				text = null;
			}
			if (back != null)
			{
				UI.destroy(back);
				back = null;
			}
		}
		
		public function isSelected():Boolean 
		{
			if (control != null)
			{
				return control.isSelected();
			}
			return false;
		}
		
		public function unselect():void 
		{
			if (control != null)
			{
				return control.unselect();
			}
		}
	}
}