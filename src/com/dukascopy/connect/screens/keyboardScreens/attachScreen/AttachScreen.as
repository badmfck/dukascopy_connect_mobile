package com.dukascopy.connect.screens.keyboardScreens.attachScreen {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.AddInvoiceAction;
	import com.dukascopy.connect.data.screenAction.customActions.AttachDocumentAction;
	import com.dukascopy.connect.data.screenAction.customActions.CreateCoinTradeAction;
	import com.dukascopy.connect.data.screenAction.customActions.CreatePuzzleAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenCameraAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenGalleryAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenGiftsAction;
	import com.dukascopy.connect.data.screenAction.customActions.SendMoneyAction;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.keyboardScreens.attachScreen.attachButtons.AttachScreenButtonLabel;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.payments.PayConfig;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.type.BankPhaze;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.vo.screen.AttachScreenData;
	import com.dukascopy.langs.Lang;
	import flash.display.Shape;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class AttachScreen extends BaseScreen {
		
		private var bg:Shape;
		private var buttons:Vector.<AttachScreenButtonLabel>;
		private var scrollableContainer:ScrollPanel;
		
		public function AttachScreen() {
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
		
		private function onConnectionChanged():void 
		{
			if (NetworkManager.isConnected || Config.isTest() == true)
			{
				enableButtons();
			}
			else
			{
				disableButtons();
			}
		}
		
		private function enableButtons():void 
		{
			if (isActivated)
			{
				if (buttons != null)
				{
					for (var i:int = 0; i < buttons.length; i++) {
						buttons[i].activate();
					}
				}
			}
		}
		
		private function disableButtons():void 
		{
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) {
					buttons[i].deactivate();
				}
			}
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.doDisposeAfterClose = false;
			var showPayButtons:Boolean = true;
			if (data && (data is AttachScreenData) && !(data as AttachScreenData).showPayButtons)
				showPayButtons = false;
			
			NetworkManager.S_CONNECTION_CHANGED.add(onConnectionChanged);
			
			addButtons(showPayButtons);
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
		
		private function addButtons(showPayButtons:Boolean = true):void {
			var actions:Vector.<IScreenAction> = prepareActions(showPayButtons);
			createActionButtons(actions);
		}
		
		private function prepareActions(showPayButtons:Boolean = true):Vector.<IScreenAction> {
			var actions:Vector.<IScreenAction> = new Vector.<IScreenAction>();
			
			var callCameraAction:IScreenAction = new OpenCameraAction();
			callCameraAction.setData(Lang.textCamera);
			
			/*var callGalleryAction:IScreenAction = new OpenGalleryAction();
			callGalleryAction.setData(Lang.photoGallery);*/
			
			var sendMoneyAction:IScreenAction = new SendMoneyAction();
			sendMoneyAction.setData(Lang.sendMoney);
			
			var addInvoiceAction:IScreenAction = new AddInvoiceAction();
			addInvoiceAction.setData(Lang.sendInvoice);
			
		//	var composeVoiceMessageAction:IScreenAction = new ComposeVoiceMessageAction();
		//	composeVoiceMessageAction.setData(Lang.sendVoice);
			
			
			
			
			var puzzle:IScreenAction = new CreatePuzzleAction();
			puzzle.setData(Lang.textPuzzle);
			
			var tradeAction:IScreenAction = new CreateCoinTradeAction();
			tradeAction.setData(Lang.escrow);
			
			var sendGiftAction:IScreenAction = new OpenGiftsAction();
			sendGiftAction.setData(Lang.sendGift);
			
			actions.push(callCameraAction);
			if (ChatManager.getCurrentChat() != null && Auth.key != "web")
			{
				var attachFileAction:IScreenAction = new AttachDocumentAction(ChatManager.getCurrentChat().uid);
				attachFileAction.setData(Lang.attachDocument);
				actions.push(attachFileAction);
			}
			
		//	actions.push(callGalleryAction);
			/*if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().type != ChatRoomType.COMPANY && ChatManager.getCurrentChat().type != ChatRoomType.CHANNEL && ChatManager.getCurrentChat().type != ChatRoomType.GROUP)
			{
				actions.push(puzzle);
			}*/
			
			if (ChatManager.getCurrentChat() != null && 
				ChatManager.getCurrentChat().type != ChatRoomType.COMPANY && 
				ChatManager.getCurrentChat().type != ChatRoomType.CHANNEL && 
				ChatManager.getCurrentChat().type != ChatRoomType.GROUP &&
				Auth.bank_phase == BankPhaze.ACC_APPROVED)
			{
				actions.push(tradeAction);
			}
			
		//	actions.push(composeVoiceMessageAction);
			
			if (showPayButtons) {
				if (needAddSendMoneyAction())
				{
					actions.push(sendMoneyAction);
					actions.push(addInvoiceAction);
				}
				
				actions.push(sendGiftAction);
			}
			
			return actions;
		}
		
		private function createActionButtons(actions:Vector.<IScreenAction>):void {
			clearButtons();
			if (actions == null || actions.length == 0)
				return;
			buttons = new Vector.<AttachScreenButtonLabel>();
			var button:AttachScreenButtonLabel;
			for (var i:int = 0; i < actions.length; i++)
			{
				button = buttons[buttons.push(new AttachScreenButtonLabel(actions[i])) - 1];
				scrollableContainer.addObject(button);
				if (isActivated && (WS.connected || Config.isTest() == true))
				{
					enableButtons();
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
		
		private function needAddSendMoneyAction():Boolean {
			if (PayConfig.SHOW_BUTTON_IN_CHAT == PayConfig.SHOWING_TYPE_COMPANY && Auth.companyID != "08A29C35B3")
				return false;
			if (PayConfig.SHOW_BUTTON_IN_CHAT == PayConfig.SHOWING_TYPE_NOPINDOS && Auth.countryCode + "" == "1")
				return false;
			return true;
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
			if ((NetworkManager.isConnected && WS.connected) || Config.isTest())
				enableButtons();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			disableButtons();
		}
		
		override public function dispose():void {
			if (_isDisposed)
				return;
			clearButtons();
			if (scrollableContainer != null)
			{
				scrollableContainer.dispose();
				scrollableContainer = null;
			}
			super.dispose();
			NetworkManager.S_CONNECTION_CHANGED.remove(onConnectionChanged);
		}
		
		public function initButtons(showPayButtons:Boolean = true):void {
			addButtons(showPayButtons);
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