/**
 * Created by aleksei.leschenko on 13.04.2017.
 */
package com.dukascopy.connect.gui.components.groupList.item.vo {
	public class VOItemGL {
		private var _switchSelected:Boolean;
		private var _id:String;
		public function VOItemGL(id:String) {
			this.id = id;
		}

		public function get switchSelected():Boolean {
			return _switchSelected;
		}

		public function set switchSelected(value:Boolean):void {
			_switchSelected = value;
		}

		public function get id():String {
			return _id;
		}

		public function set id(value:String):void {
			_id = value;
		}
	}
}
