package com.dukascopy.connect.screens.payments.card {
	
	import com.dukascopy.connect.sys.assets.Assets;
	import flash.display.BitmapData;
	import flash.display.Sprite;

	public class CardCommon {
		
		public static const TYPE_VISA:String = 'visa';
		public static const TYPE_VISA_ELECTRON:String = 'visa-electron';
		public static const TYPE_MAESTRO:String = 'maestro';
		public static const TYPE_MASTERCARD:String = 'mastercard';
		public static const TYPE_MC:String = 'mc';
		public static const TYPE_AMEX:String = 'amex';
		
		private static const cardTypeObj:Object = {
			'visa-electron': {length: [16], prefixes: ['4026', '4175', '4405', '4508', '4844', '4913', '4917']},
			'maestro': {
				length: [12, 13, 14, 15, 16, 17, 18, 19],
				prefixes: ['5010', '5011', '5012', '5013', '5014', '5015', '5016', '5017', '5018',
					'502', '503', '504', '505', '506', '507', '508',
					'6012', '6013', '6014', '6015', '6016', '6017', '6018', '6019',
					'602', '603', '604', '605', '6060',
					'677', '675', '674', '673', '672', '671', '670',
					'6760', '6761', '6762', '6763', '6764', '6765', '6766', '6768', '6769']
			},
			'mastercard': {length: [16], prefixes: ['50', '51', '52', '53', '54', '55']},
			'visa': {length: [13, 16], prefixes: ['4']}
		}
		
		static public function getCardIconClassByType(type:String):Class {
			switch (type) {
				case CardCommon.TYPE_VISA: {
					return SWFVisaIcon;
				}
				case CardCommon.TYPE_VISA_ELECTRON: {
					return SWFVISAElectronIcon;
				}
				case CardCommon.TYPE_MASTERCARD: {
					return SWFMasterCardIcon;
				}
				case CardCommon.TYPE_MC: {
					return SWFMasterCardIcon;
				}
				case CardCommon.TYPE_MAESTRO: {
					return SWFMaestroIcon;
				}
				case CardCommon.TYPE_AMEX: {
					return SWFAmexIcon;
				}
			}
			return null;
		}
		
		static public function getCardIconByType(type:String):Sprite {
			switch (type) {
				case CardCommon.TYPE_VISA: {
					return new SWFVisaIcon();
				}
				case CardCommon.TYPE_VISA_ELECTRON: {
					return new SWFVISAElectronIcon();
				}
				case CardCommon.TYPE_MASTERCARD: {
					return new SWFMasterCardIcon();
				}
				case CardCommon.TYPE_MC: {
					return new SWFMasterCardIcon();
				}
				case CardCommon.TYPE_MAESTRO: {
					return new SWFMaestroIcon();
				}
				case CardCommon.TYPE_AMEX: {
					return new SWFAmexIcon();
				}
			}
			return null;
		}
		
		static public function getCardTypeByNumber(number:String):String {
			if ((number.indexOf("34") == 0 || number.indexOf("37") == 0) && number.length == 15)
				return TYPE_AMEX;
			if (number.charAt(0) == "4" && (number.length == 13 || number.length == 16 || number.length == 19)) {
				if (number.indexOf("4026") == 0 ||
					number.indexOf("417500") == 0 ||
					number.indexOf("4405") == 0 ||
					number.indexOf("4508") == 0 ||
					number.indexOf("4844") == 0 ||
					number.indexOf("4913") == 0 ||
					number.indexOf("4917") == 0)
						return TYPE_VISA_ELECTRON;
				return TYPE_VISA;
			}
			if (number.indexOf("5018") == 0 ||
				number.indexOf("5020") == 0 ||
				number.indexOf("5038") == 0 ||
				number.indexOf("5612") == 0 ||
				number.indexOf("5893") == 0 ||
				number.indexOf("6304") == 0 ||
				number.indexOf("6759") == 0 ||
				number.indexOf("6761") == 0 ||
				number.indexOf("6762") == 0 ||
				number.indexOf("6763") == 0 ||
				number.indexOf("0604") == 0 ||
				number.indexOf("6390") == 0)
					return TYPE_MAESTRO;
			if (int(number.substr(0, 2)) > 50 && int(number.substr(0, 2)) < 56 && number.length == 16)
				return TYPE_MASTERCARD;
			if (int(number.substr(0, 4)) > 2220 && int(number.substr(0, 4)) < 2721 && number.length == 16)
				return TYPE_MASTERCARD;
			return "";
		}
		
		public static function getBitmapDataCardByNumberCard(number:String):BitmapData {
			var str:String = CardCommon.getTypeCardByNumberCard(number);
			var btm:BitmapData;
			switch (str) {
				case CardCommon.TYPE_VISA: {
					btm =  Assets.getAsset(Assets.PAYMENT_ICON_VISA);
					break;
				}
				case CardCommon.TYPE_VISA_ELECTRON: {
					btm =  Assets.getAsset(Assets.PAYMENT_ICON_ELECTRON_VISA);
					break;
				}
				case CardCommon.TYPE_MAESTRO: {
					btm =  Assets.getAsset(Assets.PAYMENT_ICON_MAESTRO);
					break;
				}
				case CardCommon.TYPE_MASTERCARD: {
					btm =  Assets.getAsset(Assets.PAYMENT_ICON_MASTERCARD);
					break;
				}
				default:{
					return null
				}
			}
			return btm;
		}

		public static function getTypeCardByNumberCard(number:String):String {
			var resultTypeCard:String = "";
			var isT:Boolean;

			if (checkItem(TYPE_VISA_ELECTRON) == false) {
				if (checkItem(TYPE_MAESTRO) == false) {
					if (checkItem(TYPE_MASTERCARD) == false) {
						if (checkItem(TYPE_VISA) == false) {
							resultTypeCard = "";
						} else {
							resultTypeCard = TYPE_VISA;
						}
					} else {
						resultTypeCard = TYPE_MASTERCARD;
					}
				} else {
					resultTypeCard = TYPE_MAESTRO;
				}
			} else {
				resultTypeCard = TYPE_VISA_ELECTRON;
			}
			return resultTypeCard;

			function checkItem(type:String):Boolean {
				var tempObj:Object = cardTypeObj[type];
				var arr:Array = (tempObj.length as Array);
				var i:int = 0;
				var value:int;
				for (i; i < arr.length; i++) {
					value = arr[i];
					if (number.length == value) {
						isT = true;
						break;
					}
				}

				if (isT) {
					isT = false;
					i = 0;
					arr = tempObj.prefixes as Array;
					for (i; i < arr.length; i++) {
						value = arr[i];
						number.length;
						var str:String = String(number).substr(0, String(value).length);
						if (str == String(value)) {
							isT = true;
							break;
						}
					}
				} else {
					return false;
				}
				return isT;
			}

			/*switch (resultTypeCard) {
			 case TYPE_VISA_ELECTRON: {

			 break;
			 }
			 case TYPE_MAESTRO: {

			 break;
			 }
			 case TYPE_MASTERCARD: {

			 break;
			 }
			 case TYPE_VISA: {

			 break;
			 }
			 }*/
		}
	}
}