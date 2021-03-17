package com.dukascopy.connect.screens.dialogs {
	import com.dukascopy.connect.sys.echo.echo;
	import assets.CloseButtonIcon;
	import assets.IconDone;
	import com.adobe.utils.IntUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.langs.Lang;
	import com.greensock.easing.Back;
	import com.greensock.easing.Quint;
	import com.greensock.TweenMax;
	import com.telefision.shapes.ShapeBox;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ScreenNotificationDialog extends BaseScreen {
		static public const SHOW_TIME_INTERVAL:Number = 10;
		
		private var buttonClose:BitmapButton;
		private var message:Bitmap;
		private var back:Shape;
		private var serviceTextField:TextField;
		private var iconSend:Bitmap;
		private var iconDone:Bitmap;
		private var animationStarted:Boolean;
		private var container:Sprite;
		
		public function ScreenNotificationDialog() {
			super();
		}
		
		override protected function createView():void
		{
			super.createView();
			
			container = new Sprite();
			view.addChild(container);
			
			back = new Shape();
			container.addChild(back);
			
			message = new Bitmap();
			container.addChild(message);
			
			var btnSize:int = Config.FINGER_SIZE*.4;
			var btnOffset:int = (Config.FINGER_SIZE - btnSize) * .5;
			
			//close button;
			buttonClose = new BitmapButton();
			buttonClose.setStandartButtonParams();
			buttonClose.setDownScale(1.3);
			buttonClose.setDownColor(0xFFFFFF);
			buttonClose.tapCallback = onCloseTap;
			buttonClose.disposeBitmapOnDestroy = true;
			buttonClose.show();
			container.addChild(buttonClose);
			var iconClose:CloseButtonIcon = new CloseButtonIcon();
			iconClose.width = iconClose.height = btnSize;
			buttonClose.setBitmapData(UI.getSnapshot(iconClose, StageQuality.HIGH, "ScreenNotificationDialog.iconClose"), true);
			buttonClose.setOverflow(btnOffset, int(btnOffset * .6), Config.FINGER_SIZE, btnOffset);
			UI.destroy(iconClose);
			iconClose = null;
			
			var iconSendSource:IconSend = new IconSend();
			var iconDoneSource:IconDone = new IconDone();
			
			UI.scaleToFit(iconSendSource, Config.FINGER_SIZE, Config.FINGER_SIZE);
			UI.scaleToFit(iconDoneSource, Config.FINGER_SIZE, Config.FINGER_SIZE);
			
			iconSend = new Bitmap(UI.getSnapshot(iconSendSource, StageQuality.HIGH, "ScreenNotificationDialog.iconSend"));
			iconDone = new Bitmap(UI.getSnapshot(iconDoneSource, StageQuality.HIGH, "ScreenNotificationDialog.iconDone"));
			
			UI.destroy(iconSendSource);
			UI.destroy(iconDoneSource);
			iconSendSource = null;
			iconDoneSource = null;
			
			container.addChild(iconSend);
			container.addChild(iconDone);
			
			iconDone.visible = false;
			
		}
		//!TODO: copied from BitmapButton. Need to move animation functionality to some general utils class;
		public function showIcon(iconBitmap:DisplayObject, _time:Number=1, delay:Number = 0):void {
			TweenMax.killTweensOf(iconBitmap);
			
			var deltaX:Number = (iconBitmap.width) * .5;
			var deltaY:Number = (iconBitmap.height) * .5;
				
			iconBitmap.x += deltaX;
			iconBitmap.y += deltaY;
			
			iconBitmap.visible = true;
			iconBitmap.scaleX = iconBitmap.scaleY = 0;
			iconBitmap.rotation = 0;
			
			TweenMax.to(iconBitmap, _time, {rotation:0,  transformMatrix: { scaleX:1, scaleY:1, x:iconBitmap.x - deltaX, y:iconBitmap.y - deltaY }, delay:delay, ease:Back.easeOut } );
		}
		
		//!TODO: copied from BitmapButton. Need to move animation functionality to some general utils class;
		public function hideIcon(iconBitmap:DisplayObject, _time:Number=1) :void{
			TweenMax.killTweensOf(iconBitmap);
			var deltaX:Number = iconBitmap.width*.5;
			var deltaY:Number = iconBitmap.height*.5;
					
			TweenMax.to(iconBitmap, _time, {rotation:0,  transformMatrix: { scaleX:0, scaleY:0, x:iconBitmap.x + deltaX, y:iconBitmap.y + deltaY }, colorTransform:{tint:0xff0000, tintAmount:0}, ease:Quint.easeOut } );	
		}
		
		private function onCloseTap():void {
			close();
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			animationStarted = false;
			
			iconDone.visible = false;
			iconDone.alpha = 1;
			iconDone.scaleX = 1;
			iconDone.scaleY = 1;
			
			iconSend.visible = true;
			iconSend.alpha = 1;
			iconSend.scaleX = 1;
			iconSend.scaleY = 1;
		}
		
		//used to provide bitmap data with valid actual(minimal possible) width and height of the needed text;
		private function createTextFieldData(text:String = "", width:int = 100, height:int = 10, multiline:Boolean = true, align:String =  TextFormatAlign.CENTER, 
												autoSize:String = TextFieldAutoSize.LEFT, fontSize:int = 26, wordWrap:Boolean = false, 
												textColor:uint = 0x686868, backgroundColor:uint = 0xffffff, isTransparent:Boolean = false):BitmapData 
		{
			if (width < 1) width = 1;
			if (height < 1) height = 1;
		
			serviceTextField ||= new TextField();
			var textFormat:TextFormat = new TextFormat();		
			textFormat.font = Config.defaultFontName;
			textFormat.size = fontSize;
			textFormat.align = align;
			textFormat.italic = false;
			serviceTextField.autoSize = autoSize;
			serviceTextField.multiline = multiline;
			serviceTextField.wordWrap = wordWrap;
			serviceTextField.textColor = textColor;
			serviceTextField.border = false;
			serviceTextField.defaultTextFormat = textFormat;
			serviceTextField.text = text;
			serviceTextField.width = width;
			
			serviceTextField.height = serviceTextField.textHeight;
			
			var textFieldWidth:Number;
			if (autoSize == TextFieldAutoSize.LEFT)
			{
				textFieldWidth = Math.min(serviceTextField.width, width);
			}
			else
			{
				textFieldWidth = width;
			}
			
			var newBmd:ImageBitmapData =  new ImageBitmapData("", textFieldWidth, serviceTextField.height, isTransparent, backgroundColor);
			newBmd.draw(serviceTextField);
			return newBmd;
		}
		
		override protected function drawView():void {
			
			container.y = Math.max(int(_height * .5 - _width * .5), Config.MARGIN);
			
			back.graphics.clear();
			back.graphics.beginFill(MainColors.WHITE, 1);
			back.graphics.drawRect(0, 0, _width, _width);
			
			var circleSize:int = _width / 2.5;
			var yCirclePosition:int = (_width - circleSize) / 3.5;
			
			back.graphics.beginFill(MainColors.GREEN, 1);
			back.graphics.drawCircle(int(_width*0.5), yCirclePosition + circleSize*0.5, circleSize*0.5);
			back.graphics.endFill();
			
			back.graphics.endFill();
			
			var messageText:BitmapData = createTextFieldData(Lang.userInvitedText + "\n" + data.name,
																	_width - Config.MARGIN*4, 
																	_height - circleSize - yCirclePosition - Config.MARGIN*4,
																	false,
																	TextFormatAlign.CENTER,
																	TextFieldAutoSize.LEFT,
																	Config.FINGER_SIZE * 0.37,
																	false,
																	AppTheme.GREY_DARK,
																	0xffffff,
																	false);
			if (message.bitmapData) {				
				message.bitmapData.dispose();
				message.bitmapData = null;
			}
			message.bitmapData = messageText;
			
			message.x = int((_width - message.width)*.5);
			message.y = int(yCirclePosition + circleSize + (yCirclePosition * 2.5 - message.height) * .5);
			
			buttonClose.x = int(_width - buttonClose.width - Config.MARGIN*2.4);
			buttonClose.y = int(Config.MARGIN * 2.4);
			
			iconDone.x = int(_width * 0.5 - iconDone.width * 0.5);
			iconDone.y = int(yCirclePosition + circleSize * 0.5 - iconDone.height*.5);
			
			iconSend.x = int(_width * 0.5 - iconSend.width * 0.5);
			iconSend.y = int(yCirclePosition + circleSize * 0.5 - iconSend.height*.5);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			buttonClose.activate();
			
			playIconAnimation();
			
			TweenMax.killDelayedCallsTo(close);
			TweenMax.delayedCall(SHOW_TIME_INTERVAL,close);
		}
		
		private function playIconAnimation():void {
			if (!animationStarted) {
				animationStarted = true;
				TweenMax.killDelayedCallsTo(hideSendIcon);
				TweenMax.delayedCall(1, hideSendIcon);
			}
		}
		
		private function hideSendIcon():void {
			echo("ScreenNtotificationDialog", "hideSendIcon");
			hideIcon(iconSend, 0.4);
			showIcon(iconDone, 0.4, 0.1);
		}
		
		override public function deactivateScreen():void {
			if (isDisposed) return;
			super.deactivateScreen();
			
			buttonClose.deactivate();
			
			if (iconSend)
				TweenMax.killTweensOf(iconSend);
			if (iconDone)
				TweenMax.killTweensOf(iconDone);
			TweenMax.killDelayedCallsTo(hideSendIcon);
			TweenMax.killDelayedCallsTo(close);
		}
		
		private function close():void {
			echo("ScreenNtotificationDialog", "close");
			TweenMax.killDelayedCallsTo(close);
			if (isDisposed) return;
			DialogManager.closeDialog();
		}		
		
		override public function dispose():void {
			if (isDisposed) return;
			super.dispose();
			
			if (buttonClose)
				buttonClose.dispose();
			buttonClose = null;
			
			if (message)
				UI.destroy(message);
			message = null;
			
			if (message)
				UI.destroy(message);
			message = null;
			
			if (iconSend)
			{
				TweenMax.killTweensOf(iconSend);
				UI.destroy(iconSend);
			}
			iconSend = null;
			
			if (iconDone)
			{
				TweenMax.killTweensOf(iconDone);
				UI.destroy(iconDone);
			}
			iconDone = null;
			
			if (back)
				UI.destroy(back);
			back = null;
			
			if (container)
				UI.destroy(container);
			container = null;
			
			if (serviceTextField)
				serviceTextField.text = "";
			serviceTextField = null;
			
			TweenMax.killDelayedCallsTo(hideSendIcon);
			TweenMax.killDelayedCallsTo(close);
		}
	}
}