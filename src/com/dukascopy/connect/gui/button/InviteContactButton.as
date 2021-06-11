package com.dukascopy.connect.gui.button {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.uiFactory.UIFactory;
	import com.dukascopy.langs.Lang;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import white.SendSmall;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class InviteContactButton extends BitmapButton
	{
		private var generatedBitmap:ImageBitmapData;
		private var value:String = Lang.textInvite + "!";
		
		private var box:Sprite;
		private var tf:TextField;
		
		private var w:int = 0;
		private var h:int = 0;
		private var icon:Sprite;
		private var mainHeight:Number;
		private var mainWidth:int;
		
		public function InviteContactButton(callBack:Function, value:String = "")
		{
			if(value == ""){
				value = Lang.textInvite + "!";
			}
			super();
			this.value = value;
			setStandartButtonParams();	
			usePreventOnDown = true;
			cancelOnVerticalMovement = true;
			tapCallback = callBack;	
			
			box = new Sprite();
				tf = UIFactory.createTextField(Config.FINGER_SIZE*.2);
				tf.textColor = MainColors.GREEN;
			box.addChild(tf);
			
			icon = new SendSmall();
			box.addChild(icon);
			icon.x = int(Config.MARGIN*.8);
			icon.height = Config.FINGER_SIZE*.25;
			icon.scaleX = icon.scaleY;
			mainHeight = Config.MARGIN * 2.8;
			icon.y = int((mainHeight - icon.height)*.5);
		}
		
		public function draw():void
		{
			tf.text = value;
			tf.x = int(Config.MARGIN*.9 + icon.x + icon.width);
			tf.y = int((mainHeight - tf.height) * .5);
			tf.autoSize = TextFieldAutoSize.LEFT;
			mainWidth = int(icon.width + tf.width + Config.MARGIN * 2.5);
			
			box.graphics.clear();
			box.graphics.lineStyle(1, MainColors.GREEN);
			box.graphics.beginFill(0xFFFFFF, 1);
			box.graphics.drawRoundRect(0, 0, mainWidth - 1, mainHeight - 1, Config.MARGIN, Config.MARGIN);
			box.graphics.endFill();
			
			if (generatedBitmap == null){
				generatedBitmap = new ImageBitmapData("InviteContactButton.draw", mainWidth, mainHeight, true, 0);
			}else {
				generatedBitmap.fillRect(generatedBitmap.rect, 0);	
			}
			
			generatedBitmap.drawWithQuality(box, null, null, null, null, true, StageQuality.BEST);
			
			setBitmapData(generatedBitmap);
		}
		
		public function setValue(value:String = null):void
		{
			if (value == null)
				value = Lang.textInvite;
			this.value = value;
			draw();
		}
		
		override public function dispose():void
		{
			UI.safeRemoveChild(tf);			
			tf = null;				
			if (box != null) {
				box.graphics.clear();			
				box = null;
			}			
			if (generatedBitmap != null) {
				generatedBitmap.dispose();
				generatedBitmap = null;				
			}
			icon = null;
			
			super.dispose();
		}
		
		public function getWidth():int
		{
			return mainWidth;
		}
		
		public function getHeight():int
		{
			return mainHeight;
		}
		
	}

}