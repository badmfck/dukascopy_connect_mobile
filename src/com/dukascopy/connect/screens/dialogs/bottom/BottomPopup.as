package com.dukascopy.connect.screens.dialogs.bottom 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power2;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class BottomPopup extends BaseScreen
	{
		protected var background:Sprite;
		protected var backgroundContent:Sprite;
		protected var container:Sprite;
		private var firstTime:Boolean = true;
		private var needExecute:Boolean;
		private var backAnimation:Object;
		private var showTime:Number = 0.25;
		
		public function BottomPopup() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			_params.doDisposeAfterClose = true;
			background.graphics.beginFill(0x000000, 0.45);
			background.graphics.drawRect(0, 0, _width, _height);
			background.alpha = 0;
			
			container.y = _height;
		}
		
		override protected function createView():void {
			super.createView();
			
			background = new Sprite();
			view.addChild(background);
			
			backgroundContent = new Sprite();
			view.addChild(backgroundContent);
			
			container = new Sprite();
			view.addChild(container);
		}
		
		override protected function drawView():void {
			super.drawView();
			view.graphics.clear();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			super.dispose();
			TweenMax.killDelayedCallsTo(close);
			TweenMax.killTweensOf(container);
			TweenMax.killTweensOf(background);
			TweenMax.killTweensOf(backgroundContent);
			if (backAnimation != null)
			{
				TweenMax.killTweensOf(backAnimation);
			}
			if (background != null)
				UI.destroy(background);
			background = null;
			if (container != null)
				UI.destroy(container);
			container = null;
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			if (firstTime) {
				drawBack();
				
				firstTime = false;
				showTime = getHeight() * .5 / _height;
				showTime = Math.max(showTime, 0.25);
				showTime = Math.min(showTime, 0.7);
				TweenMax.to(container, showTime, { y:getContentShowPosition(), ease:Power2.easeOut, onComplete:animationFinished} );
				TweenMax.to(backgroundContent, showTime, { y:int(_height - getHeight()), ease:Power2.easeOut } );
				TweenMax.to(background, showTime, { alpha:1 } );
			}
			PointerManager.addTap(background, close);
		}
		
		protected function getContentShowPosition():int 
		{
			return _height - getHeight();
		}
		
		protected function drawBack():void 
		{
			backgroundContent.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			var radius:int = Config.FINGER_SIZE * .22;
			backgroundContent.graphics.drawRoundRectComplex(0, 0, _width, getHeight(), radius, radius, 0, 0);
			backgroundContent.graphics.endFill();
			backgroundContent.y = _height;
			background.alpha = 0;
		}
		
		protected function animationFinished():void 
		{
			
		}
		
		protected function animateBack():void 
		{
			if (backAnimation != null)
			{
				TweenMax.killTweensOf(backAnimation);
			}
			backAnimation = new Object();
			backAnimation.height = backgroundContent.height;
			TweenMax.to(backAnimation, 0.3, {height:getHeight(), onUpdate:redrawBack});
		}
		
		private function redrawBack():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			if (backAnimation == null)
			{
				return;
			}
			backgroundContent.graphics.clear();
			backgroundContent.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			var radius:int = Config.FINGER_SIZE * .22;
			backgroundContent.graphics.drawRoundRectComplex(0, 0, _width, backAnimation.height, radius, radius, 0, 0);
			backgroundContent.graphics.endFill();
			backgroundContent.y = _height - backAnimation.height;
		}
		
		protected function getHeight():int 
		{
			return container.height;
		}
		
		protected function close(e:Event = null):void {
			if (isDisposed == true)
			{
				return;
			}
			
			TweenMax.killDelayedCallsTo(close);
			
			onCloseStart();
			
			deactivateScreen();
			TweenMax.to(container, 0.3, { y:getContentHidePosition(), onComplete:remove, ease:Power2.easeIn } );
			TweenMax.to(backgroundContent, 0.3, { y:_height, ease:Power2.easeIn } );
			TweenMax.to(background, 0.3, { alpha:0 } );
		}
		
		protected function onCloseStart():void 
		{
			
		}
		
		protected function getContentHidePosition():int 
		{
			return _height;
		}
		
		private function remove():void {
			onRemove();
			if (manager == DialogManager)
			{
				DialogManager.closeDialog();
			}
			else if(manager == ServiceScreenManager)
			{
				ServiceScreenManager.closeView();
			}
			else
			{
				ServiceScreenManager.closeView();
			}
		}
		
		protected function onRemove():void 
		{
			
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			PointerManager.removeTap(background, close);
		}
	}
}