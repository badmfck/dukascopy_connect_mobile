/**
 * Created by aleksei.leschenko on 27.02.2017.
 */
package com.dukascopy.connect.gui.tabs.vo {
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;

	public class TabsItemVO {
		private var _name:String;
		private var _id:String;
		private var _icon:ImageBitmapData;
		private var _bg:ImageBitmapData;
		private var _doSelection:Boolean;
		public const neadDrawView:Boolean = false;
		public function TabsItemVO(name:String, id:String, icon:ImageBitmapData = null, bg:ImageBitmapData = null, doSelection:Boolean = true, neadDrawView:Boolean = false) {
			_name = name;
			_id = id;
			_icon = icon;
			_bg = bg;
			_doSelection = doSelection;
		}

		public function get name():String {
			return _name;
		}

		public function set name(value:String):void {
			_name = value;
		}

		public function get id():String {
			return _id;
		}

		public function set id(value:String):void {
			_id = value;
		}

		public function get icon():ImageBitmapData {
			return _icon;
		}

		public function set icon(value:ImageBitmapData):void {
			_icon = value;
		}

		public function get bg():ImageBitmapData {
			return _bg;
		}

		public function set bg(value:ImageBitmapData):void {
			_bg = value;
		}

		public function get doSelection():Boolean {
			return _doSelection;
		}

		public function set doSelection(value:Boolean):void {
			_doSelection = value;
		}
	}
}
