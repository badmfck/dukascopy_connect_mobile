package com.dukascopy.connect.gui.chat 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Alexey Skuryat

	 */
	public class BotMenu extends Sprite 
	{
		
		
		private static var removedButtonsArray:Array = [];		
		private var addedButtons:Array = [];
		private var sourceData:Array;
		private var _isDisposed:Boolean = false;
		private var BUTTON_HEIGHT:int = 20;// 50;// Config.FINGER_SIZE_DOT_75;
		private var _viewWidth:int = 100;
		private var totalHeight:int = 0;
		private static var tempRect:Rectangle = new Rectangle();
		private static var _instancesCount:int = 0;
		
		private var vTextMargin:Number;
		private var _selectedIndex:int = -1;
		
		
		/**
		 * @CONSTRUCTOR
		 */
		public function BotMenu() 
		{
			vTextMargin = Math.ceil(Config.FINGER_SIZE * .13);
			_instancesCount++;			
			this.mouseChildren = this.mouseEnabled = false;	// Note ! remove this in case other usage 		 
			//trace("Bot menu Instances Count ="+_instancesCount);
		}
		
		
		
		public function createMenu(source:Array):void {
			// if has created buttons -> remove first 
			sourceData = source;	
			var lastY:int = 0;
			for (var i:int = 0; i < source.length; i++) {
				var newButton:BotMenuItem = getFreeMenuItem();
				
				if(_selectedIndex!=-1){
					newButton.create(_viewWidth, BUTTON_HEIGHT, source[i].text, 0xffffff,  i == 0 , i == source.length - 1, i!=_selectedIndex);
				}else{
					newButton.create(_viewWidth, BUTTON_HEIGHT, source[i].text, 0xffffff,  i == 0 , i == source.length - 1, false);
				}
				addedButtons.push(newButton);	
				addChild(newButton);
				newButton.y = lastY;
				lastY += newButton.viewHeight;
				totalHeight = lastY;
			}			
		}
		
		
		public function destroyMenu():void
		{
			var btn:BotMenuItem;
			for (var i:int = 0; i < addedButtons.length; i++) {
				btn = addedButtons[i];
				UI.safeRemoveChild(btn);
				removedButtonsArray.push(btn);
			}			
			addedButtons.length = 0;
		}
		
		
		private function updateViewPort():void
		{
			if (sourceData == null) return;			
			var btn:BotMenuItem;
			var lastY:int = 0;
			for (var i:int = 0; i < addedButtons.length; i++) {
				btn = addedButtons[i];
				btn.setSize(_viewWidth, BUTTON_HEIGHT);
				
				if (_selectedIndex !=-1){
					if (_selectedIndex == i){
						btn.disabled = false;
					}else{
						btn.disabled = true;
					}
				}else{
					btn.disabled = false;
				}
				
				btn.y = lastY;
				lastY += btn.viewHeight;
				totalHeight = lastY;
			}	
		}
		
		
		private function getFreeMenuItem():BotMenuItem{
			if (removedButtonsArray.length > 0){
				//trace(this, " Return reusable Bot menu item");
				return removedButtonsArray.pop();
			}else{
				//trace(this, " Create new Bot menu item");
				return new BotMenuItem();
			}
		}
		
		
		public function getTotalHeight():int{
			return totalHeight;// addedButtons.length * Config.FINGER_SIZE_DOT_75;
		}
		
		
		public function dispose():void	{		
			if (_isDisposed) return;
			_isDisposed = true;			
			_instancesCount--;
			destroyMenu(); // maybe left cached buttons instances
			sourceData = null;
			addedButtons = null;
			_selectedIndex = -1;
			// add clear storage 
			//trace("//////////////\n/////////////////\n////////////////");
			//trace("Bot menu Destroyed Instances Count ="+_instancesCount);
		}
		
		
		
		public function getBtnBounds(i:int):Rectangle 
		{
			tempRect.x = 0;
			tempRect.y = 0;
			tempRect.width = 0;
			tempRect.height = 0;			
			if (i<0 || i > addedButtons.length - 1){				
				return tempRect;
			}else{
				var btn:BotMenuItem = addedButtons[i];
				if (btn != null){
					tempRect.x = btn.x;
					tempRect.y = btn.y;
					tempRect.width = btn.width;
					tempRect.height = btn.viewHeight;
					//return btn.getBounds(this);
					return tempRect;					
				}else{
					return tempRect;
				}
			}
		
			
		}
		
		public function get viewWidth():int {return _viewWidth;}		
		public function set viewWidth(value:int):void 
		{
			if (_viewWidth == value) return;
			_viewWidth = value;
			updateViewPort();
		}
		
		public function set selectedIndex(value:int):void {
			_selectedIndex = value;
			updateViewPort();
		}
		
		
		
		
		
	}

}