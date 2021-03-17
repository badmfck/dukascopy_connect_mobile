package com.dukascopy.connect.screens.dialogs.bottom 
{
	import com.dukascopy.connect.Config;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ResizeAnimatedTitlePopup extends AnimatedTitlePopup
	{
		
		public function ResizeAnimatedTitlePopup() 
		{
			super();
		}
		
		override protected function getHeight():int 
		{
			return int(Math.min(_height - Config.FINGER_SIZE * .5, getContentHeight()));
		}
		
		private function getContentHeight():int 
		{
			var result:int = 0;
			if (container != null)
			{
				for (var i:int = 0; i < container.numChildren; i++) 
				{
					result = Math.max(result, container.getChildAt(i).y + container.getChildAt(i).height)
				}
			}
			
			return result;
		}
		
		protected function getMaxContentHeight():int
		{
			return _height - Config.FINGER_SIZE * .5 - headerHeight;
		}
	}
}