package com.dukascopy.connect.gui.graph.lineChart 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PointValueClip extends Sprite
	{
		private var text:Bitmap;
		private var back:Sprite;
		private var toast:Sprite;
		
		public function PointValueClip() 
		{
			back = new Sprite();
			addChild(back);
			
			toast = new Sprite();
			addChild(toast);
			
			text = new Bitmap();
			addChild(text);
			
			back.graphics.beginFill(0xFFFFFF);
			back.graphics.drawCircle(0, 0, Config.FINGER_SIZE * .1);
			back.graphics.endFill();
			
			back.graphics.beginFill(0xCE2527);
			back.graphics.drawCircle(0, 0, Config.FINGER_SIZE * .04);
			back.graphics.endFill();
		}
		
		public function draw(value:String):void
		{
			if (text.bitmapData != null)
			{
				text.bitmapData.dispose();
				text.bitmapData = null;
			}
			
			text.bitmapData = TextUtils.createTextFieldData(value, Config.FINGER_SIZE * 2, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .26, false, 0xFFFFFF);
			
			toast.graphics.clear();
			toast.graphics.beginFill(0x349DD7);
			toast.graphics.drawRect(0, 0, int(text.width + Config.FINGER_SIZE * .3), int(text.height + Config.FINGER_SIZE * .3));
			var currentHeight:int = toast.height;
			toast.graphics.moveTo(toast.width * .5 - Config.FINGER_SIZE * .08, currentHeight);
			toast.graphics.lineTo(toast.width * .5, currentHeight + Config.FINGER_SIZE * .08);
			toast.graphics.lineTo(toast.width * .5 + Config.FINGER_SIZE * .08, currentHeight);
			toast.graphics.lineTo(toast.width * .5 - Config.FINGER_SIZE * .08, currentHeight);
			toast.graphics.endFill();
			
			toast.y = -(toast.height + Config.FINGER_SIZE * .17);
			
			text.x = int(-text.width*.5);
			text.y = int(toast.y + Config.FINGER_SIZE * .15);
			
			toast.x = int( -toast.width * .5);
		}
		
		public function dispose():void 
		{
			if (text != null)
			{
				UI.destroy(text);
				text = null;
			}
			if (back != null)
			{
				UI.destroy(back);
				back = null;
			}
			if (toast != null)
			{
				UI.destroy(toast);
				toast = null;
			}
		}
	}
}