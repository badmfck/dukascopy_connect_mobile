package com.dukascopy.connect.screens {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.photoGaleryManager.PhotoGaleryManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class ParanoicScreen extends BaseScreen {
		
		private var textLock:String = Lang.addPinCode.toUpperCase();//"ADD PIN CODE";
		private var textUnlock:String = Lang.removePinCode.toUpperCase();//"REMOVE PIN CODE";
		
		private var iconLock:ImageBitmapData;
		private var iconUnlock:ImageBitmapData;
		
		private var btnLock:Sprite;
		private var btnUnlock:Sprite;
		private var tfInfo:TextField;
		
		public function ParanoicScreen() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			var rect:Rectangle = new Rectangle(0, 0, 100, 100);
			var ct:ColorTransform = new ColorTransform();
			ct.color = 0xFFFFFF;
			
			var tmp:BitmapData = Assets.getAsset(Assets.ICON_LOCK).clone();
			iconLock = new ImageBitmapData("iconLock", 100, 100);
			iconLock.copyBitmapData(tmp);
			iconLock.colorTransform(rect, ct);
			
			tmp = Assets.getAsset(Assets.ICON_UNLOCK).clone();
			iconUnlock = new ImageBitmapData("iconUnlock", 100, 100);
			iconUnlock.copyBitmapData(tmp);
			iconUnlock.colorTransform(rect, ct);
			tmp = null;
			
			ct = null;
			rect = null;
			
			var round:int = Config.FINGER_SIZE * .3;
			
			btnLock = new Sprite();
			btnLock.graphics.clear();
			btnLock.graphics.beginFill(AppTheme.RED_MEDIUM);
			btnLock.graphics.drawRoundRect(0, 0, 150, 150, round, round);
			btnLock.graphics.endFill();
			ImageManager.drawGraphicImage(btnLock.graphics, 25, 25, 100, 100, iconLock, ImageManager.SCALE_INNER_PROP);
			_view.addChild(btnLock);
			
			btnUnlock = new Sprite();
			btnUnlock.graphics.clear();
			btnUnlock.graphics.beginFill(AppTheme.RED_MEDIUM);
			btnUnlock.graphics.drawRoundRect(0, 0, 150, 150, round, round);
			btnUnlock.graphics.endFill();
			ImageManager.drawGraphicImage(btnUnlock.graphics, 25, 25, 100, 100, iconUnlock, ImageManager.SCALE_INNER_PROP);
			_view.addChild(btnUnlock);
			
			var tf:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * 0.3, 0x5D5552);
			tf.align = TextFormatAlign.CENTER;
			tfInfo = new TextField();
			tfInfo.defaultTextFormat = tf;
			tfInfo.x = Config.DOUBLE_MARGIN;
			tfInfo.y = Config.DOUBLE_MARGIN;
			tfInfo.mouseEnabled = false;
			tfInfo.selectable = false;
			tfInfo.multiline = false;
			tfInfo.wordWrap = false;
			_view.addChild(tfInfo);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			btnLock.visible = false;
			btnUnlock.visible = false;
			
			if (ChatManager.currentChat != null && ChatManager.currentChat.locked == true) {
				tfInfo.text = textUnlock;
				btnUnlock.visible = true;
			} else {
				tfInfo.text = textLock;
				btnLock.visible = true;
			}
		}
		
		
		override protected function drawView():void {
			_view.graphics.clear();
			
			var trueY:int = (_height - 150) * .5;
			var trueX:int = (_width - 150) * 0.5;
			
			btnLock.y = btnUnlock.y = trueY;
			btnLock.x = btnUnlock.x = trueX;
			
			tfInfo.width = _width - Config.DOUBLE_MARGIN * 2;
		}
		
		override public function activateScreen():void {
			PointerManager.addTap(btnLock, onLockTap);
			PointerManager.addTap(btnUnlock, onUnlockTap);
		}
		
		override public function deactivateScreen():void {
			PointerManager.removeTap(btnLock, onLockTap);
			PointerManager.removeTap(btnUnlock, onUnlockTap);
		}
		
		private function onLockTap(...rest):void {
			//trace("onLockTap: " + ChatManager.currentChat.pin);
			DialogManager.showPin(function(val:int, pin:String):void {
				if (val != 1)
					return;
				if (pin.length == 0)
					return;
				TweenMax.delayedCall(1, function():void {
					echo("ParanoicScreen","onLockTap", "TweenMax.delayedCall");
					ChatManager.addPin(pin);
				}, null, true);
				btnLock.visible = false;
				btnUnlock.visible = true;
				tfInfo.text = textUnlock;
				//trace("onLockTap-1: " + ChatManager.currentChat.pin);
			});
		}
		
		private function onUnlockTap(...rest):void {
			//trace("onUnlockTap: " + ChatManager.currentChat.pin);
			DialogManager.alert(Lang.textAttention, Lang.areYouSureRemovePin, function(val:int):void {
				if (val != 1)
					return;
				ChatManager.removePin();
				btnLock.visible = true;
				btnUnlock.visible = false;
				tfInfo.text = textLock;
				//trace("onUnlockTap-1: " + ChatManager.currentChat.pin);
			}, Lang.textOk, Lang.textCancel);
		}
		
		override public function dispose():void {
			_view.graphics.clear();
			btnLock.graphics.clear();
			btnUnlock.graphics.clear();
			iconLock.dispose();
			iconLock.dispose();
			super.dispose();
		}
	}
}