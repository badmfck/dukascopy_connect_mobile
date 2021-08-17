package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.AddItemButton;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.QuestionCreateUpdateScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.dialogs.escrow.EscrowFilterScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ShowFilterEscrowAction extends ScreenAction implements IScreenAction {
		
		public function ShowFilterEscrowAction() {
			setIconClass(Style.icon(Style.ICON_FILTERS));
		}
		
		public function execute():void {
			DialogManager.showDialog(EscrowFilterScreen, {title:Lang.escrow_filter_title}, DialogManager.TYPE_SCREEN);
		//	dispose();
		}
		
		override public function getIconScale():Number {
			return 20/30;
		}
	}
}