package com.dukascopy.connect.sys.settings {
	
	import com.dukascopy.connect.data.settings.SettingsControlData;
	import com.dukascopy.connect.data.settings.SettingsControlType;
	import com.dukascopy.connect.data.settings.SettingsValue;
	import com.dukascopy.connect.data.settings.SettingsValueType;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.sound.SoundController;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	
	/**
	 * ...
	 * @author Alexey
	 */
	
	public class GlobalSettings {
		
		public function GlobalSettings() { }
		
	//	public static const SETTING_SHOW_NOTIFICATIONS:String = "settings_notification";
		public static const SETTING_USE_MESSAGE_SOUND:String = "settings_message_sound";
		public static const SETTING_USE_CALL_SOUND:String = "settings_call_sound";
		public static const SETTINGS_DATA:String = "settings_data_array";
		public static const SETTINGS_PENDING_DATA:String = "settings_pending_data_array";
		
		static public var SETTINGS_LOADED:Signal = new Signal('GlobalSettings.SETTINGS_LOADED');
		
	//	public static var notifications:Boolean = true;
		public static var soundOnMessages:Boolean = true;
		public static var soundOnCalls:Boolean = true;
		public static var userLanguage:String = "en";
		
		public static var S_UPDATE:Signal = new Signal('GlobalSettings.S_UPDATE');
		static private var isLoading:Boolean;
		static private var needUploadSettings:Boolean;
		static private var settingsReady:Boolean = false;
		static private var controlsData:Vector.<SettingsControlData>;
		
		public static function initSettings():void {
		//	Store.load(SETTING_SHOW_NOTIFICATIONS, onSettingsNotificationsLoad);
			Store.load(SETTING_USE_MESSAGE_SOUND, onSettingsMessageSound);
			Store.load(SETTING_USE_CALL_SOUND, onSettingsCallSound);
			
			checkForPendingSettings();
		}
		
		static private function checkForPendingSettings():void 
		{
			Store.load(SETTINGS_PENDING_DATA, onLocalPendingSettingsStatusLoaded);
		}
		
		private static function onLocalPendingSettingsStatusLoaded(data:Object, err:Boolean):void {			
			if (err == true || data == null)
			{
				
			}
			else
			{
				createSettingsData(data);
				needUploadSettings = true;
				uploadCurrentSettings();
			}
		}
		
		// LOADED settings --------------------------------------------------------------------
		//-------------------------------------------------------------------------------------
		/*private static function onSettingsNotificationsLoad(data:Object, err:Boolean):void {			
			if (err == true) {
				echo("GlobalSettings", "onSettingsNotificationsLoad", "Error");
				return;
			}
			notifications = data as Boolean;
		}	*/	
		
		private static function onSettingsMessageSound(data:Object, err:Boolean):void {			
			if (err == true) {
				echo("GlobalSettings", "onSettingsMessageSound", "Error");
				return;
			}
			soundOnMessages = data as Boolean;
		}
		
		private static function onSettingsCallSound(data:Object, err:Boolean):void {			
			if (err == true) {
				echo("GlobalSettings", "onSettingsCallSound", "Error");
				return;
			}
			var oldValue:Boolean = soundOnCalls;
			soundOnCalls = data as Boolean;
			SoundController.soundOnCalls = soundOnCalls;
			if (oldValue != soundOnCalls) {
				S_UPDATE.invoke();
			}
		}
	
		// ACCESSOR interface -----------------------------------------------------------------
		//-------------------------------------------------------------------------------------
		/*public static function setNotifications(value:Boolean):void	{
			notifications = value;
			Store.save(SETTING_SHOW_NOTIFICATIONS, value);
		}*/
			
		public static function setSoundOnMessages(value:Boolean):void {
			soundOnMessages = value;
			Store.save(SETTING_USE_MESSAGE_SOUND, value);
		}
			
		public static function setSoundOnCalls(value:Boolean):void {
			soundOnCalls = value;
			Store.save(SETTING_USE_CALL_SOUND, value);
			SoundController.soundOnCalls = soundOnCalls;
		}
		
		// do on logout or clear auth
		public static function reset():void	{
			soundOnMessages = true;
			soundOnCalls = true;
			controlsData = null;
			needUploadSettings = false;
			settingsReady = false;
			isLoading = false;
		}
		
		static public function save(controlData:SettingsControlData):void 
		{
			updateSettings(controlData);
			savePendingSettingsData();
			saveCurrentSettings();
			needUploadSettings = true;
			uploadCurrentSettings();
		}
		
		static private function updateSettings(controlData:SettingsControlData):void 
		{
			//!TODO:;
		}
		
		static private function savePendingSettingsData():void 
		{
			saveLocalSettings(SETTINGS_PENDING_DATA);
		}
		
		static private function saveLocalSettings(type:String):void 
		{
			if (controlsData != null && controlsData.length > 0)
			{
				var data:Array = new Array();
				var item:Object;
				for (var i:int = 0; i < controlsData.length; i++) 
				{
					item = new Object();
					item[controlsData[i].type.getValue()] = controlsData[i].getSelectedType();
					data.push(item);
				}
				Store.save(type, data);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		static public function loadSettings():void 
		{
			if (isLoading == true)
			{
				return;
			}
			isLoading = true;
			
			Store.load(SETTINGS_PENDING_DATA, onLocalPendingSettingsLoaded);
		}
		
		private static function onLocalPendingSettingsLoaded(data:Object, err:Boolean):void {			
			if (err == true || data == null)
			{
				loadSettingsFromPHP();
			}
			else
			{
				createSettingsData(data);
				onSettingsLoaded();
				uploadCurrentSettings();
				isLoading = false;
			}
		}
		
		static private function loadSettingsFromPHP():void 
		{
			PHP.call_getChatFilters(onSettingsLoadedFromPHP);
		}
		
		static private function saveCurrentSettings():void 
		{
			saveLocalSettings(SETTINGS_DATA);
		}
		
		static private function onSettingsLoaded():void 
		{
			//!TODO:;
			settingsReady = true;
			
			SETTINGS_LOADED.invoke();
		}
		
		static private function uploadCurrentSettings():void 
		{
			if (controlsData != null && controlsData.length > 0)
			{
				needUploadSettings = true;
				var settingsArray:Object = new Object();
				
				var item:Object;
				for (var i:int = 0; i < controlsData.length; i++) 
				{
					item = new Object();
					settingsArray[controlsData[i].type.getValue()] = controlsData[i].getSelectedType();
				}
				
				PHP.call_setChatFilters(onSettingsUploadedToPHP, settingsArray);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		static private function onSettingsUploadedToPHP(r:PHPRespond):void 
		{
			if (r.error == true)
			{
				if (r.errorMsg == PHP.NETWORK_ERROR)
				{
					NetworkManager.S_CONNECTION_CHANGED.add(onConnectionChanged);
				}
			}
			else
			{
				clearPendingSettings();
				needUploadSettings = false;
				NetworkManager.S_CONNECTION_CHANGED.remove(onConnectionChanged);
			}
		}
		
		static private function clearPendingSettings():void 
		{
			Store.remove(SETTINGS_PENDING_DATA);
		}
		
		static private function onConnectionChanged():void 
		{
			if (NetworkManager.isConnected)
			{
				if (needUploadSettings == true)
				{
					uploadCurrentSettings();
				}
				else
				{
					if (settingsReady == true)
					{
						NetworkManager.S_CONNECTION_CHANGED.remove(onConnectionChanged);
					}
					else
					{
						loadSettingsFromPHP();
					}
				}
			}
		}
		
		static private function createSettingsData(data:Object):void 
		{
			controlsData = new Vector.<SettingsControlData>();
			var control:SettingsControlData;
			var type:SettingsControlType;
			
			if (data == null || (data is Array == false))
			{
				type = SettingsControlType.typeCreateChat;
				control = new SettingsControlData(type, SettingsControlType.getlabel(type));
				control.addValue(new SettingsValue(SettingsValueType.typeAll, Lang.privacy_all));
				control.addValue(new SettingsValue(SettingsValueType.typeVerified, Lang.privacy_verified));
				control.addValue(new SettingsValue(SettingsValueType.typeNoOne, Lang.privacy_noOne));
				control.select(SettingsControlType.getDefaultSelection(type));
				controlsData.push(control);
				
				type = SettingsControlType.typeAddChat;
				control = new SettingsControlData(type, SettingsControlType.getlabel(type));
				control.addValue(new SettingsValue(SettingsValueType.typeAll, Lang.privacy_all));
				control.addValue(new SettingsValue(SettingsValueType.typeVerified, Lang.privacy_verified));
				control.addValue(new SettingsValue(SettingsValueType.typeNoOne, Lang.privacy_noOne));
				control.select(SettingsControlType.getDefaultSelection(type));
				controlsData.push(control);
				
				type = SettingsControlType.typeCall;
				control = new SettingsControlData(type, SettingsControlType.getlabel(type));
				control.addValue(new SettingsValue(SettingsValueType.typeAll, Lang.privacy_all));
				control.addValue(new SettingsValue(SettingsValueType.typeVerified, Lang.privacy_verified));
				control.addValue(new SettingsValue(SettingsValueType.typeNoOne, Lang.privacy_noOne));
				control.select(SettingsControlType.getDefaultSelection(type));
				controlsData.push(control);
				
				type = SettingsControlType.typeFind;
				control = new SettingsControlData(type, SettingsControlType.getlabel(type));
				control.addValue(new SettingsValue(SettingsValueType.typeAll, Lang.privacy_all));
				control.addValue(new SettingsValue(SettingsValueType.typeVerified, Lang.privacy_verified));
				control.addValue(new SettingsValue(SettingsValueType.typeNoOne, Lang.privacy_noOne));
				control.select(SettingsControlType.getDefaultSelection(type));
				controlsData.push(control);
			}
			else
			{
				var controlData:Object;
				
				for (var i:int = 0; i < (data as Array).length; i++) 
				{
					type = null;
					controlData = data[i];
					for (var key:String in controlData) 
					{
						type = SettingsControlType.getType(key);
						if (type != null)
						{
							control = new SettingsControlData(type, SettingsControlType.getlabel(type));
							
							control.addValue(new SettingsValue(SettingsValueType.typeAll, Lang.privacy_all));
							control.addValue(new SettingsValue(SettingsValueType.typeVerified, Lang.privacy_verified));
							control.addValue(new SettingsValue(SettingsValueType.typeNoOne, Lang.privacy_noOne));
							
							control.select(SettingsValueType.getType(controlData[key]));
						}
					}
					if (type != null)
					{
						controlsData.push(control);
					}
				}
				
				checkSettingsData();
			}
		}
		
		static private function checkSettingsData():void 
		{
			if (controlsData != null)
			{
				var types:Vector.<SettingsControlType> = new Vector.<SettingsControlType>();
				types.push(SettingsControlType.typeAddChat);
				types.push(SettingsControlType.typeCall);
				types.push(SettingsControlType.typeCreateChat);
				types.push(SettingsControlType.typeFind);
				
				var control:SettingsControlData;
				for (var i:int = 0; i < types.length; i++) 
				{
					var exist:Boolean = false;
					for (var j:int = 0; j < controlsData.length; j++) 
					{
						if (types[i].getValue() == controlsData[j].type.getValue())
						{
							exist = true;
						}
					}
					if (!exist)
					{
						control = new SettingsControlData(types[i], SettingsControlType.getlabel(types[i]));
						control.addValue(new SettingsValue(SettingsValueType.typeAll, Lang.privacy_all));
						control.addValue(new SettingsValue(SettingsValueType.typeVerified, Lang.privacy_verified));
						control.addValue(new SettingsValue(SettingsValueType.typeNoOne, Lang.privacy_noOne));
						control.select(SettingsControlType.getDefaultSelection(types[i]));
						controlsData.push(control);
					}
				}
			}
		}
		
		static private function onSettingsLoadedFromPHP(r:PHPRespond):void 
		{
			if (r.error == true)
			{
				if (r.errorMsg == PHP.NETWORK_ERROR)
				{
					NetworkManager.S_CONNECTION_CHANGED.add(onConnectionChanged);
				}
				
				loadLocalSettings();
			}
			else
			{
				isLoading = false;
				createSettingsData(toArray(r.data));
				saveCurrentSettings();
				onSettingsLoaded();
			}
			r.dispose();
		}
		
		static private function toArray(data:Object):Array 
		{
			if (data is Array)
			{
				return data as Array;
			}
			else
			{
				var result:Array = new Array();
				var item:Object;
				for (var key:String in data) 
				{
					item = new Object();
					item[key] = data[key];
					result.push(item);
				}
				return result;
			}
		}
		
		static private function loadLocalSettings():void 
		{
			Store.load(SETTINGS_DATA, onLocalSettingsLoaded);
		}
		
		private static function onLocalSettingsLoaded(data:Object, err:Boolean):void {
			isLoading = false;
			createSettingsData(data);
			onSettingsLoaded();
		}
		
		static public function getSettings():Vector.<SettingsControlData> 
		{
			return controlsData;
		}
		
		static public function isAvaliable():Boolean 
		{
			return settingsReady;
		}
	}
}