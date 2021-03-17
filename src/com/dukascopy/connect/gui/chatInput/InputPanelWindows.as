package com.dukascopy.connect.gui.chatInput 
{
	import assets.SendButtonSound;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.richTextField.RichTextSmilesCodes;
	import com.dukascopy.connect.sys.richTextField.RichTextSmilesCodes;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapData;
	import flash.display.FocusDirection;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class InputPanelWindows extends Sprite implements IInputPanel
	{
		private var sendBtnVoice:BitmapButton;
		private var tf:TextField;
		private var smilesShape:Bitmap;
		private var cursor:Sprite;
		private var cursorFlash:Shape;
		private var inputBox:Sprite;
		private var smileStickerBtn:BitmapButton;
		private var attachBtn:BitmapButton;
		private var sendBtn:BitmapButton;
		private var lblInput:Bitmap;
		
		private var trueHeight:int = Config.FINGER_SIZE * .85;
		private var _width:int;
		
		private var bmdSmile:ImageBitmapData;
		private var bmdSmileColor:ImageBitmapData;
		private var bmdSticker:ImageBitmapData;
		private var bmdStickerColor:ImageBitmapData;
		
		static private var textColor:uint = Style.color(Style.COLOR_TEXT);
		static private var ta:TextFormat = new TextFormat(null, Config.FINGER_SIZE * .35, textColor);
		private var ct:ColorTransform;
		private var lineH:int = 0;
		private var _isFocused:Boolean = false;
		
		private var onSoftKeyboardActivatingFunction:Function;
		private var onSoftKeyboardActivateFunction:Function;
		private var onSoftKeyboardDeactivateFunction:Function;
		private var onSentVoicePressedFunction:Function;
		private var onSmileStickerPressedFunction:Function;
		private var onAttachPressedFunction:Function;
		private var format:TextFormat = new TextFormat();
		private var dontFocused:Boolean = false;
		private var removeFocusFunction:Function;
		
		private var offsetTB:int;
		private var inputH:Number;
		private var onSentPressedFunction:Function;
		private var keyboardHeight:int;
		private var lastStickerMenu:int;
		private var onInputChangedFunction:Function;
		
		public function InputPanelWindows() 
		{
			inputBox = new Sprite();
				var btnSize:Number = trueHeight * .54;
				bmdSmile = UI.renderAsset(UI.colorize(new (Style.icon(Style.ICON_SMILE)), Style.color(Style.ICON_ATTACH_COLOR)), btnSize * 2, btnSize, true, "ChatInput.smile");
				bmdSmileColor = UI.renderAsset(new (Style.icon(Style.ICON_SMILE_COLOR)), btnSize * 2, btnSize, true, "ChatInput.smileColor");
			//	btnSize = trueHeight * .8;
				
				if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().pid == Config.EP_VI_DEF)
				{
					bmdSticker = UI.renderAsset(UI.colorize(new (Style.icon(Style.ICON_BOT)), Style.color(Style.ICON_ATTACH_COLOR)), btnSize * 2, btnSize, true, "ChatInput.sticker");
					bmdStickerColor = UI.renderAsset(new (Style.icon(Style.ICON_BOT)), btnSize * 2, btnSize, true, "ChatInput.stickerColor");
				}
				else
				{
					bmdSticker = UI.renderAsset(UI.colorize(new (Style.icon(Style.ICON_STICKER)), Style.color(Style.ICON_ATTACH_COLOR)), btnSize * 2, btnSize, true, "ChatInput.sticker");
					bmdStickerColor = UI.renderAsset(new (Style.icon(Style.ICON_STICKER_COLOR)), btnSize * 2, btnSize, true, "ChatInput.stickerColor");
				}
				
				var btnOffsetH:int = trueHeight * .1;
				smileStickerBtn = new BitmapButton();
					smileStickerBtn.usePreventOnDown = false;
					smileStickerBtn.setStandartButtonParams();
					smileStickerBtn.setBitmapData(bmdSticker);
					smileStickerBtn.setDownAlpha(1);
					smileStickerBtn.setDownColor(0x6F92B0);
					smileStickerBtn.setDownScale(1);
					smileStickerBtn.show();
					smileStickerBtn.setOverflow(int((trueHeight - bmdSticker.height) * .5), btnOffsetH + Config.FINGER_SIZE_DOT_25, btnOffsetH, int((trueHeight - bmdSticker.height) * .5));
					smileStickerBtn.x = Config.MARGIN + btnOffsetH;
				inputBox.addChild(smileStickerBtn);
			//	btnSize = trueHeight * .5;
				var btnOffsetV:int = trueHeight * .25;
				btnOffsetH = trueHeight * .15;
				attachBtn = new BitmapButton();
					attachBtn.usePreventOnDown = false;
					attachBtn.setStandartButtonParams();
					attachBtn.setDownColor(0x6F92B0);
					attachBtn.setDownAlpha(1);
					attachBtn.setDownScale(1);
					attachBtn.setBitmapData(UI.renderAsset(UI.colorize(new (Style.icon(Style.ICON_ATTACH)), Style.color(Style.ICON_ATTACH_COLOR)), btnSize * 2, btnSize, true, "ChatInput.attach"));
					attachBtn.show();
					attachBtn.setOverflow(btnOffsetV, btnOffsetH, btnOffsetH * 2, btnOffsetV);
					attachBtn.x = Config.MARGIN*.1 + trueHeight + btnOffsetH;
				inputBox.addChild(attachBtn);
				btnSize = trueHeight;
				sendBtn = new BitmapButton();
					sendBtn.usePreventOnDown = false;
					sendBtn.setStandartButtonParams();
					sendBtn.setBitmapData(UI.renderAsset(new (Style.icon(Style.ICON_SEND)), btnSize * 2, btnSize, true, "ChatInput.send"));
					sendBtn.show();
				inputBox.addChild(sendBtn);
				sendBtnVoice = new BitmapButton();
					sendBtnVoice.usePreventOnDown = false;
					sendBtnVoice.setStandartButtonParams();
					sendBtnVoice.setBitmapData(UI.renderAsset(new (Style.icon(Style.ICON_SEND_VOICE)), btnSize * 2, btnSize, true, "ChatInput.sendVoice"));
					sendBtnVoice.show();
				inputBox.addChild(sendBtnVoice);
					lblInput = new Bitmap();
					lblInput.bitmapData = UI.renderText(Lang.typeMessage, 1000, trueHeight, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .32, false, Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_INPUT_BACKGROUND), false, "ChatInput.lblInput");
					lblInput.y = int((trueHeight - lblInput.height) * .5);
					lblInput.x = attachBtn.x + trueHeight - btnOffsetH;
				inputBox.addChild(lblInput);
			addChild(inputBox);
			tf = new TextField();
				tf.width = 300;
				tf.height = 200;
				tf.multiline = true;
				tf.wordWrap = true;
				tf.type = TextFieldType.INPUT;
				tf.defaultTextFormat = ta;
				tf.text = "`Qp_|,";
				lineH = tf.textHeight;
				tf.text = "";
				tf.height = lineH + 4;
				tf.selectable = true;
				ct = new ColorTransform();
					ct.color = textColor;
				tf.transform.colorTransform = ct;
			addChild(tf);
			cursor = new Sprite();
				cursor.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				cursor.graphics.drawRect(0, 0, 3, lineH);
				cursorFlash = new Shape();
					cursorFlash.graphics.beginFill(0xFF0000);
					cursorFlash.graphics.drawRect(0, 0, 3, lineH);
					cursorFlash.alpha = 0;
				cursor.addChild(cursorFlash);
				cursor.visible = false;
			addChild(cursor);
			
			smilesShape = new Bitmap();
			addChild(smilesShape);
			
			tf.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			tf.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			tf.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onSoftKeyboardDeactivate);
			tf.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onSoftKeyboardActivate);
			tf.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, onSoftKeyboardActivating);
			
			tf.addEventListener(MouseEvent.MOUSE_DOWN, onTFMouseDown);
			tf.addEventListener(MouseEvent.MOUSE_UP, onTFMouseUp);
			tf.addEventListener(Event.SCROLL, onTextFieldScroll);
			tf.addEventListener(Event.CHANGE, onChanged);
		}
		
		private function onSoftKeyboardActivating(e:SoftKeyboardEvent):void {
			if (onSoftKeyboardActivatingFunction) {
				onSoftKeyboardActivatingFunction.call();
			}
		}
		
		private function onSoftKeyboardActivate(e:SoftKeyboardEvent):void {
			if (onSoftKeyboardActivateFunction){
				onSoftKeyboardActivateFunction.call();
			}
		}
		
		private function onSoftKeyboardDeactivate(e:SoftKeyboardEvent = null):void {
			if (onSoftKeyboardDeactivateFunction) {
				onSoftKeyboardDeactivateFunction.call();
			}
		}
		
		protected function onFocusIn(e:FocusEvent):void {
			if (_isFocused == true)
				return;
			_isFocused = true;
			activateCursor();
			Input.S_SOFTKEYBOARD.invoke(true);
		}
		
		private function deactivateCursor():void {
			if (cursor == null || cursorFlash == null)
				return;
			cursor.visible = false;
			TweenMax.killTweensOf(cursorFlash);
		}
		
		private function activateCursor(draw:Boolean = true):void {
			if (cursor == null || cursorFlash == null)
				return;
			cursor.visible = true;
			if (draw)
				drawCursor();
			cursorFlash.alpha = 0;
			TweenMax.to(cursorFlash, .2, { alpha:1, yoyo:true, repeat: -1, repeatDelay:.2 } );
		}
		
		protected function onSmileStickerPressed(e:Event = null):void {
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().pid == Config.EP_VI_DEF)
			{
				MobileGui.openBankBot();
				return;
			}
			
			if (onSmileStickerPressedFunction){
				onSmileStickerPressedFunction.call();
			}
		}
		
		protected function onAttachPressed(e:Event = null):void {
			if (onAttachPressedFunction){
				onAttachPressedFunction.call();
			}
		}
		
		protected function onFocusOut(e:FocusEvent):void {
			_isFocused = false;
			deactivateCursor();
			if (dontFocused) {
				dontFocused = false;
				return;
			}
			dontFocused = false;
			if (mouseY < 0) {
				MobileGui.stage.assignFocus(tf, FocusDirection.NONE);
				return;
			}
			MobileGui.stage.assignFocus(tf, FocusDirection.NONE);
		}
		
		public function removeFocus(e:Event = null):Boolean {
			if (MobileGui.stage.focus != tf)
				return false;
			dontFocused = true;
			MobileGui.stage.assignFocus(null, FocusDirection.NONE);
			if (removeFocusFunction) {
				removeFocusFunction.call();
			}
			return true;
		}
		
		public function drawSmileButton():void 
		{
			var btnOffsetH:int;
			var btnOffsetV:int;
			
			btnOffsetH = trueHeight * .25;
			smileStickerBtn.setBitmapData(bmdSmile);
			smileStickerBtn.y = attachBtn.y;
			smileStickerBtn.setOverflow(btnOffsetH, btnOffsetH + Config.FINGER_SIZE_DOT_25, btnOffsetH, btnOffsetH);
			
			smileStickerBtn.x = Config.MARGIN + btnOffsetH;
		}
		
		public function drawStickerButton():void 
		{
			var btnOffsetH:int;
			var btnOffsetV:int;
			
			smileStickerBtn.setBitmapData(bmdSticker);
			btnOffsetV = int((trueHeight - smileStickerBtn.height) * .5);
			btnOffsetH = int((trueHeight - smileStickerBtn.width) * .5);
			smileStickerBtn.y = int(inputH - smileStickerBtn.height - btnOffsetV);
			smileStickerBtn.setOverflow(btnOffsetV, btnOffsetH + Config.FINGER_SIZE_DOT_25, btnOffsetH, btnOffsetV);
			
			smileStickerBtn.x = Config.MARGIN + btnOffsetH;
		}
		
		public function onKeyboardRemoved(stickerMenu:int):void 
		{
			lastStickerMenu = stickerMenu;
			if (stickerMenu == 1 || stickerMenu == 3) {
				drawSmileButton();
			} else if (stickerMenu == 2 || stickerMenu == 0) {
				drawStickerButton();
			}
		}
		
		public function updateView(stickerMenu:int):int 
		{
			lastStickerMenu = stickerMenu;
			// inputbox
			var h:int = calcHeight();
			inputH = h + offsetTB * 2;
			if (inputH < sendBtn.height)
				inputH = sendBtn.height;
			inputBox.graphics.clear();
			inputBox.graphics.beginFill(Style.color(Style.COLOR_INPUT_BACKGROUND));
			inputBox.graphics.drawRect(0, 0, _width, inputH);
			inputBox.graphics.endFill();
			
			// Button Position
			sendBtn.y = int(inputH - sendBtn.height);
			sendBtnVoice.y = int(inputH - sendBtnVoice.height);
			attachBtn.y = int(inputH - attachBtn.height - int(trueHeight * .25));
			smileStickerBtn.y = int(inputH - smileStickerBtn.height - int((trueHeight - smileStickerBtn.height) * .5));
			
			tf.x = attachBtn.x + attachBtn.width + attachBtn.RIGHT_OVERFLOW;
			tf.y = Math.round((inputBox.height - tf.height) * .5);
			smilesShape.x = tf.x;
			smilesShape.y = tf.y;
			drawSmiles();
			
			return inputH;
		}
		
		public function onSmileSelected(smile:Array = null):void 
		{
			if (smile == null) {
				if (tf.caretIndex == 0)
					return;
				tf.setSelection(tf.caretIndex - 1, tf.caretIndex);
				tf.replaceSelectedText("");
				tf.scrollV = tf.getLineIndexOfChar(tf.caretIndex);
				if (tf.text == "")
					lblInput.visible = true;
				else
					lblInput.visible = false;
				tf.setSelection(tf.caretIndex, tf.caretIndex);
			}
			else{
				format.color = smile[0];
				format.size = (ta.size as Number) * 1.35;
				tf.setSelection(tf.caretIndex, tf.caretIndex);
				tf.replaceSelectedText("—");
				try{
					tf.setTextFormat(format, tf.caretIndex, tf.caretIndex + 1);
				}
				catch (e:Error)
				{
					
				}
				
				tf.scrollV = tf.getLineIndexOfChar(tf.caretIndex - 1);
				lblInput.visible = false;
				tf.setSelection(tf.caretIndex + 1, tf.caretIndex + 1);
			}
			updateView(lastStickerMenu);
		}
		
		protected function onSentVoicePressed(e:Event = null):void {
			if (onSentVoicePressedFunction) {
				onSentVoicePressedFunction.call();
			}
		}
		
		protected function onSentPressed(e:Event = null):void {
			if (tf.text == null)
				return;
			var val:String = tf.text;
			var value:String = StringUtil.trim(val);
			var result:String = "";
			var char:String = "";
			var l:int = value.length;
			var tfa:TextFormat;
			var code:uint;
			for (var n:int = 0; n < l; n++) {
				char = value.charAt(n);
				if (char == "—") {
					tfa = tf.getTextFormat(n, n + 1);
					if (tfa.color != textColor && tfa.color != 0 && tfa.color != 0xFFFFFF) {
						code = tfa.color as uint;
						char = RichTextSmilesCodes.getSmileStringByCode(code);
					}
				}
				result += char;
			}
			value = result;
			if (value.length == 0)
				return;
			
			if (onSentPressedFunction) {
				onSentPressedFunction(value);
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function setTFWidth(w:int):void 
		{
			tf.width = w;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function calcHeight():int 
		{
			var h:int = lineH;
			if (tf.textHeight > h)
				h = tf.textHeight;
			var maxSTHeight:int = MobileGui.stage.stageHeight - keyboardHeight - Config.FINGER_SIZE_DOUBLE - offsetTB * 2;
			if (h > maxSTHeight)
				h = maxSTHeight;
			h += 4;
			tf.height = h;
			return h;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function getHeight():Number 
		{
			return inputBox.height;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function activate():void 
		{
			attachBtn.activate();
			attachBtn.tapCallback = onAttachPressed;
			smileStickerBtn.activate();
			smileStickerBtn.tapCallback = onSmileStickerPressed;
			
			sendBtn.activate();
			sendBtn.tapCallback = onSentPressed;
			
			sendBtnVoice.activate();
			sendBtnVoice.tapCallback = onSentVoicePressed;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function setWidth(w:int):void 
		{
			_width = w;
			sendBtn.x = int(_width - sendBtn.width);
			sendBtnVoice.x = int(_width - sendBtnVoice.width);
			
			setTFWidth(sendBtn.x - (attachBtn.x + attachBtn.width + attachBtn.RIGHT_OVERFLOW) - Config.MARGIN);
		}
		
		public function showAccountButton():void
		{
			var btnSize:Number = trueHeight * .54;
			
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().pid == Config.EP_VI_DEF)
			{
				if (bmdSticker != null)
				{
					UI.disposeBMD(bmdSticker);
				}
				if (bmdStickerColor != null)
				{
					UI.disposeBMD(bmdStickerColor);
				}
				bmdSticker = UI.renderAsset(UI.colorize(new (Style.icon(Style.ICON_BOT)), Style.color(Style.ICON_ATTACH_COLOR)), btnSize * 2, btnSize, true, "ChatInput.sticker");
				bmdStickerColor = UI.renderAsset(new (Style.icon(Style.ICON_BOT)), btnSize * 2, btnSize, true, "ChatInput.stickerColor");
				
				smileStickerBtn.setBitmapData(bmdSticker);
			}
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function setValue(text:String):void 
		{
			tf.text = text;
			if (tf.text.length > 0)
				lblInput.visible = false;
			tf.requestSoftKeyboard();
			
			onChanged();
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function getText():String 
		{
			return tf.text;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function deactivate():void 
		{
			attachBtn.deactivate();
			smileStickerBtn.deactivate();
			sendBtn.deactivate();
			sendBtnVoice.deactivate();
			deactivateCursor();
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function dispose():void 
		{
			ct = null;
			
			UI.disposeBMD(bmdSmile);
			bmdSmile = null;
			UI.disposeBMD(bmdSmileColor);
			bmdSmileColor = null;
			UI.disposeBMD(bmdSticker);
			bmdSticker = null;
			UI.disposeBMD(bmdStickerColor);
			bmdStickerColor = null;
			
			UI.destroy(tf);
			tf = null;
			UI.destroy(smilesShape);
			smilesShape = null;
			UI.destroy(cursor);
			cursor = null;
			UI.destroy(cursorFlash);
			cursorFlash = null;
			
			if (tf != null) {
				tf.removeEventListener(MouseEvent.MOUSE_DOWN, onTFMouseDown);
				tf.removeEventListener(MouseEvent.MOUSE_UP, onTFMouseUp);
				tf.removeEventListener(Event.SCROLL, onTextFieldScroll);
				tf.removeEventListener(Event.CHANGE, onChanged);
				
				tf.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
				tf.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				tf.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onSoftKeyboardDeactivate);
				tf.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onSoftKeyboardActivate);
				tf.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, onSoftKeyboardActivating);
			}
			
			UI.destroy(inputBox);
			inputBox = null;
			UI.destroy(lblInput);
			lblInput = null;
			
			if (smileStickerBtn != null)
				smileStickerBtn.dispose();
			smileStickerBtn = null;
			if (attachBtn != null)
				attachBtn.dispose();
			attachBtn = null;
			if (sendBtn != null)
				sendBtn.dispose();
			sendBtn = null;
			if (sendBtnVoice != null)
				sendBtnVoice.dispose();
			sendBtnVoice = null;
			
			onSoftKeyboardActivatingFunction = null;
			onSoftKeyboardActivateFunction = null;
			onSoftKeyboardDeactivateFunction = null;
			onSentVoicePressedFunction = null;
			onSmileStickerPressedFunction = null;
			onAttachPressedFunction = null;
			removeFocusFunction = null;
			onSentPressedFunction = null;
			onInputChangedFunction = null;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function onSoftKeyboardActivatingCallback(callback:Function):void 
		{
			onSoftKeyboardActivatingFunction = callback;
		}
		
		public function onSoftKeyboardActivateCallback(callback:Function):void 
		{
			onSoftKeyboardActivateFunction = callback;
		}
		
		public function onSoftKeyboardDeactivateCallback(callback:Function):void 
		{
			onSoftKeyboardDeactivateFunction = callback;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function isFocused():Boolean 
		{
			return _isFocused;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function onSentVoicePressedCallback(callback:Function):void 
		{
			onSentVoicePressedFunction = callback;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function onSmileStickerPressedCallback(callback:Function):void 
		{
			onSmileStickerPressedFunction = callback;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function onAttachPressedCallback(callback:Function):void 
		{
			onAttachPressedFunction = callback;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function updateButtonsOnAttachPressed(stickerMenu:int):void 
		{
			lastStickerMenu = stickerMenu;
			var btnOffsetH:int;
			var btnOffsetV:int;
			if (stickerMenu == 1 || stickerMenu == 3) {
				btnOffsetH = trueHeight * .25;
				smileStickerBtn.setBitmapData(bmdSmile);
				smileStickerBtn.y = attachBtn.y;
				smileStickerBtn.setOverflow(btnOffsetH, btnOffsetH + Config.FINGER_SIZE_DOT_25, btnOffsetH, btnOffsetH);
			} else if (stickerMenu == 2 || stickerMenu == 0) {
				smileStickerBtn.setBitmapData(bmdSticker);
				btnOffsetV = int((trueHeight - smileStickerBtn.height) * .5);
				btnOffsetH = int((trueHeight - smileStickerBtn.width) * .5);
				smileStickerBtn.y = int(inputH - smileStickerBtn.height - btnOffsetV);
				smileStickerBtn.setOverflow(btnOffsetV, btnOffsetH + Config.FINGER_SIZE_DOT_25, btnOffsetH, btnOffsetV);
			}
			smileStickerBtn.x = Config.MARGIN + btnOffsetH;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function updateButtonsOnSmileStickerPressed(stickerMenu:int):void 
		{
			lastStickerMenu = stickerMenu;
			var btnOffsetH:int;
			var btnOffsetV:int;
			if (stickerMenu == 0 || stickerMenu == 1) {
				btnOffsetH = trueHeight * .25;
				smileStickerBtn.setBitmapData(bmdSmileColor);
				smileStickerBtn.y = attachBtn.y;
				smileStickerBtn.setOverflow(btnOffsetH, btnOffsetH + Config.FINGER_SIZE_DOT_25, btnOffsetH, btnOffsetH);
			} else {
				smileStickerBtn.setBitmapData(bmdSticker);
				btnOffsetV = int((trueHeight - smileStickerBtn.height) * .5);
				btnOffsetH = int((trueHeight - smileStickerBtn.width) * .5);
				smileStickerBtn.y = int(inputH - smileStickerBtn.height - btnOffsetV);
				smileStickerBtn.setOverflow(btnOffsetV, btnOffsetH + Config.FINGER_SIZE_DOT_25, btnOffsetH, btnOffsetV);
			}
			smileStickerBtn.x = Config.MARGIN + btnOffsetH;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function onRemoveFocusCallback(callback:Function):void 
		{
			removeFocusFunction = callback;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function onSentPressedCallback(callback:Function):void 
		{
			onSentPressedFunction = callback;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function clearInput():void 
		{
			lblInput.visible = true;
			tf.text = "";
			tf.defaultTextFormat = ta;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function setKeyboardHaight(keyboardHeight:int):void 
		{
			this.keyboardHeight = keyboardHeight;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function onInputChangedCallback(callback:Function):void 
		{
			onInputChangedFunction = callback;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function show(defaultText:String):void 
		{
			
		}
		
		public function setY(value:int):void 
		{
			
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function onPositionChangedCallback(callback:Function):void 
		{
			
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function getKeyboardHeight():int 
		{
			return SoftKeyboard.detectedKeyboardHeight;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function hide():void 
		{
			
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function showBackground():void 
		{
			
		}
		
		public function hideBackground():void 
		{
			
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function getStartHeight():int 
		{
			return inputH;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function hideStickersButton():void 
		{
			
		}
		
		public function hideAttachButton():void 
		{
			
		}
		
		public function disableVoiceRecord():void 
		{
			
		}
		
		public function setLeftPadding(valu:int):void 
		{
			
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function movoToBottom():void 
		{
			
		}
		
		private function onTFMouseDown(e:MouseEvent):void {
			drawSmiles();
		}
		
		private function onTFMouseUp(e:MouseEvent):void {
			var index:int = tf.caretIndex - 1;
			if (index >= 0 && index < tf.text.length) {
				var code:int = tf.text.charCodeAt(index)
				if (code == 55356 || code == 55357 || code == 55358) {
					tf.setSelection(index, index);
				}
			}
			drawSmiles();
		}
		
		private function onTextFieldScroll(e:Event):void {
			drawSmiles();
		}
		
		protected function onChanged(e:Event = null):void {
			if (tf.text == "") {
				tf.defaultTextFormat = ta;
				lblInput.visible = true;
				sendBtnVoice.visible = true;
			} else {
				sendBtnVoice.visible = false;
				if (tf.caretIndex != 0)
					if (tf.text.charAt(tf.caretIndex - 1) != "—" && (tf.getTextFormat(tf.caretIndex - 1, tf.caretIndex).size as Number) != (ta.size as Number))
						tf.setTextFormat(ta, tf.caretIndex - 1, tf.caretIndex);
				lblInput.visible = false;
			}
			//!TODO: перенести функционал
			if (onInputChangedFunction) {
				onInputChangedFunction.call();
			}
		}
		
		private function drawCursor():void {
			if (cursor == null || tf == null)
				return;
			cursor.x = tf.x;
			cursor.y = tf.y;
			var index:int = tf.caretIndex;
			var rect:Rectangle = tf.getCharBoundaries(index);
			if (rect == null) {
				if (index > 0) {
					rect = tf.getCharBoundaries(index - 1);
					if (rect == null) {
						// new line
						cursor.y = tf.height - lineH;
						return;
					}
					cursor.x += rect.x+rect.width;
					cursor.y += rect.y;
					cursor.height = rect.height;
				}
				return;
			}
			cursor.x += rect.x;
			cursor.y += rect.y;
			cursor.height = rect.height;
		}
		
		private function drawSmiles():void {
			drawCursor();
			
			//compare old txt hashsumm with new one
			var txt:String = tf.text;
			if (smilesShape.bitmapData == null || smilesShape.bitmapData.width != tf.width || smilesShape.bitmapData.height != tf.height) {
				if (smilesShape.bitmapData != null)
					smilesShape.bitmapData.dispose();
				smilesShape.bitmapData = new ImageBitmapData("ChatInputAndroid.drawSmiles", tf.width, tf.height, true, 0);
			} else
				smilesShape.bitmapData.fillRect(smilesShape.bitmapData.rect, 0);
			
			var l:int = txt.length;
			var charRect:Rectangle;
			
			var dummy:Sprite = new Sprite();
			dummy.graphics.beginFill(0xFFFFFF,1);
			dummy.graphics.drawRect(0, 0, 10, 10);
			
			var matrix:Matrix = new Matrix();
			var tfa:TextFormat;
			var code:uint;
			
			// detect smiles
			var smilesExist:Boolean = false;
			for (var n:int = 0; n < l; n++) {
				code = 0;
				if (txt.charAt(n) == "—") {
					tfa = tf.getTextFormat(n, n + 1);
					if (tfa.color != textColor && tfa.color != 0 && tfa.color != 0xFFFFFF)
						code = tfa.color as uint;
				}
				if (code == 0)
					continue;
				smilesExist = true;
				var smileBmp:Bitmap = null;
				// need to get char position
				charRect = tf.getCharBoundaries(n);
				if (charRect == null)
					continue;
				var y:int = charRect.y;
				var w:int = charRect.width;
				
				matrix.identity();
				matrix.scale(w / 10, charRect.height / 10);
				matrix.tx = charRect.x;
				matrix.ty = y;
				smilesShape.bitmapData.draw(dummy, matrix);
				
				var bmd:BitmapData = RichTextSmilesCodes.getSmileByCode(code.toString(16));
				var sfh:Number = (w - 2) / bmd.height;
				matrix.identity();
				matrix.scale((w-2) / bmd.width, sfh);
				matrix.tx = charRect.x;
				matrix.ty = y + ((charRect.height - bmd.height * sfh) * .5);
				smilesShape.bitmapData.drawWithQuality(bmd, matrix, null, null, null, true, StageQuality.HIGH);
			}
			if (smilesExist)
				sendBtnVoice.visible = false;
			else if(tf.text == "")
				sendBtnVoice.visible = true;
			smilesShape.smoothing = true;
		}
	}
}