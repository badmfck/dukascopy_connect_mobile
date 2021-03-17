package com.dukascopy.langs {
	
	import assets.LangFlag_ar;
	import assets.LangFlag_ch;
	import assets.LangFlag_cs;
	import assets.LangFlag_de;
	import assets.LangFlag_earth;
	import assets.LangFlag_en;
	import assets.LangFlag_es;
	import assets.LangFlag_fa;
	import assets.LangFlag_fr;
	import assets.LangFlag_hu;
	import assets.LangFlag_it;
	import assets.LangFlag_ja;
	import assets.LangFlag_lv;
	import assets.LangFlag_pl;
	import assets.LangFlag_pt;
	import assets.LangFlag_ru;
	import assets.LangFlag_sk;
	import assets.LangFlag_ua;
	import assets.LangFlag_uk;
	import assets.LangFlag_zh;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.bankManager.BankBotScenarioLang;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.php.SimpleDataLoader;
	import com.dukascopy.connect.sys.store.Store;
import com.dukascopy.connect.sys.ws.WSClient;

import flash.system.Capabilities;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class LangModel {
		
		static public const EN:String = "en";
		
		private const assetsLangFlag:String = "assets.LangFlag_";
		
		private var _loadLang:SimpleDataLoader;
		
		private var initialized:Boolean;
		
		private var hashesLoaded:Boolean = false;
		private var needToUpdateLanguage:Boolean = false;
		
		private var languagesHashes:Array;
		private var currentLanguageID:String = EN;
		private var currentLanguageHash:String = "";
		private var lastLanguageID:String = "";
		private var lastLanguageHash:String = "";
		
		private var languageOnLoadedCallback:Function;
		
		private var availableLanguages:Array;
		private var realLangId:String;
		
		public function LangModel() {
			LangFlag_ar;
			LangFlag_ch;
			LangFlag_cs;
			LangFlag_de;
			LangFlag_earth;
			LangFlag_en;
			LangFlag_es;
			LangFlag_fa;
			LangFlag_fr;
			LangFlag_hu;
			LangFlag_it;
			LangFlag_ja;
			LangFlag_lv;
			LangFlag_pl;
			LangFlag_pt;
			LangFlag_ru;
			LangFlag_sk;
			LangFlag_ua;
			LangFlag_uk;
			LangFlag_zh;
		}
		
		public function init():void {
			if (Capabilities.languages[0].indexOf("ru-") == 0 ||
				Capabilities.languages[0].indexOf("ky-") == 0 ||
				Capabilities.languages[0].indexOf("be-") == 0 ||
				Capabilities.languages[0].indexOf("kk-") == 0 ||
				Capabilities.languages[0].indexOf("uk-") == 0)
					currentLanguageID = "ru";
			else if (Capabilities.languages[0].indexOf("pl-") == 0)
				currentLanguageID = "pl";
			else if (Capabilities.languages[0].indexOf("cs-") == 0)
				currentLanguageID = "cs";
			else if (Capabilities.languages[0].indexOf("de-") == 0)
				currentLanguageID = "de";
			else if (Capabilities.languages[0].indexOf("fr-") == 0)
				currentLanguageID = "fr";
			else if (Capabilities.languages[0].indexOf("hu-") == 0)
				currentLanguageID = "hu";
			else if (Capabilities.languages[0].indexOf("sk-") == 0)
				currentLanguageID = "sk";
			else if (Capabilities.languages[0].indexOf("zh-") == 0)
				currentLanguageID = "zh";
			else if (Capabilities.languages[0].indexOf("ja-") == 0)
				currentLanguageID = "ja";
			loadHashesFromStore();
		}
		
		/**
		 * Загрузка из локального хранилища хешей которые были ранее загружены с PHP.
		 */
		public function loadHashesFromStore():void {
			Store.load(Store.VAR_LANGUAGE_HASHES, onHashesLoadedFromStore);
		}
		
		/**
		 * Проверка загруженных из локального хранилища данных по хешам и вызов метода загрузки их с PHP.
		 */
		private function onHashesLoadedFromStore(data:Object, err:Boolean):void {
			if (err == false && data != null)
				setHashData(data);
			loadHashesFromPHP();
		}
		
		/**
		 * Загрузка с PHP данных по хешам.
		 */
		public function loadHashesFromPHP():void {
			NetworkManager.S_CONNECTION_CHANGED.remove(loadHashesFromPHP);
			if (NetworkManager.isConnected == false) {
				NetworkManager.S_CONNECTION_CHANGED.add(loadHashesFromPHP);
				getLanguageFromLocalStore();
				return;
			}
			PHP.langhash_get(onLangHashesLoadedFromPHP, "");
		}
		
		/**
		 * Проверка загруженных с PHP данных  по хешам, обновление их и запись в локальное хранилище.
		 * Если локальный язык был загружен до выполнения этого метода, то проверяется хеш загруженного языка,
		 * и если он не совпадает, то мы вызываем метод загрузки языка с PHP.
		 */
		private function onLangHashesLoadedFromPHP(phpRespond:PHPRespond = null):void {
			if (phpRespond.error == true) {
				phpRespond.dispose();
				echo("LangModel", "onLangHashesLoadedFromPHP", "PHP ERROR (" + phpRespond.errorMsg + ")");
				getLanguageFromLocalStore();
				return;
			}
			if (phpRespond.data == null) {
				phpRespond.dispose();
				echo("LangModel", "onLangHashesLoadedFromPHP", "DATA IS EMPTY");
				getLanguageFromLocalStore();
				return;
			}
			setHashData(phpRespond.data);
			Store.save(Store.VAR_LANGUAGE_HASHES, phpRespond.data);
			hashesLoaded = true;
			
			Store.load(Store.VAR_LANGUAGE_ID, loadCallBack);
			/*if (needToUpdateLanguage == true && currentLanguageHash != getHashByID(currentLanguageID))
				loadLangFromPHP();*/
			phpRespond.dispose();
		}
		
		/**
		 * Проверка загруженных из локального хранилища данных по выбранному ранее языку
		 * и вызов метода загрузки языка из локального хранилища.
		 */
		private function loadCallBack(data:Object, err:Boolean):void {
			if (err == false)
				currentLanguageID = data.languageID;
			if (currentLanguageID != "en") {
				realLangId = currentLanguageID;
				currentLanguageID = "en";
			}
			getLanguageFromLocalStore();
		}
		
		/**
		 * Загрузка из локального хранилища языка по ID.
		 */
		private function getLanguageFromLocalStore():void {
			Store.load(Store.VAR_LANGUAGE + "_" + currentLanguageID, onLanguageLoadedFromStore);
		}
		
		/**
		 * Проверка загруженных из локального хранилища данных по языку ( { id:String, hash:String, data:{key:value,.....} } ).
		 * Вызов метода который устанавливает язык если он загружен и продолжает работу приложения.
		 */
		private function onLanguageLoadedFromStore(data:Object, err:Boolean):void {
			needToUpdateLanguage = !hashesLoaded;
			var _language:Object = null;
			if (err == false)
				_language = data;
			if (_language == null) {
				installLangAndAuthInit();
				if (hashesLoaded == true)
					loadLangFromPHP();
				return;
			}
			if (_language.id != currentLanguageID)
				return;
			if ("hash" in _language == false ||
				_language.hash == null ||
				_language.hash == "" ||
				"data" in _language == false ||
				_language.data == null) {
					installLangAndAuthInit();
					if (hashesLoaded == true)
						loadLangFromPHP();
					return;
			}
			currentLanguageHash = _language.hash;
			setKeysFromLoadedLanguage(_language.data);
			if (hashesLoaded == true && getHashByID(currentLanguageID) != currentLanguageHash) {
				loadLangFromPHP();
				return;
			}
			if (realLangId == null)
			{
				if (languageOnLoadedCallback != null)
					languageOnLoadedCallback();
				languageOnLoadedCallback = null;
			}
			else
			{
				currentLanguageID = realLangId;
				realLangId = null;
				getLanguageFromLocalStore();
			}
		}
		
		/**
		 * Распаковка объекта по хешам.
		 */
		private function setHashData(data:Object):void {
			var hashes:Object = data.projects.rto ? data.projects.rto : { };
			var labels:Object = data.languageNames;
			if (hashes == null || labels == null)
				return;
			languagesHashes ||= [];
			var found:Boolean;
			for (var n:String in hashes) {
				found = false;
				for (var i:int = 0; i < languagesHashes.length; i++) {
					if (n == languagesHashes[i].id) {
						found = true;
						if (languagesHashes[i].hash != hashes[n]) {
							echo("LangModel", "setHashData", "Language " + n.toUpperCase() + " NEW HASH: " + hashes[n]);
							languagesHashes[i].hash = hashes[n];
						}
						break;
					}
				}
				if (found == false) {
					if (labels[n] != null) {
						languagesHashes.push( {
							id: n,
							fullLink: labels[n],
							hash: hashes[n],
							icon: assetsLangFlag + n,
							iconColor: -1
						} );
					}
				}
			}
		}
		
		/**
		 * Взятие хеша языка по его ID.
		 */
		private function getHashByID(id:String):String {
			var resultStr:String = "";
			if (languagesHashes == null || languagesHashes.length == 0)
				return resultStr;
			var l:int = languagesHashes.length;
			var object:Object;
			for (var i:int = 0; i < l; i++) {
				object = languagesHashes[i];
				if (object.id == id) {
					resultStr = object.hash;
					break;
				}
			}
			return resultStr;
		}
		
		/**
		 * Установка языка и вызов метода авторизации.
		 */
		private function installLangAndAuthInit(update:Boolean = false):void {
			if (update == true) {
				NativeExtensionController.updateLanguageData();
				MobileGui.centerScreen.refreshEachScreen();
				MobileGui.refreshManagers();
			}
			if (initialized == true)
				return;
			initialized = true;
		}
		
		/**
		 * Загрузка языка с PHP.
		 * Если нет интернета, то возращаем предыдущие значения по языку.
		 */
		private function loadLangFromPHP():void {
			if (NetworkManager.isConnected == false) {
				if (languageOnLoadedCallback != null)
					languageOnLoadedCallback();
				languageOnLoadedCallback = null;
				
				currentLanguageID = lastLanguageID;
				currentLanguageHash = lastLanguageHash;
				return;
			}
			if (_loadLang != null) {
				_loadLang.disable();
				_loadLang = null;
			}
			_loadLang = new SimpleDataLoader(currentLanguageID, onLanguageLoaded, onLanguageLoadedError);
		}
		
		/**
		 * Обработчик ошибки загрузки языка с PHP.
		 * Если произошла ошибка, то возращаем предыдущие значения по языку.
		 */
		private function onLanguageLoadedError():void {
			if (realLangId == null) {
				if (languageOnLoadedCallback != null)
					languageOnLoadedCallback();
				languageOnLoadedCallback = null;
			}
			currentLanguageID = lastLanguageID;
			currentLanguageHash = lastLanguageHash;
			if (realLangId != null) {
				currentLanguageID = realLangId;
				realLangId = null;
				getLanguageFromLocalStore();
			}
		}
		
		/**
		 * Создание объекта языка по данным с сервера, сохранение его в локальное хранилище и вызов метода установки языка.
		 * Объект языка для сохранения: { id:String, hash:String, data:{key:value,.....} }.
		 */
		private function onLanguageLoaded(obj:Object = null):void {
			if (_loadLang != null) {
				_loadLang.disable();
				_loadLang = null;
			}
			
			Store.save(Store.VAR_LANGUAGE + "_" + currentLanguageID, { id:currentLanguageID, hash:getHashByID(currentLanguageID), data:obj } );
			
			setKeysFromLoadedLanguage(obj);
			
			if (realLangId == null)
			{
				if (languageOnLoadedCallback != null)
					languageOnLoadedCallback();
				languageOnLoadedCallback = null;
			}
			
			if (realLangId != null)
			{
				currentLanguageID = realLangId;
				realLangId = null;
				getLanguageFromLocalStore();
			}
		}
		
		private function setKeysFromLoadedLanguage(obj:Object):void {
			for (var n:String in obj) {
				if (obj[n] == null) {
					trace("Section is null: " + n);
					continue;
				}
				for (var s:String in obj[n]) {
					if (obj[n][s] == null)
						trace("Section " + n + "; Key is null: " + s);
				}
			}
			if ("mobile" in obj)
				Lang.updateKeys(obj.mobile);
			if ("common" in obj)
				Lang.updateKeys(obj.common);
			if ("payments" in obj)
				Lang.updateKeys(obj.payments);
			if ("refCodes" in obj)
				Lang.updateKeys(obj.refCodes);
			if ("BankBot" in obj)
				BankBotScenarioLang.updateKeys(obj.BankBot);
			installLangAndAuthInit(true);
		}
		
		/**
		 * Выбор языка по его ID.
		 */
		public function selectLangByIndex(id:int, callback:Function = null):void {
			if (availableLanguages == null)
				return;
			var langID:String = availableLanguages[id].id;
			WSClient.call_setLang(langID); // send language to websocket
			availableLanguages.length = 0;
			if (currentLanguageID == langID)
				return;
			languageOnLoadedCallback = callback;
			lastLanguageID = currentLanguageID;
			lastLanguageHash = currentLanguageHash;
			currentLanguageID = langID;
			currentLanguageHash = "";
			getLanguageFromLocalStore();
			Store.save(Store.VAR_LANGUAGE_ID, { languageID:langID } );


		}
		
		/**
		 * Взятие массива доступных языков не учитывая выбранный.
		 */
		public function getAvailableLanguages():Array {
			if (availableLanguages != null && availableLanguages.length != 0)
				return availableLanguages;
			if (languagesHashes == null || languagesHashes.length == 0)
				return null;
			availableLanguages ||= [];
			for (var i:int = 0; i < languagesHashes.length; i++) {
				var object:Object = languagesHashes[i];
				object.iconColor = -1;
				if (object.id != currentLanguageID)
					availableLanguages.push(object);
			}
			availableLanguages.sort(sortByID);
			return availableLanguages;
		}
		
		private function sortByID(a:Object, b:Object):int {
			if (a.id < b.id)
				return -1;
			if (b.id < a.id)
				return 1;
			return 0;
		}
		
		public function getCurrentLanguageID():String {
			return currentLanguageID;
		}

		public function getCurrentLanguageForPayments():String {
			return currentLanguageID;
		}
	}
}