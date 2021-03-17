package com.dukascopy.connect.screens.dialogs.paymentDialogs {
	
	import assets.QrIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenWebviewDialogBase;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class FeedbackPopup extends BaseScreen {
		static public const STATE_START:String = "stateStart";
		static public const STATE_FEEDBACK:String = "stateFeedback";
		
		protected var container:Sprite;
		private var bg:Shape;
		private var acceptButton:BitmapButton;
		private var backButton:BitmapButton;
		private var verticalMargin:Number;
		protected var componentsWidth:int;
		private var title:Bitmap;
		private var commissionText:Bitmap;
		private var input:InputField;
		private var state:String = STATE_START;
		private var keyboardHeight:int = 0;
		
		public function FeedbackPopup() {
			
		}
		
		override protected function createView():void {
			super.createView();
			container = new Sprite();
			
			bg = new Shape();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			var round:int = Config.FINGER_SIZE * .3;
			var round3:int = round * 3;
			bg.graphics.drawRect(0, 0, round3, round3);
			bg.scale9Grid = new Rectangle(round, round, round, round);
			container.addChild(bg);
			
			title = new Bitmap();
			container.addChild(title);
			
			acceptButton = new BitmapButton();
			acceptButton.setStandartButtonParams();
			acceptButton.setDownScale(1);
			acceptButton.setDownColor(0);
			acceptButton.tapCallback = nextClick;
			acceptButton.disposeBitmapOnDestroy = true;
			acceptButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(acceptButton);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
			
			_view.addChild(container);
		}
		
		private function onChangeInputCoins():void 
		{
			
		}
		
		private function onInputSelected():void 
		{
			
		}
		
		private function backClick():void {
			
			if (state == STATE_START)
			{
				showFeedbackState();
			}
			else if(state == STATE_FEEDBACK)
			{
				callback(4);
				ServiceScreenManager.closeView();
			}
		}
		
		private function showFeedbackState():void 
		{
			state = STATE_FEEDBACK;
			drawTitle(data.textFeedback);
			addInput();
			drawAcceptButton(data.button_3);
			drawBackButton(data.button_4);
			acceptButton.alpha = 0.5;
			drawView();
			
			listenKeyboard();
		}
		
		private function listenKeyboard():void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
			//	MobileGui.androidExtension.addEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			}
			else if (Config.PLATFORM_APPLE == true)
			{
				MobileGui.dce.addEventListener(StatusEvent.STATUS, statusHandlerApple);
			}
		}
		
		private function statusHandlerApple(e:StatusEvent):void {
			var data:Object;
			switch (e.code) {
				case "inputViewHeightChangeEnd":
				case "inputViewKeyboardShowEnd":
				case "inputViewKeyboardHideEnd": {
					data = JSON.parse(e.level);
				
					if ("inputViewHeight" in data)
						keyboardHeight = data.inputViewHeight;
					break;
				}
			}
		}
		
		private function extensionAndroidStatusHandler(e:StatusEvent):void
		{
			if (e.code == "keyboardHeight")
			{
				keyboardHeight = parseInt(e.level);
				updateOnNative();
			}
		}
		
		private function updateOnNative():void 
		{
			TweenMax.killDelayedCallsTo(drawView);
			TweenMax.delayedCall(0.5, drawView);
		}
		
		override public function isModal():Boolean {
			return false;
		}
		
		private function addInput():void 
		{
			input = new InputField( -1, Input.MODE_INPUT);
			input.onChangedFunction = onInputChange;
			input.setMaxChars(120);
			container.addChild(input);
		//	input.setMode(Input.MODE_INPUT);
			var tf:TextFormat = new TextFormat();
			tf.size = int(Config.FINGER_SIZE * .35);
			tf.color = Style.color(Style.COLOR_SUBTITLE);
			tf.font = Config.defaultFontName;
			/*input.type = TextFieldType.INPUT;
			input.border = true;
			input.borderColor = Color.GREY_LIGHT;
			input.defaultTextFormat = tf;
			input.maxChars = 120;
			input.multiline = true;
			input.wordWrap = true;*/
		//	input.updateTextFormat(tf);
			
			if (isActivated == true)
			{
				input.activate();
			}
		}
		
		private function onInputChange():void 
		{
			if (input != null)
			{
				if (input.valueString == "")
				{
					acceptButton.alpha = 0.5;
				}
				else
				{
					acceptButton.alpha = 1;
				}
			}
		}
		
		private function nextClick():void {
			SoftKeyboard.closeKeyboard()
			
			if (state == STATE_START)
			{
				callback(1);
				ServiceScreenManager.closeView();
			}
			else if(state == STATE_FEEDBACK && input != null && input.valueString != "" && input.valueString != null)
			{
				callback(3, getText());
				ServiceScreenManager.closeView();
			}
		}
		
		private function callback(index:int, text:String = null):void 
		{
			if (data.callback != null)
			{
				data.callback(index, text);
			}
		}
		
		private function getText():String
		{
			return input.valueString;
		}
		
		private function activateButtons():void
		{
			activateBackButton();
			activateAcceptButton();
		}
		
		private function activateBackButton():void
		{
			if (isDisposed)
			{
				return;
			}
			
			if (backButton != null && isActivated)
			{
				backButton.activate();
			}
		}
		
		private function activateAcceptButton():void
		{
			if (isDisposed)
			{
				return;
			}
			
			if (acceptButton != null && isActivated)
			{
				acceptButton.activate();
				acceptButton.alpha = 0.5;
			}
		}
		
		private function drawTitle(text:String, maxWidth:Number = NaN):void
		{
			if (text == null)
			{
				text = "";
			}
			var maxTextWidth:Number = maxWidth;
			if (isNaN(maxTextWidth))
			{
				maxTextWidth = componentsWidth;
			}
			
			if (title.bitmapData != null)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			
			title.bitmapData = TextUtils.createTextFieldData(
															text, maxTextWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .34, true, 0x47515B, 0xFFFFFF, true);
			title.x = int(_width * .5 - title.width * .5);
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
			drawTitle(data.text);
			
			drawAcceptButton(data.button_1);
			
			drawBackButton(data.button_2);
			
			var itemWidth:int = (componentsWidth - Config.MARGIN) / 2;
		}
		
		private function drawAcceptButton(text:String):void 
		{
			if (text == null)
			{
				text = "";
			}
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			acceptButton.setBitmapData(buttonBitmap, true);
			acceptButton.x = int(acceptButton.width + Config.DIALOG_MARGIN * 2);
		}
		
		private function drawBackButton(text:String):void
		{
			if (text == null)
			{
				text = "";
			}
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 0, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			backButton.setBitmapData(buttonBitmap);
			backButton.x = Config.DIALOG_MARGIN;
		}
		
		override protected function drawView():void 
		{
			if (_isDisposed == true)
				return;
			
			var maxHeight:int = _height;
			if (keyboardHeight > 100)
			{
				maxHeight = _height - keyboardHeight;
			}
			
			verticalMargin = Config.MARGIN * 1.5;
			
			var position:int = Config.FINGER_SIZE * .55;
			
			title.y = position;
			position += title.height + Config.FINGER_SIZE * .75;
			
			if (state == STATE_FEEDBACK)
			{
				if (input != null)
				{
					input.x = Config.DIALOG_MARGIN;
					position -= Config.FINGER_SIZE * .4;
					input.y = position;
				//	input.width = componentsWidth;
					input.draw(componentsWidth, null, null, null, null);
				//	input.height = Config.FINGER_SIZE * 2;
					position += input.height + Config.FINGER_SIZE * .35;
				}
			}
			
			acceptButton.y = position;
			backButton.y = position;
			position += acceptButton.height + verticalMargin * 1.8;
			
			var bdDrawPosition:int = title.y + title.height + Config.FINGER_SIZE * .3;
			
			bg.graphics.clear();
		//	bg.graphics.beginFill(0xD9E5F0);
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, 0, _width, bdDrawPosition);
			bg.graphics.endFill();
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, bdDrawPosition, _width, position - bdDrawPosition);
			bg.graphics.endFill();
			
			container.y = maxHeight - position;
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			acceptButton.activate();
			backButton.activate();
			if (input != null)
			{
				input.activate();
			}
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			acceptButton.deactivate();
			backButton.deactivate();
			if (input != null)
			{
				input.deactivate();
			}
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			super.dispose();
			
			TweenMax.killDelayedCallsTo(drawView);
			
			if (MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.removeEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			}
			if (MobileGui.dce != null)
			{
				MobileGui.dce.removeEventListener(StatusEvent.STATUS, statusHandlerApple);
			}
			
			Overlay.removeCurrent();
			
			if (title != null)
				UI.destroy(title);
			title = null;
			if (backButton != null)
				backButton.dispose();
			backButton = null;
			if (acceptButton != null)
				acceptButton.dispose();
			acceptButton = null;
			if (bg != null)
				UI.destroy(bg);
			bg = null;
			if (container != null)
				UI.destroy(container);
			container = null;
			/*if (input != null)
				UI.destroy(input);
			input = null;*/
			if (input != null)
			{
				input.dispose();
			}
			input = null;
		}
	}
}