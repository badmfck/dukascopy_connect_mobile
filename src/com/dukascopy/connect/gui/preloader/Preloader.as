package com.dukascopy.connect.gui.preloader {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.echo.echo;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Quint;
	import com.telefision.utils.Loop;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	
	/**
	 * ...
	 * @author Alexey Skuryat. Telefision TEAM Riga.
	 */
	
	public class Preloader extends Sprite {
		
		private var preloaderMC:Bitmap;
		protected var isDisposed:Boolean = false;
		private var _disposeOnHide:Boolean = false;
		protected var holder:Sprite = new Sprite();
		protected var rotationSpeed:int = 1;
		private var _originalWidth:int = 0;
		private var _originalHeight:int = 0;
		private var _isShown:Boolean = false;
		
		private var MAX_SPEED:int = 13;
		public var MAX_SCALE:Number = 1;
		
		public function Preloader(size:Number = -1, customAsset:Class = null) {
			if (customAsset == null)
				customAsset = SWFPreloaderAsset;
			create(getSourceImage(size, customAsset));
		}
		
		protected function getSourceImage(size:Number, customAsset:Class):Sprite {
			var tempMC:Sprite;
			tempMC = new customAsset();
			if (size == -1)
				size = Config.FINGER_SIZE;
			UI.fitAndCentrate(tempMC, size, size);
			return tempMC;
		}
		
		protected function create(tempMC:Sprite):void {
			this.mouseChildren = this.mouseEnabled = false;	
			preloaderMC = new Bitmap();
			preloaderMC.bitmapData = UI.getSnapshot(tempMC, StageQuality.HIGH, "Preloader");
			holder.addChild(preloaderMC);
			_originalWidth = preloaderMC.width;
			_originalHeight = preloaderMC.height;
			preloaderMC.x = -preloaderMC.width * .5;
			preloaderMC.y = -preloaderMC.height * .5;
			preloaderMC.smoothing = true;
			addChild(holder);
			UI.destroy(tempMC);
			tempMC = null;
		}
		
		public function startAnimation():void {
			Loop.add(onLoop);
		}
		
		public function stopAnimation():void {
			Loop.remove(onLoop);
			if (holder != null)
				holder.rotation = 0;
		}
		
		/** ROTATE PRELOADER */
		private function onLoop():void {
			if (holder != null)
				holder.rotation += rotationSpeed;
			rotationSpeed++;
			rotationSpeed = rotationSpeed >= MAX_SPEED ? MAX_SPEED : rotationSpeed; 			
		}
		
		public function show(overrideAnimation:Boolean = true, animate:Boolean = true):void	{
			if (isDisposed)
				return;
			visible = true;
			TweenMax.killTweensOf(holder);
			if (animate == false) {
				_isShown = true;
				holder.scaleX = holder.scaleY = 1;
				return;
			}
			if (_isShown && !overrideAnimation)
				return;
			_isShown = true;
			rotationSpeed = 0;
			startAnimation();
			holder.scaleX = holder.scaleY = 0;
			TweenMax.to(holder, .4 , {scaleX:MAX_SCALE, scaleY:MAX_SCALE, ease:Back.easeOut } );
		}
		
		public function hide(disposeOnHide:Boolean = false, callBack:Function = null, hideTime:Number = .3, delay:Number = 0):void {
			if (isDisposed)
				return;
			_isShown = false;
			_disposeOnHide = disposeOnHide;
			TweenMax.killTweensOf(holder);
			TweenMax.to(holder, hideTime , { scaleX:0, scaleY:0, ease:Quint.easeOut, delay:delay, onComplete:onHidePreComplete, onCompleteParams:[callBack] } );
			stopAnimation();
		}
		
		private function onHidePreComplete(callBack:Function):void {
			onHideComplete();
			if (callBack != null)
				callBack();
		}
		
		private function onHideComplete():void	{
			if (_disposeOnHide) {
				dispose();
				return;
			}
			stopAnimation();
			this.visible = false;
		}
		
		public function dispose():void	{
			if (isDisposed)
				return;
			isDisposed = true;
			TweenMax.killTweensOf(holder);
			stopAnimation();		
			UI.destroy(preloaderMC);
			preloaderMC = null;			
			if (holder != null && holder.parent)
				holder.parent.removeChild(holder);
			holder = null;
			if (this.parent)
				this.parent.removeChild(this);
		}
		
		public function get originalWidth():int { return _originalWidth; }
		public function get originalHeight():int { return _originalHeight; }
		public function get isShown():Boolean { return _isShown; }
	}
}