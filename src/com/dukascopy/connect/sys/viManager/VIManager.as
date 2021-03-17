package com.dukascopy.connect.sys.viManager 
{
	import com.telefision.sys.signals.Signal;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class VIManager 
	{
		static public var S_START_SUCCESS:Signal = new Signal('VIManager.S_START_SUCCESS');
		static public var S_INITED:Signal = new Signal('VIManager.S_INITED');
		static private var currentSession:VISession;
		
		public function VIManager() 
		{
			
		}
		
		static public function start(chatId:String):void 
		{
			if (currentSession != null)
			{
				S_INITED.invoke(currentSession.bot);
				resume();
			}
			else
			{
				startNewSession(chatId);
				S_INITED.invoke(currentSession.bot);
			}
		}
		
		static private function resume():void 
		{
			S_START_SUCCESS.invoke();
			
			currentSession.resume();
		}
		
		static public function onExit():void 
		{
			if (currentSession != null)
			{
				clearCurrentSession();
			}
		}
		
		static private function startNewSession(chatId:String):void 
		{
			currentSession = new VISession(onSessionStart, onSessionFail);
			currentSession.start(chatId);
		}
		
		static private function clearCurrentSession():void 
		{
			currentSession.close();
			currentSession = null;
		}
		
		static private function onSessionFail():void 
		{
			if (currentSession != null && currentSession.bot != null)
			{
				currentSession.bot.onDisconnect();
			}
			clearCurrentSession();
		}
		
		static private function onSessionStart(success:Boolean):void 
		{
			if (success == true)
			{
				S_START_SUCCESS.invoke();
				//currentSession.bot.ready();
			}
			else
			{
				//!TODO:;
			}
		}
	}
}