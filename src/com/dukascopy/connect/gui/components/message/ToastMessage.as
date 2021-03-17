package com.dukascopy.connect.gui.components.message 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.tools.handTip.HandTip;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ToastMessage 
	{
		static public const NOT_SHOWN:String = "notShown";
		static public const UNKNOWN:String = "unknown";
		static public const SHOWN:String = "shown";
		
		static private var _stageRef:Stage;
		private static var viewWidth:int = 0;
		private static var viewHeight:int = 0;
		static private var stageReady:Boolean;
		static private var displayed:Boolean;
		static private var messageClip:Bitmap;
		static private var showTime:Number = 3.5;
		static private var hand:com.dukascopy.connect.gui.tools.handTip.HandTip;
		
		public function ToastMessage() 
		{
			
		}
		
		public static function display(value:String, rotate:Boolean = false, additionalBottomPadding:int = 0):void
		{
			if (value == null)
			{
				return;
			}
			
			if (displayed)
			{
				cleanCurrent();
			}
			displayed = true;
			messageClip = new Bitmap();
			messageClip.bitmapData = createImage(value);
			messageClip.alpha = 0;
			
			var bottom:int;
			if (MobileGui.softKeyboardYPosition > Config.FINGER_SIZE * 2) {
				bottom = MobileGui.softKeyboardYPosition;
			}
			else {
				bottom = _stageRef.fullScreenHeight;
			}
			bottom = Math.min(bottom, _stageRef.fullScreenHeight) - Config.APPLE_BOTTOM_OFFSET - Config.FINGER_SIZE;
			
			if (additionalBottomPadding != 0)
			{
				bottom = _stageRef.fullScreenHeight - additionalBottomPadding - Config.FINGER_SIZE;
			}
			
			if (rotate == true) {
				messageClip.rotation = 90;
				messageClip.x = Config.FINGER_SIZE + messageClip.width;
				messageClip.y = int(Config.APPLE_TOP_OFFSET + (_stageRef.stageHeight - Config.APPLE_TOP_OFFSET - Config.APPLE_BOTTOM_OFFSET - messageClip.height) * .5);
			} else {
				messageClip.x = int(viewWidth * .5 - messageClip.width * .5);
				messageClip.y = int(bottom - messageClip.height - Config.DOUBLE_MARGIN);
			}
			_stageRef.addChild(messageClip);
			TweenMax.to(messageClip, 0.5, {alpha:1});
			TweenMax.to(messageClip, 0.5, {alpha:0, delay:showTime, onComplete:cleanCurrent});
		}
		
		public static function displayHandTip(value:String, position:Point, time:Number = NaN):void
		{
			if (_stageRef == null)
			{
				return;
			}
			hideHandTip();
			hand = new HandTip();
			_stageRef.addChild(hand);
			hand.x = position.x;
			hand.y = position.y;
			hand.show(value, time);
		}
		
		public static function hideHandTip():void
		{
			if (hand)
			{
				hand.hide();
				hand = null;
			}
		}
		
		static private function createImage(text:String):ImageBitmapData
		{
			var textField:TextField = UI.getTextField();
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.size = Config.FINGER_SIZE * .28;
			textFormat.color = MainColors.WHITE;
			textFormat.align = TextFormatAlign.LEFT;
			
			var autosize:String = textField.autoSize;
			var isMultiline:Boolean = textField.multiline;
			
			textField.width = viewWidth - Config.FINGER_SIZE;
			textField.autoSize = TextFieldAutoSize.NONE;
			textField.multiline = true;
			textField.wordWrap = true;
			textField.text = text;
			textField.setTextFormat(textFormat);
			textField.width = Math.max(textField.textWidth + 4, viewWidth - Config.FINGER_SIZE * 3);
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
		
		static private function cleanCurrent():void
		{
			if (messageClip)
			{
				_stageRef.removeChild(messageClip);
				TweenMax.killTweensOf(messageClip);
				
				if (messageClip.bitmapData)
				{
					messageClip.bitmapData.dispose();
					messageClip.bitmapData = null;
				}
				messageClip = null;
			}
		}
		
		public static function setStage(stageRef:Stage):void {
			if (stageRef != null) {
				_stageRef = stageRef;
				_stageRef.addEventListener(Event.RESIZE, onResize);
				stageReady = true;
				onResize();
			}/* else {
				trace("ToastMessage -> cannot assign stage reference because it cannot be null  ");
			}*/
		}
		
		static private function onResize(e:Event = null):void
		{
			echo("ToastMessage", "onResize", "START");
			if (_stageRef == null)
				return;
			var w:int = _stageRef.stageWidth;
			var h:int = _stageRef.stageHeight;
			setSize(w, h);
			echo("ToastMessage", "onResize", "END");
		}
		
		public static function setSize(width:int, height:int):void {
			echo("ToastMessage", "setSize", "START");
			viewWidth = width;
			viewHeight = height;
			echo("ToastMessage", "setSize", "END");
		}
		
		static public function updateHandTip(position:Point):void 
		{
			if (hand != null)
			{
				hand.x = position.x;
				hand.y = position.y;
			}
		}
		
		static public function hide():void 
		{
			if (displayed)
			{
				cleanCurrent();
			}
		}
	}
}