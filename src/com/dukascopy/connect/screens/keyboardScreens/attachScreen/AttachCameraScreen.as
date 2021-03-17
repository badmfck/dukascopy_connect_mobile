package com.dukascopy.connect.screens.keyboardScreens.attachScreen
{
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.customActions.CreatePuzzleAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenCameraPhotoAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenCameraVideoAction;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenGalleryAction;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.keyboardScreens.attachScreen.attachButtons.AttachScreenButtonLabel;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.langs.Lang;
	import flash.display.Shape;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class AttachCameraScreen extends BaseScreen
	{
		private var bg:Shape;
		private var buttons:Vector.<AttachScreenButtonLabel>;
		private var scrollableContainer:ScrollPanel;
		
		public function AttachCameraScreen() {
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
			if (NetworkManager.isConnected)
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
				if (buttons)
				{
					for (var i:int = 0; i < buttons.length; i++) {
						buttons[i].activate();
						buttons[i].alpha = 1;
					}
				}
			}
		}
		
		private function disableButtons():void 
		{
			if (buttons)
			{
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
			
			var photo:IScreenAction = new OpenCameraPhotoAction();
			photo.setData(Lang.makePhoto);
			
			var video:IScreenAction = new OpenCameraVideoAction();
			video.setData(Lang.makeVideo);
			
			var callGalleryAction:IScreenAction = new OpenGalleryAction();
			callGalleryAction.setData(Lang.photoGallery);
			
		//	var puzzle:IScreenAction = new CreatePuzzleAction();
		//	puzzle.setData(Lang.textPuzzle);
			
			actions.push(photo);
			actions.push(video);
			actions.push(callGalleryAction);
		//	actions.push(puzzle);
			
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
				if (isActivated && WS.connected)
				{
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
			if (buttons && NetworkManager.isConnected && WS.connected)
				for (var i:int = 0; i < buttons.length; i++) 
					buttons[i].activate();
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