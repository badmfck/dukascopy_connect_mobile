package com.dukascopy.connect.data.screenAction {
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ScreenAction extends BaseAction {
		
		private var iconClass:Class;
		
		public function ScreenAction() { }
		
		public function setIconClass(value:Class):void { iconClass = value; }
		public function getIconClass():Class { return iconClass; }
		
		public function getIconScale():Number { return 1; }
		
		public function getIconColor():Number { return NaN; }
		
		public function get avatarURL():String {
			return null;
		}
	}
}