package com.dukascopy.connect.gui.videoStreaming 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class StreamControls extends Sprite
	{
		private var area:Rectangle;
		
		private var stopButton:BitmapButton;
		private var pauseButton:BitmapButton;
		private var startButton:BitmapButton;
		private var resumeButton:BitmapButton;
		private var switchButton:BitmapButton;
		
		private var onStartCallback:Function;
		private var onStopCallback:Function;
		private var onResumeCallback:Function;
		private var onPauseCallback:Function;
		
		public function StreamControls(area:Rectangle,
										onStart:Function,
										onStop:Function,
										onResume:Function,
										onPause:Function) 
		{
			this.area = area;
			
			this.onStartCallback = onStart;
			this.onStopCallback = onStop;
			this.onResumeCallback = onResume;
			this.onPauseCallback = onPause;
			
			create();
		}
		
		private function create():void 
		{
			pauseButton = createButton(pauseClick);
			stopButton = createButton(stopClick);
			startButton = createButton(startClick);
			resumeButton = createButton(resumeClick);
			switchButton = createButton(switchClick);
			
			
			var textSettings_start:TextFieldSettings = new TextFieldSettings(Lang.startVideoStream, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap_start:ImageBitmapData = TextUtils.createbutton(textSettings_start, 0xCD3F43, 1, Config.FINGER_SIZE * .8, NaN);
			startButton.setBitmapData(buttonBitmap_start, true);
			startButton.x = int(area.width * .5 - startButton.width * .5);
			startButton.y = area.y + Config.DIALOG_MARGIN + Config.FINGER_SIZE * .6;
			
			
			var textSettings_stop:TextFieldSettings = new TextFieldSettings(Lang.stopVideoStream, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap_stop:ImageBitmapData = TextUtils.createbutton(textSettings_stop, 0xCD3F43, 1, Config.FINGER_SIZE * .8, NaN);
			stopButton.setBitmapData(buttonBitmap_stop, true);
			stopButton.x = int(area.width * .5 - stopButton.width * .5);
			stopButton.y = area.y + Config.DIALOG_MARGIN + Config.FINGER_SIZE * .6;
			
		//	startButton.show();
		//	stopButton.hide();
			
			startButton.hide();
			stopButton.hide();
			stopButton.show(0.5, 2, true, 0.9, 0);
			
			activate();
		}
		
		private function test():void 
		{
			MobileGui.stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void 
		{
			e.target.y += 100;
		}
		
		private function createButton(callback:Function):BitmapButton 
		{
			var button:BitmapButton = new BitmapButton();
			button.setStandartButtonParams();
			button.setDownScale(1);
			button.setDownColor(0);
			button.tapCallback = callback;
			button.disposeBitmapOnDestroy = true;
			addChild(button);
			return button;
		}
		
		public function activate():void
		{
			startButton.activate();
			pauseButton.activate();
			stopButton.activate();
			resumeButton.activate();
			switchButton.activate();
		}
		
		public function deactivate():void
		{
			startButton.deactivate();
			pauseButton.deactivate();
			stopButton.deactivate();
			resumeButton.deactivate();
			switchButton.deactivate();
		}
		
		public function dispose():void 
		{
			if (startButton != null)
			{
				startButton.dispose();
				startButton = null;
			}
			if (pauseButton != null)
			{
				pauseButton.dispose();
				pauseButton = null;
			}
			if (stopButton != null)
			{
				stopButton.dispose();
				stopButton = null;
			}
			if (resumeButton != null)
			{
				resumeButton.dispose();
				resumeButton = null;
			}
			if (switchButton != null)
			{
				switchButton.dispose();
				switchButton = null;
			}
		}
		
		private function switchClick():void 
		{
			
		}
		
		private function resumeClick():void 
		{
			
		}
		
		private function startClick():void 
		{
			if (onStartCallback != null)
			{
				onStartCallback();
			}
			
			startButton.hide();
			stopButton.show();
		}
		
		private function stopClick():void 
		{
			if (onStartCallback != null)
			{
				onStopCallback();
			}
		}
		
		private function pauseClick():void 
		{
			
		}
	}
}