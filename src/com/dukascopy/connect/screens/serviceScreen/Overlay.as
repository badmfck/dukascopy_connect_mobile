package com.dukascopy.connect.screens.serviceScreen 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.timeout.Timeout;
	import com.greensock.TweenMax;
	import flash.display.Sprite;
	import flash.display.Stage;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */

	public class Overlay
	{
		static private var container:Sprite;
		static private var animator:Sprite;
		static private var targetZone:Sprite;
		static private var animationTime:Number = 0.6;
		static private var currentHitzone:HitZoneData;
		static private var isPlaying:Boolean;
		static private var mainContainer:Sprite;
		static private var mainContainerMask:Sprite;
		static private var showTimeout:Timeout;
		
		public function Overlay() { }
		
		public static function displayTouch(dataZone:HitZoneData):void
		{
			if (dataZone == null || dataZone.disabled == true)
			{
				return;
			}
			
			var stage:Stage = MobileGui.stage;
			if (stage == null)
			{
				return;
			}
			
			clean(stage);
			isPlaying = true;
			currentHitzone = dataZone;
			
			
			if (showTimeout == null)
			{
				showTimeout = new Timeout();
			}
			showTimeout.add(0.1, start);
		}
		
		public static function isAnimateNow():Boolean
		{
			return isPlaying;
		}
		
		static private function start():void 
		{
			var stage:Stage = MobileGui.stage;
			if (stage == null || currentHitzone == null)
			{
				return;
			}
			
			mainContainer = new Sprite();
			mainContainer.mouseEnabled = false;
			mainContainer.mouseChildren = false;
			
			container = new Sprite();
			mainContainer.addChild(container);
			stage.addChild(mainContainer);
			
			var startY:int = 0;
			if (currentHitzone.visibilityRect != null)
			{
				mainContainerMask = new Sprite();
				container.addChild(mainContainerMask);
				
				mainContainerMask.graphics.beginFill(0, 0);
				mainContainerMask.graphics.drawRect(currentHitzone.visibilityRect.x, currentHitzone.visibilityRect.y, currentHitzone.visibilityRect.width, currentHitzone.visibilityRect.height);
				mainContainerMask.graphics.endFill();
				
				container.mask = mainContainerMask;
			}
			
			var height:int = currentHitzone.height;
			
			targetZone = new Sprite();
			targetZone.graphics.beginFill(0, 0);
			
			var radius:Number = currentHitzone.radius;
			
			if (currentHitzone.type == HitZoneType.MENU_FIRST_ELEMENT)
			{
				targetZone.graphics.drawRoundRectComplex(0, startY, currentHitzone.width, height, radius, radius, 0, 0);
			}
			else if (currentHitzone.type == HitZoneType.MENU_LAST_ELEMENT)
			{
				targetZone.graphics.drawRoundRectComplex(0, startY, currentHitzone.width, height, 0, 0, radius, radius);
			}
			else if (currentHitzone.type == HitZoneType.MENU_HORIZONTAL_FIRST_ELEMENT)
			{
				targetZone.graphics.drawRoundRectComplex(0, startY, currentHitzone.width, height, radius, 0, radius, 0);
			}
			else if (currentHitzone.type == HitZoneType.MENU_HORIZONTAL_LAST_ELEMENT)
			{
				targetZone.graphics.drawRoundRectComplex(0, startY, currentHitzone.width, height, 0, radius, 0, radius);
			}
			else if (currentHitzone.type == HitZoneType.MENU_MIDDLE_ELEMENT)
			{
				targetZone.graphics.drawRect(0, startY, currentHitzone.width, height);
			}
			else if (currentHitzone.type == HitZoneType.MENU_SIMPLE_ELEMENT)
			{
				targetZone.graphics.drawRoundRect(0, startY, currentHitzone.width, height, radius * 2, radius * 2);
			}
			else if (currentHitzone.type == HitZoneType.BUTTON)
			{
				targetZone.graphics.drawRoundRect(0, startY, currentHitzone.width, height, Style.size(Style.SIZE_BUTTON_CORNER), Style.size(Style.SIZE_BUTTON_CORNER));
			}
			
			else if (currentHitzone.type == HitZoneType.CIRCLE)
			{
				targetZone.graphics.drawCircle(currentHitzone.width * .5, radius, radius);
			}
			else
			{
				targetZone.graphics.drawRect(0, startY, currentHitzone.width, height);
			}
			
			targetZone.graphics.endFill();
			targetZone.x = currentHitzone.x;
			targetZone.y = currentHitzone.y;
			
			container.addChild(targetZone);
			
			animator = new Sprite();
			animator.graphics.beginFill(currentHitzone.color, currentHitzone.alpha);
			animator.graphics.drawCircle(0, 0, Config.FINGER_SIZE * .6);
			animator.graphics.endFill();
			
			container.addChild(animator);
			
			animator.mask = targetZone;
			
			if (currentHitzone.touchPoint != null)
			{
				animator.x = currentHitzone.touchPoint.x;
				animator.y = currentHitzone.touchPoint.y;
			}
			else{
				ApplicationErrors.add();
			}
			
			TweenMax.to(animator, animationTime, {scaleX:8, scaleY:8, alpha:0.05, onComplete:removeCurrent});
		}
		
		static public function removeCurrent():void 
		{
			isPlaying = false;
			if (showTimeout != null)
			{
				showTimeout.stop();
			}
			var stage:Stage = MobileGui.stage;
			if (stage == null)
			{
				return;
			}
			
			clean(stage);
		}
		
		static private function clean(stage:Stage):void 
		{
			isPlaying = false;
			
			if (showTimeout != null)
			{
				showTimeout.stop();
			}

			remove(mainContainer, stage);
			
			UI.destroy(container);
			UI.destroy(targetZone);
			UI.destroy(animator);
			UI.destroy(mainContainer);
			UI.destroy(mainContainerMask);
			
			container = null;
			targetZone = null;
			animator = null;
			mainContainer = null;
			mainContainerMask = null;
		}
		
		static private function remove(clip:Sprite, stage:Stage):void 
		{
			if (clip != null)
			{
			//	TweenMax.killTweensOf(clip);
				if (stage.contains(clip))
				{
					try
					{
						stage.removeChild(clip);
					}
					catch (e:Error)
					{
						
					}
				}
			}
		}
	}
}