package com.dukascopy.connect.gui.list.renderers 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ChatUserReactionMineRenderer extends ChatUserReactionRenderer
	{
		
		public function ChatUserReactionMineRenderer() 
		{
			super();
		}
		
		override protected function initColors():void 
		{
			colorMine = colorRed;
			colorAll = colorGrey;
		}
	}
}