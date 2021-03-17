package com.dukascopy.connect.gui.list.renderers.trade {
	
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public interface IMarketplaceRenderer {
		
		function getHeight(data:Object, maxWidth:int, listItem:ListItem):uint;
		function draw(data:Object, maxWidth:int, listItem:ListItem = null):void;
		function getWidth():uint;
		function getBackColor():Number;
		function updateHitzones(itemHitzones:Array):void;
		function getContentHeight():Number;
		function dispose():void;
		function getSmallGap(listItem:ListItem):int;
		function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData;
		function get animatedZone():AnimatedZoneVO;
		function get isReadyToDisplay():Boolean;
		function get y():Number;
		function set y(value:Number):void;
		function get x():Number;
		function set x(value:Number):void;
		function set visible(value:Boolean):void;
		function get width():Number;
		function get height():Number;
		function get alpha():Number;
		function set alpha(value:Number):void;
	}
}