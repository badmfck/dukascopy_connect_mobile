package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public interface IMessageRenderer {
		
		function getHeight(messageVO:ChatMessageVO, maxWidth:int, listItem:ListItem):uint;
		function draw(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null, minWidth:int = -1):void;
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
		
		function get alpha():Number;
		function set alpha(value:Number):void;
	}
}