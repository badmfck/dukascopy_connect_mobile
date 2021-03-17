package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.IconHelpClip3;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.langs.LangManager;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class Open911FaqAction extends ScreenAction implements IScreenAction {
		
		public function Open911FaqAction() {
			setIconClass(IconHelpClip3);
		}
		
		public function execute():void {
			var lang:String =  LangManager.model.getCurrentLanguageID();
			var link:String =  "https://www.dukascopy.bank/swiss/faq/#faq12"
			if (lang != ""){
				link = "https://www.dukascopy.bank/swiss/faq/?lang="+lang+"#faq12"
			}				
			navigateToURL(new URLRequest(link));
			dispose();
		}
	}
}