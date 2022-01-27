package com.dukascopy.connect.gui.chatInput {
	
	import assets.SendButtonRed;
	import assets.SortVerticalIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BankBotInput extends Sprite {
		
		private var bg:Shape;
		private var buttonMenu:BitmapButton;
		private var tfBMP:Bitmap;
		private var buttonSend:BitmapButton;
		private var buttonHome:BitmapButton;
		private var buttonMP:BitmapButton;
		private var buttonP2P:BitmapButton;
		
		private var trueWidth:int;
		
		private var firstTime:Boolean = true;
		
		private var _homeCallback:Function;
		private var _holdCallback:Function;
		private var _sendCallback:Function;
		private var _menuCallback:Function;
		private var _mpCallback:Function;
		private var _p2pCallback:Function;
		private var _title:String;
		
		private var _isActive:Boolean  = false;
		
		private var homeButtonNeeded:Boolean = false;
		private var menuButtonNeeded:Boolean = false;
		private var sendButtonNeeded:Boolean = false;
		private var mpButtonNeeded:Boolean = false;
		
		private var p2pButtonNeeded:Boolean = true;
		
		private var homeButtonShown:Boolean = false;
		private var menuButtonShown:Boolean = false;
		private var sendButtonShown:Boolean = false;
		private var mpButtonShown:Boolean = false;
		private var p2pButtonShown:Boolean = false;
		
		private var buttonSize:int = Config.FINGER_SIZE * .55;
		private var componentHeight:int = Config.FINGER_SIZE * .8;
		private var padding:int = Config.FINGER_SIZE * .25;
		private var leftPadding:int = Config.FINGER_SIZE * .25;
		
		public function BankBotInput(title:String, homeNeeded:Boolean = false, menuNeeded:Boolean = true, sendNeeded:Boolean = true, mpNeeded:Boolean = true) {
			_title = title;
			homeButtonNeeded = homeNeeded;
			menuButtonNeeded = menuNeeded;
			sendButtonNeeded = sendNeeded;
			mpButtonNeeded = mpNeeded;
			
			bg = new Shape();
			addChild(bg);
			
			tfBMP = new Bitmap();
			addChild(tfBMP);
			
			bg.graphics.clear();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, 0, 2, componentHeight + Config.APPLE_BOTTOM_OFFSET);
		}
		
		override public function set y(value:Number):void {
			super.y = value;
			updateTips();
		}
		
		private function updateTips():void {
			var point:Point;
			if (buttonHome != null) {
				point = new Point(buttonHome.x + buttonHome.width + Config.FINGER_SIZE*.05, buttonHome.y + buttonHome.height * .5);
				ToastMessage.updateHandTip(localToGlobal(point));
			} else if (buttonMenu != null) {
				point = new Point(buttonMenu.x + buttonMenu.width, buttonMenu.y + buttonMenu.height * .5);
				ToastMessage.updateHandTip(localToGlobal(point));
			} else if (buttonMP != null) {
				point = new Point(buttonMP.x + buttonMP.width, buttonMP.y + buttonMP.height * .5);
				ToastMessage.updateHandTip(localToGlobal(point));
			}
		}
		
		private function showNeededButtons():void {
			var leftOffset:int = leftPadding;
			var leftX:int  = leftPadding;
			
			var delay:Number = 0;
			if (homeButtonNeeded == true) {
				createHomeButton(leftOffset);
				leftOffset = Config.FINGER_SIZE * .1;
				buttonHome.x = leftX;
				buttonHome.y = int(componentHeight * .5 - buttonHome.height * .5);
				leftX += buttonHome.width + padding;
				if(homeButtonShown == false) {
					buttonHome.show(.3, delay);
					delay += .1;
					homeButtonShown = true;
				}
				if (_isActive == true) {
					buttonHome.activate();
				}
			} else {
				homeButtonShown =  false;
				if (buttonHome != null) {
					buttonHome.hide();
					buttonHome.deactivate();
				}
			}
			if (menuButtonNeeded == true) {
				createMenuButton(leftOffset);
				buttonMenu.x =  leftX;
				buttonMenu.y = int(componentHeight * .5 - buttonMenu.height * .5);
				leftX += buttonMenu.width + padding;
				if (menuButtonShown == false) {
					buttonMenu.show(.3, delay);
					delay += .1;
					menuButtonShown = true;
				}
				if (_isActive == true) {
					buttonMenu.activate();
				}
			} else {
				menuButtonShown = false;
				if (buttonMenu != null){
					buttonMenu.hide();
					buttonMenu.deactivate();
				}
			}
			if (mpButtonNeeded == true) {
				createMPButton(leftOffset);
				buttonMP.x =  leftX;
				buttonMP.y = int(componentHeight * .5 - buttonMP.height * .5);
				leftX += buttonMP.width + padding;
				if (mpButtonShown == false) {
					buttonMP.show(.3, delay);
					delay += .1;
					mpButtonShown = true;
				}
				if (_isActive == true) {
					buttonMP.activate();
				}
			} else {
				mpButtonShown = false;
				if (buttonMP != null){
					buttonMP.hide();
					buttonMP.deactivate();
				}
			}
			
			if (p2pButtonNeeded == true) {
				createp2pButton(leftOffset);
				buttonP2P.x =  leftX;
				buttonP2P.y = int(componentHeight * .5 - buttonP2P.height * .5);
				leftX += buttonP2P.width + padding;
				if (p2pButtonShown == false) {
					buttonP2P.show(.3, delay);
					delay += .1;
					p2pButtonShown = true;
				}
				if (_isActive == true) {
					buttonP2P.activate();
				}
			} else {
				p2pButtonShown = false;
				if (buttonP2P != null){
					buttonP2P.hide();
					buttonP2P.deactivate();
				}
			}
			
			if (sendButtonNeeded == true) {
				createSendButton();
				
				buttonSend.y = int(componentHeight * .5 - buttonSend.height * .5);
				buttonSend.x = trueWidth - int(Config.FINGER_SIZE * .7);
				if(sendButtonShown == false){
					buttonSend.show(.3, delay);
					sendButtonShown = true;
				}
				if (_isActive)
					buttonSend.activate();
			}else{
				sendButtonShown = false;
				if (buttonSend != null){
					buttonSend.hide();
					buttonSend.deactivate();
				}
			}
		}
		
		// create Home 
		public function createHomeButton(leftOffset:int = 0):void {
			if (buttonHome == null) {
				buttonHome = new BitmapButton();
				
				/*var asset:BitmapData = UI.renderAsset(
						UI.colorize(new SWFIconBank(), 0x7DA0BB),					
						buttonSize,
						buttonSize
					)*/
				
				var icon:DisplayObject = new (Style.icon(Style.ICON_BANK));
				UI.colorize(icon, Style.color(Style.ICON_COLOR));
				UI.scaleToFit(icon, buttonSize * .8, buttonSize * .8);
				var asset:BitmapData = UI.getSnapshot(icon, StageQuality.HIGH);
				
				buttonHome.setBitmapData(
					asset
				,true);
				buttonHome.setOverflow(
					Config.FINGER_SIZE * .2,
					leftOffset,
					Config.FINGER_SIZE * .15,
					Config.FINGER_SIZE * .2
				);		
				buttonHome.setDownAlpha(0);
				buttonHome.hide();
				buttonHome.tapCallback = onHomeButtonTap;
				addChild(buttonHome);
			} else {
				buttonHome.setOverflow(
					Config.FINGER_SIZE * .2,
					leftOffset,
					Config.FINGER_SIZE * .15,
					Config.FINGER_SIZE * .2
				);		
			}
		}
		
		// Create Menu button 
		public function createMenuButton(leftOffset:int = 0):void {
			if (buttonMenu == null){
			//	var asset:BitmapData = UI.drawAssetToRoundRect(UI.colorize(new SWFSwissFlagGray(), 0x7DA0BB), buttonSize, true, "BankBotInput.swissIcon");
				
				var icon:DisplayObject = new (Style.icon(Style.ICON_BOT));
				UI.colorize(icon, Style.color(Style.ICON_COLOR));
				UI.scaleToFit(icon, buttonSize * .8, buttonSize * .8);
				var asset:BitmapData = UI.getSnapshot(icon, StageQuality.HIGH);
				
				buttonMenu = new BitmapButton();
				buttonMenu.setBitmapData(asset, true);
				buttonMenu.setOverflow(
					Config.FINGER_SIZE * .2,
					leftOffset,
					Config.FINGER_SIZE * .15,
					Config.FINGER_SIZE * .2
				);
				buttonMenu.setDownAlpha(0);
				buttonMenu.hide();
				buttonMenu.tapCallback = onMenuTap;
				addChild(buttonMenu);
			} else {
				buttonMenu.setOverflow(
					Config.FINGER_SIZE * .2,
					leftOffset,
					Config.FINGER_SIZE * .15,
					Config.FINGER_SIZE * .2
				);
			}
		}
		
		// Create Marketplace button 
		public function createMPButton(leftOffset:int = 0):void {
			if (buttonMP == null) {
			//	var asset:BitmapData = UI.drawAssetToRoundRect(UI.colorize(new (Style.icon(Style.ICON_MARKETPLACE)), 0x7DA0BB), buttonSize, true, "BankBotInput.swissIcon");
			
				var icon:DisplayObject = new (Style.icon(Style.ICON_MARKETPLACE));
				UI.colorize(icon, Style.color(Style.ICON_COLOR));
				UI.scaleToFit(icon, buttonSize * .8, buttonSize * .8);
				var asset:BitmapData = UI.getSnapshot(icon, StageQuality.HIGH);
				buttonMP = new BitmapButton();
				buttonMP.setBitmapData(asset, true);
				buttonMP.setOverflow(
					Config.FINGER_SIZE * .2,
					leftOffset,
					Config.FINGER_SIZE * .15,
					Config.FINGER_SIZE * .2
				);
				buttonMP.setDownAlpha(0);
				buttonMP.hide();
				buttonMP.tapCallback = onMPButtonTap;
				addChild(buttonMP);
			} else {
				buttonMP.setOverflow(
					Config.FINGER_SIZE * .2,
					leftOffset,
					Config.FINGER_SIZE * .15,
					Config.FINGER_SIZE * .2
				);
			}
		}
		
		public function createp2pButton(leftOffset:int = 0):void {
			if (buttonP2P == null) {
			//	var asset:BitmapData = UI.drawAssetToRoundRect(UI.colorize(new (Style.icon(Style.ICON_MARKETPLACE)), 0x7DA0BB), buttonSize, true, "BankBotInput.swissIcon");
			
				var icon:DisplayObject = new (Style.icon(Style.ICON_911));
				UI.colorize(icon, Style.color(Style.ICON_COLOR));
				UI.scaleToFit(icon, buttonSize * 1.2, buttonSize * 1.2);
				var asset:BitmapData = UI.getSnapshot(icon, StageQuality.HIGH);
				buttonP2P = new BitmapButton();
				buttonP2P.setBitmapData(asset, true);
				buttonP2P.setOverflow(
					Config.FINGER_SIZE * .2,
					leftOffset,
					Config.FINGER_SIZE * .15,
					Config.FINGER_SIZE * .2
				);
				buttonP2P.setDownAlpha(0);
				buttonP2P.hide();
				buttonP2P.tapCallback = onP2PButtonTap;
				addChild(buttonP2P);
			} else {
				buttonP2P.setOverflow(
					Config.FINGER_SIZE * .2,
					leftOffset,
					Config.FINGER_SIZE * .15,
					Config.FINGER_SIZE * .2
				);
			}
		}
		
		// Create send button 
		public function createSendButton():void {
			if (buttonSend == null){
				buttonSend = new BitmapButton();
				buttonSend.setBitmapData(
					UI.renderAsset(
						new SendButtonRed(),
						buttonSize,
						buttonSize
					)
				);
				buttonSend.setOverflow(
					Config.FINGER_SIZE * .1,
					Config.FINGER_SIZE * .3,
					Config.FINGER_SIZE * .1,
					0
				);
				buttonSend.y = int(componentHeight * .5 - buttonSend.height * .5);
				buttonSend.hide();
				buttonSend.tapCallback = onSendButtonTap;
				addChild(buttonSend);			
			}
		}
		
		public function updateComponentsPosition():void {
			var buttonsTotalWidth:int = 0;
			var leftSpace:int = leftPadding;
			var leftOffset:int  =  leftPadding;
			var rightSpace:int = 0;
			var halfFreeSpace:int = 0;
			if (homeButtonNeeded == true) {
				createHomeButton(leftOffset);
				buttonHome.x = leftSpace;				
				buttonsTotalWidth += Config.FINGER_SIZE * .7;
				leftSpace += buttonHome.width + padding;
				leftOffset = int(Config.FINGER_SIZE * .1);
			}
			if (menuButtonNeeded == true) {
				createMenuButton(leftOffset);
				buttonMenu.x = leftSpace;
				buttonsTotalWidth += Config.FINGER_SIZE * .6;
				leftSpace += buttonMenu.width + padding;
			}
			if (mpButtonNeeded == true) {
				createMPButton(leftOffset);
				buttonMP.x = leftSpace;
				buttonsTotalWidth += Config.FINGER_SIZE * .6;
				leftSpace += buttonMP.width + padding;
			}
			
			if (p2pButtonNeeded == true) {
				createp2pButton(leftOffset);
				buttonP2P.x = leftSpace;
				buttonsTotalWidth += Config.FINGER_SIZE * .6;
				leftSpace += buttonP2P.width + padding;
			}
			
			if (sendButtonNeeded == true) {
				createSendButton();
				buttonSend.x = trueWidth - int(Config.FINGER_SIZE * .7);				
				buttonsTotalWidth += Config.FINGER_SIZE * .8;
				rightSpace = buttonSend.width + padding;
			} 		
			if (tfBMP.bitmapData != null) {
				tfBMP.bitmapData.dispose();
				tfBMP.bitmapData = null;
			}
			tfBMP.bitmapData = UI.renderText(
				_title,
				trueWidth - buttonsTotalWidth,
				10,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE*.26,
				false,
				Style.color(Style.ICON_COLOR),
				Style.color(Style.COLOR_INPUT_BACKGROUND)
			);
			halfFreeSpace = (trueWidth - (leftSpace + rightSpace))*.5 - tfBMP.width*.5; 		
			tfBMP.x = leftSpace + halfFreeSpace;
			tfBMP.y = int((componentHeight - tfBMP.height) * .5);
		}
		
		public function destroyHomeButton():void {			
			if (buttonHome != null) {
				buttonHome.dispose();
				buttonHome = null;
			}
		}
		
		private function onMenuTap():void {
			if (_menuCallback != null)
				_menuCallback();
			ToastMessage.hideHandTip();
		}
		
		private function onSendButtonTap():void {
			if (_sendCallback != null) {
				_sendCallback();
				return;
			}
			BankManager.openChatBotScreen( { bankBot:true } );
		}
		
		private function onHomeButtonTap():void {
			ToastMessage.hideHandTip();
			if (_homeCallback != null) {
				_homeCallback();
				return;
			}
		}
		
		private function onMPButtonTap():void {
			ToastMessage.hideHandTip();
			if (_mpCallback != null) {
				_mpCallback();
				return;
			}
		}
		
		private function onP2PButtonTap():void {
			ToastMessage.hideHandTip();
			if (_p2pCallback != null) {
				_p2pCallback();
				return;
			}
		}
		
		public function startBlinkMenu():void {
			if (buttonMenu != null){
				buttonMenu.setAlphaBlink(1);
				buttonMenu.setAlphaBlinkOff(1);
				buttonMenu.setBlinkColor(0x3f6dcd);
				buttonMenu.BLINK_INTERVAL = 10;
				buttonMenu.isBlinking = true;
			}
		}
		
		public function stopBlinkMenu():void {
			if (buttonMenu != null){
				buttonMenu.isBlinking = false;
			}
		}
		
		public function setHomeButtonColor(color:uint=0x7DA0BB):void {
			if (buttonHome != null){
				buttonHome.setBitmapData(
					UI.renderAsset(
						UI.colorize(new SWFIconBank(), color),					
						buttonSize,
						buttonSize
					)
				,true);
				buttonHome.setDownAlpha(0);
			}			
		}
		
		public function setWidth(val:int):void {
			if (trueWidth == val)
				return;
			trueWidth = val;
			bg.graphics.clear();
			bg.graphics.beginFill(Style.color(Style.COLOR_INPUT_BACKGROUND));
			bg.graphics.drawRect(0, 0, trueWidth, componentHeight + Config.APPLE_BOTTOM_OFFSET);
			
			showNeededButtons();
			updateComponentsPosition();
		}
		
		public function activate():void {
			_isActive = true;
			showNeededButtons();
			PointerManager.addTap(this, onTap);
			PointerManager.addDown(this, onDown);
		}
		
		private var ts:Number;
		private function onDown(e:Object):void {
			if (tfBMP == null)
				return;
			if ("localX" in e == true &&
				e.localX > tfBMP.x &&
				e.localX < tfBMP.x + tfBMP.width &&
				"localY" in e == true &&
				e.localY < tfBMP.y + tfBMP.height) {
					ts = new Date().getTime();
					PointerManager.addUp(MobileGui.stage, onUp);
			}
		}
		
		private function onUp(e:Object):void {
			PointerManager.removeUp(MobileGui.stage, onUp);
			var newTS:Number = new Date().getTime();
			if (newTS - ts < 5000)
				return;
			if (_holdCallback != null) {
				_holdCallback();
			}
		}
		
		private function onTap(e:Object):void {
			var newTS:Number = new Date().getTime();
			if (newTS - ts > 5000)
				return;
			if (tfBMP == null)
				return;
			if ("localX" in e == true &&
				e.localX > tfBMP.x &&
				e.localX < tfBMP.x + tfBMP.width &&
				"localY" in e == true &&
				e.localY < tfBMP.y + tfBMP.height)
					onSendButtonTap();
		}
		
		public function deactivate():void {
			_isActive = false;
			if (buttonMenu != null)
				buttonMenu.deactivate();
			if (buttonSend != null)
				buttonSend.deactivate();
			if (buttonHome != null)
				buttonHome.deactivate();
			if (buttonMP != null)
				buttonMP.deactivate();
			if (buttonP2P != null)
				buttonP2P.deactivate();
			PointerManager.addDown(this, onDown);
			PointerManager.removeUp(MobileGui.stage, onUp);
			PointerManager.removeTap(this, onTap);
			ToastMessage.hideHandTip();
		}
		
		public function set holdCallback(val:Function):void {
			_holdCallback = val;
		}
		
		public function set sendCallback(val:Function):void {
			_sendCallback = val;
		}
		
		public function set menuCallback(val:Function):void {
			_menuCallback = val;
		}
		
		public function set mpCallback(val:Function):void {
			_mpCallback = val;
		}
		
		public function set p2pCallback(val:Function):void {
			_p2pCallback = val;
		}
		
		public function set homeCallback(val:Function):void {
			_homeCallback = val;
		}
		
		public function setButtonsState(homeNeeded:Boolean = false, menuNeeded:Boolean = true, sendNeeded:Boolean = true, mpNeeded:Boolean = true):void {
			homeButtonNeeded = homeNeeded;
			menuButtonNeeded = menuNeeded;
			sendButtonNeeded  = sendNeeded;
			mpButtonNeeded = mpNeeded;
			showNeededButtons();
			updateComponentsPosition();
		}
		
		public function getHeight():int {
			return componentHeight + Config.APPLE_BOTTOM_OFFSET;
		}
		
		public function dispose():void {
			if (bg != null)
				UI.destroy(bg);
			bg = null;
			if (buttonMenu != null)
				buttonMenu.dispose();
			buttonMenu = null;
			if (buttonMP != null)
				buttonMP.dispose();
			buttonMP = null;
			if (buttonP2P != null)
				buttonP2P.dispose();
			buttonP2P = null;
			if (tfBMP != null)
				UI.destroy(tfBMP);
			tfBMP = null;
			if (buttonSend != null)
				buttonSend.dispose();
			buttonSend = null;
			if (buttonHome != null)
				buttonHome.dispose();
			buttonHome = null;
			_homeCallback = null;
			_holdCallback = null;
			_sendCallback = null;
			_menuCallback = null;
			_p2pCallback = null;
			_mpCallback = null;
		}
	}
}