package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class OpenBankBotAction extends ScreenAction implements IScreenAction {
		
		public function OpenBankBotAction() {
			setIconClass(AvatarBot);
		}
		
		public function execute():void {
			MobileGui.openBankBot();
		}
		
		override public function getIconColor():Number {
			return 0x6E92AF;
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}