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

/*import com.dukascopy.connect.managers.escrow.EscrowDealManager;
import com.dukascopy.connect.managers.webview.WebViewManager;
import com.dukascopy.connect.managers.escrow.test.EscrowTest;
import com.dukascopy.connect.managers.escrow.test.EscrowTestForm;*/
//import com.dukascopy.connect.managers.escrow.EscrowOfferManager;
import com.dukascopy.connect.GD;
import com.forms.Form;
import flash.filesystem.File;
import com.dukascopy.connect.managers.escrow.vo.EscrowOfferVO;
import com.forms.components.FormList;



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

			TweenMax.delayedCall(3, start, null, true);

		}
		
		private function start():void{
			Form.debug=true;
            var form:Form=new Form(File.applicationDirectory.resolvePath("forms"+File.separator+"escrowDealCreate.xml"));
			form.showDeviceFrame("iosx");
			var list:FormList;
			addChild(form.view);
			form.setSize(stage.stageWidth,stage.stageHeight);
			form.onDocumentLoaded=function():void{
				list=form.getComponentByID("offers") as FormList;
				GD.S_ESCROW_OFFERS_REQUEST.invoke();
			};

			GD.S_ESCROW_OFFERS_READY.add(function(offers:Vector.<EscrowOfferVO>):void{
				if(list!=null)
					list.setData(offers);
			})


			/*var url:String="https://loki.telefision.com/master/";
            var loader:SimpleLoader=new SimpleLoader({
                method:"Cp2p.GetPriceByID",
                key:"cc661021e5b5948a0634417dace5378760513a9b",
                hash:"58644ff421b7e4ed7840f4edc191616b",
                id:108
            },function(resp:SimpleLoaderResponse):void{
                trace(resp);
            },url);*/

			//new EscrowOfferManager();
			//new EscrowDealManager();
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