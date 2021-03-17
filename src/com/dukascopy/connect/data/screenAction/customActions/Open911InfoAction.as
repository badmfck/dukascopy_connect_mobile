package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.IconInfoClip;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.style.Style;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class Open911InfoAction extends ScreenAction implements IScreenAction {
		
		public function Open911InfoAction() {
			setIconClass(Style.icon(Style.ICON_INFO));
		}
		
		public function execute():void {
			QuestionsManager.showRules();
			dispose();
		}
		
		override public function getIconScale():Number {
			return 20/30;
		}
	}
}