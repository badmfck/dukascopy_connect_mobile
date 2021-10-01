package com.dukascopy.connect.gui.components.message {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.type.MainColors;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ToastMessageGD {
		
		static private const SHOW_TIME:Number = 3.5;
		
		private var stage:Stage;
		private var messageClip:Bitmap;
		private var displayed:Boolean;
		private var toastPoint:Point;
		
		public function ToastMessageGD(container:Stage) {
			stage = container;
			
			onStageSizeChanged(stage.stageWidth, stage.stageHeight);
			
			GD.S_STAGE_SIZE_CHANGED.add(onStageSizeChanged);
			GD.S_TOAST.add(display);
		}
		
		private function onStageSizeChanged(width:int, height:int):void {
			toastPoint ||= new Point(
				width,
				height - Config.APPLE_BOTTOM_OFFSET - Config.FINGER_SIZE
			);
		}
		
		public function display(value:String):void {
			if (value == null)
				return;
			if (displayed == true)
				cleanCurrent();
			displayed = true;
			messageClip = new Bitmap();
			messageClip.bitmapData = createImage(value);
			messageClip.alpha = 0;
			messageClip.x = int((toastPoint.x - messageClip.width) * .5);
			messageClip.y = int(toastPoint.y - messageClip.height);
			stage.addChild(messageClip);
			TweenMax.to(messageClip, 0.5, { alpha:1 } );
			TweenMax.to(messageClip, 0.5, { alpha:0, delay:SHOW_TIME, onComplete:cleanCurrent } );
		}
		
		private function createImage(text:String):ImageBitmapData {
			var textField:TextField = UI.getTextField();
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.size = Config.FINGER_SIZE * .28;
			textFormat.color = MainColors.WHITE;
			textFormat.align = TextFormatAlign.LEFT;
			
			var autosize:String = textField.autoSize;
			var isMultiline:Boolean = textField.multiline;
			
			textField.width = toastPoint.x - Config.FINGER_SIZE;
			textField.autoSize = TextFieldAutoSize.NONE;
			textField.multiline = true;
			textField.wordWrap = true;
			textField.text = text;
			textField.setTextFormat(textFormat);
			textField.width = Math.max(textField.textWidth + 4, toastPoint.x - Config.FINGER_SIZE * 3);
			textField.height = Math.min(textField.textHeight + 4, Config.FINGER_SIZE * 4);
			
			var horizontalPadding:int = Config.FINGER_SIZE * 0.4;
			var verticalPadding:int = Config.FINGER_SIZE * 0.3;
			
			var back:Shape = new Shape();
			back.graphics.beginFill(0x333333);
			back.graphics.drawRoundRect(0, 0, textField.width + horizontalPadding * 2, textField.height + verticalPadding * 2, Config.FINGER_SIZE * .1, Config.FINGER_SIZE * .1);
			back.graphics.endFill();
			
			var bitmapData:ImageBitmapData = new ImageBitmapData("ToastMessage", textField.width + horizontalPadding * 2, textField.height + verticalPadding * 2);
			bitmapData.draw(back);
			var matrix:Matrix = new Matrix();
			matrix.translate(horizontalPadding, verticalPadding);
			bitmapData.draw(textField, matrix);
			
			textField.autoSize = autosize;
			textField.multiline = isMultiline;
			textField = null;
			
			return bitmapData;
		}
		
		private function cleanCurrent():void {
			if (messageClip) {
				TweenMax.killTweensOf(messageClip);
				if (messageClip.parent != null)
					stage.removeChild(messageClip);
				if (messageClip.bitmapData)
					messageClip.bitmapData.dispose();
				messageClip.bitmapData = null;
			}
			messageClip = null;
		}
	}
}