package com.dukascopy.connect.sys.speechControl 
{
	import assets.IconMicOn;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.voiceCommand.VoiceCommand;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SpeechControl 
	{
		private var button:Bitmap;
		private var view:Sprite;
		private var width:int;
		private var height:int;
		private var buttonContainer:Sprite;
		private var recognizer:com.dukascopy.connect.sys.speechControl.CommandRecognizer;
		
		public function SpeechControl(view:Sprite, width:int, height:int) 
		{
			this.view = view;
			this.width = width;
			this.height = height;
			addButton();
			NativeExtensionController.S_SPEECH.add(onSpeechResult);
		}
		
		private function onSpeechResult(text:String):void 
		{
			ToastMessage.display(text);
			
			if (text != null)
			{
				var items:Array = text.split(" ");
				if (items != null && items.length > 0)
				{
					var command:VoiceCommand = getRecognizer().recognize(items);
					if (command != null)
					{
						BankManager.processCommand(command);
					}
				}
			}
		}
		
		private function getRecognizer():CommandRecognizer 
		{
			if (recognizer == null)
			{
				recognizer = new CommandRecognizer();
			}
			return recognizer;
		}
		
		private function addButton():void 
		{
			buttonContainer = new Sprite();
			button = new Bitmap();
			buttonContainer.addChild(button);
			
			var icon:IconMicOn = new IconMicOn();
			UI.scaleToFit(icon, Config.FINGER_SIZE * 1, Config.FINGER_SIZE * 1.5);
			button.bitmapData = UI.getSnapshot(icon);
			UI.destroy(icon);
			icon = null;
			
			view.addChild(buttonContainer);
			
			buttonContainer.x = width - Config.FINGER_SIZE * 1 - Config.MARGIN * 2,  
			buttonContainer.y = height - button.height - Config.FINGER_SIZE*.35;
			
			activate();
		}
		
		public function activate():void
		{
			PointerManager.addDown(buttonContainer, startListen);
		}
		
		public function deactivate():void
		{
			PointerManager.removeDown(buttonContainer, startListen);
			PointerManager.removeUp(buttonContainer, stopListen);
		}
		
		private function startListen(e:Event = null):void 
		{
			PointerManager.addUp(buttonContainer, stopListen);
			NativeExtensionController.listenSpeech();
		}
		
		private function stopListen(e:Event = null):void 
		{
			PointerManager.removeUp(buttonContainer, stopListen);
			NativeExtensionController.stopListenSpeech();
		}
		
		public function dispose():void
		{
			NativeExtensionController.S_SPEECH.remove(onSpeechResult);
			if (button != null)
			{
				UI.destroy(button);
				button = null;
			}
		}
	}
}