package com.dukascopy.connect.sys.payments {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.BankBotChatScreen;
	import com.dukascopy.connect.screens.MyAccountScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.WebViewScreen;
	import com.dukascopy.connect.screens.payments.PaymentsNewsScreen;
	import com.dukascopy.connect.screens.payments.settings.PaymentsSettingsScreen;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.vo.PaymentsNewsVO;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class PayNews {
		
		static private var news:Vector.<PaymentsNewsVO>;
		static private var alreadyInside:Boolean;
		
		static private var currentNews:PaymentsNewsVO;
		
		static public function init():void {
			MobileGui.centerScreen.S_COMPLETE_SHOW.add(start);
		}
		
		static public function start(cls:Class):void {
			if (checkForInsidePayments(cls) == true) {
				if (alreadyInside == true)
					return;
				alreadyInside = true;
				getNews();
				return;
			}
			alreadyInside = false;
			stop();
		}
		
		static private function getNews():void {
			TweenMax.killDelayedCallsTo(getNews);
			if (MobileGui.centerScreen.currentScreenClass == PaymentsNewsScreen)
				return;
			if (PayAPIManager.hasSwissAccount == true) {
				if (BankManager.getAccountInfo() != null && BankManager.getAccountInfo().settings.PWP_ENABLED == true) {
					PayServer.call_getNews(onNewsGetted, LangManager.model.getCurrentLanguageID(), "");
					return;
				}
				if (PayAuthManager.isLockedByPass == false) {
					PayServer.call_getNews(onNewsGetted, LangManager.model.getCurrentLanguageID(), "");
					return;
				}
			}
			TweenMax.delayedCall(5, getNews);
		}
		
		static private function onNewsGetted(payRespond:PayRespond):void {
			echo("PayNews", "onNewsGetted", "");
			if (payRespond.error == true) {
				if (payRespond.hasAuthorizationError == true) {
					if (payRespond.errorCode == 2000) {
						TweenMax.delayedCall(60, getNews);
						return;
					}
					PayAuthManager.isLockedByPass = true;
					TweenMax.delayedCall(5, getNews);
				}
				return;
			}
			TweenMax.delayedCall(3600, getNews);
			news ||= new Vector.<PaymentsNewsVO>();
			while (news.length != 0) {
				news[0].dispose();
				news.shift();
			}
			if (payRespond.data == null)
				return;
			var arr:Array = payRespond.data as Array;
			for (var i:int = 0; i < arr.length; i++)
				news.push(new PaymentsNewsVO(arr[i]));
			echo("PayNews", "onNewsGetted", "News count: " + news.length);
			showNews();
		}
		
		static private function showNews():void {
			TweenMax.delayedCall(1, showNewsContinue, null, true);
		}
		
		static private function showNewsContinue():void {
			echo("PayManager", "showNewsContinue", "");
			if (alreadyInside == false)
				return;
			if (news == null || news.length == 0)
				return;
			if (MobileGui.dialogShowed == true) {
				MobileGui.S_DIALOG_CLOSED.add(onDialogClosed);
				return;
			}
			if (MobileGui.serviceShowed == true) {
				ServiceScreenManager.S_CLOSE_DIALOG.add(onServiceClosed);
				return;
			}
			currentNews = news[0];
			MobileGui.changeMainScreen(
				PaymentsNewsScreen,
				{
					callback:confirmPaymentNewAndShowNext,
					backScreen:MobileGui.centerScreen.currentScreenClass,
					backScreenData:MobileGui.centerScreen.currentScreen.data
				}
			);
		}
		
		static private function onServiceClosed():void {
			ServiceScreenManager.S_CLOSE_DIALOG.remove(onDialogClosed);
			showNews();
		}
		
		static private function onDialogClosed():void {
			MobileGui.S_DIALOG_CLOSED.remove(onDialogClosed);
			showNews();
		}
		
		private static function confirmPaymentNewAndShowNext(val:int):void {
			if (val == 0) {
				PayManager.callLogout();
				MobileGui.changeMainScreen(RootScreen);
				return;
			}
			PayServer.call_postNews(onConfirmationRespond, currentNews.id.toString()); 
			removeNewsByID(currentNews.id);
			currentNews = null;
			showNews();
		}
		
		private static function getNewsByID(id:int):PaymentsNewsVO {
			for each(var curr:PaymentsNewsVO in news)
				if (curr.id == id)
					return curr;
			return null;
		}
		
		private static function removeNewsByID(id:int):void {
			var curr:PaymentsNewsVO;
			for (var i:int = 0; i < news.length; i++) {
				curr = news[i];
				if (curr.id == id) {
					news.splice(i, 1);
					return;
				}
			}
		}
		
		static private function onConfirmationRespond(payRespond:PayRespond):void {
			if (payRespond.error)
				return;
		}
		
		static public function stop():void {
			TweenMax.killDelayedCallsTo(getNews);
			TweenMax.killDelayedCallsTo(showNewsContinue);
		}
		
		static public function checkForInsidePayments(cls:Class):Boolean {
			if (cls == null)
				return false;
			if (cls == MyAccountScreen ||
				cls == BankBotChatScreen ||
				cls == WebViewScreen ||
				cls == PaymentsSettingsScreen ||
				cls == PaymentsNewsScreen)
					return true;
			return false;
		}
		
		static public function getCurrentNews():PaymentsNewsVO { return currentNews; }
	}
}