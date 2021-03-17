package com.dukascopy.connect.gui.components.countdown 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.utils.TextUtils;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power1;
	import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class CountdownItem extends Sprite
	{
		static public const STATE_1:String = "state1";
		static public const STATE_2:String = "state2";
		
		private var top1:flash.display.Sprite;
		private var top2:flash.display.Sprite;
		private var bottom1:flash.display.Sprite;
		private var bottom2:flash.display.Sprite;
		
		private var halfHeight:int;
		private var itemWidth:int;
		private var radius:int;
		private var currentValue:int = -1;
		
		private var shadow:flash.display.Sprite;
		private var top1Bitmap:flash.display.Bitmap;
		private var top2Bitmap:flash.display.Bitmap;
		private var bottom1Bitmap:flash.display.Bitmap;
		private var bottom2Bitmap:flash.display.Bitmap;
		private var curentState:String;
		private var debug:Boolean;
		private var lineWhite:flash.display.Bitmap;
		private var lineBlack:flash.display.Bitmap;
		private var time:Number = 0.2;
		private var shadow2:flash.display.Sprite;
		private var shadowMatrix:Object;
		private var animate:Boolean;
		private var targetValue:Number = -1;
		private var disposed:Boolean;
		
		public function CountdownItem(itemWidth:int) 
		{
			this.itemWidth = itemWidth;
			halfHeight = itemWidth * .9;
			radius = itemWidth * 0.1;
			
			create();
		}
		
		private function create():void 
		{
			shadow = new Sprite();
			shadow.graphics.beginFill(0, 0.24);
			shadow.graphics.drawRoundRectComplex(0, 0, itemWidth, halfHeight, 0, 0, radius, radius);
			shadow.graphics.endFill();
			shadow.y = halfHeight * .12;
			addChild(shadow);
			
			shadow2 = new Sprite();
			shadow2.graphics.beginFill(0, 0.24);
			shadow2.graphics.drawRoundRectComplex(0, 0, itemWidth, halfHeight, 0, 0, radius, radius);
			shadow2.graphics.endFill();
		//	addChild(shadow2);
			
			top1 = new Sprite();
			top2 = new Sprite();
			
			bottom1 = new Sprite();
			bottom2 = new Sprite();
			
			top1.graphics.beginFill(0x444C51);
			top1.graphics.drawRoundRectComplex(0, -halfHeight, itemWidth, halfHeight, radius, radius, 0, 0);
			top1.graphics.endFill();
			
			top2.graphics.beginFill(0x444C51);
			top2.graphics.drawRoundRectComplex(0, -halfHeight, itemWidth, halfHeight, radius, radius, 0, 0);
			top2.graphics.endFill();
			
			bottom1.graphics.beginFill(0x626D74);
			bottom1.graphics.drawRoundRectComplex(0, 0, itemWidth, halfHeight, 0, 0, radius, radius);
			bottom1.graphics.endFill();
			
			bottom2.graphics.beginFill(0x626D74);
			bottom2.graphics.drawRoundRectComplex(0, 0, itemWidth, halfHeight, 0, 0, radius, radius);
			bottom2.graphics.endFill();
			
			addChild(top1);
			addChild(top2);
			addChild(bottom1);
			addChild(bottom2);
			
			top1Bitmap = new Bitmap();
			top2Bitmap = new Bitmap();
			
			bottom1Bitmap = new Bitmap();
			bottom2Bitmap = new Bitmap();
			
			top1Bitmap.smoothing = true;
			top2Bitmap.smoothing = true;
			
			bottom1Bitmap.smoothing = true;
			bottom2Bitmap.smoothing = true;
			
			top1.addChild(top1Bitmap);
			top2.addChild(top2Bitmap);
			
			bottom1.addChild(bottom1Bitmap);
			bottom2.addChild(bottom2Bitmap);
			
		//	top2.visible = false;
		//	bottom2.visible = false;
			
			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(2, 0xFFFFFF);
			lineWhite = new Bitmap(hLineBitmapData);
			addChild(lineWhite);
			lineWhite.alpha = 0.4;
			lineWhite.width = itemWidth;
			
			hLineBitmapData = UI.getHorizontalLine(4, 0x000000);
			lineBlack = new Bitmap(hLineBitmapData);
			addChild(lineBlack);
			lineBlack.alpha = 0.25;
			lineBlack.width = itemWidth;
			lineBlack.y = -lineBlack.height;
		}
		
		public function setValue(value:int, animate:Boolean = false, delay:Number = NaN):void
		{
			if (disposed == true)
			{
				return;
			}
			
			this.animate = animate;
			if (currentValue == value)
			{
				return;
			}
			
			if (animate == true)
			{
				animate = false;
				targetValue = value;
				TweenMax.delayedCall(delay, stepNext, [0]);
			}
			else
			{
				if (currentValue == -1)
				{
					currentValue = value;
				//	curentState = STATE_1;
					drawValue(currentValue, top1Bitmap, bottom1Bitmap);
					toState1();
				}
				else
				{
					currentValue = value;
					if (curentState == STATE_1)
					{
						drawValue(currentValue, top2Bitmap, bottom2Bitmap);
						toState2();
					}
					else if (curentState == STATE_2)
					{
						drawValue(currentValue, top1Bitmap, bottom1Bitmap);
						toState1();
					}
				}
			}
			
			setChildIndex(lineBlack, numChildren - 1);
			setChildIndex(lineWhite, numChildren - 1);
		}
		
		private function stepNext(value:int):void 
		{
			setValue(value);
		}
		
		private function updateShadow():void
		{
			shadow2.x = 30;
			
			shadow2.scaleY = shadowMatrix.scale;
			var skewMatrix:Matrix = shadow2.transform.matrix;
			skewMatrix.c = shadowMatrix.scale; 
			shadow2.transform.matrix = skewMatrix;
		}
		
		private function toState1():void 
		{
			setChildIndex(top2, numChildren - 1);
			setChildIndex(bottom1, numChildren - 1);
			
		//	setChildIndex(shadow2, numChildren - 1);
			shadow2.scaleY = -1;
			
			top1.scaleY = 1;
			top1.transform.colorTransform = new Color();
			
			bottom1.scaleY = 0;
			var light:Color = new Color();
			light.brightness = 0.5;
			bottom1.transform.colorTransform = light;
			
			var animateTime:Number = time;
			if (targetValue != -1)
			{
				animateTime = time * .65;
			}
			
			TweenMax.to(top2, animateTime, {scaleY:0, ease:Power1.easeIn, colorTransform:{brightness: -0.6}});
			TweenMax.to(bottom1, animateTime, {scaleY:1, delay:animateTime, ease:Power1.easeOut, colorTransform:{brightness:1}, onComplete:animationEnd});
			
			top1.visible = true;
			bottom1.visible = true;
			
			curentState = STATE_1;
		}
		
		private function toState2():void 
		{
			setChildIndex(top1, numChildren - 1);
			setChildIndex(bottom2, numChildren - 1);
			
			top2.scaleY = 1;
			top2.transform.colorTransform = new Color();
			
			bottom2.scaleY = 0;
			var light:Color = new Color();
			light.brightness = 0.5;
			bottom2.transform.colorTransform = light;
			
			var animateTime:Number = time;
			if (targetValue != -1)
			{
				animateTime = time * .65;
			}
			
			TweenMax.to(top1, animateTime, {scaleY:0, ease:Power1.easeIn, colorTransform:{brightness: -0.6}});
			TweenMax.to(bottom2, animateTime, {scaleY:1, delay:animateTime, ease:Power1.easeOut, colorTransform:{brightness:1}, onComplete:animationEnd});
			
			
			top2.visible = true;
			bottom2.visible = true;
			
			curentState = STATE_2;
		}
		
		private function animationEnd():void 
		{
			if (targetValue != -1)
			{
				if (currentValue < targetValue)
				{
					stepNext(currentValue + 1);
				}
				else
				{
					targetValue = -1;
				}
			}
		}
		
		private function setBrightness(value:Number):ColorMatrixFilter
	    {
	        value = value*(255/250);
	        var m:Array = new Array();
	        m = m.concat([1, 0, 0, 0, value]);  // red
	        m = m.concat([0, 1, 0, 0, value]);  // green
	        m = m.concat([0, 0, 1, 0, value]);  // blue
	        m = m.concat([0, 0, 0, 1, 0]);      // alpha
	        return new ColorMatrixFilter(m);
	    }
		
		public function dispose():void 
		{
			disposed = true;
			
			TweenMax.killTweensOf(top1);
			TweenMax.killTweensOf(top2);
			TweenMax.killTweensOf(bottom1);
			TweenMax.killTweensOf(bottom2);
			TweenMax.killDelayedCallsTo(stepNext);
			
			if (shadow != null)
			{
				UI.destroy(shadow);
				shadow = null;
			}
			if (bottom1 != null)
			{
				UI.destroy(bottom1);
				bottom1 = null;
			}
			if (bottom2 != null)
			{
				UI.destroy(bottom2);
				bottom2 = null;
			}
			if (top1 != null)
			{
				UI.destroy(top1);
				top1 = null;
			}
			if (top2 != null)
			{
				UI.destroy(top2);
				top2 = null;
			}
			if (top1Bitmap != null)
			{
				UI.destroy(top1Bitmap);
				top1Bitmap = null;
			}
			if (top2Bitmap != null)
			{
				UI.destroy(top2Bitmap);
				top2Bitmap = null;
			}
			if (lineBlack != null)
			{
				UI.destroy(lineBlack);
				lineBlack = null;
			}
			if (lineWhite != null)
			{
				UI.destroy(lineWhite);
				lineWhite = null;
			}
			if (bottom1Bitmap != null)
			{
				UI.destroy(bottom1Bitmap);
				bottom1Bitmap = null;
			}
			if (bottom2Bitmap != null)
			{
				UI.destroy(bottom2Bitmap);
				bottom2Bitmap = null;
			}
		}
		
		private function drawValue(value:int, topClip:Bitmap, bottomClip:Bitmap):void
		{
			if (disposed == true)
			{
				return;
			}
			
			var valueBitmap:ImageBitmapData = TextUtils.createTextFieldData(
															value.toString(), Config.FINGER_SIZE, 10, false, 
															TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
															halfHeight*1.2, false, 0xFFFFFF, 0x626D74, true);
			if (topClip.bitmapData != null)
			{
				topClip.bitmapData.dispose();
				topClip.bitmapData = null;
			}
			if (bottomClip.bitmapData != null)
			{
				bottomClip.bitmapData.dispose();
				bottomClip.bitmapData = null;
			}
			var topHeight:int = valueBitmap.height * .5;
			var bottomHeight:int = valueBitmap.height - topHeight;
			
			var topBD:ImageBitmapData = new ImageBitmapData("counter", valueBitmap.width, topHeight);
			topBD.copyPixels(valueBitmap, new Rectangle(0, 0, valueBitmap.width, topHeight), new Point());
			topClip.bitmapData = topBD;
			
			var bottomBD:ImageBitmapData = new ImageBitmapData("counter", valueBitmap.width, bottomHeight);
			bottomBD.copyPixels(valueBitmap, new Rectangle(0, topHeight, valueBitmap.width, bottomHeight), new Point());
			bottomClip.bitmapData = bottomBD;
			
			topClip.y = -topClip.height;
			topClip.x = int(itemWidth * .5 - valueBitmap.width * .5);
			bottomClip.x = int(itemWidth * .5 - valueBitmap.width * .5);
			
			valueBitmap.dispose();
		}
	}
}