package com.dukascopy.connect.sys.chat 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.store.Store;
	import com.greensock.TweenMax;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class DraftMessage 
	{
		static private var messages:Object;
		
		public function DraftMessage() 
		{
			
		}
		
		public static function init():void
		{
			Store.load(Store.DRAFT_MESSAGES, onLocalDataLoaded)
			Auth.S_NEED_AUTHORIZATION.add(clear);
		}
		
		static private function onLocalDataLoaded(data:Object = null, error:Boolean = true):void 
		{
			messages = new Object();
			if (error == false)
			{
				if (data != null)
				{
					var json:Object;
					try
					{
						json = JSON.parse(data as String);
					}
					catch (e:Error)
					{
						ApplicationErrors.add();
					}
					if (json != null)
					{
						messages = json;
					}
				}
			}
		}
		
		static public function getValue(chatId:String, key:String):String
		{
			if (messages != null)
			{
				if (messages[chatId] != null)
				{
					return Crypter.decrypt(messages[chatId], key);
				}
			}
			return null;
		}
		
		static public function setValue(chatId:String, key:String, value:String):void
		{
			if (messages != null)
			{
				if (value == null || value == "")
				{
					delete messages[chatId];
				}
				else
				{
					messages[chatId] = Crypter.crypt(value, key);
				}
			}
			updateStore();
		}
		
		static public function clearValue(chatId:String):void
		{
			if (messages != null)
			{
				if (messages[chatId] != null)
				{
					messages[chatId] = null;
					delete messages[chatId];
				}
			}
			TweenMax.killDelayedCallsTo(updateStore);
			TweenMax.delayedCall(2, updateStore);
		}
		
		static private function updateStore():void 
		{
			TweenMax.killDelayedCallsTo(updateStore);
			if (messages != null)
			{
				var result:String = JSON.stringify(messages);
				Store.save(Store.DRAFT_MESSAGES, result);
			}
		}
		
		static public function clear():void
		{
			TweenMax.killDelayedCallsTo(updateStore);
			if (messages != null)
			{
				messages = null;
			}
			clearStore();
			messages = new Object();
		}
		
		static private function clearStore():void 
		{
			TweenMax.killDelayedCallsTo(updateStore);
			Store.remove(Store.DRAFT_MESSAGES);
		}
	}
}