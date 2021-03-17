package com.dukascopy.connect.gui.button 
{
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.greensock.TweenMax;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
		import com.dukascopy.connect.sys.echo.echo;
	/**
	 * ...
	 * @author Anton Bodrychenko
	 */
	public class LongClick
	{
		static public const DELAY:Number = 1.0;
		
		private var longClickCallback:Function;
		private var view:Sprite;
		
		public function LongClick(_view:Sprite, longClickCallback:Function) 
		{
			this.longClickCallback = longClickCallback;
			setup(_view);
		}
		
		
		private function setup(view:Sprite):void 
		{
			this.view = view;
			//view.mouseEnabled = false;
			//view.mouseChildren = false;
			activate();
		}
		
		private function onTouchUp(...rest):void 
		{
			TweenMax.killTweensOf(onLongTap);
		}
		
		private function onTouchDown(...rest):void 
		{
			if(view.visible && view.hitTestPoint(MobileGui.stage.mouseX, MobileGui.stage.mouseY)){
				TweenMax.delayedCall(DELAY, onLongTap);
			}
		}
		
		private function onLongTap():void {
			echo("LongClick", "onLongTap");
			if(view.visible && view.hitTestPoint(MobileGui.stage.mouseX, MobileGui.stage.mouseY)){
				if (longClickCallback!=null) longClickCallback();
			}
		}
		
		public function dispose():void 
		{                   
			deactivate();
			view = null;
			longClickCallback = null;
		}
		
		public function activate():void 
		{
			MobileGui.stage.addEventListener(MouseEvent.MOUSE_DOWN, onTouchDown);
			MobileGui.stage.addEventListener(MouseEvent.MOUSE_UP, 	onTouchUp);
			
		}
		
		public function deactivate():void 
		{
			MobileGui.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onTouchDown);
			MobileGui.stage.removeEventListener(MouseEvent.MOUSE_UP, 	onTouchUp);
		}
		
	}

}