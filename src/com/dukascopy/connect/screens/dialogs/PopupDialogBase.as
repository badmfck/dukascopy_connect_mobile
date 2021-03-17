package com.dukascopy.connect.screens.dialogs {
	
	import assets.CloseButtonIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.topBar.TopBarDialog;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class PopupDialogBase extends BaseScreen
	{
		protected var vPadding:Number;
		protected var hPadding:Number;
		
		protected var contentWidth:int;
		protected var screenHeight:int;
		protected var screenWidth:int;
		protected var container:Sprite;
		protected var title:TopBarDialog;
		protected var contentHeight:int;
		protected var positionDrawing:Number;
		
		public function PopupDialogBase() 
		{
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			container = new Sprite();
			
			vPadding = Config.FINGER_SIZE * .32;
			hPadding = Config.FINGER_SIZE * .35;
			
			// Title
			title = new TopBarDialog(hPadding);
			container.addChild(title);
			
			_view.addChild(container);
		}
		
		override public function onBack(e:Event = null):void
		{
			
		}
		
		override public function setWidthAndHeight(width:int, height:int):void {
			_width = width;
			_height = height;
			
			screenWidth = _width;
			screenHeight = _height;
			
			contentWidth = screenWidth;
			
			drawView();
		}
		
		protected function getCloseButtonIcon():Sprite 
		{
			return new CloseButtonIcon();
		}
		
		protected function onCloseButtonClick():void
		{
			DialogManager.closeDialog();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			screenWidth = _width;
			screenHeight = _height;
		}
		
		protected function getMaxContentHeight():Number 
		{
			return screenHeight - title.trueHeight;
		}
		
		override protected function drawView():void {
			
			positionDrawing = 0;
			
			// TITLE
			
			
			var isMutiline:Boolean = false;
			//!TODO: rewrite data to new Screen type and remove this strange checking in all screens;
			if ("showFullTitle" in data && Boolean(data.showFullTitle) == true)
			{
				isMutiline = true;
			}
			
			title.init(data.title, onCloseTap);
			title.draw(_width, isMutiline);
			positionDrawing = title.trueHeight;
			
			contentHeight = vPadding * 3 + title.trueHeight;
			
			container.x = int(screenWidth * .5 - contentWidth * .5);
		}
		
		private function onCloseTap():void 
		{
			onCloseButtonClick();
		}
		
		protected function updateBack():void 
		{
			container.graphics.clear();
			container.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			container.graphics.drawRect(0, 0, contentWidth, Math.min(contentHeight, screenHeight));
			container.graphics.endFill();
			
			container.y = int(screenHeight*.5 - Math.min(contentHeight, screenHeight)*.5);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			title.activate();
		}
		
		override public function deactivateScreen():void {
			if (isDisposed) return;
			super.deactivateScreen();
			title.deactivate();
		}
		
		override public function dispose():void {
			if (isDisposed) return;
			super.dispose();			
			
			if (title != null)
			{
				title.dispose()
				title = null;
			}
			
			container.graphics.clear();
			container = null;
		}
	}
}