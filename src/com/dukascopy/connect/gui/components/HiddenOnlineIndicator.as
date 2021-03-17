package com.dukascopy.connect.gui.components 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.utils.timeout.Timeout;
	import fl.motion.Color;
	import flash.display.Sprite;
	import flash.system.Capabilities;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class HiddenOnlineIndicator extends Sprite
	{
		private var timeout:Timeout;
		private var time:Number = 10;
		private var container:Sprite;
		private var successColor:Color;
		private var failColor:Color;
		
		public function HiddenOnlineIndicator() 
		{
			if (Config.PLATFORM_APPLE == true && Config.isRetina() > 0)
			{
				construct();
				refreshTimeout();
				WSClient.S_ACTIVITY.add(onWSActivity);
			}
			else
			{
				if (parent != null)
				{
					try
					{
						parent.removeChild(this);
					}
					catch (e:Error)
					{
						ApplicationErrors.add();
					}
				}
			}
		}
		
		private function construct():void 
		{
			container = new Sprite();
			container.graphics.beginFill(0xFFFFFF);
			container.graphics.drawRect(0, 0, 6, 6);
			container.graphics.endFill();
			addChild(container);
			
			if (MobileGui.stage != null)
			{
				container.x = MobileGui.stage.fullScreenWidth - Config.FINGER_SIZE * .35;
			}
			else
			{
				container.x = Config.FINGER_SIZE * .5;
			}
			
			container.y = Config.APPLE_TOP_OFFSET*.5 - 3;
			
			successColor = new Color();
			successColor.color = 0x60B82C;
			
			failColor = new Color();
			failColor.color = 0xB8B8B8;
		}
		
		private function toFailState():void 
		{
			container.transform.colorTransform = failColor;
		}
		
		private function onWSActivity():void 
		{
			refreshTimeout();
			toSuccessState();
		}
		
		private function refreshTimeout():void 
		{
			if (timeout != null)
			{
				timeout.stop();
			}
			timeout = new Timeout();
			timeout.add(time, toFailState);
		}
		
		private function toSuccessState():void 
		{
			container.transform.colorTransform = successColor;
		}
	}
}