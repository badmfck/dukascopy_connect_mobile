package com.dukascopy.connect.screens.roadMap.actions 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.BaseAction;
	import com.dukascopy.connect.data.screenAction.IAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.screens.roadMap.RoadMapScreenNew;
	import com.dukascopy.connect.sys.mrz.MrzBridge;
	import com.dukascopy.connect.sys.mrz.MrzData;
	import com.dukascopy.connect.sys.mrz.MrzError;
	import com.dukascopy.connect.sys.mrz.MrzResult;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ScanDocumentAction extends BaseAction implements IAction 
	{
		private var inAction:Boolean;
		
		public function ScanDocumentAction() 
		{
			
		}
		
		public function execute():void 
		{
			inAction = true;
			showBirthdatePopup();
		}
		
		private function showBirthdatePopup():void 
		{
			if (Config.PLATFORM_ANDROID == true && NativeExtensionController.getVersion() > 22) {
				MrzBridge.startRecognition(onMrzScannedAndroid, null);
			}
			else
			{
				MrzBridge.startRecognition(onMrzScanned, null, false, false);
			}
		}
		
		private function onMrzScannedAndroid(result:MrzResult):void {
			if (result.error == true && result.errorText == MrzError.ENGINE_INIT_FAILED)
			{
				ToastMessage.display(result.getErrorLocalized());
				// fallback to server recognition;
				MrzBridge.startRecognition(onMrzScanned, result.promoCode, true, true);
			}
			else
			{
				onMrzScanned(result);
			}
		}
		
		private function onMrzScanned(result:MrzResult):void {
			if (result.error == false) {
				saveBirthDate(result.data);
			}
			else {
				ToastMessage.display(result.getErrorLocalized());
				if (disposed == false)
				{
					inAction = false;
					if (S_ACTION_FAIL != null)
					{
						S_ACTION_FAIL.invoke();
					}
				}
				return;
			}
		}
		
		private function saveBirthDate(mrzData:MrzData):void 
		{
			var birthDate:String = "";
			if (mrzData != null) {
				birthDate = mrzData.dateOfBirth;
			}
			else
			{
				ToastMessage.display(Lang.textError);
				if (disposed == false)
				{
					inAction = false;
					if (S_ACTION_FAIL != null)
					{
						S_ACTION_FAIL.invoke();
					}
				}
				
				return;
			}
			
			var curDate:Date = new Date();
			var tmp:Array = birthDate.split(/\D/);
			if (tmp.length == 3) {
				var mrzY:int = parseInt(tmp[2]);
				var mrzM:int = parseInt(tmp[1]);
				var mrzD:int = parseInt(tmp[0]);
				
				var mounth:String = mrzM.toString();
				if (mounth != null && mounth.length == 1)
				{
					mounth = "0" + mounth;
				}
				var day:String = mrzD.toString();
				if (day != null && day.length == 1)
				{
					day = "0" + day;
				}
				birthDate = mrzY.toString() + "-" + mounth + "-" + day;
			}
			else
			{
				ToastMessage.display(Lang.textError);
				if (disposed == false)
				{
					inAction = false;
					if (S_ACTION_FAIL != null)
					{
						S_ACTION_FAIL.invoke();
					}
				}
				return;
			}
			
			RoadMapScreenNew.busy = true;
			PHP.user_saveExtraData(onBirthdateSave, "birthDate", birthDate);
		}
		
		private function onBirthdateSave(respond:PHPRespond):void 
		{
			respond.dispose();
			inAction = false;
			if (S_ACTION_SUCCESS != null)
			{
				S_ACTION_SUCCESS.invoke();
			}
		}
		
		override public function dispose():void {
			if (inAction == true)
			{
				return;
			}
			super.dispose();
		}
	}
}