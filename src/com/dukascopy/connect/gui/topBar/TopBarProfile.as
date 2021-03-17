package com.dukascopy.connect.gui.topBar {
	
	/**
	 * Используется в UserProfileScreen
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class TopBarProfile extends TopBarWithUserStatus {
		
		public function TopBarProfile() {
			super();
		}
		
		public function setStatusUserUID(userUID:String):void {
			statusUserUID = userUID;
		}
	}
}