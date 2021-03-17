package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.SendGiftIcon;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.chatInput.ChatInputAndroid;
	import com.dukascopy.connect.sys.Gifts;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.Style;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class OpenGiftsAction extends ScreenAction implements IScreenAction
	{
		
		public function OpenGiftsAction()
		{
			setIconClass(Style.icon(Style.ICON_ATTACH_GIFT));
		}
		
		public function execute():void
		{
			if (Gifts.tuturialShown)
			{
				ChatInputAndroid.S_ATTACH.invoke(ChatInputAndroid.ATTACH_GIFT);
				dispose();
			}
			else
			{
				Store.load(Store.VAR_GIFTS_TUTORIAL_SHOWN, onTutorialStatusLoaded);
			}
		}
		
		private function onTutorialStatusLoaded(data:Object, err:Boolean):void {
			if (err == true || data == null)
			{
				Gifts.showTutorial();
			}
			else
			{
				Gifts.tuturialShown = true;
				ChatInputAndroid.S_ATTACH.invoke(ChatInputAndroid.ATTACH_GIFT);
			}
			dispose();
		}
	}
}