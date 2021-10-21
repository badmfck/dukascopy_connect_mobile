package com.dukascopy.connect.screens.base {
	
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.dialogs.PopupDialogBase;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power1;
	import com.greensock.easing.Power3;
	import com.greensock.easing.Sine;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Igor Bloom
	 */
	
	public class ScreenManager{
		
		static public const DIRECTION_LEFT_RIGHT:int = 1;
		static public const DIRECTION_RIGHT_LEFT:int = 0;
		
		static public var S_SCREEN_INITED:Signal = new Signal("ScreenManager.S_SCREEN_INITED");
		
		public var S_START_SHOW:Signal = new Signal("ScreenManager.S_START_SHOW");
		public var S_COMPLETE_SHOW:Signal = new Signal("ScreenManager.S_COMPLETE_SHOW");
		
		private var isBackgroundShows:Boolean = true;
		private var backgroundColor:uint = 0xF5F5f5;
		private var _inTransition:Boolean = false;
		private var _width:int = 320;
		private var _height:int = 240;
		
		private var _view:Sprite;
		
		private var boxScreen:Sprite;
		
		private var _currentScreen:BaseScreen;
		private var _currentScreenClass:Class;
		private var _busy:Boolean;
		
		private var oldScreen:Bitmap;
		private var newScreen:Bitmap;
		
		private var tweenObj:Object;
		private var screenStock:Array=[];
		private var oldHash:String = "";
		
		private var pendingScreenClass:Class;
		private var pendingScreenData:Object;
		public var dontActivate:Boolean = false;
		public var manager:Class;
		
		private var screenManagerName:String = "";
		
		private var ntx:int = 0;
		private var kf:Number = .4;// 1.2;
		private var otx:int = 10;
		private var _cls:Class;
		private var _data:Object ;
		private var _direction:int = 0;
		private var _transitionTime:Number=0.3;
		private var ignoreBackSignal:Boolean = false;
		private var _isDisposed:Boolean = false;
		private var _isActive:Boolean = true;
		
		public function ScreenManager(screenManagerName:String = "") {
			this.screenManagerName = screenManagerName;
			createView();
		}
		
		private function createView():void{
			_view = new Sprite();
				boxScreen = new Sprite();
			_view.addChild(boxScreen);
			setBackground(isBackgroundShows);
			MobileGui.S_BACK_PRESSED.add(onBackPressed);
		}
		
		public function setBackground(val:Boolean):void {
			if (val == isBackgroundShows && val == false)
				return;
			isBackgroundShows = val;
			setBackgroundColor(backgroundColor);
		}
		
		private function setBackgroundColor(color:uint):void {
			view.graphics.clear();
			if (isBackgroundShows == false)
				return;
			backgroundColor = color;
		//	view.graphics.beginFill(backgroundColor, 1);
		//	view.graphics.drawRect(0, 0, _width, _height);
		}
		
		public function setSize(w:Number, h:Number):void {
			if (_width != w || _height != h)
			{
				_width = w;
				_height = h;
				setBackground(isBackgroundShows);
				setScreenSizeAndDrawView(_currentScreen);
			}
		}
		
		public function hide():void{
			_view.visible = false;
		}
		
		/**
		 * 
		 * @param	cls
		 * @param	data
		 * @param	direction  0 - hides to left, shows from right, 1 - hides to right, shows from left
		 */
		public function show(cls:Class, data:Object = null, direction:int = 0, transitionTime:Number = 0.3, currentScreenEndAlpha:Number = 1):void {
			
			_direction = direction;
			_transitionTime = transitionTime;
			
			if (cls == null) {
				echo("ScreenManager (" + screenManagerName + ")", "show", "ERROR -> TRYING TO SHOW SCREEN WITH CLASS NULL");
				cls = RootScreen;
				data = null;
			}
			
			_cls = cls;
			_data = data;
			
			var classname:String = getQualifiedClassName(cls);
			classname = classname.substr(classname.indexOf("::") + 2);
			echo("ScreenManager (" + screenManagerName + ")", "show " + classname, data);
			if (_busy == true){
				pendingScreenClass = cls;
				pendingScreenData = data;
				return;
			}
			
			S_START_SHOW.invoke();
			_busy = true;
			
			if (_view.visible == false)
				_view.visible = true;
			
			var hashData:Object;
			if (data == null)
				hashData = data;
			else if (data is ChatScreenData) {
				if (data.chatVO != null)
					hashData = data.chatVO.uid;
				else
					hashData = data.chatUID;
			} else if ("backScreenData" in data) {
				var backScreenData:Object = data.backScreenData;
				data.backScreenData = null;
			} else {
				hashData = data;
			}
			if (hashData == null)
				hashData = { };
				
			var hash:String = null;
			try{
				var ba:ByteArray = new ByteArray();
				ba.writeObject(hashData);
				
			//	hash = MD5.hash(JSON.stringify(hashData));
				hash = MD5.hashBinary(ba);
			}catch (e:Error){
				echo("ScreenManager (" + screenManagerName + ")", "show", "Can`t create hash for object");
			}
			
			if (backScreenData != null)
				data.backScreenData = backScreenData;
			backScreenData = null;
			
			if (hash == null)
				hash = "nohash";
			
			if (_currentScreen is cls && oldHash == hash && (oldHash != MD5.hash(JSON.stringify( { } )))) {
				S_COMPLETE_SHOW.invoke(cls);
				_inTransition = false;
				_busy = false;
				return;
			}
			
			oldHash = hash;
			
			// CREATE SNAPSHOT FOR PREV SCREEN
			if (_currentScreen != null) {
				// draw oldscreen
				if (oldScreen==null || oldScreen.bitmapData == null || oldScreen.bitmapData.width!=_width || oldScreen.bitmapData.height!=_height) {
					if (oldScreen == null){
						oldScreen = new Bitmap(null, "auto", true);
					} else {
						if( oldScreen.bitmapData != null)
							oldScreen.bitmapData.dispose();
					}				
					oldScreen.bitmapData = new ImageBitmapData("ScreenManager.oldscreen", _width, _height, true, 0);
				} else {
					if (_currentScreen.params.transparentBg)
						oldScreen.bitmapData.fillRect(oldScreen.bitmapData.rect, 0);
				}
				_currentScreen.startRenderingBitmap();
				oldScreen.bitmapData.drawWithQuality(_currentScreen.view, null, null, null, null, true, StageQuality.HIGH);
				_currentScreen.stopRenderingBitmap();
				_currentScreen.deactivateScreen();
				
				if (oldScreen.parent == null)
					boxScreen.addChild(oldScreen);
				oldScreen.x = 0;
				
				if ('onHide' in _currentScreen) {
					_currentScreen['onHide']();
				}
				if(_currentScreen.params.doDisposeAfterClose) {
					_currentScreen.dispose();
					removeScreenFromStock(_currentScreen);
				} else {
					if (_currentScreen.view == null) {
						_currentScreen.dispose();
						removeScreenFromStock(_currentScreen);
					} else {
						if (_currentScreen.view.parent)
							_currentScreen.view.parent.removeChild(_currentScreen.view);
					}
				}
			}
			
			var waitTime:Number = 0.01;
			// START TO SHOW SCREEN
			if (transitionTime == 0) {
				waitTime = 0;
				startToShowScreen();
			}else{
				TweenMax.delayedCall(waitTime, startToShowScreen, [currentScreenEndAlpha], false);
			}
		}

		private function startToShowScreen(currentScreenEndAlpha:Number = 1):void {
			echo("ScreenManager (" + screenManagerName + ")", "show", "TweenMax.delayedCall (START SHOW)");
			
			// FORM NEW SCREEN
			var screen:BaseScreen = getScreenFromStock(_cls);
			if (screen == null || screen.isDisposed == true) {
				screen = new _cls();
				screen.sm = this;
				addScreenToStock(screen, _cls);
			}
			_currentScreenClass = _cls;
			_currentScreen = screen;
			screen.manager = manager;
			screen.setInitialSize(_width, _height);
			screen.initScreen(_data);
			GD.S_SCREEN_READY.invoke(getQualifiedClassName(screen).split("::")[1]);
			S_SCREEN_INITED.invoke(_cls + "");
			
			setScreenSizeAndDrawView(screen);
			
			if (newScreen == null)
				newScreen = new Bitmap(null, "auto", true);
			if (newScreen.bitmapData != null)
			{
				newScreen.bitmapData.dispose();
				newScreen.bitmapData = null;
			}
			newScreen.bitmapData = new ImageBitmapData("ScreenManager.newscreen", _width, _height, true, 0);
			_currentScreen.startRenderingBitmap();
			newScreen.bitmapData.drawWithQuality(_currentScreen.view, null, null, null, null, true, StageQuality.HIGH);
			_currentScreen.stopRenderingBitmap();
			boxScreen.addChild(newScreen);
			
			// TARGETS
			ntx = 0;
			kf = .4;// 1.2;
			otx = _width * kf;
			
			// INIT POS
			if (_transitionTime != 0) {
				newScreen.x = -_width;
				newScreen.alpha = 0;
			}
			
			// DIRECTION
			if (_direction == 0) {
				newScreen.x = _width;
				otx = -_width * kf;
			}
			
			// OBJECT TO TWEEN
			if (tweenObj == null)
				tweenObj = { };
			
			tweenObj.na = newScreen.alpha;
			tweenObj.nx = 0;
			tweenObj.ox = 0;
			tweenObj.oa = 0;
			tweenObj.oldScreenAlphaTarget = 1;
			
			if (oldScreen != null){
				tweenObj.ox = oldScreen.x;
				//tweenObj.oa =oldScreen.alpha;
				tweenObj.na = 0;
				newScreen.alpha = 0;
				tweenObj.nx = newScreen.x;
			}
			else{
				newScreen.alpha = 1;
				tweenObj.na = 1;
			}

			if (_direction == 3)
			{
				newScreen.x = _width;
				tweenObj.nx = _width;
			}

			var transitionFrames:Number = (_transitionTime == 0) ? 0 : _transitionTime * MobileGui.stage.frameRate;
			var useFramesInTransition:Boolean = _transitionTime == 0?false:true;
			
			// START TWEEN
			echo("ScreenManager (" + screenManagerName + ")", "show", "TweenMax.delayedCall (START SHOW CONTINUE)");
			
			if (_transitionTime != 0)
			{
				TweenMax.to(tweenObj, transitionFrames, { useFrames:useFramesInTransition, oldScreenAlphaTarget:currentScreenEndAlpha, na:1, nx:ntx, ox:otx, oa:0, ease:Power3.easeOut, onUpdate:startTweenOnUpdate, onComplete:startTweenComplete});
			}
			else{
				startTweenComplete();
			}
		}
		
		private function startTweenOnUpdate():void {
			if (newScreen != null) {
				newScreen.x = tweenObj.nx;
				newScreen.alpha = tweenObj.na;
			}
			if (oldScreen != null) {
				oldScreen.x = tweenObj.ox;
				oldScreen.alpha = tweenObj.oldScreenAlphaTarget;
			}
		}
		
		private function startTweenComplete():void {
			var classname:String = getQualifiedClassName(_cls);
			echo("ScreenManager (" + screenManagerName + ")", "startTweenComplete", "onComplete: " + classname);
			if (_currentScreen != null) {
				boxScreen.addChild(_currentScreen.view);
				if ("onShowComplete" in _currentScreen) {
					_currentScreen["onShowComplete"]();
				}
				_busy = false;
				if (_isActive == true) {
					if (dontActivate)
						_currentScreen.activateScreen();
					else if (dontActivate == false && MobileGui.dialogShowed == false)
						_currentScreen.activateScreen();
				}
				if (newScreen && newScreen.bitmapData) {
					newScreen.bitmapData.dispose();
					newScreen.bitmapData = null;
				}
				if (oldScreen != null && oldScreen.bitmapData != null) {
					oldScreen.bitmapData.dispose();
					oldScreen.bitmapData = null;
				}
				if (pendingScreenClass != null) {
					show(pendingScreenClass, pendingScreenData);
					pendingScreenClass = null;
					pendingScreenData = null;
				} else
					S_COMPLETE_SHOW.invoke(_cls);
			}
		}

		private function getScreenFromStock(cls:Class):BaseScreen {
			var n:int = 0;
			if (screenStock == null)
				return null;
			var l:int = screenStock.length;
			for (n; n < l; n++) {
				if (screenStock[n][0] == cls){
					var res:BaseScreen = screenStock[n][1];
					if (res == null || res.isDisposed == true) {
						screenStock.splice(n, 1);						
						return null;
					}
					return res;
				}
			}
			return null;
		}
		
		public function refreshEachScreen():void {
			if (LangManager.initialized == false)
				return;
			var n:int = 0;
			if (screenStock == null)
				return ;
			var l:int = screenStock.length;
			for (n; n < l; n++) {
				if (screenStock[n][0] ){
					var res:BaseScreen = screenStock[n][1];
					if (res != null && res.isDisposed == false) {
						res.drawViewLang();
					}
				}
			}
		}

		private function addScreenToStock(screen:BaseScreen, cls:Class):void {
			var n:int = 0;
			if (screenStock == null)
				screenStock = [];
			var l:int = screenStock.length;
			for (n; n < l; n++) {
				if (screenStock[n][0] == cls) {
					echo("ScreenManager (" + screenManagerName + ")", 'addScreenToStock', 'Screen Already in Stock, disposing old, adding new');
					var res:BaseScreen = screenStock[n][1];
					if(res!=null){
						res.dispose();
						res = null;
					}
					screenStock[n][1] = screen;
					return;
				}
			}
			
			screenStock.push([cls, screen]);
		}
		
		private function removeScreenFromStock(screen:Object):void {
			var className:String = getQualifiedClassName(screen)
			var cls:Class = getDefinitionByName(className) as Class;
			var n:int = 0;
			var l:int = screenStock.length;
			for (n; n < l; n++) {
				if (screenStock[n] == null) 
					continue;
				if (screenStock[n][0] == cls){
					var res:BaseScreen = screenStock[n][1];
					if (res != null && res.isDisposed == false)
						res.dispose();
					echo("ScreenManager (" + screenManagerName + ")", "removeScreenFromStock", "");
					screenStock.splice(n, 1);
				}
			}
		}
		
		public function deactivate():void {
			if (_isActive == false)
				return;
			_isActive = false;
			if (_currentScreen != null)
				_currentScreen.deactivateScreen();
			MobileGui.S_BACK_PRESSED.remove(onBackPressed);
		}
		
		public function activate():void {
			if (_isActive == true)
				return;
			_isActive = true;
			if (_currentScreen != null && _busy == false) {
				if (dontActivate)
					_currentScreen.activateScreen();
				else if (dontActivate == false && MobileGui.dialogShowed == false)
					_currentScreen.activateScreen();
			}
			MobileGui.S_BACK_PRESSED.add(onBackPressed);
		}
		
		private function onBackPressed():void {
			if (ignoreBackSignal == true)
				return;
			if (_currentScreen)
				_currentScreen.onBack();
		}
		
		public function disposeCurentScreen():void {
			if (_currentScreen != null) {
				if (_currentScreen is PopupDialogBase)
					(_currentScreen as PopupDialogBase).onBack();
				if (_currentScreen.params.doDisposeAfterClose){
					_currentScreen.dispose();
					_currentScreenClass = null;
					_currentScreen = null;
				} else {
					_currentScreen.deactivateScreen();
				}
			}
		}
		
		public function dispose():void {
			disposeCurentScreen();
			if (S_COMPLETE_SHOW != null)
				S_COMPLETE_SHOW.dispose();
			S_COMPLETE_SHOW = null;
			
			if (S_START_SHOW != null)
				S_START_SHOW.dispose();
			S_START_SHOW = null;
			
			if (screenStock!=null) {
				var n:int = 0;
				var l:int = screenStock.length;
				for (n; n < l; n++) {
					if (screenStock[n][1] != null)
						screenStock[n][1].dispose();
				}
			}
			screenStock = null;
			
			if (tweenObj != null)
				TweenMax.killTweensOf(tweenObj);
			tweenObj = null;
			
			if (oldScreen != null && oldScreen.bitmapData!=null)
				oldScreen.bitmapData.dispose();
			oldScreen = null;
			if (newScreen != null && newScreen.bitmapData!=null)
				newScreen.bitmapData.dispose();
			newScreen = null;
			
			MobileGui.S_BACK_PRESSED.remove(onBackPressed);
			
			_isDisposed = true;
		}
		
		public function clear():void {
			if (newScreen != null) {
				TweenMax.killTweensOf(newScreen);
				if (newScreen.bitmapData != null)
					newScreen.bitmapData.dispose();
				newScreen.bitmapData = null;
				if (newScreen.parent != null)
					newScreen.parent.removeChild(newScreen);
			}
			newScreen = null;
			
			if (oldScreen != null) {
				TweenMax.killTweensOf(oldScreen);
				if (oldScreen.bitmapData != null)
					oldScreen.bitmapData.dispose();
				oldScreen.bitmapData = null;
				if (oldScreen.parent != null)
					oldScreen.parent.removeChild(oldScreen);
			}
			oldScreen = null;
			
			if (screenStock!=null) {
				var n:int = 0;
				var l:int = screenStock.length;
				for (n; n < l; n++) {
					if (screenStock[n][1] != null)
						screenStock[n][1].dispose();
				}
			}
			screenStock = null;
			
			_currentScreenClass = null;
			_currentScreen = null;
			
			_busy = false;
		}
		
		private function setScreenSizeAndDrawView(screen:BaseScreen):void {
			if (screen == null)
				return;
			if (screen.isDisposed == true)
				return;
			var screenHeight:int = _height;
			screen.view.y = 0;
			screen.setWidthAndHeight(_width, screenHeight);
		}
		
		public function ingnoreBackSignal():void {
			ignoreBackSignal = true;
		}
		
		public function getScreenByClass(cls:Class):BaseScreen {
			for (var i:int = 0; i < screenStock.length; i++) {
				if (screenStock[i][1] is cls)
					return screenStock[i][1];
			}
			return null;
		}
		
		public function listenBackSignal():void {
			ignoreBackSignal = false;
		}
		
		public function get currentScreen():BaseScreen { return _currentScreen; }
		public function get currentScreenClass():Class { return _currentScreenClass; }
		public function get busy():Boolean { return _busy; }
		public function get view():Sprite { return _view; }
		public function get inTransition():Boolean { return _inTransition; }
		public function get isDisposed():Boolean { return _isDisposed; }
		public function get isActive():Boolean { return _isActive; }
	}
}