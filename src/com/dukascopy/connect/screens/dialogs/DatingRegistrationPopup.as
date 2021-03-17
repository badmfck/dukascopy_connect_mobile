package com.dukascopy.connect.screens.dialogs {
	
	import assets.CloseButtonIcon;
	import assets.stiker.Stiker_198;
	import assets.stiker.Stiker_210;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.topBar.TopBarDialog;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class DatingRegistrationPopup extends BaseScreen {
		
		static public const ACCEPT_CODE:int = 1;
		
		protected var container:Sprite;
		private var bg:Shape;
		private var buttonClose:BitmapButton;
		private var image:Bitmap;
		private var title:Bitmap;
		private var text:Bitmap;
		private var acceptButton:BitmapButton;
		private var acceptCallback:Function;
		
		protected var componentsWidth:int;
		
		public function DatingRegistrationPopup() {
			
		}
		
		override protected function createView():void {
			super.createView();
			container = new Sprite();
			
				bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGRIUND));
				var round:int = Config.FINGER_SIZE * .3;
				var round3:int = round * 3;
			//	bg.graphics.drawRoundRect(0, 0, round3, round3, round, round);
				bg.graphics.drawRect(0, 0, round3, round3);
				bg.scale9Grid = new Rectangle(round, round, round, round);
			container.addChild(bg);
			
			image = new Bitmap();
			image.smoothing = true;
			container.addChild(image);
			
			var imageSource:Sprite = new Stiker_198();
			UI.scaleToFit(imageSource, Config.FINGER_SIZE * 2.7, Config.FINGER_SIZE * 2.7);
			
			image.bitmapData = UI.getSnapshot(imageSource, StageQuality.HIGH, "DatingRegistrationPopup.image");
			UI.destroy(imageSource);
			imageSource = null;
			
			title = new Bitmap();
			container.addChild(title);
			
			text = new Bitmap();
			container.addChild(text);
			
			buttonClose = new BitmapButton();
			buttonClose.setStandartButtonParams();
			buttonClose.setDownScale(1.3);
			buttonClose.setDownColor(0xFFFFFF);
			buttonClose.tapCallback = closeClick;
			buttonClose.disposeBitmapOnDestroy = true;
			
			var iconClose:Sprite = new CloseButtonIcon();
			var hh:int = Config.FINGER_SIZE * .4;
			iconClose.width = hh;
			iconClose.height = hh;
			buttonClose.setBitmapData(UI.getSnapshot(iconClose, StageQuality.HIGH, "DatingRegistrationPopup - iconClose"), true);
			var vv:int = (Config.FINGER_SIZE - hh) * .5;
			buttonClose.setOverflow(Config.DIALOG_MARGIN, vv, vv, Config.DIALOG_MARGIN);
			UI.destroy(iconClose);
			iconClose = null;
			
			container.addChild(buttonClose);
			
			acceptButton = new BitmapButton();
			acceptButton.setStandartButtonParams();
			acceptButton.setDownScale(1);
			acceptButton.setDownColor(0);
			acceptButton.tapCallback = acceptClick;
			acceptButton.disposeBitmapOnDestroy = true;
			
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textRegister, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x81CA2E, 1, Config.FINGER_SIZE * .8);
			acceptButton.setBitmapData(buttonBitmap);
			container.addChild(acceptButton);
			
			container.addChild(buttonClose);
			
			_view.addChild(container);
		}
		
		private function closeClick():void 
		{
			DialogManager.closeDialog();
		}
		
		private function acceptClick():void 
		{
			if (acceptCallback != null)
			{
				acceptCallback(ACCEPT_CODE);
			}
			DialogManager.closeDialog();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
			buttonClose.x = _width - buttonClose.width - Config.MARGIN * 2;
			buttonClose.y = Config.MARGIN * 2;
			
			title.bitmapData = TextUtils.createTextFieldData(
															Lang.dating911, 
															componentsWidth, 
															10, 
															false, 
															TextFormatAlign.CENTER, 
															TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .41, 
															false, 
															0x81CA2E, 
															0xffffff, 
															false);
			
			title.x = int(_width * .5 - title.width * .5);
			
			text.bitmapData = TextUtils.createTextFieldData(
															Lang.needRegister, 
															componentsWidth, 
															10, 
															true, 
															TextFormatAlign.CENTER, 
															TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .3, 
															true, 
															0x84AABA, 
															0xffffff, 
															false);
			
			text.x = int(_width * .5 - text.width * .5);
			
			image.x = int(_width * .5 - image.width * .5);
			
			acceptButton.x = int(_width * .5 - acceptButton.width * .5);
			
			if (data != null && "callback" in data && data.callback != null && data.callback is Function)
			{
				acceptCallback = data.callback;
			}
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			bg.width = _width;
			
			var verticalMargin:int = Config.MARGIN * 1.5;
			
			var position:int = verticalMargin;
			
			image.y = position;
			position += image.height + verticalMargin;
			
			title.y = position;
			position += title.height + verticalMargin;
			
			text.y = position;
			position += text.height + verticalMargin * 1.8;
			
			acceptButton.y = position;
			position += acceptButton.height + verticalMargin * 1.8;
			
			bg.height = position;
			
			container.y = int((_height - bg.height) * .5);
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			buttonClose.activate();
			acceptButton.activate();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			buttonClose.deactivate();
			acceptButton.deactivate();
		}
		
		protected function onCloseTap():void {
			DialogManager.closeDialog();
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			super.dispose();
			
			if (buttonClose != null)
			{
				buttonClose.dispose();
				buttonClose = null;
			}
			
			if (acceptButton)
			{
				acceptButton.dispose();
				acceptButton = null;
			}
			
			if (image)
			{
				UI.destroy(image);
				image = null;
			}
			
			if (text)
			{
				UI.destroy(text);
				text = null;
			}
			
			if (title)
			{
				UI.destroy(title);
				title = null;
			}
			
			if (bg)
			{
				UI.destroy(bg);
				bg = null;
			}
			
			acceptCallback = null;
			
			container = null;
		}
	}
}