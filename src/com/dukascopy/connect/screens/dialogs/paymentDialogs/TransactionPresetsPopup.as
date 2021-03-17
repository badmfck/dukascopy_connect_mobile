package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.TransactionTemplateRenderer;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.newDialogs.DialogBaseScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.events.Event;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class TransactionPresetsPopup extends DialogBaseScreen
	{
		private const OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE * .8;
		
		private var backButton:BitmapButton;
		
		private var padding:int;
		private var transactionTemplates:Array;
		private var list:List;
		
		public function TransactionPresetsPopup()
		{
			
		}
		
		override protected function createView():void
		{
			super.createView();
			
			list = new List("Templates");
			list.setMask(true);
			list.setContextAvaliable(true);
			container.addChild(list.view);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
		}
		
		private function backClick():void {
			rejectPopup();
		}
		
		private function rejectPopup():void 
		{
			DialogManager.closeDialog();
		}
		
		override public function onBack(e:Event = null):void
		{
			rejectPopup();
		}
		
		override public function initScreen(data:Object = null):void
		{
			var titleValue:String;
			
			if (data != null)
			{
				titleValue = Lang.selectPreset;
				
				if (titleValue != null && data != null)
				{
					data.title = titleValue;
				}
				
				if ("transactionTemplates" in data)
				{
					transactionTemplates = data.transactionTemplates as Array;
				}
			}
			
			super.initScreen(data);
			
			topBar.draw(_width);
			list.view.y = topBar.trueHeight;
			
			padding = Config.DIALOG_MARGIN;
			
			list.setData(transactionTemplates, TransactionTemplateRenderer);
			list.setWidthAndHeight(_width, Config.FINGER_SIZE * 5);
			list.setWidthAndHeight(_width, Math.min(getMaxContentHeight(), list.itemsHeight));
			
			drawBackButton();
		}
		
		override protected function getMaxContentHeight():int {
			return _height - list.view.y - vPadding * 2 - backButton.height - Config.FINGER_SIZE;
		}
		
		override protected function calculateBGHeight():int {
			var value:int = list.view.y + list.height + vPadding * 2 + backButton.height;
			return value;
		}
		
		private function drawBackButton():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0x657280, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0xFFFFFF, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			backButton.setBitmapData(buttonBitmap, true);
		}
		
		override protected function drawView():void
		{
			if (_isDisposed == true)
				return;
				
			super.drawView();
			
			backButton.y = list.view.y + list.height + vPadding;
			backButton.x = int(_width * .5 - backButton.width * .5);
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			list.activate();
			list.S_ITEM_TAP.add(onItemTap);
			
			backButton.activate();
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			list.deactivate();
			list.S_ITEM_TAP.remove(onItemTap);
			
			backButton.deactivate();
		}
		
		private function onItemTap(dataObject:Object, n:int):void {
			var lastHitzoneObject:Object =  list.getItemByNum(n).getLastHitZoneObject();
			var lhz:String = lastHitzoneObject != null ? lastHitzoneObject.type : null;
			if (lhz == HitZoneType.DELETE) {
				
				if (data != null && "deleteTemplate" in data && data.deleteTemplate != null && data.deleteTemplate is Function && (data.deleteTemplate as Function).length == 1)
				{
					(data.deleteTemplate as Function)(n);
					list.setData(transactionTemplates, TransactionTemplateRenderer);
				}
				return;
			}
			
			if (data != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 2)
			{
				(data.callback as Function)(dataObject, data.data);
			}
			rejectPopup();
		}
		
		override public function dispose():void
		{
			if (_isDisposed == true)
				return;
			super.dispose();
			
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
			}
			
			if (list != null) {
				list.dispose();			
				list = null;
			}
		}
		
		override protected function onCloseTap():void {
			if (_isDisposed == true)
				return;
			rejectPopup();
		}
	}
}