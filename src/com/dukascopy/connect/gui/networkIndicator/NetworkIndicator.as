package com.dukascopy.connect.gui.networkIndicator {
	
	import com.dukascopy.connect.Config;
import com.dukascopy.connect.GD;
import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
import com.dukascopy.connect.sys.pointerManager.PointerManager;
import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.ws.WS;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class NetworkIndicator extends Sprite {
		
		private var tf:TextField = new TextField();
		private var redSquare:Sprite = new Sprite();
		private var greenSquare:Sprite = new Sprite();
		
		public function NetworkIndicator() {
			MobileGui.stage.addEventListener(Event.RESIZE, onStageResize);
			
			tf.mouseEnabled = false;
			tf.mouseWheelEnabled = false;
			tf.selectable = false;
			tf.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .18, 0xFFFFFF);
			tf.x = Config.DOUBLE_MARGIN;
			tf.y = Config.MARGIN + Config.APPLE_TOP_OFFSET;
			tf.text = "Net: " + ((NetworkManager.isConnected == true) ? "Online" : "Offline");
			tf.text += "\nWS: Disconnected";
			tf.height = tf.textHeight + 4;
			addChild(tf);
			
			redSquare.y = Config.APPLE_TOP_OFFSET + Config.MARGIN;
			redSquare.graphics.beginFill(0xFF0000);
			redSquare.graphics.drawRect(0, 0, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .6);
			redSquare.addEventListener(MouseEvent.CLICK,function(...rest):void{
				GD.S_SHOW_SYSTEM_TRACE.invoke();
			})
			MobileGui.stage.addChild(redSquare);
			
			greenSquare.y = Config.APPLE_TOP_OFFSET + Config.MARGIN;
			greenSquare.graphics.beginFill(0x00FF00);
			greenSquare.graphics.drawRect(0, 0, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .6);
			greenSquare.addEventListener(MouseEvent.CLICK,function(...rest):void {
				WS.closeByUser();
			} );
			MobileGui.stage.addChild(greenSquare);
			
			graphics.beginFill(0, 0.5);
			graphics.drawRoundRect(Config.MARGIN, Config.MARGIN + Config.APPLE_TOP_OFFSET, MobileGui.stage.stageWidth - Config.DOUBLE_MARGIN, tf.height, Config.DOUBLE_MARGIN, Config.DOUBLE_MARGIN);
			
			MobileGui.S_WS_EVENT.add(onWSEvent);
			
			mouseChildren = false;
			mouseEnabled = false;
			
			onStageResize();
		}
		
		public function dispose():void {
			if (this.parent != null)
				this.parent.removeChild(this);
			graphics.clear();
			tf.text = "";
			tf = null;
			MobileGui.S_WS_EVENT.remove(onWSEvent);
			MobileGui.stage.removeEventListener(Event.RESIZE, onStageResize);
		}
		
		private function onWSEvent(val:String):void {
			tf.text = "Net: " + ((NetworkManager.isConnected == true) ? "Online" : "Offline");
			tf.text += "\nWS: " + val;
		}
		
		private function onStageResize(e:Event = null):void {
			tf.width = MobileGui.stage.stageWidth - Config.DOUBLE_MARGIN * 2;
			tf.height = tf.textHeight + 4;
			
			redSquare.x = int(MobileGui.stage.stageWidth * .5 - Config.FINGER_SIZE * .6) - Config.MARGIN;
			greenSquare.x = int(MobileGui.stage.stageWidth * .5) + Config.MARGIN;
			
			graphics.clear();
			graphics.beginFill(0, 0.5);
			graphics.drawRoundRect(Config.MARGIN, Config.MARGIN + Config.APPLE_TOP_OFFSET, MobileGui.stage.stageWidth - Config.DOUBLE_MARGIN, tf.height, Config.DOUBLE_MARGIN, Config.DOUBLE_MARGIN);
		}
	}
}