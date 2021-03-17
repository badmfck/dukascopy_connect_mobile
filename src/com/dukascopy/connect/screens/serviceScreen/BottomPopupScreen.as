package com.dukascopy.connect.screens.serviceScreen {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.PopupData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power2;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class BottomPopupScreen extends BaseScreen {
		
		private var background:Sprite;
		private var nextButton:BitmapButton;
		private var screenData:PopupData;
		private var illustration:Bitmap;
		private var text:Bitmap;
		private var title:Bitmap;
		private var container:Sprite;
		private var firstTime:Boolean = true;
		private var needExecute:Boolean;
		
		public function BottomPopupScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			if (data != null && data is PopupData) {
				screenData = data as PopupData;
			} else {
				ServiceScreenManager.closeView();
				return;
			}
			_params.doDisposeAfterClose = true;
			background.graphics.beginFill(0x000000, 0.35);
			background.graphics.drawRect(0, 0, _width, _height);
			createButton();
			createIllustration();
			createTitle();
			createText();
			var position:int = 0;
			if (illustration.height > 0) {
				illustration.y = position;
				illustration.x = int(_width * .5 - illustration.width * .5);
				position += illustration.height + Config.FINGER_SIZE * .3;
			} else {
				position += Config.FINGER_SIZE * .5;
			}
			if (title.height > 0) {
				title.y = position;
				title.x = int(_width * .5 - title.width * .5);
				position += title.height + Config.FINGER_SIZE * .15;
			}
			if (text.height > 0) {
				text.y = position;
				text.x = int(_width * .5 - text.width * .5);
				position += text.height + Config.FINGER_SIZE * .4;
			}
			nextButton.y = position;
			nextButton.x = int(_width * .5 - nextButton.width * .5);
			position += nextButton.height + Config.FINGER_SIZE * .6;
			position += Config.APPLE_BOTTOM_OFFSET;
			container.graphics.beginFill(0xFFFFFF);
			var startPosition:int = 0;
			if (illustration.height > 0) {
				position -= illustration.height * .5;
				startPosition = int(illustration.height * .5);
			}
			container.graphics.drawRect(0, startPosition, _width, position);
			container.graphics.endFill();
			container.y = _height;
			background.alpha = 0;
		}
		
		private function createIllustration():void {
			if (screenData.illustration != null) {
				try {
					var clip:Sprite = new screenData.illustration() as Sprite;
					if (clip != null) {
						var size:int = Config.FINGER_SIZE * 2.6;
						UI.scaleToFit(clip, size, size);
						illustration.bitmapData = UI.getSnapshot(clip, StageQuality.HIGH, "BottomPopupScreen.illustration", true);
					}
				} catch (e:Error) {
					ApplicationErrors.add();
				}
			}
		}
		
		private function createTitle():void {
			if (screenData.title != null) {
				title.bitmapData = TextUtils.createTextFieldData(
					screenData.title,
					_width - Config.DIALOG_MARGIN * 4,
					10,
					true,
					TextFormatAlign.CENTER,
					TextFieldAutoSize.LEFT,
					int(Config.FINGER_SIZE * .42),
					true,
					0x596269,
					0xFFFFFF
				);
			}
		}
		
		private function createText():void {
			if (screenData.text != null) {
				text.bitmapData = TextUtils.createTextFieldData(
					screenData.text,
					_width - Config.DIALOG_MARGIN * 4,
					10,
					true,
					TextFormatAlign.CENTER,
					TextFieldAutoSize.LEFT,
					int(Config.FINGER_SIZE * .3),
					true,
					0x596269,
					0xFFFFFF
				);
			}
		}
		
		private function createButton():void {
			var text:String;
			if (screenData.action != null && screenData.action.getData() != null && screenData.action.getData() is String) {
				text = screenData.action.getData() as String;
			} else {
				text = Lang.close;
			}
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x77C043, 1, Config.FINGER_SIZE * .8, NaN);
			nextButton.setBitmapData(buttonBitmap);
		}
		
		override protected function createView():void {
			super.createView();
			
			background = new Sprite();
			view.addChild(background);
			
			container = new Sprite();
			view.addChild(container);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			container.addChild(nextButton);
			
			illustration = new Bitmap();
			container.addChild(illustration);
			
			title = new Bitmap();
			container.addChild(title);
			
			text = new Bitmap();
			container.addChild(text);
		}
		
		private function nextClick():void {
			needExecute = true;
			close();
		}
		
		override protected function drawView():void {
			super.drawView();
			view.graphics.clear();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			super.dispose();
			TweenMax.killTweensOf(container);
			TweenMax.killTweensOf(background);
			if (background != null)
				UI.destroy(background);
			background = null;
			if (nextButton != null)
				nextButton.dispose();
			nextButton = null;
			if (title != null)
				UI.destroy(title);
			nextButton = null;
			if (text != null)
				UI.destroy(text);
			text = null;
			if (illustration != null)
				UI.destroy(illustration);
			illustration = null;
			if (container != null)
				UI.destroy(container);
			container = null;
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			if (firstTime) {
				firstTime = false;
				TweenMax.to(container, 0.3, { y:int(_height - container.height), ease:Power2.easeOut } );
				TweenMax.to(background, 0.3, { alpha:1 } );
			}
			PointerManager.addTap(background, close);
			nextButton.activate();
		}
		
		private function close(e:Event = null):void {
			deactivateScreen();
			TweenMax.to(container, 0.3, { y:_height, onComplete:remove, ease:Power2.easeIn } );
			TweenMax.to(background, 0.3, { alpha:0 } );
		}
		
		private function remove():void {
			ServiceScreenManager.closeView();
			if (needExecute == true && screenData.action != null) {
				needExecute = false;
				screenData.action.execute();
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			PointerManager.removeTap(background, close);
			nextButton.deactivate();
		}
	}
}