package com.dukascopy.connect.gui.components 
{
	import assets.PhotoShotIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class Counter 
	{
		
		public function Counter() 
		{
			
		}
		
		static public function draw(IconClass:Class, text:String):ImageBitmapData 
		{
			var back:Sprite = new Sprite();
			
			var textSize:int = Config.FINGER_SIZE * .2;
			var itemHeight:int = textSize + Config.FINGER_SIZE * .2;
			
			var textBD:ImageBitmapData = TextUtils.createTextFieldData(
														text, Config.FINGER_SIZE * 2, 10, 
														false, TextFormatAlign.CENTER, 
														TextFieldAutoSize.LEFT, textSize, 
														false, 0xB6BED0, 0x3E4756, false);
			
			var icon:Sprite = new IconClass();
			var ct:ColorTransform = new ColorTransform();
			ct.color = 0xB6BED0;
			icon.transform.colorTransform = ct;
			UI.scaleToFit(icon, Config.FINGER_SIZE * 0.3, Config.FINGER_SIZE * 0.3);
			back.addChild(icon);
			
			icon.x = int(Config.FINGER_SIZE * .15);
			icon.y = int(itemHeight * .5 - icon.height * .5);
			
			back.graphics.beginFill(0x3E4756);
			back.graphics.drawRoundRect(0, 0, Config.FINGER_SIZE * .15 + icon.width + Config.FINGER_SIZE * .1 + textBD.width + Config.FINGER_SIZE * .1, itemHeight,
										itemHeight, itemHeight);
			
			var resultBD:ImageBitmapData = new ImageBitmapData("Counter", back.width, back.height);
			resultBD.draw(back);
			
			resultBD.copyPixels(textBD, textBD.rect, new Point(Config.FINGER_SIZE * .15 + icon.width + Config.FINGER_SIZE * .1, itemHeight * .5 - textBD.height * .5));
			textBD.dispose();
			textBD = null;
			back.removeChildren();
			back.graphics.clear();
			back = null;
			icon = null;
			
			return resultBD;
		}
	}
}