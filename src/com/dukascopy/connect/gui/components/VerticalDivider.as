package com.dukascopy.connect.gui.components 
{
	import assets.SortHorizontalIcon;
	import assets.SortVerticalIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class VerticalDivider extends Sprite
	{
		private var icon:SortHorizontalIcon;
		private var callback:Function;
		
		public function VerticalDivider(callback:Function) 
		{
			this.callback = callback;
			
			icon = new SortHorizontalIcon();
			UI.scaleToFit(icon, Config.FINGER_SIZE * .37, Config.FINGER_SIZE * .37);
			addChild(icon);
		}
		
		public function draw(itemHeight:int):void
		{
			graphics.clear();
			graphics.lineStyle(int(Config.FINGER_SIZE * .03), 0xD9D9D9, 1, false, "notmal", CapsStyle.NONE, JointStyle.MITER);
			graphics.moveTo(Config.FINGER_SIZE * .4, 0);
			graphics.lineTo(Config.FINGER_SIZE * .4, itemHeight);
			
			graphics.lineStyle(0, 0xFFFFFF, 0);
			graphics.beginFill(0xFFFFFF, 0);
			graphics.drawCircle(Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .5 + Config.FINGER_SIZE * .07, Config.FINGER_SIZE * .40);
			graphics.endFill();
			
			graphics.lineStyle(int(Config.FINGER_SIZE * .03), 0xD9D9D9);
			graphics.beginFill(0xFFFFFF);
			graphics.drawCircle(Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .5 + Config.FINGER_SIZE * .07, Config.FINGER_SIZE * .30);
			graphics.endFill();
			
			icon.x = int(Config.FINGER_SIZE * .4 - icon.width * .5);
			icon.y = int(Config.FINGER_SIZE * .5 + Config.FINGER_SIZE * .07 - icon.height * .5);
		}
		
		public function activate():void
		{
			PointerManager.addTap(this, onTap);
		}
		
		private function onTap(e:Event = null):void 
		{
			if (callback != null)
			{
				callback();
			}
		}
		
		public function deactivate():void
		{
			PointerManager.removeTap(this, onTap);
		}
		
		public function dispose():void
		{
			callback = null;
			graphics.clear();
			if (icon != null)
			{
				UI.destroy(icon);
				icon = null;
			}
		}
	}
}