package com.dukascopy.connect.gui.chatInput {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.keyboardScreens.SmilesScreen;
	import com.dukascopy.connect.screens.keyboardScreens.StickersScreen;
	import com.dukascopy.connect.screens.keyboardScreens.attachScreen.AttachCameraScreen;
	import com.dukascopy.connect.screens.keyboardScreens.attachScreen.AttachGiftScreen;
	import com.dukascopy.connect.screens.keyboardScreens.attachScreen.AttachScreen;
	import com.dukascopy.connect.screens.keyboardScreens.attachScreen.AttachVoiceScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chat.DraftMessage;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.richTextField.RichTextSmilesCodes;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.stickerManager.StickerManager;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.vo.screen.AttachScreenData;
	import com.dukascopy.connect.vo.screen.ScreenData;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.FocusDirection;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import com.dukascopy.connect.GD;
	
	/**
	 * ...
	 * @author Igor Bloom
	 */
	
	public class ChatInputAndroid extends Sprite implements IChatInput {
		
		static public const ATTACH_VOICE_MESSAGE:String = "attachVoiceMessage";
		static public const ATTACH_GIFT:String = "attachGift";
		static public const ATTACH_CAMERA:String = "attachCamera";
		
		static public var S_SMILE_SELECTED:Signal = new Signal("ChatInput.S_SMILE_SELECTED");
		static public var S_ATTACH:Signal = new Signal("ChatInput.S_ATTACH");
		static public var S_CLOSE_MEDIA_KEYBOARD:Signal = new Signal('ChatInputAndroid.S_CLOSE_MEDIA_KEYBOARD');
		
		static private var keyboardHeight:int = Config.FINGER_SIZE * 4;
		
		static public var S_INPUT_HEIGHT_CHANGED:Signal = new Signal("ChatInput.S_INPUT_HEIGHT_CHANGED");
		
		private var mediaKeyboardBox:Sprite;
		
		private var mediaScreenManager:ScreenManager;
		
		private var downPoint:Point = new Point();
		private var lastBlackHoleTime:Number;
		
		private var _mediaScreenActivated:Boolean = false;
		private var _softKeyboardActivated:Boolean = false;
		private var _softKeyboardActivating:Boolean = false;
		
		private var inputH:int;
		
		private var selectedID:String;
		
		private var _width:int = 320;
		private var isDisposed:Boolean = false;
		
		private var tapOffset:int = Config.FINGER_SIZE * .8;
		
		private var chatSendCallBack:Function = null;
		private var busy:Boolean = false;
		private var extraFunctionsAvaliable:Boolean = true;
		private var stickersAvaliable:Boolean = true;
		private var payButtonActive:Boolean = false;
		private var wasMove:Boolean = false;
		
		private var preventBack:Boolean;
		private var shown:Boolean;
		private var inputPanel:IInputPanel;
		private var stickerMenu:int = 0;
		
		public function ChatInputAndroid() {
			
			inputPanel = getInputPanel();
			inputPanel.onSoftKeyboardActivatingCallback(onSoftKeyboardActivating);
			inputPanel.onSoftKeyboardActivateCallback(onSoftKeyboardActivate);
			inputPanel.onSoftKeyboardDeactivateCallback(onSoftKeyboardDeactivate);
			inputPanel.onSentVoicePressedCallback(onSentVoicePressed);
			inputPanel.onSmileStickerPressedCallback(onSmileStickerPressed);
			inputPanel.onAttachPressedCallback(onAttachPressed);
			inputPanel.onRemoveFocusCallback(onRemoveFocus);
			inputPanel.onSentPressedCallback(onSentPressed);
			inputPanel.setKeyboardHaight(keyboardHeight);
			inputPanel.onInputChangedCallback(onInputChanged);
			inputPanel.onPositionChangedCallback(onPositionChanged);
			addChild(inputPanel as Sprite);
			
			mediaKeyboardBox = new Sprite();
			addChildAt(mediaKeyboardBox, 0);
			
			RichTextSmilesCodes.loadRecentFromStore();
			StickerManager.loadRecentFromStore();
			
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onAppDeactivated);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, true);
			S_CLOSE_MEDIA_KEYBOARD.add(removeMediaKeyboard);
			
			if (MobileGui.stage != null)
			{
				setY(MobileGui.stage.stageHeight - getStartHeight());
			}
			
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
		}
		
		private function onActivate(e:Event):void 
		{
			echo("imput! onActivate !", "");
			if (mediaScreenActivated == false)
			{
				inputPanel.movoToBottom();
			}
			
			if (mediaScreenActivated)
			{
				echo("imput! onActivate y=", y.toString());
				TweenMax.killTweensOf(setY);
				TweenMax.delayedCall(0.2, setY, [y]);
			}
		}
		
		private function onPositionChanged(position:int):void {
			if (_mediaScreenActivated) {
				y = MobileGui.stage.stageHeight - getHeight();
				mediaKeyboardBox.y = inputPanel.getHeight();
			} else {
				y = position;
			}
			
			graphics.clear();
			graphics.beginFill(0xFFFFFF);
			graphics.drawRect(0, 0, _width, MobileGui.stage.stageHeight - y);
			graphics.endFill();
			
			ChatInputAndroid.S_INPUT_HEIGHT_CHANGED.invoke();
		}
		
		private function getInputPanel():IInputPanel {
			if (Config.PLATFORM_ANDROID) {
				if (NativeExtensionController.getVersion() <= 19)
					return new InputPanelWindows();
				return new InputPanelAndroid();
			} else {
				return new InputPanelWindows();
			}
		}
		
		private function onInputChanged():void 
		{
			if (inputPanel.getText() != null && inputPanel.getText().length != 0)
				onUserWritingTimer();
			updateView(true, "onInputChanged");
			inputPanel.updateView(stickerMenu);
			if (ChatManager.getCurrentChat() != null)
			{
				DraftMessage.setValue(ChatManager.getCurrentChat().uid, ChatManager.getCurrentChat().chatSecurityKey, inputPanel.getText());
			}
		}
		
		private function onSentPressed(value:String):void 
		{
			if(ChatManager.getCurrentChat()==null){
				GD.S_LOG.invoke("Can't send to chat, no current chat");
				return;
			}
			DraftMessage.clearValue(ChatManager.getCurrentChat().uid);
			if (chatSendCallBack != null){
				var sent:Boolean = chatSendCallBack(value);
				if (sent == true) {
					inputPanel.clearInput();
					updateView(true, "onSentPressed");
				}
			}
		}
		
		private function onRemoveFocus():void 
		{
			downPoint.x = -1;
		}
		
		private function onAttachPressed():void 
		{
			inputPanel.removeFocus();
			if (!extraFunctionsAvaliable) {
				return;
			}
			if (busy == true)
				return;
			if (selectedID == "attach")
				return;
			
			if (stickerMenu == 1 || stickerMenu == 3) {
				stickerMenu = 3;
			} else if (stickerMenu == 2 || stickerMenu == 0) {
				stickerMenu = 0;
			}
			
			inputPanel.updateButtonsOnAttachPressed(stickerMenu);
			
			_mediaScreenActivated = true;
			updateView(true, "onAttachPressed");
			onTabItemSelected("attach", "right");
		}
		
		private function onSmileStickerPressed():void 
		{
			inputPanel.removeFocus();
			if (busy == true)
				return;
			
			if (stickerMenu == 0 || stickerMenu == 1) {
				stickerMenu = 2;
				onTabItemSelected("stickers", "right");
			} else {
				stickerMenu = 1;
				onTabItemSelected("smiles", "right");
			}
			
			inputPanel.updateButtonsOnSmileStickerPressed(stickerMenu);
			_mediaScreenActivated = true;
			updateView(true, "onSmileStickerPressed");
		}
		
		private function onSentVoicePressed():void 
		{
			inputPanel.removeFocus();
			if (busy == true)
				return;
			_mediaScreenActivated = true;
			updateView(true, "onSentVoicePressed");
			if (selectedID == ATTACH_VOICE_MESSAGE)
				return;
			onTabItemSelected(ATTACH_VOICE_MESSAGE, "right");
		}
		
		private function onSoftKeyboardActivating():void {
			_softKeyboardActivating = true;
			_softKeyboardActivated = false;
		}
		
		private function onSoftKeyboardActivate():void {
			_softKeyboardActivating = false;
			_softKeyboardActivated = true;
			removeMediaKeyboard();
		}
		
		private function onSoftKeyboardDeactivate():void {
			if (_softKeyboardActivated == false && _softKeyboardActivating == false)
				return;
			_softKeyboardActivating = false;
			_softKeyboardActivated = false;
			
			preventBack = inputPanel.removeFocus();
			updateView(true, "onSoftKeyboardDeactivate");
			Input.S_SOFTKEYBOARD.invoke(false);
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			if (preventBack == false)
				return;
			preventBack = false;
			if (e.keyCode == Keyboard.BACK) {
				e.preventDefault();
				e.stopImmediatePropagation();
			}
		}
		
		private function onAppDeactivated(e:Event):void {
			onSoftKeyboardDeactivate();
		}
		
		protected function onStageDown(e:Event):void {
			wasMove = false;
			downPoint.x = mouseX;
			downPoint.y = mouseY;
			PointerManager.addMove(MobileGui.stage, onStageMove);
		}
		
		protected function onStageMove(e:Event):void {
			if (wasMove == true)
				return;
			if (mouseX < downPoint.x - tapOffset || 
				mouseX > downPoint.x + tapOffset || 
				mouseY < downPoint.y - tapOffset || 
				mouseY > downPoint.y + tapOffset)
					wasMove = true;
		}
		
		protected function onStageUp(e:Event = null):void {
			PointerManager.removeMove(MobileGui.stage, onStageMove);
			if ((downPoint.y < 0 && wasMove == false)) {
				inputPanel.removeFocus();
				if (_mediaScreenActivated)
					removeMediaKeyboard();
				return;
			}
			downPoint.x = -1;
		}
		
		protected function removeMediaKeyboard():void {
			if (isDisposed == true || _mediaScreenActivated == false)
				return;
			
			if (stickerMenu == 1 || stickerMenu == 3) {
				stickerMenu = 3;
			} else if (stickerMenu == 2 || stickerMenu == 0) {
				stickerMenu = 0;
			}
			
			inputPanel.onKeyboardRemoved(stickerMenu);
			
			if (mediaScreenManager != null && mediaScreenManager.view.parent != null) {
				mediaScreenManager.deactivate();
				mediaScreenManager.view.parent.removeChild(mediaScreenManager.view);
			}
			
			selectedID = "";
			
			_mediaScreenActivated = false;
			updateView(true, "removeMediaKeyboard");
		}
		
		protected function updateView(doSignal:Boolean = true, target:String = ""):void {
			if (isDisposed == true)
				return;
			var h:int = calcHeight();
			inputH = inputPanel.updateView(stickerMenu);
			mediaKeyboardBox.y = inputH;
			if (doSignal) {
				setY(MobileGui.stage.stageHeight - getHeight());
				MobileGui.setSoftKeyboardY(y);
				S_INPUT_HEIGHT_CHANGED.invoke();
			}
			graphics.clear();
			graphics.beginFill(0xFFFFFF);
			graphics.drawRect(0, 0, _width, MobileGui.stage.stageHeight - y);
			graphics.endFill();
		}
		
		public function getHeight():int {
			if (inputPanel.getKeyboardHeight() != -1) {
				keyboardHeight = inputPanel.getKeyboardHeight();
				inputPanel.setKeyboardHaight(keyboardHeight);
			}
			if (_mediaScreenActivated)
				return keyboardHeight + inputPanel.getHeight();
			if (_softKeyboardActivated == true || _softKeyboardActivating == true)
				return inputPanel.getHeight() + keyboardHeight;
			return inputPanel.getHeight();
		}
		
		protected function onSmileSelected(smile:Array = null):void {
			inputPanel.onSmileSelected(smile);
		//	updateView();
		}
		
		protected function setTFWidth(w:int):void {
			inputPanel.setTFWidth(w);
		}
		
		protected function calcHeight():int {
			return inputPanel.calcHeight();
		}
		
		public function get mediaScreenActivated():Boolean { return _mediaScreenActivated; }
		
		public function get softKeyboardActivated():Boolean { return _softKeyboardActivated; }
		
		protected function onUserWritingTimer():void {
			if (isDisposed == true)
				return;
			TweenMax.killDelayedCallsTo(onUserWritingTimer);
			if (ChatManager.getCurrentChat() == null)
				return;
			if (MobileGui.centerScreen.currentScreenClass != ChatScreen)
				return;
			TweenMax.delayedCall(2, onUserWritingTimer);
			
			if (!inputPanel.isFocused() || inputPanel.getText() == "")
				return;
			var date:Date = new Date();
			var curentTS:Number = date.getTime();
			if (curentTS - lastBlackHoleTime < 5000)
				return;
			lastBlackHoleTime = curentTS;
			WSClient.call_chatSendAll(ChatManager.getCurrentChat().uid, {
				method: "userWriting",
				userUID: Auth.uid,
				userName: Auth.username,
				chatUID: ChatManager.getCurrentChat().uid
			} );
			MobileGui.setSoftKeyboardY(MobileGui.stage.stageHeight);
		}
		
		private function setBusy(cls:Class):void {
			busy = false;
			if (mediaScreenManager.currentScreen != null && !(mediaScreenManager.currentScreen is AttachScreen))
				mediaScreenManager.currentScreen["showRecent"]();
		}
		
		public function setWidth(w:int):void {
			if (_width == w)
				return;
			_width = w;
			
			inputPanel.setWidth(w);
			
			updateView(true, "setWidth");
		}
		
		public function activate():void {
			inputPanel.activate();
			this;
			PointerManager.addUp(MobileGui.stage, onStageUp);
			PointerManager.addDown(MobileGui.stage, onStageDown);
			if (mediaScreenManager != null) {
				mediaScreenManager.activate();
				mediaScreenManager.S_COMPLETE_SHOW.add(setBusy);
			}
			S_SMILE_SELECTED.add(onSmileSelected);
			onUserWritingTimer();
			S_ATTACH.add(onAttachCall);
			
			StickersScreen.S_STICKER_PRESSED.add(onStickerSelected);
		}
		
		private function onStickerSelected(val:String):void {
			if (stickersAvaliable == false)
				return;
			if (chatSendCallBack != null)
				chatSendCallBack(val);
		}
		
		private function onAttachCall(type:String):void {
			if (type == ATTACH_VOICE_MESSAGE)
				onTabItemSelected(ATTACH_VOICE_MESSAGE, "right");
			else if (type == ATTACH_GIFT)
				onTabItemSelected(ATTACH_GIFT, "right");
			else if (type == ATTACH_CAMERA)
				onTabItemSelected(ATTACH_CAMERA, "right");
		}
		
		private function onTabItemSelected(id:String, side:String):void {
			if (mediaScreenManager == null) {
				mediaScreenManager = new ScreenManager("MediaKeyboard");
				mediaScreenManager.ingnoreBackSignal();
			}
			var openWithoutTween:Boolean = mediaScreenManager.view.parent == null;
			if (openWithoutTween) {
				mediaKeyboardBox.addChildAt(mediaScreenManager.view, 0);
				mediaScreenManager.activate();
				mediaScreenManager.S_COMPLETE_SHOW.add(setBusy);
			}
			mediaScreenManager.setSize(_width, keyboardHeight);
			
			selectedID = id;
			
			var screenData:ScreenData;
			
			var cls:Class = null;
			if (id == 'stickers')
				cls = StickersScreen;
			else if (id == 'smiles')
				cls = SmilesScreen;
			else if (id == 'attach') {
				screenData = new AttachScreenData();
				(screenData as AttachScreenData).showPayButtons = payButtonActive;
				cls = AttachScreen;
			} else if (id == ATTACH_VOICE_MESSAGE)
			{
				cls = AttachVoiceScreen;
			}
			else if (id == ATTACH_GIFT)
			{
				cls = AttachGiftScreen;
			}
			else if (id == ATTACH_CAMERA)
			{
				cls = AttachCameraScreen;
			}
			
			var screen:BaseScreen = mediaScreenManager.getScreenByClass(cls);
			if (screen != null && "showRecent" in screen)
				screen["showRecent"]();
			if (mediaScreenManager.currentScreenClass == cls) {
				return;
			}
			
			var direction:int = 1;
			if (side == 'right')
				direction = 0;
			
			if (cls != null) {
				busy = true;
				mediaScreenManager.show(cls, screenData, direction, ((openWithoutTween == true) ? 0 : .3));
			}
		}
		
		public function setCallBack(onChatSend:Function):void {
			chatSendCallBack = onChatSend;
		}
		
		public function setValue(text:String):void {
			inputPanel.setValue(text);
		}
		
		public function deactivate():void {
			//onSoftKeyboardDeactivate(); David Pravil eto ne znaju zachem
			
			inputPanel.deactivate();
			
			PointerManager.removeDown(MobileGui.stage, onStageDown);
			PointerManager.removeUp(MobileGui.stage, onStageUp);
			PointerManager.removeMove(MobileGui.stage, onStageMove);
			if (mediaScreenManager != null) {
				mediaScreenManager.deactivate();
				mediaScreenManager.S_COMPLETE_SHOW.remove(setBusy);
			}
			S_SMILE_SELECTED.remove(onSmileSelected);
			S_ATTACH.remove(onAttachCall);
			TweenMax.killDelayedCallsTo(onUserWritingTimer);
		}
		
		public function dispose():void {
			TweenMax.killTweensOf(setY);

			if (isDisposed)
				return;
			isDisposed = true;
			NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE, onActivate);
			TweenMax.killDelayedCallsTo(onUserWritingTimer);
			
			SoftKeyboard.stopDetectHeight();
			deactivate();
			
			if (inputPanel != null) {
				inputPanel.dispose();
				inputPanel = null;
			}
			
			UI.destroy(mediaKeyboardBox);
			mediaKeyboardBox = null;
			
			if (mediaScreenManager != null)
				mediaScreenManager.dispose();
			mediaScreenManager = null;
			
			if (this.parent)
				this.parent.removeChild(this);
			this.graphics.clear();
			
			chatSendCallBack = null;
			_width = 0;
			
		//	if (S_INPUT_HEIGHT_CHANGED != null)
		//		S_INPUT_HEIGHT_CHANGED.dispose();
		//	S_INPUT_HEIGHT_CHANGED = null;
			
			MobileGui.stage.assignFocus(null, FocusDirection.NONE);
			SoftKeyboard.S_CLOSED.invoke();
			
			NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE, onAppDeactivated);
			NativeApplication.nativeApplication.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, true);
		}
		
		public function setY(openChatY:int):void {
			echo("imput! setY y=", openChatY.toString());
			TweenMax.killTweensOf(setY);
			y = openChatY;
			inputPanel.setY(openChatY);
			if (mediaScreenManager != null && mediaScreenManager.currentScreen != null)
				mediaScreenManager.currentScreen.updateBounds();
		}
		
		public function getStartHeight():Number { return inputPanel.getStartHeight(); }
		
		public function showBG():void {
			inputPanel.showBackground();
		}
		
		public function show(defaultText:String = null):void
		{
			shown = true;
			visible = true;
			
			inputPanel.show(defaultText);
		}
		
		public function hide():void {
			shown = false;
			if (!Config.PLATFORM_ANDROID) {
				visible = false;
			}
			
			inputPanel.removeFocus();
			inputPanel.hide();
		}
		
		public function setMaxTopY(margin:int):void {}
		public function getView():DisplayObject { return this; }
		
		public function blockStickers(val:Boolean = true):void {
			stickersAvaliable = !val;
		}
		
		public function blockExtraFunctions():void {
			extraFunctionsAvaliable = false;
		}
		
		public function initButtons(showPayButtons:Boolean = false):void {
			payButtonActive = showPayButtons;
			if (mediaScreenManager && (mediaScreenManager.currentScreen != null) && (mediaScreenManager.currentScreen is AttachScreen))
			{
				(mediaScreenManager.currentScreen as AttachScreen).initButtons(payButtonActive);
				onActivate(null);
			}
			if (Config.PLATFORM_WINDOWS == true && ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().pid == Config.EP_VI_DEF)
			{
				inputPanel.showAccountButton();
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IChatInput */
		
		public function hideBackground():void 
		{
			inputPanel.hideBackground();
			graphics.clear();
		}
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IChatInput */
		
		public function isShown():Boolean 
		{
			return shown;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IChatInput */
		
		public function hideStickersAndAttachButton():void 
		{
			inputPanel.hideAttachButton();
			inputPanel.hideStickersButton();
		}
		
		public function setLeftMargin(value:int):void 
		{
			inputPanel.setLeftPadding(value);
		}
		
		public function hideStickersButton():void
		{
			inputPanel.hideStickersButton();
		}
		
		public function hideAttachButton():void
		{
			inputPanel.hideAttachButton();
		}
		
		public function disableVoiceRecord():void
		{
			inputPanel.disableVoiceRecord();
		}
	}
}