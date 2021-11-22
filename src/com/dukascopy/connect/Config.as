package com.dukascopy.connect {

    import com.dukascopy.connect.data.BarabanSettings;
    import com.dukascopy.connect.sys.auth.Auth;
    import flash.system.Capabilities;
	
    /**
     * @author Igor Bloom
     */
	
    public class Config {
		
/* LIVE */
        static public const URL_PHP_CORE_SERVER:String = 'https://dccapi.dukascopy.online/';
        static public const URL_WS_HOST_1:String = "wss://ws.dukascopy.online"; //192.168.240.142; // 144 или 142
        static public const URL_WS_HOST_2:String = "wss://ws.dukascopy.ch"; //192.168.240.142; // 144 или 142
        static public const URL_MEDIA_VI:String = "rtmp://socket.dukascopy.online/recognition";
		
        static public const URL_FXCOMM_PROFILE:String = "https://www.dukascopy.online/fxcomm/profile/?nickname=";
        static public const URL_PHP_CORE_SERVER_FILE:String = 'https://dccfilesapi.dukascopy.online/';
        static public const URL_LANG:String = "https://dccfilesapi.dukascopy.online/";
        static public const PAYMENTS_WEB:String="https://my.dukascopy.bank/new/";
		
        static public const EP_MAIN:int = 133;//30;
        static public const EP_PAYMENTS:int = 113;
        static public const EP_VI_EUR:int = 135;
        static public const EP_VI_PAY:int = 136;
        static public const EP_VI_DEF:int = 133;
        static public const EP_911:int = 138;
        static public const EP_TRADING:int = 143;
        static public const EP_CONNECT:int = 41;
        static public const CAT_DATING:int = 5;
        static public const CAT_GENERAL:int = 2;
        static public const SERVER_NAME:String = "";
        static public const test:Boolean = false;

        static public const ADMIN_UIDS:String = "WdW6DJI1WbWo," +	// Igor Bloom
            "WdW6DJWbW3IsIb," +	// Ilya Shcherbakov
            "I6DzDaWqWKWE," +	// Sergey Dobarin
            "WrD0DyIsDMW3," +	// Semen Lutonin
            "WdW6DJIEW3WpWm," +	// Kirill Sergeev/
            "WgWZWrWZWvWUIKWe," +	// Katerina Aleksejenko
            "W9W5WhIkW7WhIk";	// Anastasiya Duka
		static public const TF_UIDS:String = "WdW6DJI1WbWo," +	// Igor Bloom
			"WdW6DJWbW3IsIb," +	// Ilya Shcherbakov
			"I6DzDaWqWKWE";		// Sergey Dobarin
		static public const BOT_UIDS:String = "WgDNWdIEW4I6IsWg" // Support bot
		
/* PRE * /
		static public const URL_PHP_CORE_SERVER:String = 'https://pre-dccapi-02.site.dukascopy.com/';
        static public const URL_WS_HOST_1:String = "wss://ws-pre.dukascopy.com/"; //192.168.240.142; // 144 или 142
        static public const URL_WS_HOST_2:String = "wss://ws-pre.dukascopy.com/"; //192.168.240.142; // 144 или 142
		static public const URL_MEDIA_VI:String = "rtmp://socket.dukascopy.com/recognition";
		
		static public const URL_FXCOMM_PROFILE:String = "https://www.dukascopy.com/fxcomm/profile/?nickname=";
		static public const URL_PHP_CORE_SERVER_FILE:String = 'https://dccfilesapi.dukascopy.com/';
		static public const URL_LANG:String = "https://dccfilesapi.dukascopy.ch/";
        static public const PAYMENTS_WEB:String="https://my.dukascopy.bank/new/";
		
		static public const EP_MAIN:int = 30;
		static public const EP_PAYMENTS:int = 113;
		static public const EP_VI_EUR:int = 135;
		static public const EP_VI_PAY:int = 136;
		static public const EP_VI_DEF:int = 133;
		static public const EP_911:int = 138;
        static public const EP_TRADING:int = 143;
		static public const EP_CONNECT:int = 41;
		static public const CAT_DATING:int = 5;
		static public const CAT_GENERAL:int = 2;
		static public const SERVER_NAME:String = " PRE";
		static public const test:Boolean = false;
		
		static public const ADMIN_UIDS:String = "WdW6DJI1WbWo," +	// Igor Bloom
			"WdW6DJWbW3IsIb," +	// Ilya Shcherbakov
			"I6DzDaWqWKWE," +	// Sergey Dobarin
			"WrD0DyIsDMW3," + 	// Semen Lutonin
			"WdW6DJIEW3WpWm," +	// Kirill Sergeev
			"W9W5WhIkW7WhIk"	// Anastasiya Duka
		static public const TF_UIDS:String = "WdW6DJI1WbWo," +	// Igor Bloom
            "WdW6DJWbW3IsIb," +	// Ilya Shcherbakov
            "I6DzDaWqWKWE";		// Sergey Dobarin
        static public const BOT_UIDS:String = "WgDNWdIEW4I6IsWg" // Support bot
		
/* TEST * /
		static public const URL_PHP_CORE_SERVER:String = 'https://loki.telefision.com/master/';
		static public const URL_WS_HOST_1:String = "wss://loki.telefision.com/wss/";
		static public const URL_WS_HOST_2:String = "wss://loki.telefision.com/wss/";
		static public const URL_MEDIA_VI:String = "rtmp://vi.telefision.com/recognition";
		
		static public const URL_FXCOMM_PROFILE:String = "https://www.php-test.site.dukascopy.com/fxcomm/profile/?nickname=";
		static public const URL_PHP_CORE_SERVER_FILE:String = 'https://loki.telefision.com/master/';
		static public const URL_LANG:String = "https://dccfilesapi.dukascopy.online/";
        static public const PAYMENTS_WEB:String="https://my.dukascopy.bank/new/";
		
		static public const EP_MAIN:int = 30;
		static public const EP_PAYMENTS:int = 45;
		static public const EP_VI_EUR:int = 46;
		static public const EP_VI_PAY:int = 47;
		static public const EP_VI_DEF:int = 36;
		static public const EP_911:int = 30;
        static public const EP_TRADING:int = 143;
		static public const EP_CONNECT:int = 41;
		static public const CAT_DATING:int = 41;
		static public const CAT_GENERAL:int = 4;
		static public const SERVER_NAME:String = " TEST";
		static public const test:Boolean = true;
		
		static public const ADMIN_UIDS:String = "WdW6DJI1WbWo," +	// Igor BloomC
			"WdW6DJWbW3IsIb," +	// Ilya Shcherbakov
			"I6D5WsWZDLWj";		// Sergey Dobarin44
		static public const TF_UIDS:String = "WdW6DJI1WbWo," +	// Igor Bloom
			"WdW6DJWbW3IsIb," +	// Ilya Shcherbakov
			"I6D5WsWZDLWj";		// Sergey Dobarin
		static public const BOT_UIDS:String = "WgDNWdIEW4I6IsWg" // Support bot
/**/
		
        static public const URL_IMAGE:String = "https://www.dukascopy.com/imageserver/img/";
		
        static public const URL_REMOTE_DEBUGGER:String = "ws://172.18.30.103:9080/";
		
        static public function get URL_PHP_LOG_SERVER():String {
			var base:String= '//wb-dev.telefision.com/dcc/';
			return "https:" + base;
		}
		
        static public function get URL_PHP_STAT_SERVER():String {
            var base:String= '//ws.telefision.com/save';
			return "https:" + base;
		}
		
		static public function get URL_VI_STAT():String {
			var base:String= "//ws.telefision.com/vidid";
			return "https:" + base;
		}
		
		static public function get URL_DEV_STAT():String {
			var base:String= "//ws.telefision.com/dev/stat";
			return "https:" + base;
		}
		
        static public const URL_MEDIA:String = "rtmp://socket.telefision.com/callapp";
		
        static public var MIN_ANDROID_SDK:int=20;
		
        static public const NOTEBOOK_USER_UID:String = "WdDOWTIKWiIk";
        static public const DUKASCOPY_INFO_SERVICE_UID:String = "WIDMD0IaWwIsWD";
        static public const SERVICE_INFO_USER_UID:String = "WIDMD0IaWwIsWD";
        static public const CHANNEL_911_NEWS_UID:String = "WFWGWcWyDPIEI2";
		
        static public const COMPANY_ID:String = "08A29C35B3";
		
        static public const APPLE_LOG:Boolean=true;
        static public const ANDROID_LOG:Boolean=true;
        static public const VERSION:String = "3.5.92o"+(Capabilities.isDebugger?" dbg":"");
        static public const VERSION_SQL:int = 1;
		
        static public const MAX_UPLOAD_THUMB_SIZE:int = 230;
        static public const MAX_UPLOAD_IMAGE_SIZE:int = 1200;
        static public const CHUNK_SIZE:int = 280000;
		
        static public const BOUNDS:String = ".&70o}.?F";
        static public const BOUNDS_INVOICE:String = "#07INVOICE";
		static public const BOUNDS_ESCROW:String = "#04CP2P";
		
        static public const CHAT_AVATAR_SIZE_MAX:int = 200;
        static public const USER_AVATAR_SIZE_MAX:int = 1280;
        static public const BITMAP_SIZE_MAX:int = 3000;
		
        static public const PLATFORM_TYPE:String = "2";
		
        static public const CHAT_INPUT_BOTTOM_PADDING_COLOR:Number = 0xFFFFFF;
		
        static public const MUTE_SOUNDS_ON_ANDROID:Boolean = true;
        static public var MAX_OPEN_ACC_AGE:int = 18;
        static public var MAX_IDENTIFICATION_QUEUE_ALL:int = 30;
        static public var MAX_IDENTIFICATION_QUEUE_SNG:int = 15;
        static public var START_URL:String = "https://www.dukascoin.com/";
        static public const CRYPTO_CHART_URL:String = "https://www.dukascoin.com/?cat=inf&page=chart";
		static public const EP_COINS_SUPPORT:int = 142;
		static public const EP_P2P_CLAIM:int = 133;
		
        static public var FAST_TRACK_COST:Number = 100;
        static public var FAST_TRACK_PROPOSAL_DELAY:Number = 5;
        static public var FAST_TRACK:Boolean = false;
		
        static public var FT_COUNTRIES_AGES:Array = [
            {code:7,age:20}, //ru,kaz
            {code:995,age:25},//georgia
            {code:375,age:25}, // bel
            {code:380,age:20}, // ukr
            {code:998,age:25}, // uzb
            {code:880,age:25}, // bang
            {code:373,age:25}, // mold
            {code:63,age:25}, // philip
            {code:996,age:99}, // kirgz
        ];
		
        static public var BARABAN:Boolean = true;
        static public var JAIL_SECTION_PROTECTIONS_NUM:int = 20;
		
        static public var MIN_CHAT_OPEN_PAY_RATING:int=10;
		
        static public var defaultFontName:String = "Tahoma";
        static public var multiLanguage:Boolean = true;
        static public var webRTCAvaliable:Boolean = true;
        static public var socialAvailable:Boolean = true;
		
        static public var BANKBOT:Boolean = true;
        static public var PASS_PHOTO:Boolean = false;
        static public var GEO_POSITION:Boolean = false;
        static public var LOTTERY:Boolean = false;
        static public var PAID_CHANNEL:Boolean = false;
        static public var BOTS:Boolean = false;
        static public var ENABLE_INVESTMENTS:Boolean = false;
        static public var PUBLIC_QUESTIONS_ALLOWED:Boolean = true;
        static public var barabanSettings:BarabanSettings = new BarabanSettings();
		
        static public var START_DUK_AMMOUNT:Number = 0;
		static public var minimumNotesAmount:Number = 1000;
		
		static public var SECURE_MONEY_SEND:Boolean = true;
        static public var MIN_VERSION:int=-1;
		
        static private var _fingerSize:int = -1;
		
        static public function get FINGER_SIZE():int {
            if (_fingerSize == -1) {
                _fingerSize = 70;
                var i:Number=Capabilities.screenDPI;
                if (Capabilities.screenDPI >= 100 && Capabilities.screenDPI < 140)
                    _fingerSize = 62;
                if (Capabilities.screenDPI >= 140 && Capabilities.screenDPI < 200)
                    _fingerSize = 60;
                if (Capabilities.screenDPI >= 200 && Capabilities.screenDPI < 250)
                    _fingerSize = 80;
                if (Capabilities.screenDPI >= 250 && Capabilities.screenDPI < 300)
                    _fingerSize = 95;
                if (Capabilities.screenDPI >= 300 && Capabilities.screenDPI < 350)
                    _fingerSize = 115;
                if (Capabilities.screenDPI >= 350 && Capabilities.screenDPI < 400)
                    _fingerSize = 130;
                if (Capabilities.screenDPI >= 400 && Capabilities.screenDPI < 450)
                    _fingerSize = 150;
                if (Capabilities.screenDPI >= 450 && Capabilities.screenDPI < 500)
                    _fingerSize = 160;
                if (Capabilities.screenDPI >= 500 && Capabilities.screenDPI < 550)
                    _fingerSize = 197;
                if (Capabilities.screenDPI >= 550 && Capabilities.screenDPI < 600)
                    _fingerSize = 215;
                if (Capabilities.screenDPI >= 600 && Capabilities.screenDPI < 650)
                    _fingerSize = 230;
                if (Capabilities.screenDPI >= 650)
                    _fingerSize = 245;
            }
            return _fingerSize;
        }
		
        static private var _fingerSizeDot5:int = -1;
		
        static public function get FINGER_SIZE_DOT_5():int {
            if (_fingerSizeDot5 == -1)
                _fingerSizeDot5 = Math.round(FINGER_SIZE * .5);
            return _fingerSizeDot5;
        }
		
        static private var _fingerSizeDot75:int = -1;
		
        static public function get FINGER_SIZE_DOT_75():int {
            if (_fingerSizeDot75 == -1)
                _fingerSizeDot75 = Math.round(FINGER_SIZE * .75);
            return _fingerSizeDot75;
        }
		
        static private var _fingerSizeDot25:int = -1;
		
        static public function get FINGER_SIZE_DOT_25():int {
            if (_fingerSizeDot25 == -1)
                _fingerSizeDot25 = Math.round(FINGER_SIZE * .25);
            return _fingerSizeDot25;
        }
		
        static private var _fingerSizeDot35:int = -1;
		
        static public function get FINGER_SIZE_DOT_35():int {
            if (_fingerSizeDot35 == -1)
                _fingerSizeDot35 = Math.round(FINGER_SIZE * .35);
            return _fingerSizeDot35;
        }
		
        static private var _fingerSizeDouble:int = -1;
		
        static public function get FINGER_SIZE_DOUBLE():int {
            if (_fingerSizeDouble == -1)
                _fingerSizeDouble = Math.round(FINGER_SIZE * 2);
            return _fingerSizeDouble;
        }
		
        static private var _dialodMargin:int = -1;
		
        static public function get DIALOG_MARGIN():int {
            if (_dialodMargin == -1)
                _dialodMargin = Math.round(FINGER_SIZE * .4);
            return _dialodMargin;
        }
		
        static private var _smallAvatarSize:int = -1;
		
        static public function get SMALL_AVATAR_SIZE():int {
            if (_smallAvatarSize == -1)
                _smallAvatarSize = Math.round(FINGER_SIZE * .92);
            return _smallAvatarSize;
        }
		
        static private var _topBarHeight:int = -1;
		
        static public function get TOP_BAR_HEIGHT():Number {
            if (_topBarHeight == -1)
                _topBarHeight = Math.round(FINGER_SIZE * .85);
            return _topBarHeight;
        }
		
        static public function set TOP_BAR_HEIGHT(val:Number):void{
            _topBarHeight=val;
        }
		
        static private var _topBarFontSize:int = -1;
		
        static public function get TOP_BAR_FONT_SIZE():int {
            if (_topBarFontSize == -1)
                _topBarFontSize = Math.round(FINGER_SIZE * .4);
            return _topBarFontSize;
        }
		
        static private var _topBarDialogFontSize:int = -1;
		
        static public function get TOP_BAR_DIALOG_FONT_SIZE():int {
            if (_topBarDialogFontSize == -1)
                _topBarDialogFontSize = Math.round(FINGER_SIZE * .27);
            return _topBarDialogFontSize;
        }
		
        static private var __platform:int = -1;
        static private var isPlatformWindow:Boolean;
        static private var isPlatformDroid:Boolean;
        static private var isPlatformIos:Boolean;
		
        static public function get PLATFORM_WINDOWS():Boolean {
            if (__platform == -1)
                getPlatform();
            return isPlatformWindow;
        }
		
        static public function get PLATFORM_ANDROID():Boolean {
            if (__platform == -1)
                getPlatform();
            return isPlatformDroid;
        }
		
        static public function get PLATFORM_APPLE():Boolean {
            if (__platform == -1)
                getPlatform();
            return isPlatformIos;
        }
		
        static private function getPlatform():void {
            isPlatformWindow = false;
            isPlatformDroid = false;
            isPlatformIos = false;
            if (Capabilities.manufacturer.toLowerCase().indexOf('android') > -1)
                isPlatformDroid = true;
            else if (Capabilities.manufacturer.toLowerCase().indexOf('ios') > -1)
                isPlatformIos = true;
            else
                isPlatformWindow = true;
            __platform = 1;
        }
		
        static public function isTest():Boolean {
            return test;
		}
		
        static public function isAdmin():Boolean {
            return ADMIN_UIDS.indexOf(Auth.uid) != -1;
        }
		
        static public function isTF():Boolean {
            return TF_UIDS.indexOf(Auth.uid) != -1;
        }
		
        static public function isCompanyMember():Boolean {
            return (Auth.companyID != null && Auth.companyID == COMPANY_ID);
        }
		
        static public function isBot(uid:String):Boolean{
            return BOT_UIDS.indexOf(uid) != -1;
        }
		
        static public function get PLATFORM():String {
            if (PLATFORM_ANDROID == true)
                return 'android';
            if (PLATFORM_APPLE == true)
                return 'ios'
            return 'win';
        }
		
        static private var _margin:int = -1;
		
        static public function get MARGIN():int {
            if (_fingerSize < 0)
                var f:int = FINGER_SIZE;
            if (_margin < 0)
                _margin = FINGER_SIZE * .15;
            return _margin;
        }
		
        static private var _dobule_margin:int = -1;
		
        static public function get DOUBLE_MARGIN():int {
            if (_margin < 0)
                var f:int = MARGIN;
            if (_dobule_margin < 0)
                _dobule_margin = MARGIN * 2;
            return _dobule_margin;
        }
		

        
        static private var _appleTopOffset:int = -1;
		
        static public function setupAppleTopOffset(offset:int):void{
            _appleTopOffset=offset;
        }
		
        static public function setupAppleBottomOffset(offset:int):void{
            _appleBottomOffset=offset;
        }
        
        static public function setupFingerSize(size:int):void{
            _fingerSize=size;
        }

        static public function get APPLE_TOP_OFFSET():int {
            if (_appleTopOffset == -1) {
                if (PLATFORM_APPLE == false) {
                    _appleTopOffset = 0;
                    return _appleTopOffset;
                }
                // SETS FINGER SIZE
                _appleTopOffset = 45; // IPHONE
                if (Capabilities.screenDPI == 326)
                    _appleTopOffset = 45;
                if (Capabilities.screenDPI == 401)
                    _appleTopOffset = 76;
                var ato:Number = isRetina();
                if (ato > 0)
                    _appleTopOffset=ato;
                // DEBUG FOR iphone X screen
                if (Capabilities.screenDPI == 101) {
                    _appleBottomOffset = 44;
                }
            }
            return _appleTopOffset;
        }
		
        static public function isRetina():Number{
            // iphone X, Xs;
            if (Capabilities.screenResolutionX == 1125 && Capabilities.screenResolutionY == 2436) {
                return 44 * 3
            }
            // iphone XS MAX;
            if (Capabilities.screenResolutionX == 1242 && Capabilities.screenResolutionY == 2688) {
                return 44 * 3; // should be 2
            }
            // iphone XS MAX;
            if (Capabilities.screenResolutionX == 828 && Capabilities.screenResolutionY == 1792) {
                return 44 * 3;
            }
    
            return  -1;
        }
		
        static private var _appleBottomOffset:int = -1;
		
        static public function get APPLE_BOTTOM_OFFSET():int {
            if (_appleBottomOffset == -1) {
                if (PLATFORM_APPLE == false) {
                    _appleBottomOffset = 0;
                    return _appleBottomOffset;
                }
                // SETS FINGER SIZE
                _appleBottomOffset = 0; // IPHONE
                if (isRetina() > 0)
                    _appleBottomOffset = 102; //IPHONE X
                // DEBUG FOR iphone X screen
                if (Capabilities.screenDPI == 101) {
                    _appleBottomOffset = 102;
                }
            }
            return _appleBottomOffset;
        }
		
        static private var _avatarSize:int = -1;
		
        static public function get avatarSize():int {
            if (_avatarSize == -1)
                _avatarSize = Math.ceil(Config.FINGER_SIZE * .35);
            return _avatarSize;
        }
		
        static private var _avatarSizeDouble:int = -1;
		
        static public function get avatarSizeDouble():int {
            if (_avatarSizeDouble == -1)
                _avatarSizeDouble = _avatarSize * 2;
            return _avatarSizeDouble;
        }
    }
}
