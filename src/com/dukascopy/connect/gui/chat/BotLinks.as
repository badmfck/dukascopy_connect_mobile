package com.dukascopy.connect.gui.chat 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Sergey Dobarin

	 */
	public class BotLinks extends Sprite 
	{
		private static var removedLinksArray:Array = [];		
		private var addedLinks:Array = [];
		private var sourceData:Array;
		private var _isDisposed:Boolean = false;
		private var _viewWidth:int = 100;
		private var totalHeight:int = 0;
		private static var tempRect:Rectangle = new Rectangle();
		private static var _instancesCount:int = 0;
		
		private var vTextMargin:Number;
		
		/**
		 * @CONSTRUCTOR
		 */
		public function BotLinks() 
		{
			vTextMargin = Math.ceil(Config.FINGER_SIZE * .13);
			_instancesCount++;			
			this.mouseChildren = this.mouseEnabled = false;	// Note ! remove this in case other usage 		 
			//trace("Bot menu Instances Count ="+_instancesCount);
		}
		
		public function createLinks(source:Array):void {
			// if has created buttons -> remove first 
			sourceData = source;	
			var lastY:int = 0;
			for (var i:int = 0; i < source.length; i++) {
				var newLink:BotLinkItem = getFreeLinkItem();
				
				newLink.create(_viewWidth, source[i].title);
				
				addedLinks.push(newLink);	
				addChild(newLink);
				newLink.y = lastY;
				lastY += newLink.viewHeight + Config.FINGER_SIZE * .1;
				totalHeight = lastY;
			}			
		}
		
		public function destroyLinks():void
		{
			var btn:BotLinkItem;
			for (var i:int = 0; i < addedLinks.length; i++) {
				btn = addedLinks[i];
				UI.safeRemoveChild(btn);
				removedLinksArray.push(btn);
			}			
			addedLinks.length = 0;
		}
		
		private function updateViewPort():void
		{
			if (sourceData == null) return;			
			var btn:BotLinkItem;
			var lastY:int = 0;
			for (var i:int = 0; i < addedLinks.length; i++) {
				btn = addedLinks[i];
				btn.setSize(_viewWidth);
				
				btn.y = lastY;
				lastY += btn.viewHeight + Config.FINGER_SIZE * .1;
				totalHeight = lastY;
			}	
		}
		
		private function getFreeLinkItem():BotLinkItem{
			if (removedLinksArray.length > 0){
				//trace(this, " Return reusable Bot link item");
				return removedLinksArray.pop();
			}else{
				//trace(this, " Create new Bot link item");
				return new BotLinkItem();
			}
		}
		
		public function getTotalHeight():int{
			return totalHeight;// addedButtons.length * Config.FINGER_SIZE_DOT_75;
		}
		
		public function dispose():void	{		
			if (_isDisposed) return;
			_isDisposed = true;			
			_instancesCount--;
			destroyLinks(); // maybe left cached links instances
			sourceData = null;
			addedLinks = null;
			// add clear storage 
			//trace("//////////////\n/////////////////\n////////////////");
			//trace("Bot link Destroyed Instances Count ="+_instancesCount);
		}
		
		public function getBtnBounds(i:int):Rectangle 
		{
			tempRect.x = 0;
			tempRect.y = 0;
			tempRect.width = 0;
			tempRect.height = 0;			
			if (i<0 || i > addedLinks.length - 1){				
				return tempRect;
			}else{
				var btn:BotLinkItem = addedLinks[i];
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
	}
}