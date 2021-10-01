package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.AddItemButton;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.EscrowAdsCreateScreen;
	import com.dukascopy.connect.screens.QuestionCreateUpdateScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class Create911QuestionAction extends ScreenAction implements IScreenAction {
		
		public function Create911QuestionAction() {
			setIconClass(Style.icon(Style.ICON_ADD));
		}
		
		public function execute():void {
			if (QuestionsManager.checkForUnsatisfiedQuestions() == true) {
				DialogManager.alert(Lang.information, Lang.limitQuestionExists);
				return;
			}
			MobileGui.changeMainScreen(EscrowAdsCreateScreen, {
					backScreen:RootScreen,
					title:Lang.escrow_create_your_ad, 
					backScreenData:null,
					data:null
				}, ScreenManager.DIRECTION_RIGHT_LEFT
			);
			dispose();
		}
		
		override public function getIconScale():Number {
			return 20/30;
		}
	}
}