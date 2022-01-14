package com.dukascopy.connect.gui.topBar {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.button.ActionButton;
	import com.dukascopy.connect.gui.input.SearchBar;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import white.Back;
	
	/**
	 * Используется в RootScren
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class TopBar extends MobileClip {
		public var topPadding:int = 0;
		private var _viewWidth:int;
		private var _viewHeight:int;
		private var _y:int = 0;
		private var _isActivated:Boolean = false;
		private var _isShown:Boolean = false;
		private var titleBitmap:Bitmap;
		private var searchBar:SearchBar;
		private var currentActions:Vector.<IScreenAction>;
		private var actionsBar:Sprite;
		private var actionButtons:Array;
		private var titleToDraw:String;
		private var titleChanged:Boolean;
		private var underline:Sprite;
		private var backButton:BitmapButton;
		private var onBackCallback:Function;
		private var content:Sprite;
		
		public function TopBar() {
			super();
			create();
		}
		
		private function create():void {
			_view = new Sprite();
			
			content = new Sprite();
			_view.addChild(content);
			
			titleBitmap = new Bitmap();
			titleBitmap.x = Config.DOUBLE_MARGIN;// Config.FINGER_SIZE;
			content.addChild(titleBitmap);
			
		//	addSearchBar();
			
			actionsBar = new Sprite();
			content.addChild(actionsBar);
			
			underline = new Sprite();
			content.addChild(underline);
			
			setTitle("");
		}
		
		private function addSearchBar():void 
		{
			searchBar = new SearchBar();
			content.addChild(searchBar.view);
			
			searchBar.setSize(_viewWidth, _viewHeight);
			searchBar.view.y = 0;
		}
		
		public function show(time:Number = 0, delay:Number = 0):void
		{
			_isShown = true;
		}
		
		public function set onBack(value:Function):void
		{
			onBackCallback = value;
		}
		
		public function hide(time:Number = 0, delay:Number = 0):void
		{
			_isShown = false;
		}
		
		public function activate():void {
			_isActivated = true;
			
			if (searchBar != null)
			{
				SearchBar.UPDATE_STATE.add(onSearchBarUpdate);
				searchBar.activate();
			}
			if (backButton != null)
			{
				backButton.activate();
			}
		}
		
		public function deactivate():void {
			_isActivated = false;
			
			if (searchBar != null)
			{
				SearchBar.UPDATE_STATE.remove(onSearchBarUpdate);
				searchBar.deactivate();
			}
			if (backButton != null)
			{
				backButton.deactivate();
			}
		}
		
		private function onSearchBarUpdate():void {
			if (searchBar && searchBar.inSearchState()) {
				actionsBar.visible = false;
				deactivateActions();
			} else {
				actionsBar.visible = true;
				activateActions();
			}
		}
		
		private function activateActions():void {
			if (actionButtons) {
				var actionsLength:int = actionButtons.length;
				for (var j:int = 0; j < actionsLength; j++) {
					(actionButtons[j] as ActionButton).activate();
				}
			}
		}
		
		private function deactivateActions():void {
			if (actionButtons) {
				var actionsLength:int = actionButtons.length;
				for (var j:int = 0; j < actionsLength; j++) {
					(actionButtons[j] as ActionButton).deactivate();
				}
			}
		}
		
		public function setTitle(text:String):void {
			titleToDraw = text;
			titleChanged = true;
			updateTitle();
		}
		
		private function updateTitle():void {
			if (_viewWidth == 0 || _viewHeight == 0)
				return;
			var titleTextMaxWidth:int;
			if (currentActions && currentActions.length > 0)
				titleTextMaxWidth = actionsBar.x - titleBitmap.x - Config.MARGIN;
			else
				titleTextMaxWidth = actionsBar.x - titleBitmap.x - Config.MARGIN;
				
			if (backButton != null)
			{
			//	titleTextMaxWidth -= backButton.width + Config.FINGER_SIZE * .5;
			}
			if(titleBitmap && titleBitmap.width == titleTextMaxWidth && !titleChanged)
				return;
			if (titleBitmap == null)
				return;
			if (titleBitmap.bitmapData != null)
				titleBitmap.bitmapData.dispose();
			titleBitmap.bitmapData = UI.renderTopBarTitle(titleToDraw, titleTextMaxWidth, 
															Style.size(Style.TOP_BAR_FONT_SIZE), 
															Style.color(Style.TOP_BAR_TEXT_COLOR), 
															Style.bold(Style.TOP_BAR_TEXT_BOLD));
			titleChanged = false;
			titleBitmap.y = int((_viewHeight - titleBitmap.height) * .5);
		}
		
		public function setSize(viewWidth:int, viewHeight:int):void {
			_viewWidth = viewWidth;
			_viewHeight = viewHeight;
			
			if (searchBar != null)
			{
				searchBar.setSize(_viewWidth, _viewHeight);
			}
			
			updateTitle();
			
			underline.graphics.clear();
			underline.graphics.lineStyle(UI.getLineThickness(), Style.color(Style.COLOR_SEPARATOR));
			underline.graphics.moveTo(0, 0);
			underline.graphics.lineTo(_viewWidth, 0);
			underline.y = _viewHeight - 2;
			
			_view.graphics.clear();
			_view.graphics.beginFill(Style.color(Style.TOP_BAR));
			_view.graphics.drawRect(0, 0, _viewWidth, Config.APPLE_TOP_OFFSET + _viewHeight + topPadding);
			
			content.y = Config.APPLE_TOP_OFFSET + topPadding;
		}
		
		private function resizeActions():void {
			var itemsWidth:int = 0;
			if (actionButtons != null && actionButtons.length > 0)
			{
				itemsWidth = actionButtons[actionButtons.length - 1].x + actionButtons[actionButtons.length - 1].width;
			}
			var pos:int = _viewWidth - itemsWidth - Config.MARGIN * 2;
			if (searchBar != null)
			{
				pos -= searchBar.getIconWidth();
			}
			
			actionsBar.x = pos;
			actionsBar.y = int(Config.TOP_BAR_HEIGHT * .5);
		}
		
		public function get height():int {
			return _viewHeight + topPadding;
		}
		
		override public function dispose():void {
			super.dispose();
			
			onBackCallback = null;
			
			if (titleBitmap != null && titleBitmap.bitmapData != null)
				titleBitmap.bitmapData.dispose();
			titleBitmap = null;
			
			if (searchBar != null)
				searchBar.dispose();
			
			if (actionsBar) {
				UI.destroy(actionsBar);
				actionsBar = null;
			}
			
			if (underline != null) {
				UI.destroy(underline);
				underline = null;
			}
			
			if (content != null) {
				UI.destroy(content);
				content = null;
			}
			
			removeBackButton();
		}
		
		public function setSearchBarVisibility(value:Boolean):void {
			if (searchBar == null && value == true)
			{
				addSearchBar();
			}
			if (searchBar != null)
			{
				
				searchBar.view.visible = value;
				searchBar.reset();
				if (value == true)
				{
					searchBar.activate();
				}
				else
				{
					searchBar.deactivate();
				}
			}
		}
		
		public function setActions(actions:Vector.<IScreenAction>, tapOffset:Number = 1):void {
			clearActions();
			actionButtons = new Array();
			currentActions = actions;
			if (actions) {
				var actionButton:ActionButton;
				var actionsLength:int = actions.length;
				var trueX:int = 0;
				for (var i:int = 0; i < actionsLength; i++) {
					actionButton = new ActionButton(actions[i]);
					actionButton.activate();
					actionButton.build(Config.FINGER_SIZE * 3 * tapOffset, Style.size(Style.TOP_BAR_ICON_SIZE), actions[i].getIconScale());
					actionButton.x = trueX;
					actionButton.y = int( -actionButton.height * .5);
					actionsBar.addChild(actionButton);
					actionButtons.push(actionButton);
					trueX += actionButton.width + Config.MARGIN * 2.5;
				}
			}
			resizeActions();
		}
		
		public function setTitleIcon(iconClass:Class):void {
			titleBitmap.bitmapData.dispose();
			
			var icon:Sprite = new iconClass();
			var ct:ColorTransform = new ColorTransform();
			ct.color = Style.color(Style.TOP_BAR_TEXT_COLOR);
			icon.transform.colorTransform = ct;
			UI.scaleToFit(icon, Config.FINGER_SIZE_DOUBLE, Config.TOP_BAR_HEIGHT * .56);
			titleBitmap.bitmapData = UI.getSnapshot(icon, StageQuality.HIGH, "TopBar.title");
			titleBitmap.y = int((Config.TOP_BAR_HEIGHT - titleBitmap.height) * .5);
		}
		
		public function updateUnderline(showUnderline:Boolean):void 
		{
			underline.visible = showUnderline;
		}
		
		public function addBackButton():void 
		{
			if (backButton == null)
			{
				backButton = new BitmapButton();
				backButton.setStandartButtonParams();
				backButton.tapCallback = onBackClick;
				backButton.disposeBitmapOnDestroy = true;
				backButton.setDownScale(1);
				backButton.setOverlay(HitZoneType.CIRCLE);
				content.addChild(backButton);
				
				var icon:Sprite = new Back();
				UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS));
				UI.scaleToFit(icon, int(Config.FINGER_SIZE * .4), int(Config.FINGER_SIZE * .4));
				backButton.setBitmapData(UI.getSnapshot(icon), true);
				backButton.setOverflow(Config.FINGER_SIZE*.3, Config.FINGER_SIZE*.3, Config.FINGER_SIZE*.3, Config.FINGER_SIZE*.3);
				if (_isActivated)
				{
					backButton.activate();
				}
				backButton.x = int(Config.MARGIN * 2);
				backButton.y = int(_viewHeight * .5 - backButton.height * .5);
			}
			updateLayout();
		}
		
		private function onBackClick():void {
			if (onBackCallback != null) {
				onBackCallback();
			}
			updateLayout();
		}
		
		private function updateLayout():void {
			if (_isDisposed == true)
				return;
			if (backButton != null) {
				titleBitmap.x = backButton.x + backButton.width + Config.DOUBLE_MARGIN;
			} else {
				titleBitmap.x = Config.DOUBLE_MARGIN;
			}
			updateTitle();
		}
		
		public function removeBackButton():void {
			if (backButton != null) {
				if (content != null && _view.contains(backButton)) {
					content.removeChild(backButton);
				}
				backButton.dispose();
				backButton = null;
			}
			updateLayout();
		}
		
		public function getHeight():int 
		{
			return Config.APPLE_TOP_OFFSET + _viewHeight + topPadding;
		}
		
		private function clearActions():void {
			if (currentActions) {
				var actionsLength:int = actionButtons.length;
				for (var j:int = 0; j < actionsLength; j++)
					(actionButtons[j] as ActionButton).dispose();
				actionButtons = null;
				currentActions = null;
			}
		}
	}
}