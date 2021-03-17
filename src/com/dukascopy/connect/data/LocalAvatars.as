package com.dukascopy.connect.data {
	
	import assets.AskQuestionAvatar;
	import assets.BankBotAvatar;
	import assets.LogoRectangle;
	import assets.SecretAvatar;
	import assets.SettingsMaskIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class LocalAvatars {
		
		//TODO:LANG
		static public const QUESTIONS:String = "###questions";
		static public const SECRET:String = "###secret";
		static public const SUPPORT:String = "###support";
		static public const SUPPORT_VI:String = "###supportVi";
		static public const BANK:String = "###bank";
		
		static public const BOT_1:String = "###botAvatar_1";
		static public const BOT_2:String = "###botAvatar_2";
		static public const BOT_3:String = "###botAvatar_3";
		static public const BOT_4:String = "###botAvatar_4";
		static public const BOT_5:String = "###botAvatar_5";
		
		static public const BOT_1_BIG:String = "###botAvatarBig_1";
		static public const BOT_2_BIG:String = "###botAvatarBig_2";
		static public const BOT_3_BIG:String = "###botAvatarBig_3";
		static public const BOT_4_BIG:String = "###botAvatarBig_4";
		static public const BOT_5_BIG:String = "###botAvatarBig_5";
		
		static public const MEN:String = "###m";
		static public const WOMAN:String = "###woman";
		
		static private var avatars:Array = [];
		
		public function LocalAvatars() {
			
		}
		
		static public function isLocal(url:String):Boolean {
			if (url == null)
			{
				return false;
			}
			
			if (url.indexOf(escape(QUESTIONS)) != -1 || url.indexOf(QUESTIONS) != -1)
				return true;
			if (url.indexOf(escape(SECRET)) != -1 || url.indexOf(SECRET) != -1)
				return true;
			if (url.indexOf(escape(SUPPORT)) != -1 || url.indexOf(SUPPORT) != -1)
				return true;
			if (url.indexOf(escape(SUPPORT_VI)) != -1 || url.indexOf(SUPPORT_VI) != -1)
				return true;
			if (url.indexOf(escape(BANK)) != -1 || url.indexOf(BANK) != -1)
				return true;
			
			if (url.indexOf(escape(BOT_1)) != -1 || url.indexOf(BOT_1) != -1)
				return true;
			if (url.indexOf(escape(BOT_2)) != -1 || url.indexOf(BOT_2) != -1)
				return true;
			if (url.indexOf(escape(BOT_3)) != -1 || url.indexOf(BOT_3) != -1)
				return true;
			if (url.indexOf(escape(BOT_4)) != -1 || url.indexOf(BOT_4) != -1)
				return true;
			if (url.indexOf(escape(BOT_5)) != -1 || url.indexOf(BOT_5) != -1)
				return true;
			
			if (url.indexOf(escape(BOT_1_BIG)) != -1 || url.indexOf(BOT_1_BIG) != -1)
				return true;
			if (url.indexOf(escape(BOT_2_BIG)) != -1 || url.indexOf(BOT_2_BIG) != -1)
				return true;
			if (url.indexOf(escape(BOT_3_BIG)) != -1 || url.indexOf(BOT_3_BIG) != -1)
				return true;
			if (url.indexOf(escape(BOT_4_BIG)) != -1 || url.indexOf(BOT_4_BIG) != -1)
				return true;
			if (url.indexOf(escape(BOT_5_BIG)) != -1 || url.indexOf(BOT_5_BIG) != -1)
				return true;
			if (url.indexOf(escape(MEN)) != -1 || url.indexOf(MEN) != -1)
				return true;
			if (url.indexOf(escape(WOMAN)) != -1 || url.indexOf(WOMAN) != -1)
				return true;
			
			return false;
		}	
		
		static public function getAvatar(url:String, size:Number = -1):ImageBitmapData {
			if (size == -1)
				size = int(Config.FINGER_SIZE * 0.56);
			var icon:Sprite;
			if (url == QUESTIONS) {
				if (avatars[QUESTIONS] == null || (avatars[QUESTIONS] as ImageBitmapData).isDisposed == false) {
					icon = new SWF911Avatar();
					UI.scaleToFit(icon, size, size);
					avatars[QUESTIONS] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.QUESTIONS");
					(avatars[QUESTIONS] as ImageBitmapData).isAsset = true;
				}
				return avatars[QUESTIONS];
			} else if (url == SECRET) {
				if (avatars[SECRET] == null || (avatars[SECRET] as ImageBitmapData).isDisposed == false) {
					icon = new SWFIncognitoAvatar();;
					UI.scaleToFit(icon, int(Config.FINGER_SIZE), int(Config.FINGER_SIZE));
					avatars[SECRET] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.SECRET");
					(avatars[SECRET] as ImageBitmapData).isAsset = true;
				}
				return avatars[SECRET];
			} 
			else if (url == SUPPORT) {
				if (avatars[SUPPORT] == null || (avatars[SUPPORT] as ImageBitmapData).isDisposed == false) {
					icon = new SWFSupportAvatar();
					UI.scaleToFit(icon, int(Config.FINGER_SIZE), int(Config.FINGER_SIZE));
					avatars[SUPPORT] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.SUPPORT");
					(avatars[SUPPORT] as ImageBitmapData).isAsset = true;
				}
				return avatars[SUPPORT];
			}
			else if (url == SUPPORT_VI) {
				if (avatars[SUPPORT_VI] == null || (avatars[SUPPORT_VI] as ImageBitmapData).isDisposed == false) {
					icon = new LogoRectangle();
					UI.scaleToFit(icon, int(Config.FINGER_SIZE), int(Config.FINGER_SIZE));
					avatars[SUPPORT_VI] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.SUPPORT_VI");
					(avatars[SUPPORT_VI] as ImageBitmapData).isAsset = true;
				}
				return avatars[SUPPORT_VI];
			}
			else if (url == BANK) {
				if (avatars[BANK] == null || (avatars[BANK] as ImageBitmapData).isDisposed == false) {
					icon = new SWFAccountAvatar();
				//	UI.colorize(icon, Style.color());
					UI.scaleToFit(icon, int(Config.FINGER_SIZE), int(Config.FINGER_SIZE));
					avatars[BANK] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.BANK");
					(avatars[BANK] as ImageBitmapData).isAsset = true;
				}
				return avatars[BANK];
			}
			else if (url == BOT_1) {
				if (avatars[BOT_1] == null || (avatars[BOT_1] as ImageBitmapData).isDisposed == false) {
					icon = new BotAvatar_1();
					UI.scaleToFit(icon, int(Config.FINGER_SIZE), int(Config.FINGER_SIZE));
					avatars[BOT_1] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.BOT_1");
					(avatars[BOT_1] as ImageBitmapData).isAsset = true;
				}
				return avatars[BOT_1];
			}
			else if (url == BOT_2) {
				if (avatars[BOT_2] == null || (avatars[BOT_2] as ImageBitmapData).isDisposed == false) {
					icon = new BotAvatar_2();
					UI.scaleToFit(icon, int(Config.FINGER_SIZE), int(Config.FINGER_SIZE));
					avatars[BOT_2] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.BOT_2");
					(avatars[BOT_2] as ImageBitmapData).isAsset = true;
				}
				return avatars[BOT_2];
			}
			else if (url == BOT_3) {
				if (avatars[BOT_3] == null || (avatars[BOT_3] as ImageBitmapData).isDisposed == false) {
					icon = new BotAvatar_3();
					UI.scaleToFit(icon, int(Config.FINGER_SIZE), int(Config.FINGER_SIZE));
					avatars[BOT_3] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.BOT_3");
					(avatars[BOT_3] as ImageBitmapData).isAsset = true;
				}
				return avatars[BOT_3];
			}
			else if (url == BOT_4) {
				if (avatars[BOT_4] == null || (avatars[BOT_4] as ImageBitmapData).isDisposed == false) {
					icon = new BotAvatar_4();
					UI.scaleToFit(icon, int(Config.FINGER_SIZE), int(Config.FINGER_SIZE));
					avatars[BOT_4] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.BOT_4");
					(avatars[BOT_4] as ImageBitmapData).isAsset = true;
				}
				return avatars[BOT_4];
			}
			else if (url == BOT_5) {
				if (avatars[BOT_5] == null || (avatars[BOT_5] as ImageBitmapData).isDisposed == false) {
					icon = new BotAvatar_5();
					UI.scaleToFit(icon, int(Config.FINGER_SIZE), int(Config.FINGER_SIZE));
					avatars[BOT_5] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.BOT_5");
					(avatars[BOT_5] as ImageBitmapData).isAsset = true;
				}
				return avatars[BOT_5];
			}
			
			else if (url == BOT_1_BIG) {
				if (avatars[BOT_1_BIG] == null || (avatars[BOT_1_BIG] as ImageBitmapData).isDisposed == false) {
					icon = new BotAvatar_1();
					UI.scaleToFit(icon, int(Config.FINGER_SIZE), int(Config.FINGER_SIZE));
					avatars[BOT_1_BIG] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.BOT_1");
					(avatars[BOT_1_BIG] as ImageBitmapData).isAsset = true;
				}
				return avatars[BOT_1_BIG];
			}
			else if (url == BOT_2_BIG) {
				if (avatars[BOT_2_BIG] == null || (avatars[BOT_2_BIG] as ImageBitmapData).isDisposed == false) {
					icon = new BotAvatar_2();
					UI.scaleToFit(icon, int(Config.FINGER_SIZE), int(Config.FINGER_SIZE));
					avatars[BOT_2_BIG] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.BOT_2");
					(avatars[BOT_2_BIG] as ImageBitmapData).isAsset = true;
				}
				return avatars[BOT_2_BIG];
			}
			else if (url == BOT_3_BIG) {
				if (avatars[BOT_3_BIG] == null || (avatars[BOT_3_BIG] as ImageBitmapData).isDisposed == false) {
					icon = new BotAvatar_3();
					UI.scaleToFit(icon, int(Config.FINGER_SIZE), int(Config.FINGER_SIZE));
					avatars[BOT_3_BIG] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.BOT_3");
					(avatars[BOT_3_BIG] as ImageBitmapData).isAsset = true;
				}
				return avatars[BOT_3_BIG];
			}
			else if (url == BOT_4_BIG) {
				if (avatars[BOT_4_BIG] == null || (avatars[BOT_4_BIG] as ImageBitmapData).isDisposed == false) {
					icon = new BotAvatar_4();
					UI.scaleToFit(icon, int(Config.FINGER_SIZE), int(Config.FINGER_SIZE));
					avatars[BOT_4_BIG] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.BOT_4");
					(avatars[BOT_4_BIG] as ImageBitmapData).isAsset = true;
				}
				return avatars[BOT_4_BIG];
			}
			else if (url == BOT_5_BIG) {
				if (avatars[BOT_5_BIG] == null || (avatars[BOT_5_BIG] as ImageBitmapData).isDisposed == false) {
					icon = new BotAvatar_5();
					UI.scaleToFit(icon, int(Config.FINGER_SIZE), int(Config.FINGER_SIZE));
					avatars[BOT_5_BIG] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.BOT_5");
					(avatars[BOT_5_BIG] as ImageBitmapData).isAsset = true;
				}
				return avatars[BOT_5_BIG];
			}
			else if (url == MEN) {
				if (avatars[MEN] == null || (avatars[MEN] as ImageBitmapData).isDisposed == false) {
					icon = new MenIcon();
					UI.scaleToFit(icon, size, size);
					avatars[MEN] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.MEN");
					(avatars[MEN] as ImageBitmapData).isAsset = true;
				}
				return avatars[MEN];
			}
			else if (url == WOMAN) {
				if (avatars[WOMAN] == null || (avatars[WOMAN] as ImageBitmapData).isDisposed == false) {
					icon = new wonamIcon();
					UI.scaleToFit(icon, size, size);
					avatars[WOMAN] = UI.getSnapshot(icon, StageQuality.HIGH, "LocalAvatars.WOMAN");
					(avatars[WOMAN] as ImageBitmapData).isAsset = true;
				}
				return avatars[WOMAN];
			}
			return null;
		}
	}
}