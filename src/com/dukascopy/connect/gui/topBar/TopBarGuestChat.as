package com.dukascopy.connect.gui.topBar {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.GuestChatScreen;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.vo.ChatVO;
	import com.greensock.TweenMax;
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	
	/**
	 * Используется в ChatScreen
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class TopBarGuestChat extends MobileClip {
		
		private var _height:int;
		private var _width:int;
		private var _circleStatusHeight:int;
		private var _maxTextWidth:int;
		
		private var icoBack:MovieClip = new (Style.icon(Style.ICON_BACK));
		
		private var bg:Bitmap;
		private var bgBMD:BitmapData;
		private var bgRect:Rectangle;
		
		private var title:Bitmap;
		private var status:Sprite;
		private var statusTxt:Bitmap;
		
		private var trueH:int;
		private var btnY:int;
		private var btnSize:int = 0;
		private var btnOffsetH:Number;
		private var btnOffsetW:Number;
		private var titleHeight:int;
		
		private var screen:GuestChatScreen = null;
		
		private var lastTitleValue:String;
		private var rightOffset:int;
		private var firstTime:Boolean;
		private var backButton:BitmapButton;
		
		public function TopBarGuestChat() {
			createView();
			firstTime = true;
		}
		
		private function createView():void {
			
			_view = new Sprite();
			bgRect = new Rectangle(0, 0, 1, Config.APPLE_TOP_OFFSET);
			bg = new Bitmap();
			_view.addChild(bg);
			
			backButton = new BitmapButton();
			backButton.listenNativeClickEvents(true);
			backButton.setStandartButtonParams();
			backButton.setDownScale(1.3);
			backButton.setDownColor(0xFFFFFF);
			backButton.tapCallback = onBtnBackTap;
			backButton.disposeBitmapOnDestroy = true;
			backButton.show();
			_view.addChild(backButton);
			
			title = new Bitmap(null, "auto", true);
			_view.addChild(title);
			
			status = new Sprite();
			status.visible = false;
			statusTxt = new Bitmap(null, "auto", true);
			status.addChild(statusTxt);
			_view.addChild(status);
			
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeativate);
			ChatManager.S_CHAT_UPDATED.add(onChatUpdated);
		}
		
		private function onActivate(e:Event):void {
			if (screen.isActivated == true)
				activate();
		}
		
		private function onDeativate(e:Event):void {
			deactivate();
		}
		
		public function activate():void {
			echo("ChatTop", "activate", "");
			if (backButton != null)
				backButton.activate();
		}
		
		public function deactivate():void {
			echo("ChatTop", "deactivate", "");
			if (backButton != null)
				backButton.deactivate();
		}
		
		public function setWidthAndHeight(w:int, h:int):void {
			echo("ChatTop", "setWidthAndHeight", "");
			if (h == 0)
				return;
			
			_height = h;
			_width = w;
			
			bgRect.width = _width;
			
			if (bgBMD != null)
				bgBMD.dispose();
			bgBMD = new ImageBitmapData("ChatTop.BG", _width, _height, false, Style.color(Style.TOP_BAR));
			if (bgRect.height > 0)
				bgBMD.fillRect(bgRect, Style.color(Style.TOP_BAR));
			bg.bitmapData = bgBMD;
			
			trueH = h - Config.APPLE_TOP_OFFSET;
			
			btnSize = Style.size(Style.CHAT_TOP_ICON_SIZE);
			btnY = (trueH - btnSize) * .5;
			btnOffsetH = (trueH - btnSize) * .5;
			btnOffsetW = btnOffsetH * .7;
			
			_circleStatusHeight = Config.FINGER_SIZE * .08;
			
			UI.scaleToFit(icoBack, btnSize, btnSize);
		//	icoBack.width = icoBack.height = btnSize;
			UI.colorize(icoBack, Style.color(Style.TOP_BAR_ICON_COLOR));
			backButton.setBitmapData(UI.getSnapshot(icoBack, StageQuality.HIGH, "ChatTop.backButon"), true);
			backButton.x = btnOffsetH;
			backButton.y = btnY + Config.APPLE_TOP_OFFSET;
			backButton.setOverflow(btnOffsetH, btnOffsetH, btnOffsetH, btnOffsetH);
			
			redrawTitle();
			
			title.y = int((trueH - title.height) * .5 + Config.APPLE_TOP_OFFSET);
			title.x = int(Config.FINGER_SIZE * .65);
			status.x = (title.x + Config.FINGER_SIZE * .05);
			statusTxt.x = _circleStatusHeight + Config.MARGIN;
		}
		
		private function onChatUpdated(chatVO:ChatVO):void {
			echo("ChatTop", "onChatUpdated", "")
			redrawTitle();
		}
		
		public function redrawTitle():void {
			echo("ChatTop", "redrawTitle", value);
			var value:String = getTitleValue();
			if (rightOffset == 0)
				_maxTextWidth = _width - Config.MARGIN;
			else
				_maxTextWidth = rightOffset;
			_maxTextWidth -= title.x; 
			if (_maxTextWidth < 1)
				return;
			if (lastTitleValue == value && title.bitmapData && title.bitmapData.width == _maxTextWidth)
				return;
			UI.disposeBMD(title.bitmapData);
			if (value == null || value.length == 0)
				value = " ";
			lastTitleValue = value;
			title.bitmapData = UI.renderText(value, _maxTextWidth, 1, false, TextFormatAlign.LEFT, TextFieldAutoSize.NONE, trueH * .45, false, Style.color(Style.TOP_BAR_TEXT_COLOR), 0, true, "ChatTop.title", false, true);
		}
		
		private function getTitleValue():String {
			if (screen != null)
				return screen.getTitleValue();
			return "";
		}
		
		public function update():void {
			firstTime = true;
			statusTxt.alpha = 1;
		}
		
		private function onBtnBackTap(e:Event = null):void {
			echo("ChatTop", "onBtnBackTap", "");
			screen.onBack();
		}
		
		private function drawStatus(val:Boolean, txt:String):void {
			if (statusTxt.bitmapData != null)
				statusTxt.bitmapData.dispose();
			statusTxt.bitmapData = UI.renderText(txt, _maxTextWidth, Config.FINGER_SIZE_DOT_25, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, trueH * .25, false, Style.color(Style.TOP_BAR_ICON_COLOR), 0, true, "ChatTop.status");
			var metrics:TextLineMetrics = UI.getTextField().getLineMetrics(0);
			var _circleCenterY:Number = UI.getTextField().textHeight - metrics.descent - _circleStatusHeight + 2;
			metrics = null;
			status.graphics.clear();
			status.graphics.beginFill((val) ? 0x65BF37 : Style.color(Style.TOP_BAR_ICON_COLOR));
			status.graphics.drawCircle(_circleStatusHeight, _circleCenterY, _circleStatusHeight);
		}
		
		override public function dispose():void {
			echo("ChatTop", "dispose", "");
			
			super.dispose();
			
			TweenMax.killTweensOf(status);
			TweenMax.killTweensOf(title);
			TweenMax.killTweensOf(bg);
			
			NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE, onActivate);
			NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE, onDeativate);
			ChatManager.S_CHAT_UPDATED.remove(onChatUpdated);
			
			screen = null;
			
			_height = 0;
			_width = 0;
			
			if (bgRect != null)
				bgRect.setEmpty();
			bgRect = null;
			
			if (bgBMD != null)
				bgBMD.dispose();
			bgBMD = null;
			
			UI.destroy(bg)
			bg = null;
			
			UI.destroy(title)
			title = null;
			
			UI.destroy(statusTxt);
			statusTxt = null;
			
			if (status != null) {
				while (status.numChildren != 0)
					status.removeChild(status.getChildAt(0));
				if (status.parent != null)
					status.parent.removeChild(status);
				status.graphics.clear();
			}
			status = null;
			
			if (backButton != null)
				backButton.dispose();
			backButton = null;
			
			icoBack = null;
		}
		
		public function setChatScreen(chatScreen:GuestChatScreen):void {
			screen = chatScreen;
		}
		
		public function updateTitleVerticalPosition():void {
			var space:int = (trueH - title.height - status.height) * .33;
			var newPosition:int = Config.APPLE_TOP_OFFSET + space;
			TweenMax.killTweensOf(title);
			TweenMax.to(title, 0.7, { y:newPosition, delay:1 } );
			status.y = title.y + title.height - space;
			TweenMax.to(status, 0.7, { y:(newPosition + title.height - space), delay:1 } );
		}
		
		public function hide(time:Number = 0.5):void {
			TweenMax.to(bg, time, { alpha:0.3, delay:time * 2 } );
		}
		
		public function show():void {
			bg.alpha = 1;
		}
		
		public function get height():int {
			return _height;
		}
		
		private function get width():int {
			return _width;
		}
	}
}