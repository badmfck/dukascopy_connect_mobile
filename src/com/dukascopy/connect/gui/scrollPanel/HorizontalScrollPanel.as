package com.dukascopy.connect.gui.scrollPanel 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.sys.tapper.TapperInstance;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power2;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class HorizontalScrollPanel extends ScrollPanel
	{
		public function HorizontalScrollPanel(){
			super();
			scrollBar.visible = false;
		}
		
		override public function enable():void {
			if (_isDisposed)
				return;
			/*if (scrollBar != null)
				scrollBar.visible = true;*/
			if (tapper == null){
				tapper = new TapperInstance(MobileGui.stage, box, onMoved, [_width, _height], 'x');
			}
			tapper.setTapCallback(onTap);
			tapper.activate();
		}
		
		override protected function onMoved(scrollStopped:Boolean = false):void {
			//echo("ScrollPanel", "onMoved");
			if (scrollStopped == false)
				scrollBar.alpha = 1;
			checkBoxBounds(scrollStopped);
			var l:int = items.length;
			for (var n:int = 0; n < l; n++) {
				var i:DisplayObject = (items[n] is MobileClip) ? items[n].view : items[n];
				var trueX:int = i.x + box.x;
				if (trueX + i.width > 0 && trueX < _width) {
					if (i.visible == false)
						i.visible = true;
				}else {
					if(i.visible==true && changeItemVisibility == true)
						i.visible = false;
				}
			}
			if (scrollCallbackFunction != null)
			{
				scrollCallbackFunction();
			}
			Overlay.removeCurrent();
		}
		
		override protected function checkBoxBounds(scrollStopped:Boolean=false):void{
			var b:int = _width - box.width;
			if (box.width <= _width) {
				box.x = 0;
				scrollBar.alpha = 0;
			} else {
				if (scrollStopped) {
					if (box.x + box.width < _width) {
						TweenMax.to(box, 10, { useFrames:true, x:int(_width - box.width), 
						onUpdate:onMoved } );
					} else if (box.x > 0) {
						TweenMax.to(box, 10, { useFrames:true, x:0, 
						onUpdate:onMoved, onComplete:onTweenMovingComplete } );
					}
					TweenMax.to(scrollBar, 10, { useFrames:true, alpha:0});
				}else {
					if (box.x > 0){
						box.x -= int(box.x * .4);
					}else if (box.x + /*box.height */+box.width < _width) {
						box.x -= int((box.x-(_width - box.width)) * .4);
					}
				}
			}
			var razn:Number = -box.x / (box.width - _width);
			scrollBar.x = (_width - scrollBar.width) * razn;
		}
		
		override protected function setScrollBarSize():void {
			var h:Number = (_height / box.width) * _width;
			scrollBar.graphics.clear();
			if (h < _width) {
				if (h < Config.FINGER_SIZE*.5)
					h = Config.FINGER_SIZE*.5;
				scrollBar.graphics.beginFill(0x7E95A8, .4);
				scrollBar.graphics.drawRect(0, 0, h, scrollBarWidth);
			}
			scrollBar.y = int( _height - scrollBarWidth);
		}
		
		override protected function checkForItemInFocus():void {
			if (MobileGui.softKeyboardOpened == true || MobileGui.softKeyboardMoving == true) {
				var focusObject:DisplayObject = findObjectWithFocus(box);
				if (focusObject == null)
					return;
				var trueX:int = view.globalToLocal(focusObject.localToGlobal(__point(0, 0))).x;
				var xAndH:int = trueX + focusObject.width + Config.DOUBLE_MARGIN;
				
				if (!(trueX > -1 && xAndH < _width)) {
					// NEED TO SCROLL TO ITEM!
					if (tapper != null)
						tapper.stop();
					TweenMax.killTweensOf(box);
					if (trueX > 0)
					{
						var newPos:Number = box.x - (xAndH - _width);
						if (newPos + box.width < _width && box.width > _width)
						{
							newPos = _width - box.width;
						}
						box.x = newPos;
					}
					else
						box.x = 0;
					onMoved(true);
				}
			} else {
				if (box.x + box.width < _width) {
					box.x = Math.min(0, _width - box.width);
				}
			}
		}
		
		override public function getPositionY():int {
			return box.x;
		}
		
		override public function fitInScrollArea():Boolean 
		{
			return box.width <= _width;
		}
		
		override public function scrollToBottom():void 
		{
			if (box.width > _width)
			{
				box.x = _width - box.width;
				onMoved(true);
			}
		}
		
		override public function scrollToPosition(position:int, animate:Boolean = false, time:Number = 0.2, delay:Number = 0):void 
		{
			var newPosition:int = -position;
			
			if (newPosition + box.width < _width)
			{
				newPosition = _width - box.width;
			}
			if (animate == true)
			{
				if (newPosition != box.x)
				{
					TweenMax.to(box, time, { useFrames:false, x:newPosition, ease:Power2.easeOut, delay:delay,
						onUpdate:onMoved, onComplete:onTweenMovingComplete } );
				}
			}
			else
			{
				box.x = newPosition;
				onMoved();
			}
		}
		
		override public function isItemVisible(item:Sprite):Boolean 
		{
			if (item.x + box.x < 0)
			{
				return false;
			}
			else if (item.x + box.x + item.width > _width)
			{
				return false;
			}
			return true;
		}
		
		override public function get itemsHeight():int {
			return box.width;
		}
	}
}