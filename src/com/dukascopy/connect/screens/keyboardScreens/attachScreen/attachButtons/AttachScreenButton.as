package com.dukascopy.connect.screens.keyboardScreens.attachScreen.attachButtons {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class AttachScreenButton extends Sprite {
		
		protected var buttonClip:BitmapButton;
		protected var action:IScreenAction;
		private var offset:int = -1;
		private var size:int;
		private var mainHeight:int;
		private var padding:int = 0;
		private var rotationAdded:Number = 0;
		protected var mainWidth:int;
		
		public function AttachScreenButton(action:IScreenAction) {
			this.action = action;
			create();
		}	
		
		protected function create():void {
			buttonClip = new BitmapButton();
			buttonClip.setStandartButtonParams();
			buttonClip.setDownScale(1);
			buttonClip.usePreventOnDown = false;
			buttonClip.cancelOnVerticalMovement = true;
			buttonClip.tapCallback = onClick;
			buttonClip.hide(0);
			addChild(buttonClip);
			alpha = 0.4;
		}
		
		private function applyOverflow(offset:int):void {
			if (offset != -1 && buttonClip)
				buttonClip.setOverflow(offset, offset, offset, offset);
		}
		
		public function draw():void {
			var icon:MovieClip;
			if (buttonClip && action && action.getIconClass() != null) {
				icon = new (action.getIconClass())();
				buttonClip.setBitmapData(
					UI.renderAsset(
						icon,
						mainWidth - padding,
						mainHeight - padding - getAdditionalContentHeight(),
						true,
						"AttachScreenButton.icon"
					)
				);
				var l:int = icon.currentLabels.length;
				for (var i:int = 0; i < l; i++) {
					if (icon.currentLabels[i].name == "down") {
						icon.gotoAndStop("down");
						buttonClip.setUpState(
							UI.renderAsset(
								icon,
								mainWidth - padding,
								mainHeight - padding - getAdditionalContentHeight(),
								true,
								"AttachScreenButton.icon"
							)
						);
					}
				}
			}
			icon = null;
			
			buttonClip.x = int((mainWidth - buttonClip.width) * .5);
			buttonClip.y = int((mainHeight - (buttonClip.height + getAdditionalContentHeight())) * .5);
			buttonClip.setOverflow(buttonClip.y, buttonClip.x, buttonClip.x, mainHeight - buttonClip.height - buttonClip.y);
			buttonClip.rotationAdded = rotationAdded;
		}
		
		protected function getAdditionalContentHeight():int {
			return 0;
		}
		
		protected function onClick():void {
			if (action)
				action.execute();
		}
		
		public function dispose():void {
			if (buttonClip)
				buttonClip.dispose();
			buttonClip = null;
			if (action != null)
				action.dispose();
			action = null;
		}
		
		public function setOffset(offset:int):void 
		{
			this.offset = offset;
			applyOverflow(offset);
		}
		
		public function setSize(size:int):void 
		{
			this.size = size;
		}
		
		public function show(_time:Number = 0, _delay:Number = 0, overrideAnimation:Boolean = true):void {
			if (buttonClip != null)
				buttonClip.show(_time, _delay, overrideAnimation, 0.85, 0);
		}
		
		public function hide():void {
			if (buttonClip)
				buttonClip.hide();
		}
		
		public function activate():void {
			alpha = 1;
			if (buttonClip)
				buttonClip.activate();
		}
		
		public function deactivate():void {
			alpha = 0.4;
			if (buttonClip)
				buttonClip.deactivate();
		}
		
		public function setSizes(horizontalSize:int, verticalSize:int, padding:int = -1):void {
			this.mainWidth = horizontalSize * .9;
			this.mainHeight = verticalSize * .9;
			if (padding == -1) {
				this.padding = Config.DOUBLE_MARGIN * 2;
			}
			else {
				this.padding = padding;
			}
			this.padding = padding;
		}
		
		public function setRotation(value:Number):void {
			rotationAdded = value;
			if (buttonClip != null) {
				buttonClip.rotationAdded = rotationAdded;
			}
		}
	}
}