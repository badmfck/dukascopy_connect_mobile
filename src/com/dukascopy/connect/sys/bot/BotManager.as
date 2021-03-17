package com.dukascopy.connect.sys.bot {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.data.screenAction.customActions.OpenBankAccountAction;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.adds.BotVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class BotManager {
		
		static private var inited:Boolean;
		static private var _bots:Array;
		static private var currentHash:String;
		static private var busy:Boolean;
		static private var _botsResponded:Boolean;
		static private var bankBotContact:BotVO;
		
		static public const S_BOTS:Signal = new Signal("BotManager.S_BOTS");
		static public const S_LOAD_STOP:Signal = new Signal("BotManager.S_LOAD_STOP");
		static public const S_LOAD_START:Signal = new Signal("BotManager.S_LOAD_START");
		static public const S_BOT_ADDED_TO_CHAT:Signal = new Signal("BotManager.S_BOT_ADDED_TO_CHAT");
		static public const S_BOT_ADDITIONAL_DATA:Signal = new Signal("BotManager.S_BOT_ADDITIONAL_DATA");
		
		static public const GROUP_BANK:String = "DC";
		static public const GROUP_MY:String = "ME";
		static public const GROUP_ACIVE:String = "ACT";
		static public const GROUP_OTHER:String = "TRSH";
		
		public function BotManager() { }
		
		static private function init():void {
			if (inited == true)
				return;
			inited = true;
			WS.S_CONNECTED.add(onWSConnected);
			Auth.S_NEED_AUTHORIZATION.add(onAuthNeeded);
		}
		
		static private function onAuthNeeded():void {
			_bots = null;
			currentHash = "";
			inited = false;
			busy = false;
			_botsResponded = false;
		}
		
		static private function onWSConnected():void {
			if (currentHash != null && currentHash != "") {
				loadBotsFromPHP(currentHash);
			} else {
				Store.load(Store.VAR_BOTS_HASH, onLoadHashFromStore);
			}
		}
		
		static public function getAllBots(addLocalBots:Boolean = true):Array {
			init();
			if (_bots == null) {
				_bots = new Array();
				loadBots();
			}
			
			var needAddBot:Boolean = false;
			
			if (addLocalBots == false)
			{
				needAddBot = false;
			}
			else if (Config.BANKBOT == true || Auth.companyID == "08A29C35B3") {
				if (PayAPIManager.hasSwissAccount == true) {
					if (_bots.length > 0 && _bots[0] != bankBotContact)
					{
						needAddBot = true;
					}
					else if (_bots.length == 0)
					{
						needAddBot = true;
					}
				}
			}
			
			var result:Array = _bots.concat();
			
			var groups:Dictionary = new Dictionary();
			var itemsNum:int = result.length;
			for (var i:int = 0; i < itemsNum; i++) 
			{
				if (groups[result[i].group] == null)
				{
					groups[result[i].group] = new GroupData();
				}
				groups[result[i].group].addItem(result[i]);
			}
			
			result = new Array();
			
			if (groups[GROUP_BANK] != null)
			{
				result.push(Lang.botsGroupBank);
				result = result.concat((groups[GROUP_BANK] as GroupData).items);
			}
			if (groups[GROUP_MY] != null)
			{
				result.push(Lang.botsGroupMy);
				result = result.concat((groups[GROUP_MY] as GroupData).items);
			}
			if (groups[GROUP_ACIVE] != null)
			{
				result.push(Lang.botsGroupActive);
				result = result.concat((groups[GROUP_ACIVE] as GroupData).items);
			}
			if (addLocalBots == true)
			{
				if (groups[GROUP_OTHER] != null)
				{
					result.push(Lang.botsGroupOther);
					result = result.concat((groups[GROUP_OTHER] as GroupData).items);
				}
			}
			
			if (needAddBot == true)
			{
				result.unshift(getBankBot());
			}
			
			return result;
		}
		
		static private function getBankBot():BotVO
		{
			if (bankBotContact == null)
			{
				bankBotContact = new BotVO();
				bankBotContact.setData({name:Lang.bankBot, avatar:LocalAvatars.BANK});
				bankBotContact.action = new OpenBankAccountAction();
				bankBotContact.action.setData(Lang.bankBot);
			}
			return bankBotContact;
		}
		
		static public function addBotToChannel(channelID:String, botUID:String, requestId:String):void {
			if (channelID == null || channelID.length == 0)
				return;
			if (botUID == null)
				return;
			PHP.addBotToChannel(channelID, botUID, onBotAddedToChannel, requestId);
		}
		
		static public function removeBotFromChannel(channelId:String, botUID:String):void {
			PHP.removeBotFromChannel(channelId, botUID, onBotRemovedFromChannel);
		}
		
		static private function onBotRemovedFromChannel(phpRespond:PHPRespond):void {
			var requestID:String;
			var botUID:String;
			var channelID:String;
			if (phpRespond.additionalData != null) {
				if ("requestID" in phpRespond.additionalData == true)
					requestID = phpRespond.additionalData.requestID;
				if ("botUID" in phpRespond.additionalData == true)
					botUID = phpRespond.additionalData.botUID;
				if ("channelID" in phpRespond.additionalData == true)
					channelID = phpRespond.additionalData.channelID;
			}
			//TODO
			if (phpRespond.error == true) {
				//TODO
				phpRespond.dispose();
				return;
			}
			
			/*var channelModel:ChatVO = ChannelsManager.getChannel(channelID);
			var botModel:ChatUserVO = getBot(botUID);
			if (channelModel != null && botModel != null) {
				channelModel.addUser(botModel);
			}*/
			
			phpRespond.dispose();
		}
		
		static private function onBotAddedToChannel(phpRespond:PHPRespond):void {
			var requestID:String;
			var botUID:String;
			var channelID:String;
			if (phpRespond.additionalData != null) {
				if ("requestID" in phpRespond.additionalData == true)
					requestID = phpRespond.additionalData.requestID;
				if ("botUID" in phpRespond.additionalData == true)
					botUID = phpRespond.additionalData.botUID;
				if ("channelID" in phpRespond.additionalData == true)
					channelID = phpRespond.additionalData.channelID;
			}
			//TODO
			if (phpRespond.error == true) {
				//TODO
				S_BOT_ADDED_TO_CHAT.invoke( { success:false, requestId:requestID } );
				phpRespond.dispose();
				return;
			}
			
			var channelModel:ChatVO = ChannelsManager.getChannel(channelID);
			var botModel:BotVO = getBot(botUID);
			if (channelModel != null && botModel != null) {
				var chatUser:ChatUserVO = new ChatUserVO(botModel);
				channelModel.addUser(chatUser);
			}
				
			S_BOT_ADDED_TO_CHAT.invoke( { success:true, requestId:requestID, botUID:botUID} );
			phpRespond.dispose();
		}
		
		static private function getBot(botUID:String):BotVO {
			if (_bots != null) {
				var l:int = _bots.length;
				for (var i:int = 0; i < l; i++) {
					if ((_bots[i] as BotVO).uid == botUID) {
						return _bots[i]
					}
				}
			}
			return null;
		}
		
		static private function loadBots():void {
			Store.load(Store.VAR_BOTS, onLoadBotsFromStore);
		}
		
		static private function onLoadBotsFromStore(data:Object, error:Boolean):void {
			if (data != null && "bots" in data && data.bots != null) {
				if (_bots != null)
					clear();
				_bots = new Array;
				var botsCount:int = data.bots.length;
				var bot:BotVO;
				var contact:Object;
				for (var i:int = 0; i < botsCount; i++) {
					contact = UsersManager.getUserByContactObject(data.bots[i]);
					if (contact != null && contact is BotVO)
					{
						bot = contact as BotVO;
						addBot(bot);
					}
					else
					{
						ApplicationErrors.add();
					}
					
				}
			//	_bots = ArrayUtils.sortArray(_bots, "name");
				_botsResponded = true;
				S_BOTS.invoke();
			}
			Store.load(Store.VAR_BOTS_HASH, onLoadHashFromStore);
		}
		
		static public function getBotAdditionalData(uid:String, obligatory:Boolean = false):void {
			var bot:BotVO = getBot(uid);
			if (bot == null)
				return;
			if (obligatory == false && bot.additionalDataAdded == true) {
				S_BOT_ADDITIONAL_DATA.invoke(bot);
				return;
			}
			PHP.bot_getByUID(onBotAdditionalDataReceived, uid);
		}
		
		static private function onBotAdditionalDataReceived(phpRespond:PHPRespond):void {
			if (phpRespond.error == true)
				return;
			var bot:BotVO = getBot(phpRespond.data.uid);
			if (bot == null)
				return;
			bot.addAdditional(phpRespond.data);
			S_BOT_ADDITIONAL_DATA.invoke(bot);
		}
		
		static private function addBot(bot:BotVO):void {
			_bots.push(bot);
		}
		
		static private function onLoadHashFromStore(data:String, error:Boolean):void {
			if (_bots == null || _bots.length == 0)
				data = "";
			loadBotsFromPHP(data);
		}
		
		static private function loadBotsFromPHP(hash:String):void {
			currentHash = hash;
			S_LOAD_START.invoke();
			PHP.bots_get(onLoadBotsFromPHP, currentHash);
		}
		
		static private function onLoadBotsFromPHP(phpRespond:PHPRespond):void {
			S_LOAD_STOP.invoke();
			_botsResponded = true;
			busy = false;
			
			if (phpRespond.error == true) {
				S_BOTS.invoke();
				phpRespond.dispose();
				return;
			}
			//TODO
			if (phpRespond.data == null || phpRespond.data.bots == null) {
				S_BOTS.invoke();
				phpRespond.dispose();
				return;
			}
			
			Store.save(Store.VAR_BOTS, phpRespond.data);
			
			if (phpRespond.data.hash != null) {
				currentHash = phpRespond.data.hash;
				Store.save(Store.VAR_BOTS_HASH, phpRespond.data.hash);
			}
			
			if (_bots == null)
				_bots = new Array();
			
			var botsCount:int = phpRespond.data.bots.length;
			
			var botRawData:Object;
			var bot:BotVO;
			var userObject:Object;
			for (var i:int = 0; i < botsCount; i++) {
				botRawData = phpRespond.data.bots[i];
				/*if (botRawData != null && "avatar" in botRawData && botRawData.avatar != null && botRawData.avatar != "")
				{
					botRawData.avatar = Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&key=web&uid=" + botRawData.avatar + "&type=image";
				}*/
				if (botRawData != null && botRawData.hasOwnProperty("uid"))
				{
					var existingBot:BotVO = getBot(botRawData.uid);
					if (existingBot != null)
					{
						existingBot.update(botRawData);
					}
					else{
						userObject = UsersManager.getUserByContactObject(botRawData);
						if (userObject != null && userObject is BotVO)
						{
							bot = userObject as BotVO;
							addBot(bot);
						}
						else
						{
							ApplicationErrors.add();
						}
					}
				}
			}
			
		//	_bots = ArrayUtils.sortArray(_bots, "name");
			S_BOTS.invoke();
			phpRespond.dispose();
		}
		
		static private function clear():void
		{
			if (_bots != null)
			{
				while (_bots.length != 0)
				{
					bankBotContact = null;
					_bots[0].dispose();
					_bots[0] = null;
					_bots.splice(0, 1);
				}
			}
			_bots = null;
		}
	}
}