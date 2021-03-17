package com.dukascopy.connect.gui.list.renderers{
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.list.ListItem;
	import flash.display.IBitmapDrawable;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	public interface IListRenderer{
		function getHeight(data:ListItem,width:int):int;
		function getView(data:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable;
		function get isTransparent():Boolean;
		function dispose():void;
		function getSelectedHitzone(itemTouchPoint:Point, item:ListItem):HitZoneData;
		function getOverlayPosition():Rectangle;
	}
}