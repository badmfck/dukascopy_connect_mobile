package com.dukascopy.connect.screens.chat.video 
{
	import assets.HanguotIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.call.IProgressIndicator;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ChatMessagePanel extends Sprite implements IProgressIndicator
	{
		private var background:flash.display.Sprite;
		private var text:flash.display.Bitmap;
		private var hangoutButton:com.dukascopy.connect.gui.menuVideo.BitmapButton;
		private var hangoutCallback:Function;
		private var currentSize:Point;
		
		public function ChatMessagePanel(hangoutCallback:Function) 
		{
			this.hangoutCallback = hangoutCallback;
			create();
		}
		
		public function draw(size:Point, message:String):void
		{
			currentSize = size;
			if (text.bitmapData != null)
			{
				text.bitmapData.dispose();
				text.bitmapData = null;
			}
			
			text.bitmapData = TextUtils.createTextFieldData(
															message, 
															size.x - Config.DIALOG_MARGIN*2 - hangoutButton.width - Config.MARGIN - Config.DIALOG_MARGIN, 
															10, 
															true, 
															TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .32, 
															true, 
															Style.color(Style.COLOR_SUBTITLE), 
															Style.color(Style.COLOR_BACKGROUND), false, true);
			text.x = Config.DIALOG_MARGIN;
			text.y = int(Config.FINGER_SIZE * .3);
			
			background.graphics.clear();
			background.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			background.graphics.drawRect(0, 0, size.x, Math.max(int(text.height + Config.FINGER_SIZE * .6), size.y));
			background.graphics.endFill();
			
			background.graphics.lineStyle(1, Style.color(Style.COLOR_SUBTITLE));
			background.graphics.moveTo(0, background.height);
			background.graphics.lineTo(size.x, background.height);
			
			hangoutButton.x = int(size.x - Config.DIALOG_MARGIN * 0.7 - hangoutButton.width);
			hangoutButton.y = int(background.height * .5 - hangoutButton.height * .5);
			
			text.y = int(background.height * .5 - text.height * .5);
		}
		
		private function create():void 
		{
			background = new Sprite();
			addChild(background);
			
			text = new Bitmap();
			addChild(text);
			
			hangoutButton = new BitmapButton();
			hangoutButton.setStandartButtonParams();
			hangoutButton.setOverflow(Config.MARGIN, Config.MARGIN, Config.MARGIN, Config.MARGIN);
			hangoutButton.usePreventOnDown = false;
			hangoutButton.tapCallback = hanguot;
			hangoutButton.cancelOnVerticalMovement = true;
			var icon:HanguotIcon = new HanguotIcon();
			UI.scaleToFit(icon, Config.FINGER_SIZE * .36, Config.FINGER_SIZE * .36);
			hangoutButton.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "ChatMessagePanel.button"));
			addChild(hangoutButton);
		}
		
		private function hanguot():void 
		{
			if (hangoutCallback != null)
			{
				hangoutCallback.call();
			}
		}
		
		public function dispose():void
		{
			UI.destroy(text);
			UI.destroy(background);
			hangoutButton.dispose();
			
			text = null;
			background = null;
			hangoutButton = null;
			
			hangoutCallback = null;
		}
		
		public function activate():void 
		{
			hangoutButton.activate();
		}
		
		public function deactivate():void 
		{
			hangoutButton.deactivate();
		}
		
		
		/* INTERFACE com.dukascopy.connect.screens.call.IProgressIndicator */
		
		public function setSize(width:int, height:int):void 
		{
			
		}
		
		public function setStepsCount(totalVideoRecognitionStates:int):void 
		{
			
		}
		
		public function selectStep(step:Number, animate:Boolean):void 
		{
			var text:String = "";
			if (step == 1)
			{
				text = "1. " + Lang.documentPhoto;
			}
			else if (step == 2)
			{
				text = "2. " + Lang.idCardMrz;
			}
			else if (step == 3)
			{
				text = "3. " + Lang.makeSelfie;
			}
			
			draw(currentSize, text);
		}
	}
}