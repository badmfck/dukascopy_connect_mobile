package com.dukascopy.connect.gui.topBar {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.input.SearchBar;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.sys.style.Style;
	import com.greensock.TweenMax;
	import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * Используется во всех экранах, кроме RootScren & ChatScreen
	 * @author Pavel Karpov Telefision TEAM Kiev.
	 */
	
	public class TopBarScreen extends Sprite {
		
		public static var btnSize:int;
		public static const marge:int = Config.FINGER_SIZE * .16;
		public static const margeLR:int = Config.FINGER_SIZE * .16;
		public static const _trueHeight:int = Config.APPLE_TOP_OFFSET + Config.TOP_BAR_HEIGHT;
		
		protected var _isActivated:Boolean;
		protected var _width:int;
		private var firstTime:Boolean = true;
		private var created:Boolean;
		private var needToAnimate:Object;
		private var searchBar:SearchBar;
		private var _onBackFunction:Function;
 		protected var onBack:Boolean;
		protected var backButton:BitmapButton;
		protected var titleText:String;
		protected var titleBitmap:Bitmap;
		protected var titleWidth:int;
		protected var additionalText:String;
		protected var additionalBitmap:Bitmap;
		protected var bgShape:Shape;
		protected var _actions:Array;
		protected var actionButtons:Object;
		protected var actionsBar:Sprite;
		protected var syncIndicator:Preloader;
		protected var tmpBtn:BitmapButton;
		
		public function TopBarScreen() {
			btnSize = Style.size(Style.CHAT_TOP_ICON_SIZE);
		}
		
		public function setData(title:String, onBack:Boolean = true, actions:Array = null):void {
			this.onBack = onBack;
			this.titleText = title;
			_actions = actions;
			_onBackFunction = onBackDefault;
		}
		
		public function set onBackFunction(value:Function):void 
		{
			_onBackFunction = value;
		}
		
		private function onBackDefault():void 
		{
			MobileGui.S_BACK_PRESSED.invoke();
		}
		
		public function set backgroundColor(value:Number):void
		{
			if (bgShape != null)
			{
				var ct:Color = new Color();
				ct.color = value;
				bgShape.transform.colorTransform = ct;
			}
		}
		
		public function updateAction(id:String, action:Object):void {
			if (actionButtons == null || actionButtons[id] == null)
				return;
			var btn:BitmapButton = actionButtons[id];
			delete actionButtons[id];
			if (action != null) {
				btn.setBitmapData(UI.getSnapshot(getIco(action.img, action.imgColor), StageQuality.HIGH, "TopBarScreen." + action.id), true);
				btn.tapCallback = action.callback;
				actionButtons[action.id] = btn;
			} else {
				btn.dispose();
				arrangeActionsInOrder();
			}
		}
		
		public function setActions(actions:Array):void {
			if (_actions == null && actions == null)
				return;
			_actions = actions;
			if (created == false)
				return;
			createButtonsFromActions();
			arrangeActionsInOrder();
			titleWidth = _width - Config.FINGER_SIZE - actionsBar.width;
		}
		
		private function createButtonsFromActions():void {
			deleteActions();
			if (_actions == null || _actions.length == 0)
				return;
			actionButtons ||= {};
			actionsBar ||= new Sprite();
			if (actionsBar.parent == null)
				addChild(actionsBar);
			var ll:int = _actions.length;
			var tmp:Object;
			var btn:BitmapButton;
			var id:String;
			var delay:Number = .15;
			for (var i:int = 0; i < ll; i++) {
				tmp = _actions[i];
				id = tmp.id;
				btn = createButton(tmp.img, tmp.imgColor, id);
				btn.tapCallback = tmp.callback;
				actionButtons[id] = btn;
				if (_isActivated == true) {
					delay += .15;
					actionButtons[id].show(.3, delay);
					btn.activate();
				}
				actionsBar.addChild(btn);
			}
		}
		
		private function createView():void {
			created = true;
			
			bgShape = UI.getTopBarShape();
			addChild(bgShape);
			
			titleBitmap = new Bitmap(null, "auto", true);
			titleBitmap.x = Config.DOUBLE_MARGIN;
			addChild(titleBitmap);
			
			if (onBack == true) {
				backButton = createButton(Style.icon(Style.ICON_BACK), Style.color(Style.TOP_BAR_ICON_COLOR), "backButton");
				backButton.tapCallback = onBackHandler;
				backButton.x = Config.DOUBLE_MARGIN;
			//	backButton.y += Config.APPLE_TOP_OFFSET;
				addChild(backButton);
				titleBitmap.x = backButton.x + backButton.width + Config.DOUBLE_MARGIN;
			}
			if (_actions != null) 
				createButtonsFromActions();
			if (searchBar != null)
			{
				setChildIndex(searchBar.view, numChildren - 1);
			}
		}
		
		private function arrangeActionsInOrder():void {
			if (titleWidth == 0)
				return;
			var ll:int = actionsBar.numChildren;
			var btn:BitmapButton;
			var x0:int = margeLR;
			for (var i:int = 0; i < ll; i++) {
				btn = actionsBar.getChildAt(i) as BitmapButton;
				btn.x = x0;
				x0 += btn.fullWidth;
			}
		//	actionsBar.y = Config.APPLE_TOP_OFFSET;
			
			var position:int = 0;
			
			actionsBar.x = Math.round(_width - actionsBar.width - Config.MARGIN);
		}
		
		private function deleteActions():void {
			if (actionButtons != null) {
				for (var name:String in actionButtons) {
					actionButtons[name].dispose();
					delete actionButtons[name];
				}
			}
		}
		
		private function getIco(img:Class, color:Number):Sprite {
			var ico:Sprite = new img() as Sprite;
			if (isNaN(color) == false)
				UI.colorize(ico, color);
			ico.height = btnSize;
			ico.scaleX = ico.scaleY;
			return ico;
		}
		
		private function createButton(img:Class, imgColor:Number, id:String):BitmapButton {
			var btn:BitmapButton = new BitmapButton();
			btn.listenNativeClickEvents(true);
			btn.setStandartButtonParams();
			btn.setDownScale(1.3);
			btn.setDownColor(imgColor);
			btn.disposeBitmapOnDestroy = true;
			btn.setBitmapData(UI.getSnapshot(getIco(img, imgColor), StageQuality.HIGH, "TopBarScreen." + id), true);
			btn.setOverflow(marge, margeLR, margeLR, marge);
			btn.y = Config.APPLE_TOP_OFFSET + int((trueHeight-Config.APPLE_TOP_OFFSET) * .5 - btn.height * .5);
			btn.hide();
			return btn;
		}
		
		public function showAnimationOverButton(id:String, needMaxTime:Boolean = true):void {
			var tmp:Object;
			var maxTime:int = 1;
			if (_isActivated == false) {
				needToAnimate = { id:id, needMaxTime:needMaxTime }
				return;
			}
			if (actionButtons == null)
				return;
			if (actionButtons == null || actionButtons[id] == null || actionsBar == null)
				return;
			var btn:BitmapButton = actionButtons[id];
			tmpBtn = btn;
			TweenMax.killDelayedCallsTo(hideAnimation);
			if (needMaxTime == true)
				TweenMax.delayedCall(maxTime, hideAnimation);
			if (syncIndicator == null)
				syncIndicator = new Preloader(Config.FINGER_SIZE * .4, SWFPaymentsRefreshIcon);
			UI.colorize(syncIndicator, Style.color(Style.TOP_BAR_ICON_COLOR));
			addChild(syncIndicator);
			syncIndicator.x = actionsBar.x + Math.round(tmpBtn.x + tmpBtn.width * .5);
			syncIndicator.y = actionsBar.y + Math.round(tmpBtn.y + tmpBtn.height * .5);
			
			tmpBtn.deactivate();
			tmpBtn.hide(.3);
			syncIndicator.show();
		}
		
		public function hideAnimation():void {
			needToAnimate = null;
			TweenMax.killDelayedCallsTo(hideAnimation);
			if (syncIndicator != null) {
				syncIndicator.hide(true, null, .3, .5);
				syncIndicator = null;
			}
			if (tmpBtn != null) {
				tmpBtn.show(.3, .5);
				tmpBtn.activate();
				tmpBtn = null;
			}
		}
		
		public function updateTitle(title:String, needToRedraw:Boolean = true):void {
			titleText = title;
			if (needToRedraw == true)
				setTitle(true);
		}
		
		private function setTitle(saveYPosition:Boolean = false):void {
			if (titleBitmap != null && titleBitmap.bitmapData != null)
				titleBitmap.bitmapData.dispose();
			if (titleText == null || titleText == "")
				return;
			if (titleWidth == 0)
				return;
			titleBitmap.bitmapData = UI.renderTopBarTitle(
				titleText,
				titleWidth,
				Style.size(Style.TOP_BAR_FONT_SIZE_SMALL), 
				Style.color(Style.TOP_BAR_TEXT_COLOR), 
				Style.bold(Style.TOP_BAR_TEXT_BOLD_SMALL)
			);
			if (saveYPosition == false)
				setTitleY(int(Config.APPLE_TOP_OFFSET + (Config.TOP_BAR_HEIGHT - titleBitmap.height) * .5));
		}
		
		protected function setTitleY(val:int):void {
			titleBitmap.y = val;
		}
		
		public function updateAdditional(val:String):void {
			additionalText = val;
			setAdditional(true);
		}
		
		private function setAdditional(saveYPosition:Boolean = false):void {
			var needToMove:Boolean = false;
			if (additionalBitmap == null) {
				additionalBitmap = new Bitmap();
				additionalBitmap.x = titleBitmap.x;
				additionalBitmap.alpha = 0;
				additionalBitmap.y = titleBitmap.y + titleBitmap.height;
				addChild(additionalBitmap);
				needToMove = true;
			} else if (additionalBitmap.bitmapData != null)
				additionalBitmap.bitmapData.dispose();
			if (additionalText == null || additionalText == "")
				return;
			if (titleWidth == 0)
				return;
			additionalBitmap.bitmapData = UI.renderText(
				additionalText,
				titleWidth,
				Config.FINGER_SIZE_DOT_25,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.TOP_BAR_HEIGHT  * .25,
				false,
				Style.color(Style.TOP_BAR_ICON_COLOR),
				0,
				true,
				"ChatTop.status"
			);
			if (needToMove == true) {
				TweenMax.to(additionalBitmap, 0.7, { alpha:.7, delay:1 } );
				TweenMax.to(titleBitmap, 0.7, { y:int(Config.APPLE_TOP_OFFSET + (trueHeight - Config.APPLE_TOP_OFFSET - titleBitmap.height - additionalBitmap.height) * .5), delay:1, onUpdate:setAdditionalY } );
			}
		}
		
		protected function setAdditionalY():void {
			additionalBitmap.y = titleBitmap.y + titleBitmap.height - 4;
		}
		
		public function activate(delay:Number = .15, onlyBack:Boolean = false):void {
			if (_isActivated == true || created == false)
				return;
			_isActivated = true;
			if (backButton != null) {
				backButton.show(.3, delay);
				backButton.activate();
			}
			if (searchBar != null)
			{
				searchBar.activate();
				SearchBar.UPDATE_STATE.add(onSearchBarUpdate);
			}
			if (onlyBack == true)
				return;
			if (actionButtons != null) {
				for (var name:String in actionButtons) {
					if (firstTime == true) {
						delay += .15;
						actionButtons[name].show(.3, delay);
					}
					actionButtons[name].activate();
				}	
			}
			firstTime = false;
			if (needToAnimate != null) {
				showAnimationOverButton(needToAnimate.id, needToAnimate.needMaxTime);
				needToAnimate = null;
			}
		}
		
		public function deactivate():void {
			if (_isActivated == false)
				return;
			_isActivated = false;
			if (backButton != null)
				backButton.deactivate();
			if (actionButtons != null) {
				for (var name:String in actionButtons) {
					actionButtons[name].deactivate();
				}	
			}
			if (searchBar != null)
			{
				SearchBar.UPDATE_STATE.remove(onSearchBarUpdate);
				searchBar.deactivate();
			}
		}
		
		public function drawView(width:int):void {
			if (bgShape == null)
				createView();
			if (width == bgShape.width)
				return;
			
			bgShape.width = width;
			_width = width;
			titleWidth = width - Config.FINGER_SIZE;
			if (actionsBar != null) {
				arrangeActionsInOrder();
				titleWidth -= actionsBar.width
			}
			setTitle();
			if (searchBar != null)
			{
				searchBar.setSize(_width, _trueHeight - Config.APPLE_TOP_OFFSET);
				searchBar.view.y = Config.APPLE_TOP_OFFSET;
			}
		}
		
		private function onBackHandler():void {
			if (_onBackFunction != null)
			{
				_onBackFunction();
			}
		}	
		
		public function dispose():void {
			TweenMax.killDelayedCallsTo(hideAnimation);
			TweenMax.killTweensOf(titleBitmap);
			TweenMax.killTweensOf(additionalBitmap);
			
			onBackFunction = null;
			
			if (syncIndicator != null)
				syncIndicator.dispose();
			syncIndicator = null;
			tmpBtn = null;
			if (bgShape != null) {
				bgShape.graphics.clear();
				if (bgShape.parent != null )
					bgShape.parent.removeChild(bgShape);
			}
			bgShape = null;
			titleText = null;
			if (titleBitmap != null) {
				if (titleBitmap.parent != null)
					removeChild(titleBitmap);
				if (titleBitmap.bitmapData != null)
					titleBitmap.bitmapData.dispose();
				titleBitmap.bitmapData = null;
			}
			if (searchBar != null) {
				searchBar.dispose();
			}
			titleBitmap = null;
			if (backButton != null)
				backButton.dispose();
			backButton = null;
			deleteActions();
			_actions = null;
			actionButtons = null;
			actionsBar = null;
			if (this.parent != null)
				this.parent.removeChild(this);
		}
		
		public function addSearch():void
		{
			if (searchBar == null)
			{
				addSearchBar();
			}
		}
		
		private function addSearchBar():void 
		{
			searchBar = new SearchBar();
			addChild(searchBar.view);
			if (_isActivated == true)
			{
				searchBar.activate();
			}
			
			searchBar.setSize(_width, _trueHeight - Config.APPLE_TOP_OFFSET);
			searchBar.view.y = Config.APPLE_TOP_OFFSET;
		}
		
		private function onSearchBarUpdate():void {
			if (searchBar && searchBar.inSearchState()) {
				if (actionsBar != null)	{
					actionsBar.visible = false;
				}
				
			//	deactivateActions();
			} else {
				if (actionsBar != null) {
					actionsBar.visible = true;
				}
				
			//	activateActions();
			}
		}
		
		private function activateActions():void {
			if (actionButtons != null) {
				for (var name:String in actionButtons) {
					actionButtons[name].activate();
				}	
			}
		}
		
		private function deactivateActions():void {
			if (actionButtons != null) {
				for (var name:String in actionButtons) {
					actionButtons[name].deactivate();
				}	
			}
		}
		
		public function get trueHeight():int { return _trueHeight; }
	}
}