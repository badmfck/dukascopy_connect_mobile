package com.dukascopy.connect.screens.base {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.swiper.Swiper;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Igor Bloom
	 */
	
	public class BaseScreen {
		
		protected var _isActivated:Boolean;
		protected var _isDisposing:Boolean;
		protected var _isDisposed:Boolean;
		protected var _data:Object;
		protected var _params:ScreenParams = null;
		protected var _view:Sprite;
		protected var _width:int;
		protected var _height:int;
		protected var _titleBitmap:Bitmap;
		protected var _titleIBMD:ImageBitmapData;
		protected var _sw:Swiper;
		
		public var sm:ScreenManager;
		public var manager:Class;
		
		public function BaseScreen() {
			createView();
		}
		
		/**
		 * Calls when screenManager start rendering bitmap;
		 */
		public function startRenderingBitmap():void{
			
		}
		
		/**
		 * Calls when screenManagers stop rendering bitmap;
		 */
		public function stopRenderingBitmap():void {
			
		}
		
		/**
		 * Create view, invoke in consturctor
		 */
		protected function createView():void {
			_view = new Sprite();
			_sw = new Swiper("Screen");
			_sw.S_ON_SWIPE.add(onSwipe);
		}
		
		protected function onSwipe(d:String):void {
			if (sm != MobileGui.centerScreen)
				return;
			if (_sw.startX > Config.FINGER_SIZE)
				return;
			if (MobileGui.centerScreen.currentScreenClass == RootScreen)
				return;
			if (d == Swiper.DIRECTION_RIGHT)
				onBack();
		}
		
		/**
		 * Screen params settings
		 * @param data - is data object for screen
		 */
		public function initScreen(data:Object=null):void {
			_data = data;
			_params = new ScreenParams();
		}
		
		/**
		 * Changing width and height of screen. can invoke BEFORE drawView and AFTER (when resize)
		 * @param	width
		 * @param	height
		 */
		public function setWidthAndHeight(width:int, height:int):void {
			_width = width;
			_height = height;
			drawView();
			if (_sw != null)
				_sw.setBounds(width, height, _view);
		}
		
		/**
		 * Sets width and height of screen. to have original sizes inside initScreen method
		 * @param	width
		 * @param	height
		 */
		public function setInitialSize(width:int, height:int):void {
			_width = width;
			_height = height;
			if (_sw != null)
				_sw.setBounds(width, height, _view);
		}
		/**
		 * Draw screen view after change current Lang
		 * @param	data - array of params
		 */
		public function drawViewLang():void {
			//your object draw
			drawView();
		}
		/**
		 * Draw screen view
		 * @param	data - array of params
		 */
		protected function drawView():void {
			if (_isDisposing == true || _isDisposed == true)
				return;
			_view.graphics.clear();
			_view.graphics.beginFill(0xFFCC00);
			_view.graphics.drawEllipse(0, 0, _width, _height);
		}
		
		/**
		 * Activate events and calls
		 * after that method, screen is ready to work
		 */
		public function activateScreen():void {
			if (_isDisposed) {
				_isActivated = false;
				return;
			}
			_isActivated = true;
			if (_sw != null)
				_sw.activate();
		}
		
		/**
		 * Deactivate events and calls
		 */
		public function deactivateScreen():void {
			_isActivated = false;
			if (_sw != null)
				_sw.deactivate();
		}
		
		/**
		 * Clear screen view
		 */
		public function clearView():void {
			if (_view != null)
				_view.graphics.clear();
		}
		
		/**
		 * Dispose screen
		 */
		public function dispose():void {
			_isDisposing = true;
			if (_titleIBMD != null)
				_titleIBMD.dispose();
			_titleIBMD = null;
			if (_titleBitmap != null) {
				if (_titleBitmap.parent != null)
					_titleBitmap.parent.removeChild(_titleBitmap);
				if (_titleBitmap.bitmapData != null)
					_titleBitmap.bitmapData.dispose();
				_titleBitmap.bitmapData = null;
			}
			_titleBitmap = null;
			deactivateScreen();
			clearView();
			if (_view != null && _view.parent != null)
				_view.parent.removeChild(_view);
			if (_sw != null)
				_sw.dispose();
			manager = null;
			_isDisposed = true;
		}
		
		public function updateBounds():void {
			
		}
		
		public function onBack(e:Event = null):void {
			if (MobileGui.serviceScreen != null && 	MobileGui.serviceScreen.currentScreen != null) {
				ServiceScreenManager.closeView();
				return;
			}
			
			if (data && "backScreen" in data == true && data.backScreen != null) {
				MobileGui.changeMainScreen(data.backScreen, data.backScreenData, ScreenManager.DIRECTION_LEFT_RIGHT);
				return;
			}
			MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
		}
		
		public function getScrollPosition():int {
			return 0;
		}
		
		public function getAdditionalDebugInfo():String {
			return "";
		}
		
		public function isModal():Boolean {
			return false;
		}
		
		public function get view():Sprite {
			return _view;
		}
		
		public function get params():ScreenParams {
			return _params;
		}
		
		public function get data():Object{
			return _data;
		}
		
		public function get isDisposed():Boolean{
			return _isDisposed;
		}
		
		public function get isActivated():Boolean {
			return _isActivated;
		}
	}
}