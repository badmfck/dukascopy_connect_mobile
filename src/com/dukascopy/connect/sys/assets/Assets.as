package com.dukascopy.connect.sys.assets {
	
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * @author Igor Bloom
	 */
	
	public class Assets {
		
		[Embed(source = "icons/Menu-50.png")] public static var ICON_MENU:Class;
		[Embed(source = "icons/Previous-50.png")] public static var ICON_PREVIOUS:Class;
		[Embed(source = "icons/Search-50.png")] public static var ICON_SEARCH:Class;
		[Embed(source = "icons/Cancel-50.png")] public static var ICON_CANCEL:Class;
		[Embed(source = "icons/Photo-100.png")] public static var ICON_PHOTO:Class;
		[Embed(source = "icons/Left-50.png")] public static var ICON_LEFT:Class;
		[Embed(source = "icons/Up-50.png")] public static var ICON_UP:Class;
		
		[Embed(source = "icons/Closed Topic-100.png")] public static var ICON_LOCK:Class;
		[Embed(source = "icons/Opened Topic-100.png")] public static var ICON_UNLOCK:Class;
		
		[Embed(source = "icons/Lock-32.png")] public static var ICON_LOCKED_32:Class;
		[Embed(source = "icons/Unlock-32.png")] public static var ICON_UNLOCKED_32:Class;
		
		[Embed(source = "icons/Stack Of Photos-100.png")] public static var ICON_IMAGES:Class;
		[Embed(source = "icons/chat_avatar.png")] public static var AVATAR_GROUP:Class;
		[Embed(source = "icons/no_image.png")] public static var NO_IMAGE:Class;
		
		[Embed(source = "icons/searchBG.jpg")] public static var BG_SEARCH:Class;
		[Embed(source = "icons/card_pattern.png")] public static var BG_CARD:Class;
		[Embed(source = "icons/card_pattern_light.png")] public static var BG_CARD_LIGHT:Class;
		[Embed(source = "icons/card_pattern_red.png")] public static var BG_CARD_RED:Class;
		
		[Embed(source = "icons/DP_icon.png")] public static var ICON_PAYMENTS:Class;
		[Embed(source = "icons/support.png")] public static var ICON_SUPPORT:Class;
		
		[Embed(source = "icons/Synchronize-64.png")] public static var ICON_SYNC:Class;
		
		[Embed(source = "icons/send_money.png")] public static var PAYMENT_ICON_SEND_MONEY:Class;
		[Embed(source = "icons/payments/ok-256.png")] public static var PAYMENT_ICON_COMPLETED:Class;
		[Embed(source = "icons/payments/okGlobal-256.png")] public static var PAYMENT_ICON_All:Class;
		[Embed(source = "icons/payments/cancel-256.png")] public static var PAYMENT_ICON_CANCELLED:Class;
		[Embed(source = "icons/payments/icon_time_256.png")] public static var PAYMENT_ICON_PENDING:Class;
		[Embed(source = "icons/payments/icon_transfer_256.png")] public static var PAYMENT_ICON_TRANSFER:Class;
		[Embed(source = "icons/payments/return_purchase-256.png")] public static var PAYMENT_ICON_WITHDRAWAL:Class;
		[Embed(source = "icons/payments/icon_make_deposit_256.png")] public static var PAYMENT_ICON_DEPOSIT_FUNDS:Class;
		[Embed(source = "icons/payments/icon_transfer_In_256.png")] public static var PAYMENT_ICON_INCOMING_TRANSFER:Class;
		[Embed(source = "icons/payments/icon_transfer_Out_256.png")] public static var PAYMENT_ICON_OUTGOING_TRANSFER:Class;
		[Embed(source = "icons/payments/percent_fee-256.png")] public static var PAYMENT_ICON_FEE:Class;
		[Embed(source = "icons/payments/credit-256.png")] public static var PAYMENT_ICON_CREDIT:Class;
		[Embed(source = "icons/payments/debit-256.png")] public static var PAYMENT_ICON_DEBIT:Class;
		[Embed(source = "icons/payments/info-icon.png")] public static var PAYMENT_ICON_INFO:Class;
		[Embed(source = "icons/payments/visa.png")] public static var PAYMENT_ICON_VISA:Class;
		[Embed(source = "icons/payments/visa_electron.png")] public static var PAYMENT_ICON_ELECTRON_VISA:Class;
		[Embed(source = "icons/payments/masterCard.png")] public static var PAYMENT_ICON_MASTERCARD:Class;
		[Embed(source = "icons/payments/maestro.png")] public static var PAYMENT_ICON_MAESTRO:Class;

		[Embed(source = "icons/payments/icon_history_check.png")] public static var PAYMENT_ICON_HISTORY_COMPLETE:Class;
		[Embed(source = "icons/payments/icon_history_timer.png")] public static var PAYMENT_ICON_HISTORY_PENDENG:Class;
		[Embed(source = "icons/payments/icon_history_x.png")] public static var PAYMENT_ICON_HISTORY_CANCELlED:Class;
		
		
		[Embed(source = "icons/bg_white.png")] public static var WHITE_BG:Class;
		
		[Embed(source = "chat_bg/nm_back_01.jpg")] public static var CHAT_BACK_1:Class;
		[Embed(source = "chat_bg/nm_back_02.jpg")] public static var CHAT_BACK_2:Class;
		[Embed(source = "chat_bg/nm_back_03.jpg")] public static var CHAT_BACK_3:Class;
		[Embed(source = "chat_bg/nm_back_04.jpg")] public static var CHAT_BACK_4:Class;
		[Embed(source = "chat_bg/nm_back_05.jpg")] public static var CHAT_BACK_5:Class;
		[Embed(source = "chat_bg/nm_back_06.jpg")] public static var CHAT_BACK_6:Class;
		[Embed(source = "chat_bg/nm_back_07.jpg")] public static var CHAT_BACK_7:Class;
		[Embed(source = "chat_bg/nm_back_08.jpg")] public static var CHAT_BACK_8:Class;
		[Embed(source = "chat_bg/nm_back_09.jpg")] public static var CHAT_BACK_9:Class;
		
		[Embed(source = "chat_bg/1.jpg")] public static var CHAT_BACK_10:Class;
		[Embed(source = "chat_bg/2.jpg")] public static var CHAT_BACK_11:Class;
		[Embed(source = "chat_bg/3.jpg")] public static var CHAT_BACK_12:Class;
		[Embed(source = "chat_bg/4.jpg")] public static var CHAT_BACK_13:Class;
		[Embed(source = "chat_bg/5.jpg")] public static var CHAT_BACK_14:Class;
		[Embed(source = "chat_bg/6.jpg")] public static var CHAT_BACK_15:Class;
		
		
		[Embed(source = "chat_bg/tumb_back_01.jpg")] public static var CHAT_BACK_THUMB_1:Class;
		[Embed(source = "chat_bg/tumb_back_02.jpg")] public static var CHAT_BACK_THUMB_2:Class;
		[Embed(source = "chat_bg/tumb_back_03.jpg")] public static var CHAT_BACK_THUMB_3:Class;
		[Embed(source = "chat_bg/tumb_back_04.jpg")] public static var CHAT_BACK_THUMB_4:Class;
		[Embed(source = "chat_bg/tumb_back_05.jpg")] public static var CHAT_BACK_THUMB_5:Class;
		[Embed(source = "chat_bg/tumb_back_06.jpg")] public static var CHAT_BACK_THUMB_6:Class;
		[Embed(source = "chat_bg/tumb_back_07.jpg")] public static var CHAT_BACK_THUMB_7:Class;
		[Embed(source = "chat_bg/tumb_back_08.jpg")] public static var CHAT_BACK_THUMB_8:Class;
		[Embed(source = "chat_bg/tumb_back_09.jpg")] public static var CHAT_BACK_THUMB_9:Class;
		
		[Embed(source = "chat_bg/tumb_1.jpg")] public static var CHAT_BACK_THUMB_10:Class;
		[Embed(source = "chat_bg/tumb_2.jpg")] public static var CHAT_BACK_THUMB_11:Class;
		[Embed(source = "chat_bg/tumb_3.jpg")] public static var CHAT_BACK_THUMB_12:Class;
		[Embed(source = "chat_bg/tumb_4.jpg")] public static var CHAT_BACK_THUMB_13:Class;
		[Embed(source = "chat_bg/tumb_5.jpg")] public static var CHAT_BACK_THUMB_14:Class;
		[Embed(source = "chat_bg/tumb_6.jpg")] public static var CHAT_BACK_THUMB_15:Class;
		
		//Sounds
		[Embed(source = "sound/1.mp3")] public static var SOUND_1:Class;
		[Embed(source = "sound/2.mp3")] public static var SOUND_2:Class;
		static public var keyboardSnapshot:BitmapData;
		
		
		static private var _assets:Array = [];
		static private var _backgrounds:Array = [];
		/**
		 * Get asset 
		 * @param	cls Asset Class
		 * @param	clr Color -> if == -1 - original color will use
		 * @return	ImageBitmapData
		 */
		static public function getAsset(cls:Class, clr:Number = -1):ImageBitmapData {
			var n:int = 0;
			var l:int = _assets.length;
			for (n; n < l; n++) {
				if (_assets[n][0] == cls && _assets[n][2]==clr){
					if(_assets[n][1].isDisposed == false){
						return _assets[n][1];
					}else {
						//_assets.splice(n, 1);
						
						_assets.removeAt(n);
						break;
					}
				}
			}
			
			var bmp:Bitmap = new cls() as Bitmap;
			var res:ImageBitmapData;
			res = new ImageBitmapData("Asset." + cls, bmp.bitmapData.width, bmp.bitmapData.height, true, 0, true);
			if(clr>-1){
				var ct:ColorTransform = new ColorTransform();
				ct.color = clr;
				bmp.bitmapData.colorTransform(bmp.bitmapData.rect,ct);
			}
			res.copyBitmapData(bmp.bitmapData);
			bmp.bitmapData.dispose();
			bmp.bitmapData = null;
			bmp = null;
			_assets[_assets.length] = [cls,res,clr];
			return res;
		}
		
		static public function getBackground(cls:Class):ImageBitmapData {
			
			//trace(' _------------------- ACCESS TO BG! -----------');
			
			var n:int = 0;
			var l:int = _backgrounds.length;
			for (n; n < l; n++) {
				if (_backgrounds[n][0] == cls){
					if(_backgrounds[n][1].isDisposed == false){
						return _backgrounds[n][1];
					}else {
						_backgrounds.removeAt(n);
						break;
					}
				}
			}
			
			var bmp:Bitmap = new cls() as Bitmap;
			var res:ImageBitmapData = new ImageBitmapData("Asset." + cls, bmp.bitmapData.width, bmp.bitmapData.height, true, 0, false);
			
			res.copyBitmapData(bmp.bitmapData);
			bmp.bitmapData.dispose();
			bmp.bitmapData = null;
			bmp = null;
			_backgrounds[_backgrounds.length] = [cls,res];
			return res;
		}
		
		static public function removeAsset(cls:Class):void {
			var n:int = 0;
			var l:int = _assets.length;
			for (n; n < l; n++) {
				if (_assets[n][0] == cls){
					_assets[n][1].dispose();
					_assets.removeAt(n);
					break;
				}
			}
		}
		
		static public function removeBackground(val:ImageBitmapData):void {
			var n:int = 0;
			var l:int = _backgrounds.length;
			for (n; n < l; n++) {
				if (_backgrounds[n][1] == val) {
					_backgrounds[n][1].dispose();
					_backgrounds.removeAt(n);
					break;
				}
			}
		}
		
		static public function clearBackgrounds():void {
			var l:int = _backgrounds.length;
			for (var n:int = 0; n < l; n++) {
				(_backgrounds[n][1] as ImageBitmapData).dispose();
				_backgrounds[n][1] = null;
				_backgrounds[n] = null;
			}
			_backgrounds = [];
		}
		
		static public function getKeyboardSnapshot():BitmapData {
			if (keyboardSnapshot)
				return keyboardSnapshot.clone();
			return null;
		}
	}
}