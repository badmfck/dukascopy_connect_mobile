package com.dukascopy.connect.gui.tabs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.MainColors;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Quint;
	import com.greensock.easing.Sine;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class TabsItemBottom extends MobileClip {
		
		private var _id:String;
		private var _name:String;
		private var _selection:Boolean = false;
		private var _num:int = 0;
		
		static private var src:Sprite;
	//	static private var tf:TextField;
	//	static private var ta:TextFormat;
		static private var margin:int = Config.FINGER_SIZE_DOT_5;
		static private var m:Matrix;
		
		private var bmp:ImageBitmapData;
		private var _icon:Bitmap;
		private var _iconDown:Bitmap;
		private var _clr:uint;
		private var _bg:ImageBitmapData;
		private var bgAlpha:Number;
		private var textColor:uint;
		private var _doSelection:Boolean;
		public var tapCallback:Function;
		private var tl:int;
		private var tr:int;
		private var bl:int;
		private var br:int;
		private var downX:int = 0;
		private var downY:int = 0;
		private var isShown:Boolean = true;
		private var downPressed:Boolean = false;
		private var _wasDown:Boolean = false;
		private var lastTouchID:int = -1;
		private var stageRef:Stage;
		private static var tempPoint:Point = new Point();
		private static var tempRect:Rectangle = new Rectangle();
		
		private var notifyIcon:Sprite;
		
		private var buttonWidth:int=Config.FINGER_SIZE;
	//	private var newItemsClip:Sprite;
	//	private var newItemsText:TextField;
		
		public var TOP_OVERFLOW:int = 0;
		public var LEFT_OVERFLOW:int = 0;
		public var RIGHT_OVERFLOW:int = 0;
		public var BOTTOM_OVERFLOW:int = 0;
		
		private var blinkCount:int = 0;
		private var isBlinking:Boolean = false;
		private var maxBlinkCount:int = 5;
		private var iconBaseY:int = 0;
		private var selectedBackgroundColor:Number;
		private var selectedBackground:Sprite;
		
		public function TabsItemBottom(name:String, id:String, num:int, 
										icon:DisplayObject/*MovieClip*/ = null, 
										iconDown:/*MovieClip*/DisplayObject = null, 
										bg:ImageBitmapData = null,
										clr:uint = 0xFFFFFF,
										bgAlpha:Number = 1,
										textColor:uint = 0,
										doSelection:Boolean = true,
										scale:Number = 1,
										selectedColor:Number = NaN, selectedBackgroundColor:Number = NaN){
			_doSelection = doSelection;
			this.textColor = textColor;
			this.bgAlpha = bgAlpha;
			this.selectedBackgroundColor = selectedBackgroundColor;
			_bg = bg;
			_clr = clr;
			UI.colorize(icon, selectedColor);
			UI.colorize(iconDown, textColor);
			
		//	icon.scaleX = icon.scaleY = scale;
		//	iconDown.scaleX = iconDown.scaleY = scale;
			
			var iconSize:int = Config.FINGER_SIZE * .58 * scale;
			
			UI.scaleToFit(icon, iconSize, iconSize);
			UI.scaleToFit(iconDown, iconSize, iconSize);
			
			_icon = new Bitmap(UI.getSnapshot(icon, StageQuality.HIGH, "TabsItemBottom." + id + ".icon"));
			_iconDown = new Bitmap(UI.getSnapshot(iconDown, StageQuality.HIGH, "TabsItemBottom." + id + ".Down.icon"));
			_icon.visible = false;
			_id = id;
			_name = name;
			_num = num;
			
		//	icon.scaleX = icon.scaleY = 1;
		//	iconDown.scaleX = iconDown.scaleY = 1;
			
			createView();
		}
		
		private function createView():void {
			
			src = new Sprite();
			
			/*if (tf == null) {
				tf = new TextField();
				var fontSize:int = Config.FINGER_SIZE * .22;
				if (fontSize < 9)
					fontSize = 9;
				if (ta == null)
					ta = new TextFormat("Tahoma", fontSize);
				tf.defaultTextFormat = ta;
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.textColor = textColor;
				if(src==null)
					src = new Sprite();
				src.addChild(tf);
			}*/
			
			_view = new Sprite();
			PointerManager.addDown(this.view, onDown);
			stageRef = MobileGui.stage;
			
			/*if (!newItemsClip)
			{
				newItemsClip = new Sprite();
				_view.addChild(newItemsClip);
				newItemsText = new TextField();
				newItemsText.selectable = false;
				newItemsClip.addChild(newItemsText);
				var fontSizeNew:int = Config.FINGER_SIZE * .22;
				
				var itemsTextFormat:TextFormat = new TextFormat("Tahoma", fontSizeNew);
				itemsTextFormat.bold = true;
				newItemsText.defaultTextFormat = itemsTextFormat;
				newItemsText.autoSize = TextFieldAutoSize.LEFT;
				newItemsText.textColor = MainColors.WHITE;
				newItemsText.x = int(Config.FINGER_SIZE * .05);
				newItemsText.y = int(Config.FINGER_SIZE * .0);
				
				newItemsClip.visible = false;
			}*/
			
			if (notifyIcon == null) {
				notifyIcon = new SWFAttentionIcon2();
				notifyIcon.width = Config.FINGER_SIZE * .16;
				notifyIcon.height = Config.FINGER_SIZE * .16;
				notifyIcon.visible = false;
			}
			
			if (!isNaN(selectedBackgroundColor))
			{
				selectedBackground = new Sprite();
				_view.addChildAt(selectedBackground, 0);
				
				selectedBackground.graphics.beginFill(selectedBackgroundColor);
				selectedBackground.graphics.drawCircle(0, 0, Config.FINGER_SIZE * .38);
				selectedBackground.graphics.endFill();
				selectedBackground.visible = false;
			}
		}
		
		private function onDown(e:Event = null):void
		{
			_wasDown = true;
			downPressed = true;
			
			//notifyIcon.visible = false;
			
			if (e is TouchEvent) {
				lastTouchID = (e as TouchEvent).touchPointID;
			}
			
			downX =  MobileGui.stage.mouseX;
			downY = MobileGui.stage.mouseY;
			downState();
			PointerManager.addUp(stageRef, onStageUp);
		}
		
		private function onStageUp(e:Event = null):void
		{
			PointerManager.removeUp(stageRef, onStageUp);
			if (e!=null && e is TouchEvent) {
				var newID:int = (e as TouchEvent).touchPointID;
				if(newID == lastTouchID){
					//DialogManager.alert("tapped", e.toString());	
				}else {
					upState();
					_wasDown =  false;
					return; // you touched with another finger 	
				}
			}
			upState();
			if (_wasDown) {
				// hittest 
				var isOverButton:Boolean = 	buttonHitTest(this, MobileGui.stage, MobileGui.stage.mouseX, MobileGui.stage.mouseY);
				if (isOverButton) { 
					if (tapCallback != null) {
						tapCallback();
					}
				}
			}
			_wasDown =  false;
		}
		
		private function downState():void { }
		
		private function upState():void { }
		
		public static function buttonHitTest(obj:TabsItemBottom, stage:Stage, x:Number = 0, y:Number = 0):Boolean {
			var result:Boolean  = false;
			tempPoint.x = 0;
			tempPoint.y = 0;
			var coord:Point =  obj.view.localToGlobal(tempPoint);
			var rectX:int = coord.x - obj['LEFT_OVERFLOW'];
			var rectY:int =  coord.y- obj['TOP_OVERFLOW'];
			var rectWidth:int = obj['fullWidth'];
			var rectHeight:int = obj['fullHeight'];
			tempRect.x = rectX;
			tempRect.y = rectY;
			tempRect.width = rectWidth;
			tempRect.height = rectHeight;
			var hitRect:Rectangle = tempRect;
			tempPoint.x = x;
			tempPoint.y = y;
			result = hitRect.containsPoint( tempPoint);
			hitRect = null;
			coord = null;
			return result;
		}
		
		public function rebuild(height:int,width:int,selected:Boolean=false):void {
			/*if (tf == null)
				return;*/
			if (height < 0)
				height = 1;
			/*if (_name != null){
				tf.text = _name;
				tf.visible = true;
			} else {
				tf.visible = false;
			}*/
			buttonWidth = width;
				
			var w:int = buttonWidth;
			var h:int = height;
			
			if (_name == null)
				w = Config.FINGER_SIZE * .6 + margin * 2;
			
		//	tf.x = (w-tf.width)*.5;
		//	tf.y = Math.round((height - (tf.textHeight + 4)) * .5);
			src.graphics.clear();
			src.graphics.beginFill(_clr, bgAlpha);
			src.graphics.lineStyle(0, 0,0);
			src.graphics.drawRect(0, 0, w, h);
			
			if (bmp == null || bmp.height != h || bmp.width != w) {
				if (bmp != null)
				{
					bmp.dispose();
					bmp = null;
				}
				bmp = new ImageBitmapData("TabsItemBottom." + id, w, h);
			} else {
				bmp.fillRect(bmp.rect, 0);
			}
			
			bmp.draw(src);
			_view.graphics.clear();
			_view.graphics.beginBitmapFill(bmp, null, false, true);
			_view.graphics.drawRect(0, 0, w, h);
			_view.addChild(_icon);
			
			var iphoneXOffset:int = 0;
			if (Config.PLATFORM_APPLE && Config.isRetina()>0) {
				iphoneXOffset = Config.FINGER_SIZE * .17;
			}
			_icon.x = int((w - _icon.width) * .5);
			_icon.y = int((h - _icon.height) * .5 + iphoneXOffset);
			
			_view.addChild(_iconDown);
			_iconDown.x = int((w-_iconDown.width)*.5);
			_iconDown.y = int((h - _iconDown.height) * .5 + iphoneXOffset);
			iconBaseY =  (h - _iconDown.height) * .5 + iphoneXOffset;
			
			if (selectedBackground != null)
			{
				selectedBackground.x = int(w * .5);
				selectedBackground.y = int(h * .5 + iphoneXOffset);
			}
			
			notifyIcon.x = int(_icon.x + _icon.width * .69);
			notifyIcon.y = int(Config.TOP_BAR_HEIGHT * .25);
			_view.addChild(notifyIcon);
			
		//	updateNewItemsClip();
		}
		
		public function select(sel:Boolean=false):void {
			if (sel) {
				_icon.visible = true;
				_iconDown.visible = false;
				if (selectedBackground != null)
				{
					selectedBackground.visible = true;
				}
			}else {
				_icon.visible = false;
				_iconDown.visible = true;
				if (selectedBackground != null)
				{
					selectedBackground.visible = false;
				}
			}
		}
		
		override public function dispose():void {
			if (_iconDown != null)			
				TweenMax.killTweensOf(_iconDown);	
			_id = null;
			_name = null;
			_selection = false;
			_num = 0;
			_bg = null;
		
			// STAMP
			if (src != null)
				src.graphics.clear();
			
			src = null;
			
			/*if (tf != null)
				tf.text = '';
			tf = null;*/
		  
		//	ta = null;
			if (bmp != null)
				bmp.dispose();
			bmp = null;
	
			if (_icon != null && _icon.bitmapData!=null)
				_icon.bitmapData.dispose();
			_icon = null;
			
			if (_iconDown != null && _iconDown.bitmapData!=null)
				_iconDown.bitmapData.dispose();
			_iconDown = null;
			
			if (selectedBackground != null)
			{
				UI.destroy(selectedBackground);
				selectedBackground = null;
			}
			
			super.dispose();
		}
		
		public function get id():String{
			return _id;
		}
		
		public function get selection():Boolean{
			return _selection;
		}
		
		public function get num():int {
			return _num;
		}
		
		public function get bg():ImageBitmapData{
			return _bg;
		}
		
		public function get doSelection():Boolean {
			return _doSelection;
		}
		
		public function setSelection(val:Boolean):void {
			_selection = val;
		}
		
		/*public function displayNewItemsNum(missedNum:int):void 
		{
			newItemsText.text = missedNum.toString();
			if (missedNum > 0)
			{
				newItemsClip.visible = true;
			}
			else {
				newItemsClip.visible = false;
			}
			updateNewItemsClip();
		}*/
		
		public function notificate(val:Boolean):void {
			notifyIcon.visible = val;
		}
		
		public function blink(val:Boolean):void
		{			
			if (val == true){					
				if (!isBlinking){ 
					isBlinking = true;
					blinkCount = 0;
					startBlink();	
				}
			}else{
				stopBlink();
			}
		}
		
		private function startBlink():void	{			
			blinkCount ++;
			if (_iconDown != null && blinkCount < maxBlinkCount + 1){
				TweenMax.killTweensOf(_iconDown);
				var amplitude:int = Config.FINGER_SIZE * .1;
				var upY:int = iconBaseY - amplitude ;// blinkCount == maxBlinkCount? iconBaseY - amplitude : iconBaseY - amplitude;
				var downY:int =	 blinkCount == maxBlinkCount? iconBaseY : iconBaseY + amplitude;
				var startEase:Object = Sine.easeOut;// blinkCount == 0?  Sine.easeIn:Sine.easeOut;
				var endEase:Object = Sine.easeOut;// blinkCount == maxBlinkCount? Sine.easeOut:Sine.easeIn;
				var upTime:Number =	.2;// blinkCount == 0? .2:.2;
				var downTime:Number = .2;// blinkCount == maxBlinkCount? .2:.2;
				TweenMax.to(_iconDown, upTime, {y:upY	,colorTransform: { tint:0xff0000, tintAmount:1 }, ease:startEase});
				TweenMax.to(_iconDown, downTime, {y:downY ,colorTransform: { tint:0xff0000, tintAmount:0 }, ease:endEase , delay:upTime, onComplete:startBlink});	
				
			}else{
				isBlinking = false;
			}
		}
		
		
		private function stopBlink():void {
			isBlinking = false;
			if (_iconDown != null){
				TweenMax.killTweensOf(_iconDown);			
				TweenMax.to(_iconDown, .3, {y:iconBaseY, colorTransform: { tint:0xff0000, tintAmount:0 }});				
			}
		}
		
		/*private function updateNewItemsClip():void 
		{
			newItemsClip.graphics.clear();
			newItemsClip.graphics.beginFill(Color.GREEN, 1);
			newItemsClip.graphics.drawRoundRect(0, 0, newItemsText.width + Config.FINGER_SIZE * .1, 
														newItemsText.height, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2);
			newItemsClip.graphics.endFill();
			newItemsClip.x = buttonWidth * .6;
			newItemsClip.y = Config.FINGER_SIZE * .1;
			
			_view.setChildIndex(newItemsClip, _view.numChildren - 1);
		}*/
		// returns width including overflow 
		public function get fullWidth():Number	{
			return (view.width + LEFT_OVERFLOW + RIGHT_OVERFLOW);
		}
		
		// returns height including overflow 
		public function get fullHeight():Number	{
			return (view.height + TOP_OVERFLOW + BOTTOM_OVERFLOW);
		}
	}
}