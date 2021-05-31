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
import flash.filesystem.File;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import com.dukascopy.connect.managers.escrow.test.EscrowTest;


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
			new EscrowTest();
			new WebViewManager();

			TweenMax.delayedCall(2,function():void{

				/*GD.S_ESCROW_DEAL_CREATE_REQUEST.invoke(
					new EscrowDealCreateRequest()
					.setChatUID("WLDZD8WFWBIsWQWx")
					.setInstrument("btc")
					.setMcaCcy("eur")
					.setPrimAmount(0.0531)
					.setSecAmount(23.32)
					.setSide(EscrowDealSide.BUY)
					.setMsgID(101)
				)*/
				

				setEscrowForm();


			},null,true);
		}
		
		private function setEscrowForm():void{

			var form:Form=new Form(File.applicationDirectory.resolvePath("forms"+File.separator+"escrowForm.xml"));
			stage.addEventListener(KeyboardEvent.KEY_DOWN,function(e:KeyboardEvent):void{
                if(e.keyCode==Keyboard.R && (e.commandKey || e.ctrlKey))
					form.reload();
            })
			addChild(form.view);
			form.setSize(stage.stageWidth,stage.stageHeight);
			form.onDocumentLoaded=function():void{
				

				var cmp:FormComponent=form.getComponentByID("btnEscrowCreate");
				if(cmp){
					cmp.onTap=function():void{
						trace("COMP TAPPED");
					}
				}
			}
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