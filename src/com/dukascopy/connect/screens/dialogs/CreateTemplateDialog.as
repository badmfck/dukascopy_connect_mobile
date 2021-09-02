package com.dukascopy.connect.screens.dialogs {
	
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.text.TextFormat;

	/**
	 * ...
	 * @author Aleksei L
	 */
	
	public class CreateTemplateDialog extends ScreenAlertDialog {
		
		private var passInput:Input;
		private var inputBottom:Bitmap;
		private var _isEnter:Boolean = true;
		private var _isStars:Boolean = true;
		private var transactionData:Object;

		public function CreateTemplateDialog() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			passInput = new Input();
			passInput.setMode(Input.MODE_INPUT);
			passInput.setLabelText(/*Lang.enterPassword*/Lang.TEXT_SECURITY_CODE);
			passInput.setBorderVisibility(false);
			passInput.setRoundBG(false);
			var format:TextFormat = new TextFormat(Config.defaultFontName, Config.FINGER_SIZE*.4, AppTheme.GREY_MEDIUM);
			passInput.updateTextFormat(format);
			passInput.setRoundRectangleRadius(0);
			passInput.inUse = true;
			
			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(AppTheme.GREY_MEDIUM);
			inputBottom = new Bitmap(hLineBitmapData);
		}
			
		private function focusOnInput():void 
		{
			passInput.setFocus();
			passInput.getTextField().requestSoftKeyboard();
		}
		
		override public function initScreen(data:Object = null):void {
			
			var text:String = "";
			if (data != null && "data" in data && data.data != null)
			{
				transactionData = data.data;
				
				text = transactionData.amount + " " + transactionData.currency + " " + Lang.textTo.toLowerCase() + " ";
				
				if ("userUid" in transactionData && transactionData.userUid != null && 
					transactionData.userUid is String && (transactionData.userUid as String).length > 0)
				{
					if ((transactionData.userUid as String).charAt(0) == "+")
					{
						text += transactionData.userUid;
					}
					else
					{
						var user:UserVO = UsersManager.getUserByUID(transactionData.userUid);
						if (user != null)
						{
							text += user.getDisplayName();
						}
					}
				}
			}
			
			passInput.value = text;
			data.buttonOk = Lang.textOk;
			data.buttonSecond = Lang.textCancel;
			super.initScreen(data);
		}
		
		override protected function fireCallbackFunctionWithValue(value:int):void 
		{
			if (value == 1)
			{
				transactionData.name = passInput.value;
			}
			
			var callBackFunction:Function = callback;
			callback = null;
			
			callBackFunction(value, transactionData);
		}
		
		override protected function getContentBottomPadding():Number 
		{
			return Config.FINGER_SIZE * .3;
		}
		
		override protected function getMaxContentHeight():Number 
		{
			return _height - padding * 2 - headerHeight - buttonsAreaHeight;
		}
		
		override protected function drawView():void {
			super.drawView();
			// todo add check for valid input 
			onChangeInputValue();
			//button0.alpha = 0.7;
			//button0.deactivate();
		}
		
		override protected function repositionButtons():void 
		{
			contentBottomPadding = 0;
			super.repositionButtons();
		}
		
		override protected function updateScrollArea():void 
		{
			if (!content.fitInScrollArea())
			{
				content.scrollToPosition(passInput.view.y - (Config.MARGIN));
				content.enable();
			}
			else {
				content.disable();
			}
			
			content.update();
		}
		
		override protected function recreateContent(padding:Number):void 
		{
			super.recreateContent(padding);
			
			//labelBitmapLock.x = ;
			passInput.width = _width - padding;
			passInput.view.y = (content.itemsHeight == 0 )? 0 :int(content.itemsHeight + padding);//padding*.5

			inputBottom.width = _width - padding * 2;
			inputBottom.y = int(passInput.view.y + passInput.view.height - Config.FINGER_SIZE * .1);
			
			content.addObject(passInput.view);
			content.addObject(inputBottom);
		}
		
		private function onChangeInputValue():void 
		{
			if(passInput!=null){
				var currentValue:String =  StringUtil.trim(passInput.value);
				var defValue:String =  passInput.getDefValue();
				if (currentValue != "" && currentValue != passInput.getDefValue()) {					
					// activate button
					//btn0TF.alpha = 1;
					button0.activate();
					button0.alpha = 1;
					
				}else {
					button0.alpha = .7;
					button0.deactivate();
				}
			}
		}
		
		override protected function updateContentHeight():void 
		{
			contentHeight = (padding * 3.5 + headerHeight + buttonsAreaHeight + content.itemsHeight);
		}
		
		override public function activateScreen():void {
			passInput.activate();
			super.activateScreen();
			
			if (passInput.value && passInput.value != "" && passInput.value != passInput.getDefValue())
			{
				button0.alpha = 1;
				button0.activate();
			}
			else
			{
				button0.alpha = 0.7;
				button0.deactivate();
			}
			
			passInput.S_CHANGED.add(onChangeInputValue);
			
		//	focusOnInput();
		}
		
		override public function deactivateScreen():void {
			if (passInput)
			{
				passInput.deactivate();
			}
			super.deactivateScreen();
			
			passInput.S_CHANGED.add(onChangeInputValue);
		}
		
		override protected function btn0Clicked():void {
			if (callback != null) {
				fireCallbackFunctionWithValue(1);
			}
			if (passInput){
				passInput.setLabelText("");
			}
			DialogManager.closeDialog();
		}
		
		override protected function onCloseButtonClick():void {
			if (callback != null) {
				fireCallbackFunctionWithValue(0);
			}
			passInput.setLabelText("");
			DialogManager.closeDialog();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (passInput)
			{
				passInput.dispose();
				passInput = null;
			}
			if (inputBottom)
			{
				UI.destroy(inputBottom);
				inputBottom = null;
			}
		}
	}
}