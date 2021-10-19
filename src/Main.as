package {


/* MAIN PROJECT */
import com.dukascopy.connect.Config;
import com.dukascopy.connect.MobileGui;
import com.dukascopy.connect.sys.auth.Auth;
import com.dukascopy.connect.sys.echo.EchoParser;
import com.dukascopy.connect.sys.echo.echo;
import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
import com.dukascopy.connect.sys.php.PHP;
import com.dukascopy.connect.sys.php.PHPRespond;
import com.dukascopy.connect.utils.Debug.BloomDebugger;
import com.dukascopy.connect.utils.TextUtils;
import com.greensock.TweenMax;
import com.hurlant.util.Base64;
import flash.display.BitmapData;
import flash.display.JPEGEncoderOptions;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.ErrorEvent;
import flash.events.UncaughtErrorEvent;
import flash.system.Capabilities;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import flash.utils.ByteArray;
import flash.utils.getTimer;



[SWF(backgroundColor="#ffffff")]
public class Main extends Sprite {

		public static var timer:Number;
		public static var startTime:Number=new Date().getTime();

		public function Main() {

			timer = getTimer(); 
			stage.quality = StageQuality.LOW;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.displayState = StageDisplayState.NORMAL;

			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			EchoParser.init(stage);
			
			if (Capabilities.isDebugger == false)
				this.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onGlobalError);

			TweenMax.delayedCall(2, start, null, true);
		}
		
		private function start():void{
			new MobileGui(this, stage); 
			//onGlobalError();
		}
		
		public static function onGlobalError(e:UncaughtErrorEvent = null):void {
			
			BloomDebugger.stop();
			
			if (e != null) {
				e.preventDefault();
				if (e.error.errorID == 2032 || 
					e.error.errorID == 2031 ||
					e.error.errorID == 2029) {
						echo("Main", "onGlobalerror"," Error: " + e.error.errorID, true);
						//PHP.call_statVI("exception", "errID:"+e.error.errorID);
						BloomDebugger.start();
						return;
				}
			}
			
			TweenMax.delayedCall(1, function():void {
				echo("Main", "onGlobalError");
				var message:String = 'UNKNOWN ERROR';
				try {
					if (e != null) {
						if (e.error is Error)
						{
							message = Error(e.error).message;
						//	DialogManager.alert("error", Error(e.error).message);
						//	message = Error(e.error).getStackTrace();
						}
						else if (e.error is ErrorEvent)
							message = ErrorEvent(e.error).text;
						else if (e.error != null)
							message = e.error.toString();
					}
					if (message == null)
						message = 'UNKNOWN ERROR';
				} catch (err:Error) {
					message = 'UNDETECTED ERROR';
				}
				sendError(message);
				
			}, null, true);
			
		}
		
		static public function sendError(message:String, reason:String = null):void{
			BloomDebugger.stop();
			var cs:String = "";
			if (MobileGui.centerScreen == null)
				cs = " NO SCREEN MANAGER";
			else if (MobileGui.centerScreen.currentScreenClass == null)
				cs = " NO SCREEN CLASS";
			else
				cs = " " + MobileGui.centerScreen.currentScreenClass + " > " + MobileGui.centerScreen.currentScreen.getAdditionalDebugInfo();
			
			
			try{	
				echo("Main","sendError",message);
			}catch(e:Error){}

			var base64Screen:String="";
			
			try {
				var bmd:BitmapData = new BitmapData(MobileGui.stage.stageWidth, MobileGui.stage.stageHeight);
				bmd.draw(MobileGui.stage);
				var imgBMD:ImageBitmapData = TextUtils.scaleBitmapData(bmd, .3);
				bmd.dispose();
				var pngImage:ByteArray = imgBMD.encode(imgBMD.rect, new JPEGEncoderOptions(87));
				base64Screen = "data:image/jpeg;base64," + Base64.encodeByteArray(pngImage);
			}catch (e) {
				base64Screen="can't get screenshot";
			}
			
			var uptime:Number=new Date().getTime()-startTime;
			
			
			message += "\n";
			message += "version: " + Config.VERSION + Config.SERVER_NAME + "\n";
			message += "user: " + ((Auth.username)?Auth.username:"No username") + "\n";
			message += "user uid: " + ((Auth.uid)?Auth.uid:"No uid") + "\n";
			message += "screen: " + cs + "\n";
			message += "platform: " + Capabilities.manufacturer + "\n";
			message += "DPI: " + Capabilities.screenDPI+","+Capabilities.screenResolutionX+"x"+Capabilities.screenResolutionY + "\n";
			message += "Up time: "+uptime+"\n";
			if(reason)
				message+="reason:"+reason+"\n";
			message += "last message:\n" + EchoParser.lastMessage + "\n";
			message += "stack:\n" + BloomDebugger.getStack() + "\n";
			
			echo("Main","sendError",message);
			
			message +="last screen view:\n"+base64Screen;
			
			PHP.call_statVI("exception", message);
			
			EchoParser.clearStock();
			BloomDebugger.start();
		}
		
		static private function onReport(r:PHPRespond):void 
		{
			r.dispose();
		}
	}
}