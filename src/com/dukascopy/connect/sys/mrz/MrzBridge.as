package com.dukascopy.connect.sys.mrz {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.call.MRZScanScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class MrzBridge {
		
		static private var started:Boolean;
		static private var errorText:String;
		static private var wasError:Boolean;
		static private var curentResult:String;
		static private var promo:String;
		static private var callbackFunction:Function;
		
		public function MrzBridge() { }
		
		public static function startRecognition(callback:Function, promoCode:String, allowAndroid:Boolean = false, returnToRootScreen:Boolean = false):void {
			if (started == true)
				return;
			promo = promoCode;
			callbackFunction = callback;
			wasError = false;
			errorText = null;
			started = true;
			NativeExtensionController.S_MRZ_RESULT.add(onResult);
			NativeExtensionController.S_MRZ_ERROR.add(onError);
			NativeExtensionController.S_MRZ_STOPPED.add(onStopped);
			if (Config.PLATFORM_ANDROID == false || allowAndroid == true) {
				
				var backScreen:Class = MobileGui.centerScreen.currentScreenClass;
				var backScreenData:Object = MobileGui.centerScreen.currentScreen.data;
				if (returnToRootScreen == true)
				{
					backScreen = RootScreen;
					backScreenData = null;
				}
				
				MobileGui.changeMainScreen(
					MRZScanScreen,
					{
						data:null,
						backScreen:backScreen,
						backScreenData:backScreenData
					}
				);
				return;
			}
			NativeExtensionController.startMrz();
		}
		
		static private function onStopped():void {
			started = false;
			var result:MrzResult;
			if (wasError == true) {
				result = new MrzResult(true, null, null);
			} else if (curentResult == MrzError.ENGINE_INIT_FAILED) {
				result = new MrzResult(true, null, MrzError.ENGINE_INIT_FAILED);
				if (promo != null)
					result.promoCode = promo;
			} else if (curentResult != null) {
				var keysObject:Object;
				try {
					keysObject = JSON.parse(curentResult);
					if ("data" in keysObject == true)
						keysObject = keysObject.data;
					if (keysObject != null) {
						var mrzData:MrzData = new MrzData();
						mrzData.update(keysObject);
						mrzData.keys = new Dictionary();
						for(var key:String in keysObject) {
							mrzData.keys[key] = keysObject[key];
						}
						result = new MrzResult(false, mrzData, null);
					} else {
						result = new MrzResult(true, null, MrzError.RESULT_DATA_BROKEN_FORMAT);
					}
				} catch (err:Error) {
					result = new MrzResult(true, null, MrzError.RESULT_DATA_BROKEN_FORMAT);
				}
			} else {
				result = new MrzResult(true, null, MrzError.RESULT_DATA_EMPTY);
			}
			if (callbackFunction != null) {
				if (promo != null)
					result.promoCode = promo;
				callbackFunction(result);
				callbackFunction = null;
			}
			curentResult = null;
			wasError = false;
			errorText = null;
		}
		
		static private function onError(error:String):void {
			started = false;
			wasError = true;
			errorText = error;
			
			PHP.call_statVI("MRZ_ERROR", error);
			
			NativeExtensionController.S_MRZ_RESULT.remove(onResult);
			NativeExtensionController.S_MRZ_ERROR.remove(onError);
			NativeExtensionController.S_MRZ_STOPPED.remove(onStopped);
		}
		
		static private function onResult(result:String):void {
			curentResult = result;
		}
		
		public static function stopRecognition():void {
			NativeExtensionController.S_MRZ_RESULT.remove(onResult);
			NativeExtensionController.S_MRZ_ERROR.remove(onError);
			NativeExtensionController.S_MRZ_STOPPED.remove(onStopped);
			NativeExtensionController.stopMrz();
		}
	}
}