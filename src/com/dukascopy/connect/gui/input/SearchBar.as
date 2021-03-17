package com.dukascopy.connect.gui.input 
{
	import assets.CloseButtonIconWhite;
	import assets.SearchButtonIconWhite;
	import assets.SearchButtonIconWhite2;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	/**
	 * ...
	 * @author Anton Bodrychenko
	 */
	public class SearchBar extends MobileClip
	{
		public static const MODE_ACTIVATE:int = 0;
		public static const MODE_REST:int = 1;
		
		static public var S_CHANGED:Signal = new Signal("SearchBar SIGNAL INPUT -> S_INPUT_CHANGED");// god bless me for this
		static public var UPDATE_STATE:Signal = new Signal("SearchBar.UPDATE_STATE");// god bless me for this
		
		private var _mode:int = int.MAX_VALUE;
		
		private var searchButton:BitmapButton;
		private var closeButton:BitmapButton;
		private var backButton:BitmapButton;
		private var input:Input;
		private var inputPrompt:Input;
		private var bg:Shape;
		
		public function SearchBar() 
		{

			_view = new Sprite();
			drawView();
			
			mode = MODE_REST;
		}
		
		public function setSize(width:int, height:int):void 
		{
			bg.width = width;
			bg.height = height;
			
			backButton.x = Config.DOUBLE_MARGIN;
			backButton.y = int((height - backButton.height) * 0.5);
			backButton.activate(); 
			
			searchButton.x =  width - Config.DOUBLE_MARGIN - searchButton.width;
			searchButton.y = int((height - searchButton.height) * 0.5);
			searchButton.activate();
			
			closeButton.x =  width - Config.DOUBLE_MARGIN - closeButton.width;
			closeButton.y = int((height - closeButton.height) * 0.5);
			closeButton.activate();
			
			input.view.x = backButton.x + backButton.width + Config.DOUBLE_MARGIN;
			input.view.y = int((height - input.view.height) * 0.5);
			
			inputPrompt.view.x = input.view.x + Config.MARGIN;
			inputPrompt.view.y = input.view.y;
			
			
			input.width = width - (backButton.x + backButton.width + Config.DOUBLE_MARGIN);
			inputPrompt.width = input.width;
			//input.view.graphics.clear();
		}
		
		private function drawView():void 
		{
			const topBarBtnSize:int = Config.FINGER_SIZE * .4;
			const headerSize:int = int(Config.FINGER_SIZE * .85);
			const btnSize:int = headerSize * .38;
			
			var iconSearch:Sprite = new (Style.icon(Style.ICON_ZOOM));
			UI.colorize(iconSearch, Style.color(Style.TOP_BAR_ICON_COLOR));
			iconSearch.width = iconSearch.height = topBarBtnSize;
			searchButton = new BitmapButton();
			searchButton.setStandartButtonParams();
			searchButton.tapCallback = onSearchTap;
			searchButton.setBitmapData(UI.getSnapshot(iconSearch, StageQuality.HIGH, "SearchBar.iconSearch"), true);
			var offset:int = (Config.FINGER_SIZE - topBarBtnSize) * .5;
			searchButton.setOverflow(offset, offset, offset, offset);	
			UI.destroy(iconSearch);
			iconSearch = null;
			
			var iconClose:CloseButtonIconWhite = new CloseButtonIconWhite();
			UI.colorize(iconClose, Style.color(Style.TOP_BAR_ICON_COLOR));
			iconClose.width = iconClose.height = topBarBtnSize;
			closeButton = new BitmapButton();
			closeButton.setStandartButtonParams();
			closeButton.tapCallback = onClearTap;
			closeButton.setBitmapData(UI.getSnapshot(iconClose, StageQuality.HIGH, "SearchBar.iconClose"), true);
			closeButton.setOverflow(Config.MARGIN, Config.MARGIN, Config.MARGIN, Config.MARGIN);	
			UI.destroy(iconClose);
			iconClose = null;
			
			var iconBack:IconBack = new IconBack();
			UI.colorize(iconBack, Style.color(Style.TOP_BAR_ICON_COLOR));
			iconBack.width = iconBack.height = btnSize;
			
			backButton = createButton(Style.icon(Style.ICON_BACK), Style.color(Style.TOP_BAR_ICON_COLOR), "backButton");
			backButton.tapCallback = onBtnBack;
			backButton.show();
			
			input = new Input();
			input.setMode(Input.MODE_INPUT);
			input.inUse = true;
			input.backgroundAlpha = 0;
			input.setBorderVisibility(false);
			input.getTextField().textColor = Style.color(Style.TOP_BAR_TEXT_COLOR);
			input.S_CHANGED.add(onTextChanged);
			input.activate();
			
			inputPrompt = new Input();// made for functionality according to design. Standart input prompt works different way
			inputPrompt.setMode(Input.MODE_INPUT);
			inputPrompt.inUse = true;
			inputPrompt.backgroundAlpha = 0;
			inputPrompt.setBorderVisibility(false);
			inputPrompt.setLabelText(Lang.textSearch);
			inputPrompt.getTextField().textColor = 0xC98282;
			inputPrompt.deactivate();
			
			bg = new Shape();// needed for overlaping tabbar
			bg.graphics.beginFill(Style.color(Style.TOP_BAR));
			bg.graphics.drawRect(0, 0, 1, 1);
			bg.graphics.endFill();
			
			_view.addChild(bg);
			_view.addChild(searchButton);
			_view.addChild(backButton);
			_view.addChild(inputPrompt.view);
			_view.addChild(input.view);
			_view.addChild(closeButton);
		}
		
		private function createButton(img:Class, imgColor:Number, id:String):BitmapButton {
			var btn:BitmapButton = new BitmapButton();
			btn.listenNativeClickEvents(true);
			btn.setStandartButtonParams();
			btn.setDownScale(1.3);
			btn.setDownColor(imgColor);
			btn.disposeBitmapOnDestroy = true;
			btn.setBitmapData(UI.getSnapshot(getIco(img, imgColor), StageQuality.HIGH, "SearchBar." + id), true);
			btn.setOverflow(TopBarScreen.marge, TopBarScreen.margeLR, TopBarScreen.margeLR, TopBarScreen.marge);
			btn.y = Config.APPLE_TOP_OFFSET + int((TopBarScreen._trueHeight - Config.APPLE_TOP_OFFSET) * .5 - btn.height * .5);
			btn.hide();
			return btn;
		}
		
		private function getIco(img:Class, color:Number):Sprite {
			var ico:Sprite = new img() as Sprite;
			if (isNaN(color) == false)
				UI.colorize(ico, color);
			ico.height = TopBarScreen.btnSize;
			ico.scaleX = ico.scaleY;
			return ico;
		}
		
		public function activate():void{
			input.S_CHANGED.add(onChangeInputValue);
			Input.S_SOFTKEYBOARD.add(onSoftKeyboard);
		}
		
		public function deactivate():void{
			input.S_CHANGED.remove(onChangeInputValue);
			Input.S_SOFTKEYBOARD.remove(onSoftKeyboard);
		}
		
		private function onSoftKeyboard(shows:Boolean):void {
			if (!shows){
				//mode = MODE_REST;
				//S_CHANGED.invoke(this);
			}
		}
		
		private function onTextChanged():void {
			S_CHANGED.invoke(this);
		}
		
		private function onChangeInputValue():void {
			if(input!=null){
				var currentValue:String =  StringUtil.trim(input.value);
				var defValue:String =  input.getDefValue();
				checkButtonsVisibility();
			}
		}
		
		private function checkButtonsVisibility():void {
			searchButton.visible = !backButton.visible;
			closeButton.visible = backButton.visible && text != "" && !Config.PLATFORM_APPLE;
			
			TweenMax.delayedCall(5, updatePromptVisibility, null, true);
			UPDATE_STATE.invoke();
		}
		
		private function updatePromptVisibility():void 
		{
			if (isDisposed)
			{
				return;
			}
			TweenMax.killDelayedCallsTo(updatePromptVisibility);
			if (inputPrompt != null)
			{
				if (mode == MODE_ACTIVATE && text == "")
				{
					inputPrompt.setLabelText(Lang.textSearch);
					inputPrompt.view.visible = true;
				}
				else
				{
					inputPrompt.setLabelText("");
					inputPrompt.view.visible = false;
				}
			}
		}
		
		private function onBtnBack():void {
			input.value = "";
			mode = MODE_REST;
			onChangeInputValue();
			S_CHANGED.invoke(this);
		}
		
		private function onSearchTap():void 
		{
			mode = MODE_ACTIVATE;
			S_CHANGED.invoke(this);
		}
		
		private function onClearTap():void 
		{
			input.value = "";
			input.setFocus();
			input.getTextField().requestSoftKeyboard();
			onChangeInputValue();
			S_CHANGED.invoke(this);
		}
		
		public function set mode(value:int):void 
		{
			_mode = value;
			
			switch(value){
				case MODE_ACTIVATE:
					input.setFocus();
					input.getTextField().requestSoftKeyboard();
					backButton.visible = true;
					input.view.visible = true;
					bg.visible = true;
					break;
				case MODE_REST:
					backButton.visible = false;
					input.view.visible = false;
					inputPrompt.view.visible = false;
					searchButton.visible = true;
					bg.visible = false;
					break;
				default:
					//trace("wrong SearchBar mode "+ value);
					break;
			}
			
			checkButtonsVisibility();
		}
		
		public function get text():String  { return input.value; }
		public function get mode():int  { return _mode; }
		
		override public function dispose():void 
		{
			super.dispose();
			TweenMax.killDelayedCallsTo(updatePromptVisibility);
			input.S_CHANGED.remove(onChangeInputValue);
			Input.S_SOFTKEYBOARD.remove(onSoftKeyboard);
			
			searchButton.dispose();
			closeButton.dispose();
			backButton.dispose();
			input.dispose();
			inputPrompt.dispose();
			
			searchButton = null;
			closeButton = null;
			backButton = null;
			input = null;
			inputPrompt = null;
			
		}
		
		public function reset():void 
		{
			input.value = "";
			mode = MODE_REST;
			S_CHANGED.invoke(this);
		}
		
		public function getIconWidth():int 
		{
			if (_view.visible)
			{
				return searchButton.width + Config.MARGIN * 2.5;
			}
			else
			{
				return 0;
			}
		}
		
		public function inSearchState():Boolean 
		{
			return !searchButton.visible;
		}
	}
}