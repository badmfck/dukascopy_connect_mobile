package com.dukascopy.connect.screens.dialogs.escrow {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.screens.dialogs.x.base.float.FloatPopup;
	
	/**
	 * ...
	 * @author Sergey Dobarin.
	 */

	public class EscrowDealScreen extends FloatPopup {
		
		protected var illustrationSize:int = 0;
		
		public function EscrowDealScreen() { }
		
		override protected function getHeight():int 
		{
			return _height - Config.FINGER_SIZE * .5 - illustrationSize * .5;
		}
	}
}