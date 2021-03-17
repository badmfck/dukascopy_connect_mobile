package com.dukascopy.connect.gui.menuVideo {
	
	import assets.NumericKeyboardIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Quad;
	import com.telefision.utils.Loop;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class HidableButton extends Sprite {
		
		public var VERTICAL_CLICK_SENSITIVITY:int = Config.FINGER_SIZE * .3;
		public var HORIZONTAL_CLICK_SENSITIVITY:int = Config.FINGER_SIZE * .3;
		
		private var stageRef:Stage;
		private var button:BitmapButton;
		
		private var anchorX:int = 0;
		private var anchorY:int = 0;
		
		private var isCollapsed:Boolean = true;
		private var isDown:Boolean =  false;
		private var isWiggeling:Boolean =  false;
		private var downX:int = 0;
		private var downY:int = 0;
		private var downButtonX:int = 0;
		private var downButtonY:int = 0;
		
		private var diffVerticalOnDetect:int = 0;
		private var diffHorizontalOnDetect:int = 0;
		
		private var dragDetected:Boolean = false;
		private var offset:int;
		private var hidable:Boolean = true;
		
		public var tapCallback:Function = null;
		public var hideDistance:int = Config.FINGER_SIZE_DOT_5 + Config.DOUBLE_MARGIN;
		
		public function HidableButton() {
			button = new BitmapButton();
			button.setStandartButtonParams();
			button.setDownScale(1);
			button.usePreventOnDown = false;
			button.setOverflow(10, 10, 10, 10);
			addChild(button);
			button.show();
			tweenToAnchors(0);
			var phoneIcon:NumericKeyboardIcon = new NumericKeyboardIcon();
			setDesign(phoneIcon);
			phoneIcon = null;
		}
		
		public function setDesign(asset:DisplayObject, size:int = -1):void {
			if (asset != null) {
				if (size == -1){
					size = Config.FINGER_SIZE;
				}
				hideDistance = size * .5 + Config.DOUBLE_MARGIN;
				UI.scaleToFit(asset, size, size);				
				button.setBitmapData(UI.getSnapshot(asset, StageQuality.HIGH, "FindUserScreen.searchButton"),true);	
			}		
		}
		
		// POINTER EVENTS===============================================
		/**
		 * TODO refactor and optimize logic
		 * @param	e
		 */
		private function onDown(e:Event = null):void {
			if (button == null) return;
			
			dragDetected = false;
			isDown = true;
			e.preventDefault();
			e.stopImmediatePropagation();
				
			downX =  MobileGui.stage.mouseX;
			downY =  MobileGui.stage.mouseY;		
			
			downButtonX = button.x;
			downButtonY = button.y;
			
			TweenMax.killDelayedCallsTo(hideOnTimeout);
			Loop.add(checkForMoved);				
			PointerManager.addUp(stageRef, onStageUp);
		}
			
		
		public function startWiggle():void {
			if (isWiggeling) return;
			isWiggeling = true;			
			jump();
		}
		
		public function stopWiggle():void {
			isWiggeling = false;
			TweenMax.killTweensOf(button);
			tweenToAnchors();
		}
		
		private function jump():void {
			if(isWiggeling && isCollapsed && !isDown){
				TweenMax.killTweensOf(button);
				TweenMax.to(button, .3, {x:anchorX + hideDistance -Config.FINGER_SIZE_DOT_5, ease:Quad.easeOut});
				TweenMax.to(button, 1, {x:anchorX + hideDistance ,delay:.3, ease:Bounce.easeOut, onComplete:jump});
			}
		}
		
		
	
		private function onStageUp(e:Event = null):void {		
			isDown = false;
			PointerManager.removeUp(stageRef, onStageUp);
			Loop.remove(checkForMoved);	
			
			TweenMax.killDelayedCallsTo(hideOnTimeout);
			TweenMax.delayedCall(3, hideOnTimeout);
			
			if (!dragDetected){
				
				if (isCollapsed){
					
					if (isWiggeling){
						if (tapCallback != null){
							hideOnTimeout();
							tapCallback();
						}
					}else{
						isCollapsed = !isCollapsed;
						tweenToAnchors(.7);
					}
					// Start timeout
				
				}else{
					//trace("OPEN CHAT");
					if (tapCallback != null){
						hideOnTimeout();
						tapCallback();
					}
				}
			}else{
				//trace("Position to anchor points depending on hidden or showed");
				// check direction positive or negative and decide anchors 				
				var isDraggingRight:Boolean = (MobileGui.stage.mouseX - downX)>0;
				if (isDraggingRight){						
					isCollapsed = true;
					TweenMax.killDelayedCallsTo(hideOnTimeout);
				}else{
					isCollapsed = false;	
					// Start timeout
					TweenMax.killDelayedCallsTo(hideOnTimeout);
					TweenMax.delayedCall(3, hideOnTimeout);
				}
				tweenToAnchors();
			}			
		}
		
		
		private function hideOnTimeout():void {
			if (hidable == true)
			{
				isCollapsed = true;
				tweenToAnchors(.7);
			}
		}
		
		
		private function checkForMoved():void 	{
			// clamp stage coordinates		
			var mY:int = MobileGui.stage.mouseY;
			var mX:int = MobileGui.stage.mouseX;	
			const sH:int = MobileGui.stage.stageHeight;
			const sW:int = MobileGui.stage.stageWidth;
			const topLimit:int =  sH * .7;
			const leftLimit:int =  0;
			const bottomLimit:int =  sH - offset;
			
			if (mY < topLimit){
				var diff:int = mY - topLimit;
				mY = topLimit + diff*.5;			
			}			
				
			var horizontalMovement:Number = mX - downX;
			var verticalMovement:Number   = mY - downY;	
			
			var movedHorizontal:Boolean = abs(horizontalMovement) > HORIZONTAL_CLICK_SENSITIVITY;
			var movedVertical:Boolean = abs(verticalMovement) > VERTICAL_CLICK_SENSITIVITY;
			
			if (dragDetected && button != null){
				var destX:int =  horizontalMovement - diffHorizontalOnDetect + downButtonX ;
				var destY:int =  verticalMovement - diffVerticalOnDetect + downButtonY ;			
				if ( destY >= bottomLimit - button.height){
					destY = bottomLimit - button.height;
				}
				if (destX < leftLimit) destX = leftLimit;
				
				TweenMax.killTweensOf(button);
				button.x = destX;
				button.y = destY;				
				return;
			}
			
		
			if (movedVertical || movedHorizontal){
			//if (movedHorizontal){
				dragDetected = true;						
				diffHorizontalOnDetect = horizontalMovement;
				diffVerticalOnDetect = verticalMovement;	
				
				var destXX:int = horizontalMovement - diffHorizontalOnDetect + downButtonX ;
				var destYY:int =  verticalMovement - diffVerticalOnDetect + downButtonY ;		
				if ( destYY >= bottomLimit - button.height){
					destYY = bottomLimit - button.height;
				}
				if (destXX < leftLimit) destXX = leftLimit;
				button.x = destXX;
				button.y = destYY;					
			}		
			
		}
		
		public function setPosition(xPos:int=0, yPos:int=0):void {
			anchorX = xPos;
			anchorY = yPos;
			if(!isDown)
				tweenToAnchors(0);
		}
		
		private function tweenToAnchors(time:Number = .8):void	{
			var dx:int = (isCollapsed == true) ? anchorX + hideDistance : anchorX;			
			TweenMax.killTweensOf(button);
			TweenMax.to(button, time , {x:dx,y:anchorY, ease:Elastic.easeOut, onComplete:onButtonPlacedComplete});
		}		
		
		private function onButtonPlacedComplete():void 
		{
			jump();
		}
		
		private function addEvents():void{
			stageRef = MobileGui.stage;
			PointerManager.addDown(this, onDown);
		}
		
		private function removeEvents():void {
			PointerManager.removeUp(stageRef, onStageUp);
			PointerManager.removeDown(this, onDown);
		}
		
		public function activate():void	{
			addEvents();
			if(button!=null){
				button.activate();
			}
		}
		
		public function deactivate():void{
			removeEvents();
			if(button!=null){
				button.deactivate();
			}
		}
		
		public function dispose():void	{
			removeEvents();
			if(button!=null){
				TweenMax.killTweensOf(button);
				button.dispose();
				button = null;
			}
			isWiggeling = false;
			TweenMax.killDelayedCallsTo(hideOnTimeout);
		}				
		
		public static function abs( value:Number ):Number {	return 	(value ^ (value >> 31)) - (value >> 31); }
		public function setOffset(val:int):void {
			offset = val;
		}
		
		public function unhide():void 
		{
			hidable = false;
			isCollapsed = false;
			tweenToAnchors(0);
		}
	}
}