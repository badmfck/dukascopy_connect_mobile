package com.dukascopy.connect.gui.button {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Igor Bloom
	 */
	
	public class Button extends MobileClip{
		
		private var _width:int=-1;
		static private var _height:int=Config.FINGER_SIZE;
		static private var _round:int=Config.FINGER_SIZE*.3;
		private var callBack:Function=null;
		private var label:String='no label';
		private var color:uint=AppTheme.RED_MEDIUM;
		private var tf:TextField;
		private var _inUse:Boolean;
		
		private var src:Sprite = null;
		private var bmp:Bitmap = null;
		private var bmd:ImageBitmapData = null;
		
		static private var padding:int = Config.FINGER_SIZE * .35;
		static private var btnTextFormat:TextFormat;//= new TextFormat("Tahoma", 24, 0, null, null, null, null, null, TextFormatAlign.CENTER);
		private var type:String;
		private var icon:ImageBitmapData;
		
		
		public function Button(type:String='mobile'){
			this.type = type;
			if (type == 'desktop') {
				padding = 14;
				_height = 40;
				if(btnTextFormat==null)
					btnTextFormat = new TextFormat("Tahoma", 12, 0, null, null, null, null, null, TextFormatAlign.CENTER);
				_round = 8;
			}else {
				if(btnTextFormat==null)
					btnTextFormat= new TextFormat("Tahoma", Config.FINGER_SIZE * .6 - Config.MARGIN * 2, 0, null, null, null, null, null, TextFormatAlign.CENTER);
			}
			
			createView();
			if (type == 'desktop')
				_view.buttonMode = true;
		}
		
		public function setParams(label:String='no label',callBack:Function=null,color:uint=0xee4131,icon:ImageBitmapData=null):void{
			this.icon = icon;
			this.color = color;
			this.label = label;
			this.callBack = callBack;
			drawView();
		}
		
		protected function createView():void {
			_view = new Sprite();
			_view.buttonMode = true;
			src = new Sprite();
			bmp = new Bitmap(null, "auto", true);

			tf = new TextField();
			tf.defaultTextFormat = btnTextFormat;
			tf.textColor = 0xFFFFFF;
			src.addChild(tf);
			_view.addChild(bmp);
		}
		
		
		/*public function show(_time:Number=0, _delay:Number=0, overrideAnimation:Boolean= true):void
		{
			if (isShown) return;
			isShown = true;
			super.visible = true;
			
			TweenMax.killTweensOf(iconBitmap);
			
			if(overrideAnimation){
				iconBitmap.scaleX = iconBitmap.scaleY = 0;
				iconBitmap.rotation = 0;
			}
			
			var deltaX:Number ;
			var deltaY:Number ;
			if (currentBitmapData != null) {
				deltaX = currentBitmapData.width * .5 - (currentBitmapData.width ) * .5  ;
				deltaY = currentBitmapData.height * .5 - (currentBitmapData.height ) * .5  ;
				if(overrideAnimation){
					iconBitmap.x  = currentBitmapData.width * .5;
					iconBitmap.y = currentBitmapData.height * .5;
				}
			}else {
				deltaX = iconBitmap.width * .5 - (iconBitmap.width ) * .5;
				deltaY = iconBitmap.height * .5 - (iconBitmap.height ) * .5;
				if(overrideAnimation){
					iconBitmap.x  = iconBitmap.width * .5;
					iconBitmap.y =  iconBitmap.height * .5;
				}
			}
			
			TweenMax.to(iconBitmap, _time, {rotation:0,  transformMatrix: { scaleX:1, scaleY:1, x:deltaX, y:deltaY },delay:_delay,ease:Back.easeOut, onComplete:onShowComplete } );		
	
		}*/
		
		
		private function drawView():void {
			
		
			var trueW:int = _width;
			var padd:int = 0;
	
			
			tf.text = label;
		
			if (_width == -1){
				trueW = tf.textWidth + 4;
				padd = padding;
			}
			
			var drawW:int = trueW + padd * 2;
			
			src.graphics.clear();
			src.graphics.beginFill(color);
			src.graphics.drawRoundRect(0, 0, drawW, _height, _round, _round);
							
				
				
				if(padd==0)
					tf.width = trueW-padding*2;
						else
							tf.width = trueW;	
							
				tf.height = tf.textHeight + 4;
				tf.y = Math.round((_height - tf.height) * .5);
				tf.x = padding;
		
			
			var doDispose:Boolean= true;
			if (bmd == null)
				doDispose = false;
				
			bmd ||= new ImageBitmapData('btn: '+((label!=null)?label:"no-label"), trueW, _height, true);
			
			if (bmd.width != drawW || bmd.height != _height) {
				bmd.dispose();
				bmd = new ImageBitmapData('btn: '+((label!=null)?label:"no-label"), drawW, _height, true);
			}else{
				bmd.fillRect(bmd.rect, 0);
			}
			
			bmp.bitmapData = bmd;
			bmp.smoothing = true;
			bmd.drawWithQuality(src, null, null, null, null, true, StageQuality.HIGH);
			_width = bmp.width;
			
		}
		
		private function onTouchTap(e:Event):void{
			if (callBack != null)
				callBack();
		}
		
		public function setWidthAndHeight(w:int,h:int):void {
			_width = w;
			_height = h;
			drawView();
		}
		
		public function activate():void{
			PointerManager.addTap(_view, onTouchTap);
		}
		
		public function deactivate():void{
			PointerManager.removeTap(_view, onTouchTap);
		}
		
		override public function dispose():void {
			deactivate();
			super.dispose();
			
			if (icon != null)
				icon.dispose();
			icon = null;
			
			
			callBack=null
			label = null;
			color = 0
			
			if (tf != null)
				tf.text = '';
			tf = null;
			if (src != null)
				src.graphics.clear();
			src = null;
			
			if (bmp != null && bmp.bitmapData!=null)
				bmp.bitmapData.dispose();
			bmp = null;
			
			if(bmd!=null)
				bmd.dispose();
			bmd = null;

			type = null;
			if (icon != null)
				icon.dispose();
			icon=null
			
		}
		
	
		
		public function get height():int{
			return _height;
		}
		
		public function get width():int{
			return _width;
		}
		
		public function set width(value:int):void{
			_width = value;
			drawView();
		}
	}
}