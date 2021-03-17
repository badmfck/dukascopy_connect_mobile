package com.dukascopy.connect.gui.tools.handTip 
{
	import assets.HandTipSprite;
	import assets.Hvost;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.utils.TextUtils;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class HandTip extends Sprite
	{
		private var handContainer:flash.display.Sprite;
		private var hand:assets.HandTipSprite;
		private var time:Number = 0.8;
		private var text:flash.display.Bitmap;
		private var textContainer:flash.display.Sprite;
		private var hided:Boolean;
		private var startScale:Number;
		
		public function HandTip() 
		{
			
		}
		
		public function show(textValue:String, time:Number):void
		{
			if (textValue != null && textValue != "")
			{
				addText(textValue);
			}
			
			addHand();
			animate();
			if (!isNaN(time))
			{
				startHideTimeout(time);
			}
		}
		
		private function startHideTimeout(time:Number):void 
		{
			TweenMax.delayedCall(time, hide);
		}
		
		public function hide():void 
		{
			if (hided)
			{
				return;
			}
			hided = true;
			TweenMax.killDelayedCallsTo(hide);
			TweenMax.killTweensOf(hand);
			TweenMax.killTweensOf(textContainer);
			TweenMax.killTweensOf(handContainer);
			
			if (textContainer != null)
			{
				TweenMax.to(textContainer, 0.3, {alpha:0});
			}
			
			TweenMax.to(handContainer, 0.3, {alpha:0, onComplete:remove});
		}
		
		private function remove():void 
		{
			dispose();
			if (parent != null)
			{
				parent.removeChild(this);
			}
		}
		
		private function dispose():void 
		{
			if (textContainer != null)
			{
				UI.destroy(textContainer);
				textContainer = null;
			}
			if (text != null)
			{
				UI.destroy(text);
				text = null;
			}
			if (hand != null)
			{
				UI.destroy(hand);
				hand = null;
			}
			if (handContainer != null)
			{
				UI.destroy(handContainer);
				handContainer = null;
			}
		}
		
		private function animate():void 
		{
			down();
		}
		
		private function down():void 
		{
			TweenMax.to(hand, time, {y: -Config.FINGER_SIZE * .4, scaleX:startScale * 0.96, scaleY:startScale, onComplete:up});
		}
		
		private function up():void 
		{
			TweenMax.to(hand, time, {y: -Config.FINGER_SIZE * .6, scaleX:startScale, scaleY:startScale * 0.96, onComplete:down});
		}
		
		private function addText(textValue:String):void 
		{
			textContainer = new Sprite();
			addChild(textContainer);
			text = new Bitmap();
			
			text.bitmapData = TextUtils.createTextFieldData(textValue, Config.FINGER_SIZE*3, 10, 
															true, TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, Config.FINGER_SIZE*.28, 
															true, 0xFFFFFF, 0x000000, true);
			var textContainerBack:Sprite = new Sprite();
			textContainer.addChild(textContainerBack);
			textContainerBack.graphics.beginFill(0x000000, 0.68);
			textContainerBack.graphics.drawRoundRect(0, 0, text.width + Config.FINGER_SIZE * .6, text.height + Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .6);
			textContainerBack.graphics.endFill();
			
			textContainer.graphics.beginFill(0x000000, 0.22);
			textContainer.graphics.drawRoundRect(0 + Config.FINGER_SIZE*.06, 0 + Config.FINGER_SIZE*.06, text.width + Config.FINGER_SIZE * .6, text.height + Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .6);
			textContainer.graphics.endFill();
			text.x = Config.FINGER_SIZE * .3;
			text.y = Config.FINGER_SIZE * .2;
			
			textContainer.x = Config.FINGER_SIZE * 1.1;
			textContainer.y = -Config.FINGER_SIZE * 2;
			
			var hvost:Hvost = new Hvost();
			hvost.width = Config.FINGER_SIZE * .4;
			hvost.scaleY = hvost.scaleX;
			hvost.alpha = 0.22;
			hvost.x = Config.FINGER_SIZE * .2 + Config.FINGER_SIZE * .06;
			hvost.y = textContainerBack.height + Config.FINGER_SIZE * .06;
			textContainer.addChild(hvost);
			
			var hvost2:Hvost = new Hvost();
			hvost2.width = Config.FINGER_SIZE * .4;
			hvost2.scaleY = hvost.scaleX;
			hvost2.alpha = 0.68;
			hvost2.x = Config.FINGER_SIZE * .2;
			hvost2.y = textContainerBack.height;
			textContainer.addChild(hvost2);
			
			textContainer.addChild(text);
			textContainer.alpha = 0;
			TweenMax.to(textContainer, 0.3, {alpha:1, delay:0.7});
		}
		
		private function addHand():void 
		{
			handContainer = new Sprite();
			addChild(handContainer);
			hand = new HandTipSprite();
			hand.width = Config.FINGER_SIZE*.7;
			hand.scaleY = hand.scaleX;
			handContainer.addChild(hand);
			hand.y = -Config.FINGER_SIZE * .6;
			
			startScale = hand.scaleY;
			
			handContainer.rotation = -7.5;
			handContainer.alpha = 0;
			TweenMax.to(handContainer, 0.3, {alpha:1, delay:0.5});
		}
	}
}