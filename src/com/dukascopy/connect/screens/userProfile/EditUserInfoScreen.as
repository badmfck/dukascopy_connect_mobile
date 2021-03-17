package com.dukascopy.connect.screens.userProfile {
	
	import com.adobe.crypto.MD5;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.type.UserType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class EditUserInfoScreen extends BaseScreen	{
		private var FIT_WIDTH:Number;
		
		private var topBar:TopBarScreen;
		private var scrollPanel:ScrollPanel;
		
		private var OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE * .8;
		
		private var nameInputBottom:Bitmap;
		private var nameInput:Input;
		private var surnameInputBottom:Bitmap;
		private var surnameInput:Input;
		private var buttonPaddingLeft:Number;
		private var buttonOk:RoundedButton;
		private var back:Bitmap;
		private var currentName:String;
		private var currentSurname:String;
		private var preloader:Preloader;
		private var preloaderContainer:Sprite;
		private var changeNameRequestId:String;
		private var nameTitle:Bitmap;
		
		public function EditUserInfoScreen() {}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.title = 'Edit user info screen';
			_params.doDisposeAfterClose = true;
			topBar.setData(Lang.textEdit, true);
			
			FIT_WIDTH = _width - buttonPaddingLeft * 2;
			
			drawNameTitle();
			
			nameInput.width = FIT_WIDTH;
			nameInputBottom.width = FIT_WIDTH;
			surnameInput.width = FIT_WIDTH;
			surnameInputBottom.width = FIT_WIDTH;
			
			nameInput.view.y = nameTitle.y + nameTitle.height + Config.MARGIN;
			nameInputBottom.y = nameInput.view.y + nameInput.view.height;
			
			surnameInput.view.y = nameInputBottom.y + Config.MARGIN;
			surnameInputBottom.y = surnameInput.view.y + surnameInput.view.height;
			
			setTexts();
		}
		
		private function drawNameTitle():void 
		{
			var text:BitmapData = TextUtils.createTextFieldData(
												Lang.pleaseEnterName, 
												FIT_WIDTH, 
												10, 
												false, 
												TextFormatAlign.LEFT, 
												TextFieldAutoSize.LEFT, 
												Config.FINGER_SIZE * .26, 
												false, 
												0x93A2AE, 
												0xFFFFFF, 
												true);
			
			if (nameTitle.bitmapData != null)
			{
				nameTitle.bitmapData.dispose();
				nameTitle.bitmapData = null;
			}
			
			nameTitle.bitmapData = text;
		}
		
		override public function onBack(e:Event = null):void
		{
			MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
		}
		
		override protected function createView():void {
			super.createView();
			topBar = new TopBarScreen();
			
			buttonPaddingLeft = Config.MARGIN * 2;
			
			//scroller component;
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = MainColors.WHITE;
			_view.addChild(scrollPanel.view);
			
			nameTitle = new Bitmap();
			scrollPanel.addObject(nameTitle);
			nameTitle.x = buttonPaddingLeft;
			nameTitle.y = Config.DOUBLE_MARGIN;
			
			nameInput = new Input();
			nameInput.setMode(Input.MODE_INPUT);
			nameInput.setLabelText(Lang.firstName);
			nameInput.S_FOCUS_OUT.add(onNameFocusOut);
			nameInput.setBorderVisibility(false);
			nameInput.setRoundBG(false);
			nameInput.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			nameInput.getTextField().multiline = false;
			nameInput.setRoundRectangleRadius(0);
			nameInput.inUse = true;
			scrollPanel.addObject(nameInput.view);
			nameInput.view.x = buttonPaddingLeft;
			
			var backgroundBD:ImageBitmapData = UI.getColorTexture(MainColors.WHITE);
			back = new Bitmap(backgroundBD);
			_view.addChild(back);
			
			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(2);
			
			nameInputBottom = new Bitmap(hLineBitmapData);
			scrollPanel.addObject(nameInputBottom);
			nameInputBottom.x = buttonPaddingLeft;
			
			surnameInput = new Input();
			surnameInput.setMode(Input.MODE_INPUT);
			surnameInput.S_FOCUS_OUT.add(onSurnameFocusOut);
			surnameInput.setLabelText(Lang.secondName);
			surnameInput.setBorderVisibility(false);
			surnameInput.setRoundBG(false);
			surnameInput.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			surnameInput.getTextField().multiline = false;
			surnameInput.setRoundRectangleRadius(0);
			surnameInput.inUse = true;
			scrollPanel.addObject(surnameInput.view);
			surnameInput.view.x = buttonPaddingLeft;
			
			surnameInputBottom = new Bitmap(hLineBitmapData);
			scrollPanel.addObject(surnameInputBottom);
			surnameInputBottom.x = buttonPaddingLeft;
			
			buttonOk = new RoundedButton(Lang.saveChanges, MainColors.RED, MainColors.RED_DARK, null);
			buttonOk.setStandartButtonParams();
			buttonOk.setDownScale(1);
			buttonOk.cancelOnVerticalMovement = true;
			buttonOk.tapCallback = saveChanges;
			_view.addChild(buttonOk);
			_view.addChild(topBar);
			
			preloader = new Preloader();
			_view.addChild(preloader);
			preloader.hide();
			preloader.visible = false;
		}
		
		private function onNameFocusOut():void {
			var currentValue:String =  StringUtil.trim(nameInput.value);
			currentValue = TextUtils.clearDelimeters(currentValue);
			if (currentValue != "" && currentValue != nameInput.getDefValue()) {
				currentName = currentValue;
			}
			else {
				nameInput.value = currentName;
			}
		}
		
		
		
		private function onSurnameFocusOut():void {
			var currentValue:String =  StringUtil.trim(surnameInput.value);
			currentValue = TextUtils.clearDelimeters(currentValue);
			if (currentValue != "" && currentValue != surnameInput.getDefValue()) {
				currentSurname = currentValue;
			} else {
				if (Auth.type == UserType.USER)
					surnameInput.value = currentSurname;
				else
					currentSurname = "";
			}
		}
		
		private function saveChanges():void {
			onNameFocusOut();
			onSurnameFocusOut();
			
			Input.S_SOFTKEYBOARD.invoke(false);
			
			
			
			
			var valid:Boolean = true;
				
				var badPatterns:Array = [
											"duka",
											"dukа",
											"duкa",
											"duка",
											"dиka",
											"dиkа",
											"dикa",
											"dика",
											"bank",
											"bаnk",
											"banк",
											"bаnк",
											"support",
											"sapport",
											"suppоrt",
											"sappоrt",
											"supрort",
											"sapрort",
											"supроrt",
											"sapроrt",
											"suрport",
											"saрport",
											"suрpоrt",
											"saрpоrt",
											"suррort",
											"saррort",
											"suрроrt",
											"saрроrt",
											"банк",
											"бaнк",
											"банк",
											"бaнk",
											"чат",
											"чaт",
											"поддержка",
											"пoддержка",
											"поддержkа",
											"пoддержkа",
											"поддержкa",
											"пoддержкa",
											"поддержka",
											"пoддержka",
											"поддeржка",
											"пoддeржка",
											"поддeржkа",
											"пoддeржkа",
											"поддeржкa",
											"пoддeржкa",
											"поддeржka",
											"пoддeржka"
										];
				var i:int;
				if (currentName != null)
				{
					for (i = 0; i < badPatterns.length; i++) 
					{
						if (currentName.indexOf(badPatterns[i]) != -1)
						{
							valid = false;
							break;
						}
					}
				}
				if (currentSurname != null)
				{
					for (i = 0; i < badPatterns.length; i++) 
					{
						if (currentSurname.indexOf(badPatterns[i]) != -1)
						{
							valid = false;
							break;
						}
					}
				}
				
				if (valid == false)
				{
					Auth.changeUsername(currentName, currentSurname, "1");
				}
			
			if (Auth.type == UserType.USER)	{
				if (!currentName || currentName == "")
					currentName = Lang.textName;
				if (!currentSurname || currentSurname == "")
					currentSurname = Lang.textSurname;
			}
			lockScreen();
			
			Auth.S_PROFILE_CHANGE.add(onProfileChanged);
			changeNameRequestId = createRequestId();
			Auth.changeUsername(currentName, currentSurname, changeNameRequestId);
		}
		
		private function onProfileChanged(result:Object):void {
			if (changeNameRequestId == result.requestId){
				unlockScreen();
				Auth.S_PROFILE_CHANGE.remove(onProfileChanged);
				changeNameRequestId = null;
				if (result.success)
					onBack();
			}
		}
		
		private function lockScreen():void {
			displayPreloader();
			deactivateScreen();
		}
		
		private function unlockScreen():void {
			hidePreloader();
			activateScreen();
		}
		
		private function createRequestId():String {
			return MD5.hash(getTimer().toString());
		}
		
		override protected function drawView():void	{
			var currentYDrawPosition:int = 0;
			topBar.drawView(_width);
			
			buttonOk.setSizeLimits(Config.FINGER_SIZE * 3.5, FIT_WIDTH);
			buttonOk.draw();
			buttonOk.x = int(_width * .5 - buttonOk.width * .5);
			buttonOk.y = int(_height - buttonOk.height - Config.MARGIN*2);
			
			scrollPanel.view.y = topBar.trueHeight;
			
			scrollPanel.setWidthAndHeight(_width, _height - topBar.trueHeight - buttonOk.height - Config.MARGIN*4, false);
			
			back.width = _width;
			back.height =  buttonOk.height + Config.MARGIN * 4;
			back.y = scrollPanel.view.y + scrollPanel.height;
			
			if (!scrollPanel.fitInScrollArea())	{
				scrollPanel.scrollToPosition(surnameInput.view.y - Config.MARGIN);
				scrollPanel.enable();
			} else {
				scrollPanel.disable();
			}
			scrollPanel.update();
		}
		
		private function setTexts():void {
			currentName = Auth.getFirstName();
			currentSurname = Auth.getLastName();
			
			nameInput.value = currentName;
			surnameInput.value = currentSurname;
		}
		
		private function displayPreloader():void {
			preloader.x = _width*.5;
			preloader.y = _height*.5;
			preloader.show();
			preloader.visible = true;
		}
		
		private function hidePreloader():void {
			preloader.hide();
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function dispose():void
		{
			super.dispose();
			if (topBar != null)
				topBar.dispose();
			topBar = null;

			if (scrollPanel) {
				scrollPanel.dispose();
				scrollPanel = null;
			}
			if (nameTitle)	{
				UI.destroy(nameTitle);
				nameTitle = null;
			}
			if (surnameInputBottom)	{
				UI.destroy(surnameInputBottom);
				surnameInputBottom = null;
			}
			if (nameInputBottom) {
				UI.destroy(nameInputBottom);
				nameInputBottom = null;
			}
			if (nameInput) {
				nameInput.S_FOCUS_OUT.remove(onNameFocusOut);
				nameInput.dispose()
				nameInput = null;
			}
			if (surnameInput) {
				surnameInput.S_FOCUS_OUT.remove(onSurnameFocusOut);
				surnameInput.dispose()
				surnameInput = null;
			}
			if (buttonOk) {
				buttonOk.dispose()
				buttonOk = null;
			}
			if (back) {
				UI.destroy(back);
				back = null;
			}
			if (preloader) {
				preloader.dispose()
				preloader = null;
			}
			if (preloaderContainer)	{
				UI.destroy(preloaderContainer);
				preloaderContainer = null;
			}
			
			Auth.S_PROFILE_CHANGE.remove(onProfileChanged);
		}
		
		override public function activateScreen():void	{
			super.activateScreen();
			if (_isDisposed)
				return;
			
			if (topBar != null)
				topBar.activate();
			nameInput.activate();
			surnameInput.activate();
			buttonOk.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			
			if (topBar != null)
				topBar.deactivate();		
			nameInput.deactivate();
			surnameInput.deactivate();
			buttonOk.deactivate();
		}
	}
}