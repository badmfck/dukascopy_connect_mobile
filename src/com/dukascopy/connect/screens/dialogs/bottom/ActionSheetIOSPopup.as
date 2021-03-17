package com.dukascopy.connect.screens.dialogs.bottom 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ActionSheetIOSPopup extends BottomPopup
	{
		private var closeButton:ActionSheetItemIOS;
		private var items:Array;
		private var buttons:Vector.<ActionSheetItemIOS>;
		private var needCallback:Boolean = false;
		private var selectedItem:Object;
		protected var contentPadding:int;
		protected var contentPaddingV:int;
		
		public function ActionSheetIOSPopup() 
		{
			
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			contentPadding = Config.FINGER_SIZE * .3;
			
			if (data != null && "items" in data && data.items != null && data.items is Array)
			{
				buttons = new Vector.<ActionSheetItemIOS>();
				items = data.items as Array;
				createButtons();
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function createButtons():void 
		{
			for (var i:int = 0; i < items.length; i++) 
			{
				createButton(items[i], i == 0, i == items.length - 1);
			}
			var buttonHeight:int = Style.value(Style.HEIGHT_IOS_ACTION_SHEET_BACK);
			var buttonsPadding:int = Config.FINGER_SIZE * .025;
			
			closeButton = new ActionSheetItemIOS(null, Style.color(Style.COLOR_IOS_ACTION_SHEET_BACK), 1);
			container.addChild(closeButton);
			closeButton.draw(Lang.textCancel, getButtonWidth(), true, true);
			closeButton.onClick = onBackClick;
			
			var position:int = 0;
			for (var j:int = 0; j < buttons.length; j++) 
			{
				buttons[j].x = contentPadding;
				buttons[j].y = position;
				position += buttonHeight + buttonsPadding;
			}
			position += Config.FINGER_SIZE * .15;
			
			closeButton.x = contentPadding;
			closeButton.y = position;
		}
		
		override protected function onRemove():void 
		{
			if (needCallback == true)
			{
				needCallback = false;
				if (data != null && "callback" in data && data.callback != null && data.callback is Function)
				{
					if ((data.callback as Function).length == 1)
					{
						data.callback(selectedItem);
					}
				}
			}
		}
		
		private function onBackClick(buttonData:Object = null):void 
		{
			needCallback = false;
			close();
		}
		
		private function createButton(buttonData:Object, first:Boolean, last:Boolean):void 
		{
			var label:String = "";
			if ("label" in buttonData)
			{
				label = buttonData.label;
			}
			var button:ActionSheetItemIOS = new ActionSheetItemIOS(buttonData, Style.color(Style.COLOR_IOS_ACTION_SHEET_ITEM_BACK), Style.value(Style.ALPHA_IOS_ACTION_SHEET_BACK));
			button.draw(label, getButtonWidth(), first, last);
			button.onClick = onButtonClick;
			buttons.push(button);
			container.addChild(button);
		}
		
		private function onButtonClick(buttonData:Object):void 
		{
			needCallback = true;
			selectedItem = buttonData;
			close();
		}
		
		private function getButtonWidth():int 
		{
			return _width - contentPadding * 2;
		}
		
		override protected function drawBack():void 
		{
			
		}
		
		override protected function createView():void {
			super.createView();
		}
		
		private function onButtonCloseClick():void 
		{
			close();
		}
		
		override protected function getHeight():int 
		{
			return container.height + Config.APPLE_BOTTOM_OFFSET + Config.FINGER_SIZE * .4;
		}
		
		override protected function drawView():void {
			super.drawView();
		}
		
		override public function dispose():void {
			super.dispose();
			
			selectedItem = null;
			items = null;
			
			if (closeButton != null)
			{
				closeButton.dispose();
				closeButton = null;
			}
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].dispose();
				}
				buttons = null;
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			
			if (_isDisposed) {
				return;
			}
			closeButton.activate();
			
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].activate();
				}
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			closeButton.deactivate();
			
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].deactivate();
				}
			}
		}
	}
}