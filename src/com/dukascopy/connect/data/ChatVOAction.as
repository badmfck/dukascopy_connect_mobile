package com.dukascopy.connect.data 
{
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.Open911ScreenAction;
	import com.dukascopy.connect.vo.ChatVO;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ChatVOAction extends ChatVO
	{
		public var action:IScreenAction;
		
		public function ChatVOAction(data:Object = null) 
		{
			super(data);
		}
	}
}