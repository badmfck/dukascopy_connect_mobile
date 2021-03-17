package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListCountry;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.style.Style;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageOrientation;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class ScreenLinksDialog extends PopupDialogBase {
		 
		private var list:List;
		private var wasCallback:Boolean;
		
		public function ScreenLinksDialog() { }
		
		override protected function createView():void {
			super.createView();
			
			list = new List("LinksPicker");
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.background = true;
			list.setMask(true);
			list.view.y = Config.FINGER_SIZE;// + search.view.height;
			container.addChild(list.view);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			/*if (data.title)
				data.title = data.title.toLocaleUpperCase();*/
			
			list.setWidthAndHeight(_width, getMaxContentHeight());
			list.setData(data.data, data.itemClass);	
			
			if ("listenScreenRotation" in data && data.listenScreenRotation == true)
			{
				NativeExtensionController.S_ORIENTATION_CHANGE.add(onScreenOrientationChanged);
				
				updateSizesOnScreenRotation();
			}
		}
		
		private function updateSizesOnScreenRotation():void
		{
			var orientation:String = MobileGui.currentOrientation;
			
			if (orientation == StageOrientation.UPSIDE_DOWN || orientation == StageOrientation.DEFAULT)
			{
				view.rotation = 0;
				view.x = 0;
				view.y = 0;
				
				screenWidth = _width;
				screenHeight = _height;
			}
			else if (orientation == StageOrientation.ROTATED_LEFT)
			{
				view.rotation = 90;
				if (view.stage != null)
				{
					view.x = view.stage.fullScreenWidth;
				}
				view.y = 0;
				
				screenWidth = _height;
				screenHeight = _width;
			}
			else if (orientation == StageOrientation.ROTATED_RIGHT)
			{
				view.rotation = -90;
				if (view.stage != null)
				{
					view.y = view.stage.fullScreenHeight;
				}
				view.x = 0;
				
				screenWidth = _height;
				screenHeight = _width;
			}
			
			contentWidth = Math.min(screenWidth, Config.FINGER_SIZE * 8);
		}
		
		private function onScreenOrientationChanged():void
		{
			updateSizesOnScreenRotation();
			
			drawView();
		}
		
		override protected function onCloseButtonClick():void
		{
			wasCallback = true;
			if (_data && _data.callback != null)
			{
				_data.callback({id: -1});
			}
			super.onCloseButtonClick();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			list.activate();
			list.S_ITEM_TAP.add(onItemTap);
		}
		
		private function onItemTap(dataObject:Object, n:int):void {
			if (dataObject.hasOwnProperty("length") && dataObject.length == 2)
				return;
			wasCallback = true;
			DialogManager.closeDialog();
			if (_data && _data.callback != null) {
				_data.callback(dataObject);
			}
		}
		
		override protected function drawView():void {
			super.drawView();
			
			var maxContentHeight:int = getMaxContentHeight();
			
			if (list.innerHeight > maxContentHeight)
				list.setWidthAndHeight(contentWidth, maxContentHeight);
			else 
				list.setWidthAndHeight(contentWidth, list.innerHeight);
			
			
			contentHeight = title.trueHeight + list.height;
			
			list.view.y = positionDrawing;
			list.tapperInstance.setBounds();
			
			updateBack();
		}
		
		override public function dispose():void{
			if (wasCallback == false && _data != null && _data.callback != null)
			{
				_data.callback({id: -1});
			}
			super.dispose();
			list.dispose();
			list = null;
			NativeExtensionController.S_ORIENTATION_CHANGE.remove(onScreenOrientationChanged);
		}
	}
}