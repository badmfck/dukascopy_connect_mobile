package com.dukascopy.connect.screens.serviceScreen
{
	
	import com.dukascopy.connect.*;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.button.*;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.*;
	import com.dukascopy.connect.screens.keyboardScreens.attachScreen.attachButtons.SimpleActionButton;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.langs.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power2;
	import flash.display.*;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class BottomMenuScreen extends BaseScreen
	{
		private var background:Sprite;
		private var nextButton:BitmapButton;
		private var container:Sprite;
		private var firstTime:Boolean = true;
		private var needExecute:Boolean;
		private var actions:Vector.<IScreenAction>;
		private var buttons:Vector.<SimpleActionButton>;
		private var selectedAction:IScreenAction;
		
		public function BottomMenuScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			if (data != null && data is Vector.<IScreenAction>)
			{
				actions = data as Vector.<IScreenAction>;
			}
			else
			{
				DialogManager.closeDialog();
				return;
			}
			
			_params.doDisposeAfterClose = true;
			
			var button:SimpleActionButton;
			buttons = new Vector.<SimpleActionButton>();
			var padding:int = Config.FINGER_SIZE * .4;
			var position:int = padding + Config.FINGER_SIZE * .3;
			var hPosition:int = - Config.DIALOG_MARGIN;
			var horizontalSize:int = Config.FINGER_SIZE * 1.9;
			var verticalSize:int = Config.FINGER_SIZE * 1.1;
			for (var i:int = 0; i < actions.length; i++) 
			{
				button = new SimpleActionButton(actions[i]);
				button.callback = onSelected;
				button.setSizes(horizontalSize, verticalSize);
				button.show(0);
				button.draw();
				buttons.push(button);
				
				container.addChild(button);
				if (hPosition + button.width + padding < _width - padding * 2 + Config.DIALOG_MARGIN * 2)
				{
					button.x = hPosition + padding;
					button.y = position;
					hPosition += button.width;
				}
				else
				{
					hPosition = 0
					button.x = hPosition;
					hPosition += button.width;
					button.y = position;
					position += padding + button.height;
				}
			}
			if (buttons.length > 0)
			{
				position = buttons[buttons.length - 1].y + buttons[buttons.length - 1].height;
			}
			
			position += padding + Config.FINGER_SIZE * .3;
			
			var paddingOverride:int = Config.DIALOG_MARGIN;
			
			background.graphics.beginFill(0x000000, 0.35);
			background.graphics.drawRect( -paddingOverride, -paddingOverride, _width + paddingOverride * 2, _height + paddingOverride * 2);
			background.graphics.endFill();
			
			container.graphics.beginFill(0xFFFFFF);
			container.graphics.drawRect(-paddingOverride, 0, _width + paddingOverride * 2, position + Config.APPLE_BOTTOM_OFFSET);
			container.graphics.endFill();
			container.y = _height + paddingOverride;
			background.alpha = 0;
		}
		
		private function onSelected(action:IScreenAction):void 
		{
			selectedAction = action;
			needExecute = true;
			close();
		}
		
		override protected function createView():void {
			super.createView();
			
			background = new Sprite();
			view.addChild(background);
			
			container = new Sprite();
			view.addChild(container);
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
			{
				UI.destroy(background);
				background = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (container != null)
			{
				UI.destroy(background);
				background = null;
			}
			
			actions = null;
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].dispose();
				}
			}
			buttons = null;
		}
		
		override public function activateScreen():void
		{
			super.activateScreen();
			
			if (_isDisposed)
			{
				return;
			}
			
			if (firstTime)
			{
				firstTime = false;
				TweenMax.to(container, 0.3, {y:int(_height - container.height + Config.DIALOG_MARGIN + Config.APPLE_BOTTOM_OFFSET), ease:Power2.easeOut});
				TweenMax.to(background, 0.3, {alpha:1});
			}
			
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].activate();
				}
			}
			
			PointerManager.addTap(background, close);
		}
		
		private function close(e:Event = null):void 
		{
			Overlay.removeCurrent();
			deactivateScreen();
			TweenMax.to(container, 0.3, {y:_height, onComplete:remove, ease:Power2.easeIn});
			TweenMax.to(background, 0.3, {alpha:0});
		}
		
		private function remove():void 
		{
			DialogManager.closeDialog();
			if (needExecute == true && selectedAction != null)
			{
				needExecute = false;
				selectedAction.execute();
			}
			selectedAction = null;
		}
		
		override public function deactivateScreen():void
		{
			super.deactivateScreen();
			
			if (_isDisposed)
			{
				return;
			}
			
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].deactivate();
				}
			}
			
			PointerManager.removeTap(background, close);
		}
	}
}