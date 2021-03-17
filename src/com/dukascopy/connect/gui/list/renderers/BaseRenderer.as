package com.dukascopy.connect.gui.list.renderers 
{
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.list.ListItem;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class BaseRenderer extends Sprite
	{
		
		public function BaseRenderer() 
		{
			
		}
		
		public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData
		{
			return null;
		}
		
		public function getOverlayPosition():Rectangle
		{
			return null;
		}
	}
}