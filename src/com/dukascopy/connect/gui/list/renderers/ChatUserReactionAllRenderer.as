package com.dukascopy.connect.gui.list.renderers 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ChatUserReactionAllRenderer extends ChatUserReactionRenderer
	{
		
		public function ChatUserReactionAllRenderer() 
		{
			super();
		}
		
		override protected function initColors():void 
		{
			colorMine = colorGrey;
			colorAll = colorRed;
		}
	}
}