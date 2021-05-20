package {


import flash.display.Sprite;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import flash.system.Capabilities;
import flash.events.UncaughtErrorEvent;
import com.greensock.TweenMax;
import com.dukascopy.connect.managers.escrow.EscrowDealManager;
import com.dukascopy.connect.GD;
import com.dukascopy.connect.managers.escrow.EscrowDealCreateRequest;
import com.dukascopy.connect.managers.escrow.EscrowDealSide;
import com.forms.FormComponent;
import com.dukascopy.connect.managers.webview.WebViewManager;
import com.forms.Form;


[SWF(backgroundColor="#ffffff")]
public class MainEscrow extends Sprite {

		public function MainEscrow() {

			stage.quality = StageQuality.LOW;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.displayState = StageDisplayState.NORMAL;
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			if (Capabilities.isDebugger == false)
				this.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onGlobalError);

			TweenMax.delayedCall(2, start, null, true);

		}
		
		private function start():void{

            new EscrowDealManager();
			new WebViewManager();

			TweenMax.delayedCall(2,function():void{

				GD.S_ESCROW_DEAL_CREATE_REQUEST.invoke(
					new EscrowDealCreateRequest()
					.setChatUID("WrD8DMW0DHWo")
					.setInstrument("btc")
					.setMcaCcy("eur")
					.setPrimAmount(0.0531)
					.setSecAmount(23.32)
					.setSide(EscrowDealSide.BUY)
					.setMsgID(0)
				)


				var doc:XML = <body id="body">
					
					<div layout="horizontal" id="box">
						<div id="txt1"> 1 </div>
						<div id="txt2">
							TEXT
							<div>2</div>
							<div>3</div>
							TEXT
						</div>
					</div>
					
					<div height="100%" width="50%" id="percenage1">TEST 3</div>
					
					<div>TEST 5</div>
				</body>


				var form:Form=new Form(doc);
				addChild(form.view);
				form.setSize(stage.stageWidth,stage.stageHeight);

			},null,true);
		}
		
		public static function onGlobalError(e:UncaughtErrorEvent = null):void {
            if (e != null) {
				e.preventDefault();
				if (e.error.errorID == 2032 || 
					e.error.errorID == 2031 ||
					e.error.errorID == 2029) {
						return;
				}
			}

		}

	}
	
}