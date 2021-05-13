package com.dukascopy.connect.gui.chatInput
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.greensock.TweenMax;
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.StatusEvent;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class InputPanelAndroid extends Sprite implements IInputPanel
	{
		private var onSentPressedFunction:Function;
		private var onAttachPressedFunction:Function;
		private var onSentVoicePressedFunction:Function;
		private var onSmileStickerPressedFunction:Function;
		private var onPositionChangedFunction:Function;
		private var lastPosition:int;
		private var keyboardHeight:int = -1;
		private var bg:Bitmap;
		private var shown:Boolean;
		private var onSoftKeyboardActivateFunction:Function;
		private var onSoftKeyboardDeactivateFunction:Function;
		private static var inputDefaultBitmap:BitmapData;
		
		static public const SHOW_INPUT:String = "showInput";
		static public const ATTACH_INPUT:String = "attachInput";
		static public const SET_POSITION:String = "setPosition";
		static public const GET_HEIGHT:String = "getHeight";
		static public const GET_INPUT_VALUE:String = "getInputValue";
		static public const CLEAR_INPUT:String = "clearInput";
		static public const REMOVE_INPUT:String = "removeInput";
		static public const SET_VALUE:String = "setValue";
		static public const DRAW_STIKER_BUTTON:String = "drawStickerButton";
		static public const DRAW_SMILE_BUTTON:String = "drawSmileButton";
		static public const HIDE:String = "hide";
		static public const GET_SNAPSHOT:String = "getSnapshot";
		static public const APPEND_TEXT:String = "appendText";
		static public const CLEAR_FOCUS:String = "removeFocus";
		static public const APPEND_SMILE:String = "addEmoji";
		static public const EREASE:String = "erease";
		static public const HIDE_ATTACH_BUTTON:String = "hideAttachButton";
		static public const HIDE_STICKERS_BUTTON:String = "hideStickersButton";
		static public const SET_LEFT_PADDING:String = "setLeftMargin";
		static public const DISABLE_VOICE_RECORD:String = "disableVoiceRecord";
		
		public function InputPanelAndroid()
		{
			if (Config.PLATFORM_ANDROID)
			{
				addNativeSideListeners();
				MobileGui.androidExtension.callChatInput(ATTACH_INPUT);
			}
			shown = true;
			bg = new Bitmap();
			addChild(bg);
			
			redrawScreenshot();
			hide();
			showBackground();
		}
		
		private function addNativeSideListeners():void
		{
			if (Config.PLATFORM_ANDROID)
			{
				MobileGui.androidExtension.addEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			}
		}
		
		public function redrawScreenshot(anyway:Boolean = false):void
		{
			if (shown == true || anyway == true)
			{
				//безусловно делаем новый скриншот инпута в текущем состоянии;
				var newImage:BitmapData = MobileGui.androidExtension.callChatInput(GET_SNAPSHOT) as BitmapData;
				
				var image:BitmapData;
				
				if (newImage != null)
				{
					if (inputDefaultBitmap == null)
					{
						inputDefaultBitmap = newImage.clone();
					}
					image = newImage;
					
				}
				else if (inputDefaultBitmap != null)
				{
					image = inputDefaultBitmap.clone();
				}
				if (image != null)
				{
					if (bg.bitmapData)
					{
						bg.bitmapData.dispose();
						bg.bitmapData = null;
					}
					bg.bitmapData = image;
				}
			}
		}
		
		private function extensionAndroidStatusHandler(e:StatusEvent):void
		{
			if (e.code == "inputAndroid")
			{
				
				var args:Object;
				try
				{
					args = JSON.parse(e.level);
				}
				catch (e:Error)
				{
					
				}
				
				if (args != null && args.hasOwnProperty("method"))
				{
					switch (args.method)
					{
					case "onSendMessageClick": 
					{
						if (onSentPressedFunction)
						{
							onSentPressedFunction(args.value);
						}
						break;
					}
					case "keyboardActivate": 
					{
						if (onSoftKeyboardActivateFunction)
						{
							onSoftKeyboardActivateFunction();
						}
						break;
					}
					case "keyboardDeactivate": 
					{
						if (onSoftKeyboardDeactivateFunction)
						{
							onSoftKeyboardDeactivateFunction();
						}
						break;
					}
					case "onRecordSoundClick": 
					{
						if (onSentVoicePressedFunction != null)
						{
							onSentVoicePressedFunction();
						}
						break;
					}
					case "onStickerButtonClick": 
					{
						if (onSmileStickerPressedFunction != null)
						{
							onSmileStickerPressedFunction();
						}
						break;
					}
					case "onSmileButtonClick": 
					{
						if (onSmileStickerPressedFunction != null)
						{
							onSmileStickerPressedFunction();
						}
						break;
					}
					case "onAttachButtonClick": 
					{
						if (onAttachPressedFunction != null)
						{
							onAttachPressedFunction();
						}
						break;
					}
					case "positionChange": 
					{
						if (lastPosition != args.value)
						{
							lastPosition = args.value;
							onPositionChangedFunction(lastPosition);
						}
						break;
					}
					case "keyboardHeight": 
					{
						keyboardHeight = int(args.value);
						break;
					}
					case "inputReady": 
					{
						redrawScreenshot(true);
						break;
					}
					}
				}
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function drawSmileButton():void
		{
			MobileGui.androidExtension.callChatInput(DRAW_SMILE_BUTTON)
		}
		
		public function drawStickerButton():void
		{
			MobileGui.androidExtension.callChatInput(DRAW_STIKER_BUTTON)
		}
		
		public function removeFocus(e:Event = null):Boolean
		{
			MobileGui.androidExtension.callChatInput(CLEAR_FOCUS);
			return true;
		}
		
		public function onKeyboardRemoved(stickerMenu:int):void
		{
		
		}
		
		public function updateView(stickerMenu:int):int
		{
			//!TODO
			var h:int = getHeight();
			return h;
		}
		
		public function onSmileSelected(smile:Array = null):void
		{
			if (smile != null && smile.length > 1)
			{
				MobileGui.androidExtension.callChatInput(APPEND_SMILE, {code: smile[0]});
			}
			else{
				MobileGui.androidExtension.callChatInput(EREASE);
			}
		}
		
		public function setTFWidth(w:int):void
		{
		
		}
		
		public function calcHeight():int
		{
			return getHeight();
		}
		
		public function getHeight():Number
		{
			if (Config.PLATFORM_ANDROID)
			{
				var h:int = MobileGui.androidExtension.callChatInput(GET_HEIGHT) as int;
				if (h == 0 && inputDefaultBitmap != null)
				{
					h = inputDefaultBitmap.height;
				}
				
				return h;
			}
			
			return 0;
		}
		
		public function activate():void
		{
		
		}
		
		public function setWidth(w:int):void
		{
		
		}
		
		public function setValue(text:String):void
		{
			if (Config.PLATFORM_ANDROID)
			{
				MobileGui.androidExtension.callChatInput(SET_VALUE, {value: text});
			}
		}
		
		public function getText():String
		{
			if (Config.PLATFORM_ANDROID)
			{
				return MobileGui.androidExtension.callChatInput(GET_INPUT_VALUE) as String;
			}
			return "";
		}
		
		public function deactivate():void
		{
		
		}
		
		public function dispose():void
		{
			TweenMax.killDelayedCallsTo(setY);
			TweenMax.killDelayedCallsTo(hideBackground);
			onSentPressedFunction = null;
			onAttachPressedFunction = null;
			onSentVoicePressedFunction = null;
			onSmileStickerPressedFunction = null;
			onPositionChangedFunction = null;
			onSoftKeyboardActivateFunction = null;
			onSoftKeyboardDeactivateFunction = null;
			
			MobileGui.androidExtension.callChatInput(REMOVE_INPUT);
			MobileGui.androidExtension.removeEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			
			UI.destroy(bg);
			bg = null;
		}
		
		public function isFocused():Boolean
		{
			//!TODO
			return true;
		}
		
		public function clearInput():void
		{
			if (Config.PLATFORM_ANDROID)
			{
				MobileGui.androidExtension.callChatInput(CLEAR_INPUT);
			}
		}
		
		public function setKeyboardHaight(keyboardHeight:int):void
		{
		
		}
		
		public function onSoftKeyboardActivatingCallback(callback:Function):void
		{
		
		}
		
		public function onPositionChangedCallback(callback:Function):void
		{
			onPositionChangedFunction = callback;
		}
		
		public function onSoftKeyboardActivateCallback(callback:Function):void
		{
			onSoftKeyboardActivateFunction = callback;
		}
		
		public function onSoftKeyboardDeactivateCallback(callback:Function):void
		{
			onSoftKeyboardDeactivateFunction = callback
		}
		
		public function onSentVoicePressedCallback(callback:Function):void
		{
			onSentVoicePressedFunction = callback;
		}
		
		public function onSmileStickerPressedCallback(callback:Function):void
		{
			onSmileStickerPressedFunction = callback;
		}
		
		public function onAttachPressedCallback(callback:Function):void
		{
			onAttachPressedFunction = callback;
		}
		
		public function updateButtonsOnAttachPressed(stickerMenu:int):void
		{
		
		}
		
		public function updateButtonsOnSmileStickerPressed(stickerMenu:int):void
		{
			if (stickerMenu == 2)
			{
				drawSmileButton();
			}
			else if (stickerMenu == 1)
			{
				drawStickerButton();
			}
		}
		
		public function onRemoveFocusCallback(callback:Function):void
		{
		
		}
		
		public function onSentPressedCallback(callback:Function):void
		{
			onSentPressedFunction = callback;
		}
		
		public function onInputChangedCallback(callback:Function):void
		{
		
		}
		
		public function show(defaultText:String):void
		{
			if (Config.PLATFORM_ANDROID)
			{
				MobileGui.androidExtension.callChatInput(SHOW_INPUT, {text:defaultText});
				TweenMax.killDelayedCallsTo(hideBackground);
				TweenMax.delayedCall(0.2, hideBackground);
			}
			shown = true;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function setY(value:int):void
		{
			TweenMax.killDelayedCallsTo(setY);
			if (value > 0)
			{
				if (Config.PLATFORM_ANDROID)
				{
					MobileGui.androidExtension.callChatInput(SET_POSITION, {position: value});
				}
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function getKeyboardHeight():int
		{
			return keyboardHeight;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function hide():void
		{
			TweenMax.killDelayedCallsTo(hideBackground);
			MobileGui.androidExtension.callChatInput(HIDE);
			if (bg != null && shown)
			{
				redrawScreenshot();
				bg.visible = true;
			}
			shown = false;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function showBackground():void
		{
			bg.visible = true;
		}
		
		public function hideBackground():void
		{
			bg.visible = false;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function getStartHeight():int 
		{
			if (inputDefaultBitmap == null)
			{
				redrawScreenshot(true);
			}
			
			if (inputDefaultBitmap != null)
			{
				return inputDefaultBitmap.height;
			}
			return 0;
		}
		
		public function hideStickersButton():void
		{
			MobileGui.androidExtension.callChatInput(HIDE_STICKERS_BUTTON)
		}
		
		public function hideAttachButton():void
		{
			MobileGui.androidExtension.callChatInput(HIDE_ATTACH_BUTTON)
		}
		
		public function setLeftPadding(value:int):void
		{
			MobileGui.androidExtension.callChatInput(SET_LEFT_PADDING, {margin:value});
		}
		
		public function disableVoiceRecord():void
		{
			MobileGui.androidExtension.callChatInput(DISABLE_VOICE_RECORD);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function showAccountButton():void 
		{
			
		}
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IInputPanel */
		
		public function movoToBottom():void 
		{
			if (MobileGui.stage != null)
			{
				TweenMax.killDelayedCallsTo(setY);
				TweenMax.delayedCall(5, setY, [MobileGui.stage.stageHeight - getStartHeight()], true);
			}
		}
	}
}