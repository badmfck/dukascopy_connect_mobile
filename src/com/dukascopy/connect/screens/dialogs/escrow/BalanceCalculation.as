package com.dukascopy.connect.screens.dialogs.escrow 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class BalanceCalculation extends Sprite
	{
		private var titles:Vector.<String>;
		private var colors:Vector.<Number>;
		private var clips:Vector.<Bitmap>;
		
		public function BalanceCalculation() 
		{
			
		}
		
		public function drawTexts(titles:Vector.<String>, colors:Vector.<Number>):void
		{
			this.titles = titles;
			this.colors = colors;
			
			createClips();
		}
		
		private function createClips():void 
		{
			clearClips();
			
			clips = new Vector.<Bitmap>();
			var clip:Bitmap;
			for (var i:int = 0; i < titles.length; i++) 
			{
				clip = new Bitmap();
				addChild(clip);
				clips.push(clip);
			}
		}
		
		private function clearClips():void 
		{
			if (clips != null)
			{
				for (var i:int = 0; i < clips.length; i++) 
				{
					UI.destroy(clips[i]);
				}
				clips.length = 0;
				clips = null;
			}
		}
		
		public function draw(itemWidth:int, values:Vector.<String>):void
		{
			if (clips != null)
			{
				var i:int;
				if (values.length == 0)
				{
					for (i = 0; i < clips.length; i++) 
					{
						if (contains(clips[i]))
						{
							removeChild(clips[i]);
						}
						UI.destroy(clips[i]);
					}
				}
				else if (values.length <= clips.length)
				{
					var maxWidth:int = 0;
					var position:int = 0;
					for (i = 0; i < clips.length; i++) 
					{
						drawClip(itemWidth, clips[i], values[i], titles[i], colors[i]);
						clips[i].y = position;
						position += clips[i].height + Config.FINGER_SIZE * .12;
						maxWidth = Math.max(maxWidth, clips[i].width);
					}
					for (var j:int = 0; j < clips.length; j++) 
					{
						clips[j].x = maxWidth * .5 - clips[j].width * .5;
					}
				}
				if (values.length < clips.length)
				{
					for (i = clips.length - values.length - 1; i < clips.length; i++) 
					{
						if (contains(clips[i]))
						{
							removeChild(clips[i]);
						}
						UI.destroy(clips[i]);
					}
				}
			}
		}
		
		private function drawClip(itemWidth:int, clip:Bitmap, value:String, title:String, color:Number):void 
		{
			if (clip.bitmapData != null)
			{
				clip.bitmapData.dispose();
				clip.bitmapData = null;
			}
			
			clip.bitmapData = TextUtils.createTextFieldData(title + " " + value, itemWidth, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, color,
																	Style.color(Style.COLOR_BACKGROUND), false, true);
		}
		
		public function dispose():void
		{
			clearClips();
			
			colors = null;
			titles = null;
		}
	}
}