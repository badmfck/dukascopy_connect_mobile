package com.dukascopy.connect.data 
{
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class LabelItem 
	{
		public var action:IScreenAction;
		public var label:String;
		
		public function LabelItem(label:String, action:IScreenAction = null) 
		{
			this.label = label;
			this.action = action;
		}
	}
}