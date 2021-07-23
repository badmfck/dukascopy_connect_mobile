package com.dukascopy.connect.sys.serviceScreenManager {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.screens.dialogs.bankBot.OrderCardDialog;
	import com.dukascopy.connect.screens.dialogs.gifts.CreateGiftPopup;
	import com.dukascopy.connect.screens.gifts.GiftInfoScreen;
	import com.dukascopy.connect.screens.gifts.GiftsTutorialScreen;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ServiceScreenManager {
		
		static public const TYPE_SCREEN:String = "typeScreen";
		static public const TYPE_DIALOG:String = "typeDialog";
		
		static public var S_SHOW:Signal = new Signal('ServiceScreenManager.S_SHOW');
		static public var S_CLOSE_DIALOG:Signal = new Signal('ServiceScreenManager.S_CLOSE_DIALOG');
		
		static private var _hasOpenedDialog:Boolean;
		
		static public var currentScreenType:String;
		
		public function ServiceScreenManager() { }
		
		static public function closeView():void {
			hasOpenedDialog = false;
			S_CLOSE_DIALOG.invoke();
		}
		
		static public function showNewGiftDialog(userModel:UserVO, giftType:int, predefinedGiftData:GiftData = null, receiverSecret:Boolean = false):void {
			_hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(CreateGiftPopup, { user:userModel, giftType:giftType, giftData:predefinedGiftData, receiverSecret:receiverSecret } );
		}
		
		/**
		 * 
		 * @param	cardType - plastic or virtual
		 */
		static public function showOrderCardDialog(cardType:String):void {
			_hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(OrderCardDialog, { cardType:cardType } );
		}
		
		static public function showGiftInfoScreen(giftData:GiftData):void {
			_hasOpenedDialog = true;
			currentScreenType = TYPE_SCREEN;
			S_SHOW.invoke(GiftInfoScreen, { giftModel:giftData } );
		}
		
		static public function showGiftsTutorialScreen():void {
			_hasOpenedDialog = true;
			currentScreenType = TYPE_SCREEN;
			S_SHOW.invoke(GiftsTutorialScreen, null);
		}
		
		static public function showScreen(screenType:String, screenClass:Class, screenData:Object = null, transitionTime:Number = 0.5, transparency:Number = 0.5, direction:int = 0):void {
			_hasOpenedDialog = true;
			currentScreenType = screenType;
			S_SHOW.invoke(screenClass, screenData, transitionTime, transparency, direction);
		}
		
		static public function onBack():void {
			if (MobileGui.serviceScreen != null && 
				MobileGui.serviceScreen.currentScreen != null) {
					MobileGui.serviceScreen.currentScreen.onBack();
			}
		}
		
		static public function get hasOpenedDialog():Boolean {
			return _hasOpenedDialog;
		}
		
		static public function set hasOpenedDialog(value:Boolean):void {
			_hasOpenedDialog = value;
		}
	}
}