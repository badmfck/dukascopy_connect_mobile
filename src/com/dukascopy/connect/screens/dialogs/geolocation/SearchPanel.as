package com.dukascopy.connect.screens.dialogs.geolocation {
	
	import assets.SearchIcon3;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class SearchPanel extends Sprite {
		
		private var input:Input;
		private var nameInputBottom:Bitmap;
		private var currentPhone:String;
		private var icon:SearchIcon3;
		private var onChangeCallback:Function;
		
		public function SearchPanel(onChangeCallback:Function) {
			this.onChangeCallback = onChangeCallback;
			
			input = new Input();
		//	phoneField.backgroundColor = 0xF7F7F7;
			input.backgroundAlpha = 0;
			input.setMode(Input.MODE_INPUT);
			var textFormat:TextFormat = new TextFormat();
			textFormat.size = Config.FINGER_SIZE * .3;
			input.updateTextFormat(textFormat);
			input.setLabelText(Lang.textSearch);
			input.setBorderVisibility(false);
			input.setRoundBG(false);
			input.getTextField().textColor = 0x90959E;
			input.setRoundRectangleRadius(0);
			input.view.x = Config.DIALOG_MARGIN + Config.FINGER_SIZE * .24;
			input.inUse = true;
			addChild(input.view);
			
			icon = new SearchIcon3();
			UI.scaleToFit(icon, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			icon.x = Config.DIALOG_MARGIN;
			icon.y = int(input.view.y + input.height * .5 - icon.height * .5);
			addChild(icon);
			
			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(0x79859A);
			nameInputBottom = new Bitmap(hLineBitmapData);
			addChild(nameInputBottom);
			
			nameInputBottom.y = int(input.view.y + input.height - Config.FINGER_SIZE * .1);
			nameInputBottom.x = Config.DIALOG_MARGIN - Config.FINGER_SIZE * .1;
		}
		
		private function onPoneInputFocusOut():void {
			var currentValue:String = StringUtil.trim(input.value);
			if (currentValue != "" && currentValue != input.getDefValue()) {
				currentPhone = currentValue;
			} else {
				input.value = currentPhone;
			}
		}
		
		public function activate():void
		{
			input.S_FOCUS_OUT.add(onChange);
			input.S_CHANGED.add(onChange);
			input.activate();
		}
		
		public function deactivate():void
		{
			input.S_FOCUS_OUT.remove(onChange);
			input.S_CHANGED.remove(onChange);
			input.deactivate();
		}
		
		public function drawView(w:int):void
		{
			input.width = w - Config.DIALOG_MARGIN * 2 - Config.FINGER_SIZE * .24;
			nameInputBottom.width = w - Config.DIALOG_MARGIN * 2 + Config.FINGER_SIZE * .2;
		}
		
		private function onChange():void 
		{
			if (onChangeCallback != null)
			{
				onChangeCallback();
			}
		}
		
		public function getValue():String
		{
			if (input != null)
			{
				return StringUtil.trim(input.value);
			}
			return null;
		}
		
		public function dispose():void 
		{
			onChangeCallback = null;
			
			if (input != null)
			{
				input.dispose();
				input = null;
			}
			
			if (nameInputBottom != null)
			{
				UI.destroy(nameInputBottom);
				nameInputBottom = null;
			}
			
			if (icon != null)
			{
				UI.destroy(icon);
				icon = null;
			}
		}
	}
}