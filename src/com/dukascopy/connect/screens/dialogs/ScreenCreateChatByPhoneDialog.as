package com.dukascopy.connect.screens.dialogs {
	
	import com.adobe.utils.IntUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.langs.Lang;
	import com.telefision.utils.Loop;
	import com.telefision.utils.PhoneValidator;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class ScreenCreateChatByPhoneDialog extends BaseScreen {
		
		private var topBarHeight:int;
		
		private var container:Sprite;
		private var content:ScrollPanel;
		private var contentTF:TextField;
		private var pinInput:Input;
		
		private var callback:Function;
		private var oldHeight:int;
		
		private var titleBitmap:Bitmap;
		private var cancelButton:BitmapButton;
		private var okButton:BitmapButton;
		
		public function ScreenCreateChatByPhoneDialog() {
			topBarHeight = Config.FINGER_SIZE;			
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			container = new Sprite();
		
			// Title
			titleBitmap = new Bitmap();
			container.addChild(titleBitmap);
			titleBitmap.bitmapData = UI.renderTextShadowed(Lang.startNewChat, _width, Config.FINGER_SIZE,false, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .35,false,0xffffff,0x000000,0x000000,true,2, false);
			titleBitmap.y = int(topBarHeight - titleBitmap.height) * .5;
					
	
			// Content text 
			var tf:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * 0.35, 0, true, null, null, null, null, TextFormatAlign.CENTER);
			tf.bold = false;
			tf.color = 0;
			tf.size = Config.FINGER_SIZE * 0.32;
			contentTF = new TextField();
			contentTF.defaultTextFormat = tf;
			contentTF.x = Config.DOUBLE_MARGIN;
			contentTF.mouseEnabled = false;
			contentTF.selectable = false;
			contentTF.multiline = true;
			contentTF.wordWrap = true;
			
			// Input 
			pinInput = new Input();
			pinInput.setRoundBG(true);
			pinInput.setMode(Input.MODE_PHONE);
			pinInput.setLabelText(Lang.typePhone);
			
			// Scroll Panel
			content = new ScrollPanel();
			content.backgroundColor = 0xDEDEDE;
			content.addObject(contentTF);
			content.view.y = topBarHeight;
			
			// OK Button
			cancelButton  = new BitmapButton();						
			cancelButton.setStandartButtonParams();
			cancelButton.setDownScale(1);
			cancelButton.cancelOnVerticalMovement = true;
			cancelButton.tapCallback =callBack;		
			cancelButton.x = Config.FINGER_SIZE;	
			cancelButton.y = int((Config.FINGER_SIZE - cancelButton.height) * .5);
			cancelButton.x = Config.MARGIN;
			
			// CANCEL Button
			okButton  = new BitmapButton();						
			okButton.setStandartButtonParams();
			okButton.setDownScale(1);
			okButton.cancelOnVerticalMovement = true;
			okButton.tapCallback = onOKClick;		
			okButton.x = Config.FINGER_SIZE;	
			okButton.y = int((Config.FINGER_SIZE - cancelButton.height) * .5);
			okButton.x = Config.MARGIN;
			
			container.addChild(content.view);
			container.addChild(pinInput.view);
			container.addChild(cancelButton);
			container.addChild(okButton);			
			_view.addChild(container);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			callback = data.callBack;
			
			contentTF.text = Lang.typePhoneNumber;//"Please type phone number to start chat.";
		}
		
		override protected function drawView():void {
			if (oldHeight == _height)
				return;
			
			oldHeight = _height;
			
			var tfWidth:int = _width - Config.DOUBLE_MARGIN * 2;
			
			// Title 			
			titleBitmap.x  = (_width - titleBitmap.width) * .5;
			
			contentTF.y = 0;
			contentTF.width = tfWidth;
			contentTF.height = contentTF.textHeight + 4;
			
			var trueContentHeight:int = contentTF.height;
			var minContentHeight:int = Config.FINGER_SIZE_DOUBLE;
			var maxContentHeight:int = _height - topBarHeight - Config.FINGER_SIZE - 1 - Config.DOUBLE_MARGIN * 2;
			if (trueContentHeight > maxContentHeight)
				trueContentHeight = maxContentHeight;
			content.setWidthAndHeight(_width, trueContentHeight);
			
			pinInput.view.x = int((_width - pinInput.width) * .5);
			pinInput.view.y = content.view.y + trueContentHeight + Config.DOUBLE_MARGIN;
			
			//borderBottom.width = _width;
			//borderBottom.y = pinInput.view.y + pinInput.view.height + Config.DOUBLE_MARGIN;
			
			var trueButtonWidth:int = _width / 2;
			var buttonDestWidth:int = trueButtonWidth;
			var rad:int = Config.DOUBLE_MARGIN-14;
			
			//OK 
			var bitmapPlane:BitmapData;			
			bitmapPlane = UI.renderDialogButton(Lang.textCancel.toUpperCase(), buttonDestWidth, Config.FINGER_SIZE, 0x1381F9, 0xDEDEDE, 0xb1b1b1, 0, 0, 0, rad);
   		    		
			//CANCEL
			var bitmapPlane2:BitmapData;
			bitmapPlane2 = UI.renderDialogButton(Lang.textOk.toUpperCase(), buttonDestWidth + 1, Config.FINGER_SIZE, 0x1381F9, 0xDEDEDE, 0xb1b1b1, 0,0,rad);
			
			cancelButton.setBitmapData(bitmapPlane,true);
			okButton.setBitmapData(bitmapPlane2, true);
			cancelButton.y = okButton.y = pinInput.view.y + pinInput.view.height + Config.DOUBLE_MARGIN;
			cancelButton.x = 0;
			okButton.x = buttonDestWidth;
			
			var trueViewHeight:int = okButton.y + okButton.height;
			container.graphics.clear();
			container.graphics.beginFill(0xDEDEDE);
			container.graphics.drawRoundRect(0, 0, _width, trueViewHeight, Config.DOUBLE_MARGIN, Config.DOUBLE_MARGIN);
			container.graphics.endFill();
			container.y = int((_height - trueViewHeight) * .5);
			
			onChangeInputValue();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			cancelButton.activate();
			okButton.activate();
			//PointerManager.addTap(btn0, onOKClick);
			pinInput.activate();
			Loop.add(onChangeInputValue);
			//pinInput.S_CHANGED.add(onChangeInputValue);
			content.enable();
			//if (btn1 != null)
			//PointerManager.addTap(btn1, callBack);
			
			onChangeInputValue();
		}
		
		private function onChangeInputValue():void 
		{			
			var phoneNumber:String = pinInput.value;	
			var isValid:Boolean = phoneNumber.length >= 6 && PhoneValidator.isValidPhoneNumber(phoneNumber)
			if (isValid) {
				okButton.alpha = 1;
			}else {
				okButton.alpha = .5;
			
			}
		}
		
		private function onOKClick(e:Event=null):void {
			var phoneNumber:String = pinInput.value;
			if (phoneNumber == Lang.typePhone)
				return;
			if (phoneNumber.length < 6)
				return
			callback(1, pinInput.value);
			callBack(e);
		}
		
		override public function deactivateScreen():void {
			if (isDisposed)
				return;
			content.disable();
			super.deactivateScreen();
			cancelButton.deactivate();
			okButton.deactivate();
			//PointerManager.removeTap(btn0, onOKClick);
			pinInput.deactivate();
			Loop.remove(onChangeInputValue);
			//if (btn1 != null)
				//PointerManager.removeTap(btn1, callBack);
		}
		
		private function callBack(e:Event=null):void {
			DialogManager.closeDialog();
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			
			deactivateScreen(); // 
			_isDisposed = true;
			super.dispose();
			
			UI.destroy(titleBitmap);
			titleBitmap = null;
			
			if (contentTF != null)
				contentTF.text = "";
			contentTF = null;
			
			if (content != null)
				content.dispose();
			content = null;
			
			if (cancelButton != null) {
				cancelButton.dispose();
				cancelButton = 	null;
			}
						
			if (okButton != null) {
				okButton.dispose();
				okButton = 	null;
			}		
			
			
			
			if (container != null)
				container.graphics.clear();
			container = null;
			
			callback = null;
			
			if (pinInput != null)
				pinInput.dispose();
			pinInput = null;
		}
	}
}