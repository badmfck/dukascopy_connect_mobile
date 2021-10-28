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
import flash.utils.setTimeout;
import com.forms.components.FormGraph;
import com.forms.FormComponent;
import com.dukascopy.connect.managers.escrow.EscrowOfferManager;
import com.dukascopy.connect.managers.escrow.EscrowDealManager;
import com.dukascopy.connect.vo.URLConfigVO;
import com.telefision.utils.maps.EscrowDealMap;
import com.forms.FPS;



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
			//Form.debug=true;
            var form:Form=new Form(File.applicationDirectory.resolvePath("forms"+File.separator+"escrowDeals.xml"));
			form.showDeviceFrame("iosx");
			var list:FormList;
			addChild(form.view);
			form.setSize(stage.stageWidth,stage.stageHeight);
			form.onDocumentLoaded=function():void{
				list=form.getComponentByID("deals") as FormList;
				

				
			
				GD.S_ESCROW_DEALS_LOADED.add(function(deals:EscrowDealMap):void{
					if(list!=null)
						list.setData(deals.getValues());
				})

				GD.S_ESCROW_DEALS_REQUEST.invoke();
				
			};

		


			setTimeout(function():void{
				var icoCurrency:FormGraph=form.getComponentByID("icoCurrency") as FormGraph;
				if(icoCurrency!=null)
					icoCurrency.src="res/p2p.svg";
			},5000)

			
			new EscrowOfferManager();
			new EscrowDealManager();

			GD.S_URL_CONFIG_READY.invoke(new URLConfigVO({
				DCCAPI_URL:"https://loki.telefision.com/master/"
			}))

			GD.S_AUTHORIZED.invoke({
				authKey:"c0b9230cfaa4fe51289c60d02efe930a60d8f08a",
				profile:{},
				devID:"test_dev_uid"
			});


			var fps:FPS=new FPS();
			addChild(fps);
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