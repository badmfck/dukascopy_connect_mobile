package com.dukascopy.connect.sys.videoStreaming 
{
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.videoStreaming.StageVideoComponent;
	import com.dukascopy.connect.gui.videoStreaming.StreamControls;
	import com.dukascopy.connect.gui.videoStreaming.StreamIndicator;
	import com.dukascopy.connect.gui.videoStreaming.StreamPreloader;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.greensock.TweenMax;
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class VideoStreaming 
	{
		static public var currentChat:String;
		private var output:StageVideoComponent;
		private var controls:StreamControls;
		private var target:Sprite;
		private var area:Rectangle;
		private var onCloseCallback:Function;
		static private var onAir:Boolean;
		private var itemToHide:DisplayObject;
		private var hideTime:Number = 0.5;
		private var showTime:Number = 0.2;
		private var hideTimeout:Number = 4;
		private var indicator:StreamIndicator;
		private var running:Boolean;
		static private var current:VideoStreaming;
		private var preloader:StreamPreloader;
		
		public function VideoStreaming(target:Sprite, area:Rectangle, onClose:Function, itemToHide:DisplayObject, chatUID:String) 
		{
			this.itemToHide = itemToHide;
			this.area = area;
			this.target = target;
			this.onCloseCallback = onClose;
			
			crateOutput();
			addControls();
			
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactivate);
			
			TweenMax.to(itemToHide, hideTime, {alpha:0, delay:2});
			PointerManager.addDown(itemToHide, showContent);
			
			running = true;
			
			current = this;
			currentChat = chatUID;
			
			//TODO:;
			onStarted();
		}
		
		private function showContent(e:Event = null):void 
		{
			TweenMax.killDelayedCallsTo(hideContent);
			TweenMax.killTweensOf(itemToHide);
			if (itemToHide)
			{
				TweenMax.to(itemToHide, showTime, {alpha:1, onComplete:startHideTimeout});
			}
			else
			{
				
			}
		}
		
		private function startHideTimeout():void 
		{
			TweenMax.killDelayedCallsTo(hideContent);
			TweenMax.delayedCall(hideTimeout, hideContent);
		}
		
		private function hideContent():void 
		{
			TweenMax.to(itemToHide, hideTime, {alpha:0});
		}
		
		private function onStarted():void
		{
			onAir = true;
		}
		
		private function onDeactivate(e:Event):void 
		{
			
		}
		
		private function onActivate(e:Event):void 
		{
			
		}
		
		public function close():void 
		{
			currentChat = null;
			current = null;
			running = false;
			onAir = false;
			output.close();
			
			clean();
		}
		
		public function cutDownStream():void
		{
			clean();
			output.cutDown();
			
			if (indicator == null)
			{
				indicator = new StreamIndicator();
				MobileGui.stage.addChild(indicator);
			}
			indicator.show();
		}
		
		private function clean():void 
		{
			onCloseCallback = null;
			itemToHide = null;
			
			NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE, onActivate);
			NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE, onDeactivate);
			PointerManager.removeDown(itemToHide, showContent);
			
			TweenMax.killTweensOf(itemToHide);
			TweenMax.killDelayedCallsTo(hideContent);
			
			if (controls)
			{
				controls.dispose();
				try
				{
					if (target != null)
					{
						target.removeChild(controls);
					}
				}
				catch (e:Error)
				{
					
				}
			}
		}
		
		private function crateOutput():void 
		{
			output = new StageVideoComponent(area);
			output.start(MobileGui.stage);
			output.displayFromCamera();
		}
		
		private function addControls():void 
		{
			controls = new StreamControls(area, onStartCall, onStopCall, onResumeCall, onPauseCall);
			target.addChild(controls);
			
			preloader = new StreamPreloader();
		//	target.addChild(preloader);
			
			preloader.x = int(area.width * .5 + area.x);
			preloader.y = int(area.height * .5 + area.y);
		}
		
		private function onPauseCall():void 
		{
			
		}
		
		private function onResumeCall():void 
		{
			
		}
		
		private function onStopCall():void 
		{
			if (onCloseCallback != null)
			{
				onCloseCallback();
			}
		}
		
		private function onStartCall():void 
		{
			
		}
		
		public function onEnter():void
		{
			if (indicator != null)
			{
				indicator.hide();
				indicator = null;
			}
			output.resume();
		}
		
		static public function isOnAir():Boolean 
		{
			return onAir;
		}
		
		static public function getCurrent():VideoStreaming 
		{
			return current;
		}
		
		public function attachTo(target:Sprite, area:Rectangle, onClose:Function, itemToHide:DisplayObject):void 
		{
			onEnter();
			
			this.itemToHide = itemToHide;
			this.area = area;
			this.target = target;
			this.onCloseCallback = onClose;
			
			addControls();
			
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactivate);
			
			TweenMax.killDelayedCallsTo(hideContent);
			TweenMax.delayedCall(2, hideContent);
			
			PointerManager.addDown(itemToHide, showContent)
			
			running = true;
			
			current = this;
		}
	}
}