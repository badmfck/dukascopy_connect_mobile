package com.dukascopy.connect.gui.components
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.utils.TextUtils;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class StatusClip extends Sprite
	{
		private var background:Sprite;
		private var textClip:Bitmap;
		private var maskClip:Sprite;
		private var contentClip:Sprite;
		
		private var itemWidth:int = -1;
		private var itemHeight:int = -1;
		private var textValue:String;
		private var shown:Boolean;
		private var nextValue:String;
		private var showTime:Number = 1.5;
		private var animationTime:Number = 0.3;
		private var inTransition:Boolean;
		private var needHide:Boolean;
		private var delayShow:Boolean;
		
		public function StatusClip()
		{
			construct();
		}
		
		private function construct():void
		{
			contentClip = new Sprite();
			addChild(contentClip);
			
			maskClip = new Sprite();
			maskClip = new Sprite();
			maskClip.graphics.beginFill(AppTheme.GREY_DARK);
			maskClip.graphics.drawRect(0, 0, 10, 10);
			maskClip.graphics.endFill();
			contentClip.addChild(maskClip);
			addChild(maskClip);
			
			background = new Sprite();
			background.graphics.beginFill(AppTheme.GREY_DARK);
			background.graphics.drawRect(0, 0, 10, 10);
			background.graphics.endFill();
			contentClip.addChild(background);
			
			textClip = new Bitmap();
			contentClip.addChild(textClip);
			
			contentClip.mask = maskClip;
			
			visible = false;
		}
		
		public function destroy():void
		{
			inTransition = false;
			TweenMax.killDelayedCallsTo(allowHide);
			TweenMax.killDelayedCallsTo(animateShow);
			TweenMax.killDelayedCallsTo(hideAnyway);
			
			if (contentClip != null)
			{
				TweenMax.killTweensOf(contentClip);
			}
			
			UI.destroy(background);
			background = null;
			
			UI.destroy(textClip);
			textClip = null;
			
			UI.destroy(contentClip);
			contentClip = null;
			
			UI.destroy(maskClip);
			maskClip = null;
		}
		
		public function show(value:String):void {
			TweenMax.killDelayedCallsTo(hideAnyway);
			
			if (Auth.companyID != null && Auth.companyID != "")
				visible = true;
			
			needHide = false;
			
			if (shown == false || delayShow == false || inTransition == false)
			{
				nextValue = null;
				setText(value);
				
				delayShow = true;
				TweenMax.delayedCall(0.2, animateShow);
			}
			else
			{
				
				nextValue = value;
			}
		}
		
		private function animateShow():void 
		{
			delayShow = false;
			inTransition = true;
			TweenMax.to(contentClip, animationTime, { y: -itemHeight, onComplete:onShown } );
		}
		
		public function hide():void
		{
			TweenMax.killDelayedCallsTo(hideAnyway);
			
			nextValue = null;
			
			if (delayShow == true)
			{
				TweenMax.killDelayedCallsTo(allowHide);
				TweenMax.killDelayedCallsTo(animateShow);
			}
			
			if (shown == true)
			{
				if (inTransition == true)
				{
					needHide = true;
				}
				else
				{
					needHide = false;
					TweenMax.to(contentClip, animationTime, { y:0, onComplete:onHided } );
				}
			}
			else
			{
				needHide = true;
			}
		}
		
		private function onShown():void 
		{
			shown = true;
			inTransition = false;
			TweenMax.delayedCall(showTime, allowHide);
			TweenMax.delayedCall(4, hideAnyway);
		}
		
		private function hideAnyway():void 
		{
			shown = false;
			needHide = false;
			
			inTransition = true;
			TweenMax.to(contentClip, animationTime, { y:0, onComplete:onHided } );
		}
		
		private function allowHide():void 
		{
			shown = true;
			
			if (needHide || nextValue != null)
			{
				inTransition = true;
				TweenMax.to(contentClip, animationTime, { y:0, onComplete:onHided } );
			}
		}
		
		private function onHided():void 
		{
			inTransition = false;
			needHide = false;
			visible = false;
			
			if (nextValue != null)
			{
				show(nextValue);
			}
		}
		
		public function setSize(width:int, height:int):void
		{
			itemWidth = width;
			itemHeight = height;
			
			update();
		}
		
		private function update():void 
		{
			if (itemWidth == -1 || itemHeight == -1)
			{
				return;
			}
			
			if (background != null)
			{
				background.width = itemWidth;
				background.height = itemHeight;
			}
			
			if (maskClip != null)
			{
				maskClip.width = itemWidth;
				maskClip.height = itemHeight;
				
				maskClip.y = -itemHeight;
			}
			
			if (textValue != null)
			{
				setText(textValue);
			}
		}
		
		private function setText(value:String):void 
		{
			textValue = value;
			
			if (textValue != null && textClip != null)
			{
				if (textClip.bitmapData != null)
				{
					textClip.bitmapData.dispose();
					textClip.bitmapData = null;
				}
				
				textClip.bitmapData = TextUtils.createTextFieldData(
														textValue, 
														itemWidth, 
														10, 
														false, 
														TextFormatAlign.CENTER, 
														TextFieldAutoSize.LEFT, 
														Config.FINGER_SIZE * .26, 
														false, 
														0xFFFFFF, 
														AppTheme.GREY_DARK, false);
				
				textClip.x = int(itemWidth * .5 - textClip.width * .5);
				textClip.y = int(itemHeight * .5 - textClip.height * .5);
			}
		}
	}
}