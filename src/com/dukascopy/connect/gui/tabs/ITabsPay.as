/**
 * Created by aleksei.leschenko on 27.02.2017.
 */
package com.dukascopy.connect.gui.tabs {
	import com.dukascopy.connect.gui.tabs.vo.TabsItemVO;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;

	public interface ITabsPay {
		/**
		 * first add all element than drawView
		 * @param vos
		 */
		function adds(vos:Vector.<TabsItemVO>):void;
		/**
		 *
		 * @param name - text
		 * @param id - init name
		 * @param icon
		 * @param bg
		 * @param doSelection
		 * @param neadDrawView - in old versio draw after each add(), new method add element is using adds();
		 */
		 function add(name:String, id:String, icon:ImageBitmapData = null, bg:ImageBitmapData = null, doSelection:Boolean = true, neadDrawView:Boolean = true):void

		function remove(id:String):Boolean;
		function removeAll():void;
		function activate():void;
		function deactivate():void;
		function dispose():void;
		function selectCurrent():void;
		function select(id:String, animate:Boolean = true, ignoreSide:Boolean = false):void;

		function selectFirst(ignoreSide:Boolean = false):void;
		function selectLast():void;
		function selectNext():void;
		function selectPrev():void;
		function setWidthAndHeight(w:int, h:int):void;
		function setY(y:int):void;
		function setX(x:int):void;
		function get height():int;
		function get offsetTop():int;
		function set selectionPosition(value:int):void;
		function get width():int;
	}

}
