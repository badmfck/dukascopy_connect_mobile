package com.dukascopy.connect.sys.questionsManager {
	
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.vo.QuestionsStatVO;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class QuestionsStatisticsManager {
		
		static public const S_MY_STAT:Signal = new Signal("QuestionsManager.S_MY_STAT");
		static public const S_USER_STAT:Signal = new Signal("QuestionsManager.S_USER_STAT");
		
		static private var initialized:Boolean = false;
		
		static private var my911StatVO:QuestionsStatVO;
		static private var others911StatVOs:Object;
		
		public function QuestionsStatisticsManager() { }
		
		static public function init():void {
			if (initialized == true)
				return;
			initialized = true;
			Auth.S_NEED_AUTHORIZATION.add(clearAllStatistics);
		}
		
		static private function clearAllStatistics():void {
			if (my911StatVO != null)
				my911StatVO.dispose();
			my911StatVO = null;
			
			for (var userUID:String in others911StatVOs)
				if (others911StatVOs[userUID].qsVO != undefined && others911StatVOs[userUID].qsVO != null)
					others911StatVOs[userUID].qsVO.dispose();
			others911StatVOs = null;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////
		//  MY 911 STATISTICS ->  //////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		static public function getMyStat(dontLoad:Boolean = false, needUpdate:Boolean = false):QuestionsStatVO {
			init();
			
			createMy911Stat();
			if (dontLoad == false) {
				if (my911StatVO.hash == null)
					Store.load(Store.VAR_911_STAT, onStore911StatLoaded);
				else if (needUpdate == true)
					PHP.question_getStatMy(onMyStatLoaded, null);
			}
			return my911StatVO;
		}
		
		static private function onStore911StatLoaded(data:Object, error:Boolean):void {
			if (error == true) {
				PHP.question_getStatMy(onMyStatLoaded, null);
				return;
			}
			createMy911Stat(data);
			PHP.question_getStatMy(onMyStatLoaded, my911StatVO.hash);
		}
		
		static private function onMyStatLoaded(phpRespond:PHPRespond):void {
			if (phpRespond.error == true) {
				S_MY_STAT.invoke();
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data == null) {
				S_MY_STAT.invoke();
				phpRespond.dispose();
				return;
			}
			if (my911StatVO != null && phpRespond.data.hash == my911StatVO.hash) {
				S_MY_STAT.invoke();
				phpRespond.dispose();
				return;
			}
			createMy911Stat(phpRespond.data);
			phpRespond.dispose();
		}
		
		static private function createMy911Stat(raw:Object = null):void {
			if (my911StatVO == null)
				my911StatVO = new QuestionsStatVO();
			if (raw == null)
				return;
			my911StatVO.setData(raw);
			Store.save(Store.VAR_911_STAT, raw);
			S_MY_STAT.invoke();
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////
		// <-  MY 911 STATISTICS - USER 911 STATISTICS ->  /////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		static public function getUserStat(userUID:String, dontLoad:Boolean = false, needUpdate:Boolean = false):QuestionsStatVO {
			init();
			
			createOther911Stat(userUID);
			if (dontLoad == false) {
				if (others911StatVOs[userUID].qsVO.hash == null)
					Store.load(Store.VAR_911_STAT_USER + "_" + userUID, onStore911StatOtherLoaded);
				else if (needUpdate == true)
					PHP.question_getStatUser(onOtherStatLoaded, userUID, null);
			}
			return others911StatVOs[userUID].qsVO;
		}
		
		static public function clearByUser(uid:String):void 
		{
			if (others911StatVOs != null && others911StatVOs[uid] != null)
			{
				others911StatVOs[uid] = null;
				delete others911StatVOs[uid];
			}
		}
		
		static private function onStore911StatOtherLoaded(data:Object, error:Boolean, name:String):void {
			var userUID:String = name.split("_")[1];
			if (error == true) {
				PHP.question_getStatUser(onOtherStatLoaded, userUID, null);
				return;
			}
			createOther911Stat(userUID, data);
			PHP.question_getStatUser(onOtherStatLoaded, userUID, my911StatVO.hash);
		}
		
		static private function onOtherStatLoaded(phpRespond:PHPRespond):void {
			var userUID:String = phpRespond.additionalData.userUID;
			if (phpRespond.error == true) {
				S_USER_STAT.invoke(userUID);
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data == null) {
				S_USER_STAT.invoke(userUID);
				phpRespond.dispose();
				return;
			}
			if (others911StatVOs[userUID].qsVO != null && phpRespond.data.hash == others911StatVOs[userUID].qsVO.hash) {
				S_USER_STAT.invoke(userUID);
				phpRespond.dispose();
				return;
			}
			createOther911Stat(userUID, phpRespond.data);
			phpRespond.dispose();
		}
		
		static private function createOther911Stat(userUID:String, raw:Object = null):void {
			if (others911StatVOs == null)
				others911StatVOs = { };
			if (others911StatVOs[userUID] == undefined || others911StatVOs[userUID] == null)
				others911StatVOs[userUID] = { qsVO:new QuestionsStatVO() };
			else if (others911StatVOs[userUID].qsVO == undefined || others911StatVOs[userUID].qsVO == null)
				others911StatVOs[userUID].qsVO = new QuestionsStatVO();
			if (raw == null)
				return;
			others911StatVOs[userUID].qsVO.setData(raw);
			Store.save(Store.VAR_911_STAT_USER, raw);
			S_USER_STAT.invoke(userUID);
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////
		// <-  USER 911 STATISTICS  ////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////
	}
}