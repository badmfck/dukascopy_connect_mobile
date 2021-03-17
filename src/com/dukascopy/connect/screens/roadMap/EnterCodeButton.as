package com.dukascopy.connect.screens.roadMap 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EnterCodeButton extends Sprite
	{
		private var back:Sprite;
		private var animation:Object;
		private var text:Bitmap;
		private var resultWidth:Number;
		private var resultHeight:Number;
		private var disposed:Boolean;
		private var shown:Boolean;
		
		public function EnterCodeButton() 
		{
			back = new Sprite()
			addChild(back);
			text = new Bitmap();
			addChild(text);
			text.bitmapData = TextUtils.createTextFieldData(Lang.enterReferralCode, Config.FINGER_SIZE*5, 10, 
																	true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .3, true, Color.WHITE, Color.GREEN, true);
			resultWidth = text.width + Config.FINGER_SIZE * .6;
			resultHeight = Config.FINGER_SIZE * .65;
			
			text.x = int(resultWidth * .5 - text.width * .5);
			text.y = int(resultHeight * .5 - text.height * .5);
			text.alpha = 0;
		}
		
		public function animate():void
		{
			if (shown)
			{
				return;
			}
			animation = new Object();
			animation.width = 1;
			animation.height = 1;
			TweenMax.to(animation, 0.2, {width:Config.FINGER_SIZE * .6, delay:0.9});
			TweenMax.to(animation, 0.7, {height:Config.FINGER_SIZE * .65, delay:0.9, ease:Back.easeOut, onUpdate:updateButton});
			TweenMax.to(animation, 0.7, {width:resultWidth, delay:1.2, ease:Back.easeOut, onUpdate:updateButton, onComplete:onShown});
			TweenMax.to(text, 0.3, {alpha:1, delay:1.2});
		}
		
		private function onShown():void 
		{
			shown = true;
		}
		
		public function activate():void
		{
			
		}
		
		public function deactivate():void
		{
			
		}
		
		public function getWidth():int 
		{
			return resultWidth;
		}
		
		private function updateButton():void 
		{
			if (disposed == true)
			{
				return;
			}
			back.graphics.clear();
			back.graphics.beginFill(Color.GREEN);
			back.graphics.drawRoundRect(resultWidth * .5 - animation.width * .5, resultHeight * .5 - animation.height * .5, animation.width, animation.height, animation.height);
			back.graphics.endFill();
		}
		
		public function dispose():void
		{
			disposed = true;
			if (animation)
			{
				TweenMax.killTweensOf(animation);
			}
			if (back != null)
			{
				UI.destroy(back);
				back = null
			}
			if (text != null)
			{
				TweenMax.killTweensOf(text);
				UI.destroy(text);
				text = null
			}
		}
	}
}