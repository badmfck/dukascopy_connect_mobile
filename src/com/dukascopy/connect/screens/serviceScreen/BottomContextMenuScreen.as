package com.dukascopy.connect.screens.serviceScreen
{
	
	import com.dukascopy.connect.*;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.IUpdatableAction;
	import com.dukascopy.connect.data.screenAction.UpdatebleAction;
	import com.dukascopy.connect.gui.button.*;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.*;
	import com.dukascopy.connect.screens.keyboardScreens.attachScreen.attachButtons.HorizontalActionButton;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.langs.*;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power2;
	import flash.display.*;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class BottomContextMenuScreen extends BaseScreen
	{
		private var background:Sprite;
		private var nextButton:BitmapButton;
		private var container:Sprite;
		private var firstTime:Boolean = true;
		private var needExecute:Boolean;
		private var actions:Vector.<IScreenAction>;
		private var buttons:Vector.<HorizontalActionButton>;
		private var selectedAction:IScreenAction;
		
		public function BottomContextMenuScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			var paddingOverride:int = Config.DIALOG_MARGIN;
			
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
			
			var button:HorizontalActionButton;
			buttons = new Vector.<HorizontalActionButton>();
			var position:int = 0
			
			for (var i:int = 0; i < actions.length; i++) 
			{
				button = new HorizontalActionButton(actions[i], _width + paddingOverride * 2);
				if (actions[i] is UpdatebleAction)
				{
					(actions[i] as UpdatebleAction).getUpdateSignal().add(onActoinUpdate);
				}
				
				button.callback = onSelected;
				button.show(0);
				button.draw();
				button.y = position;
				button.x = - paddingOverride;
				buttons.push(button);
				
				container.addChild(button);
				
				position += button.height;
			}
			if (buttons.length > 0)
			{
				position = buttons[buttons.length - 1].y + buttons[buttons.length - 1].height;
			}
			
			position += Config.FINGER_SIZE * .6;
			
			background.graphics.beginFill(Color.BLACK_TRUE, 0.35);
			background.graphics.drawRect( -paddingOverride, -paddingOverride, _width + paddingOverride * 2, _height + paddingOverride * 2);
			background.graphics.endFill();
			
			container.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			container.graphics.drawRect(-paddingOverride, 0, _width + paddingOverride * 2, position + Config.APPLE_BOTTOM_OFFSET);
			container.graphics.endFill();
			container.y = _height + paddingOverride;
			background.alpha = 0;
		}
		
		private function onActoinUpdate(action:UpdatebleAction):void 
		{
			if (buttons != null)
			{
				var l:int = buttons.length;
				for (var i:int = 0; i < l; i++) 
				{
					if (buttons[i].getAction() == action)
					{
						buttons[i].update();
					}
				}
			}
		}
		
		private function onSelected(action:IScreenAction):void 
		{
			if (action is IUpdatableAction && (action as IUpdatableAction).enable == false)
			{
				return;
			}
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
					if (buttons[i] is UpdatebleAction && (buttons[i] as UpdatebleAction).getUpdateSignal() != null)
					{
						(buttons[i] as UpdatebleAction).getUpdateSignal().remove(onActoinUpdate);
					}
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