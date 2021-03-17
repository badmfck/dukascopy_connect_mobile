package com.dukascopy.connect.screens.base {
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;

	/**
	 * ...
	 * @author Igor Bloom
	 */
	
	 
	public class ScreenParams{

		
		public static const TOP_BAR_HIDE:int = 0;
		public static const TOP_BAR_AUTOHIDE:int = 1;
		public static const TOP_BAR_SHOW:int = 2;
		public static const TOP_BAR_RELATIVE:int = 3;
		
		
		public var title:String;
		public var topBarVisibility:int;
		public var transparentBg:Boolean=true;
		public var doDisposeAfterClose:Boolean=true;
		public var hasSearchBar:Boolean = false;
		public var actions:Vector.<IScreenAction>;
	
		public function ScreenParams(title:String = 'unknown', topBarVisibility:int = TOP_BAR_HIDE){
			this.title = title;
			this.topBarVisibility = topBarVisibility;
		}
		
		public function addAction(action:ScreenAction):void
		{
			actions ||= new Vector.<IScreenAction>();
			actions.push(action);
		}
		
	}
}