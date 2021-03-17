/**
 * Created by aleksei.leschenko on 23.12.2016.
 */
package com.dukascopy.connect.gui.tabs {
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;

	import flash.display.DisplayObject;

	public interface ITabsItem {

		function rebuild(height:int):void;

		//function getWidthTF():Number;
		function dispose():void

		function get id():String;

		function get selection():Boolean

		function get num():int

		function get bg():ImageBitmapData;

		function get doSelection():Boolean

		function setSelection(val:Boolean):void
		function get view():DisplayObject;

		function cutByLeft(cutWidth:Number):void;
	}
}
