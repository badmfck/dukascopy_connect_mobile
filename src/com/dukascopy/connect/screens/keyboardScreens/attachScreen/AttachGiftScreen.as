package com.dukascopy.connect.screens.keyboardScreens.attachScreen {
	
	import assets.Gift_1;
	import assets.Gift_10;
	import assets.Gift_25;
	import assets.Gift_5;
	import assets.Gift_50;
	import assets.Gift_x;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.SendGiftAction;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.keyboardScreens.attachScreen.attachButtons.AttachScreenButton;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.type.GiftType;
	import flash.display.Shape;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class AttachGiftScreen extends BaseScreen {
		
		private var bg:Shape;
		private var buttons:Vector.<AttachScreenButton>;
		private var scrollableContainer:ScrollPanel;
		
		public function AttachGiftScreen() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, 0, 1, 1);
				bg.graphics.endFill();
			_view.addChild(bg);
			scrollableContainer = new ScrollPanel();
			_view.addChild(scrollableContainer.view);
		}
		
		private function onConnectionChanged():void {
			if (NetworkManager.isConnected || Config.isTest() == true) {
				enableButtons();
			} else {
				disableButtons();
			}
		}
		
		private function enableButtons():void {
			if (isActivated) {
				if (buttons) {
					for (var i:int = 0; i < buttons.length; i++) {
						buttons[i].activate();
						buttons[i].alpha = 1;
					}
				}
			}
		}
		
		private function disableButtons():void {
			if (buttons) {
				for (var i:int = 0; i < buttons.length; i++) {
					buttons[i].deactivate();
					buttons[i].alpha = 0.5;
				}
			}
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.doDisposeAfterClose = false;
			
			NetworkManager.S_CONNECTION_CHANGED.add(onConnectionChanged);
			
			addButtons();
			drawButtons();
			onConnectionChanged();
		}
		
		override protected function drawView():void {
			if (_isDisposed)
				return;
			bg.width = _width;
			bg.height = _height;
			scrollableContainer.setWidthAndHeight(_width, _height);
			scrollableContainer.hideScrollBar();
		}
		
		private function addButtons():void {
			var actions:Vector.<IScreenAction> = prepareActions();
			createActionButtons(actions);
		}
		
		private function prepareActions():Vector.<IScreenAction> {
			var actions:Vector.<IScreenAction> = new Vector.<IScreenAction>();
			
			var gift1:IScreenAction = new SendGiftAction();
			gift1.setIconClass(Gift_1);
			gift1.setData(GiftType.GIFT_1);
			
			var gift5:IScreenAction = new SendGiftAction();
			gift5.setIconClass(Gift_5);
			gift5.setData(GiftType.GIFT_5);
			
			var gift10:IScreenAction = new SendGiftAction();
			gift10.setIconClass(Gift_10);
			gift10.setData(GiftType.GIFT_10);
			
			var gift25:IScreenAction = new SendGiftAction();
			gift25.setIconClass(Gift_25);
			gift25.setData(GiftType.GIFT_25);
			
			var gift50:IScreenAction = new SendGiftAction();
			gift50.setIconClass(Gift_50);
			gift50.setData(GiftType.GIFT_50);
			
			var giftx:IScreenAction = new SendGiftAction();
			giftx.setIconClass(Gift_x);
			giftx.setData(GiftType.GIFT_X);
			
			actions.push(gift1);
			actions.push(gift5);
			actions.push(gift10);
			actions.push(gift25);
			actions.push(gift50);
			actions.push(giftx);
			
			return actions;
		}
		
		private function createActionButtons(actions:Vector.<IScreenAction>):void {
			clearButtons();
			if (actions == null || actions.length == 0)
				return;
			buttons = new Vector.<AttachScreenButton>();
			var button:AttachScreenButton;
			for (var i:int = 0; i < actions.length; i++) {
				button = buttons[buttons.push(new AttachScreenButton(actions[i])) - 1];
				scrollableContainer.addObject(button);
				if (isActivated && WS.connected) {
					button.activate();
				}
			}
		}
		
		private function clearButtons():void {
			if (buttons) {
				for (var i:int = 0; i < buttons.length; i++) {
					scrollableContainer.removeObject(buttons[i]);
					buttons[i].dispose();
				}
			}
			buttons = null;
		}
		
		private function drawButtons():void {
			var horizontalButtonsNum:int = 3;
			var gridSize:int = (_width - Config.DOUBLE_MARGIN) / horizontalButtonsNum;
			var btnSize:int = Math.min(gridSize * .7, Config.FINGER_SIZE * 1.4);
			var btnOffset:int = gridSize * .15;
			var verticalSize:int = (_height - Config.DOUBLE_MARGIN * 2) / 2;
			var horizontalSize:int = (_width - Config.DOUBLE_MARGIN * 2) / horizontalButtonsNum;
			var i:int;
			if (buttons) {
				for (i = 0; i < buttons.length; i++) {
					buttons[i].setSizes(horizontalSize, verticalSize);
					buttons[i].draw();
					buttons[i].show(.3, .1*i, true);
					buttons[i].x = Config.DOUBLE_MARGIN + (i % horizontalButtonsNum) * horizontalSize;
					buttons[i].y = Config.DOUBLE_MARGIN + Math.floor(i / horizontalButtonsNum) * verticalSize;
				}
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;
			if (buttons) {
				if ((NetworkManager.isConnected && WS.connected) || Config.isTest() == true) {
					for (var i:int = 0; i < buttons.length; i++)
						buttons[i].activate();
				}
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			if (buttons)
				for (var i:int = 0; i < buttons.length; i++)
					buttons[i].deactivate();
		}
		
		override public function dispose():void {
			if (_isDisposed)
				return;
			clearButtons();
			super.dispose();
			NetworkManager.S_CONNECTION_CHANGED.remove(onConnectionChanged);
		}
		
		public function initButtons(showPayButtons:Boolean = true):void {
			addButtons();
			drawButtons();
			scrollableContainer.setWidthAndHeight(_width, _height);
			scrollableContainer.hideScrollBar();
		}
		
		public function showRecent():void {
			if (_isActivated == false)
				return;
			if (buttons) {
				for (var i:int = 0; i < buttons.length; i++) {
					buttons[i].hide();
					buttons[i].show(.3, .1 * i, true);
				}
			}
		}
	}
}