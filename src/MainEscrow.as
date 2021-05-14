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

			TweenMax.delayedCall(2,function():void{

				GD.S_ESCROW_DEAL_CREATE_REQUEST.invoke(
					new EscrowDealCreateRequest()
					.setChatUID("WrD8DMW0DHWo")
					.setInstrument("btc")
					.setMcaCcy("eur")
					.setPrimAmount(0.0531)
					.setSecAmount(23.32)
					.setSide(EscrowDealSide.BUY)
				)

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