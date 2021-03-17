package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.Gifts;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class SendGiftAction extends ScreenAction implements IScreenAction
	{
		
		public function SendGiftAction()
		{
			
		}
		
		public function execute():void
		{
			Gifts.startGift(data as int);
		}
	}
}