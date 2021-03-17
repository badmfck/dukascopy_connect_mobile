package com.dukascopy.connect.sys.bot 
{
	import com.dukascopy.connect.vo.users.adds.BotVO;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class GroupData 
	{
		public var items:Array;
		
		public function GroupData() 
		{
			
		}
		
		public function addItem(value:BotVO):void
		{
			if (items == null)
			{
				items = new Array();
			}
			items.push(value);
		}
	}
}