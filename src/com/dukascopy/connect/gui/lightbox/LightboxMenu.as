package com.dukascopy.connect.gui.lightbox 
{
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Alexey
	 */
	public class LightboxMenu extends Sprite 
	{
		private var _viewWidth:int = 100;
		private var _viewHeight:int = 100;
		
		private var okCallback:Function;
		private var cancelCallback:Function;

		
		public var stageRef:Stage;
		private var menuHolder:Sprite = new Sprite();
		private var _hideOffset:int  = 0;
		
		private var buttonOkBitmap:Bitmap = new Bitmap();
		private var buttonCancelBitmap:Bitmap   = new Bitmap();
		
		
		private  var isShown:Boolean = false;
		private const buttonsVericalSizeCoef:int = 10;
		private var buttonVerticalSize:int;

		public function LightboxMenu() {
			super();
			addChild(menuHolder);
			menuHolder.addChild(buttonCancelBitmap);
			menuHolder.addChild(buttonOkBitmap);
			
			this.mouseChildren = false;
			this.visible = false;
			this.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void {
			echo("LightboxMenu", "onClick", "START");
			if (stageRef.mouseY < stageRef.stageHeight - buttonVerticalSize)
				return;
			
			if (this.okCallback != null && this.cancelCallback != null)
			{
				// two callbacks
				if (stageRef.mouseX < stageRef.stageWidth *.5 ) {
					if (cancelCallback != null) cancelCallback(); 
				}else {
					if (okCallback != null) okCallback(); 
				}
				return;
			}else {
				if (okCallback != null) okCallback();
				if (cancelCallback != null) cancelCallback();
			}
			echo("LightboxMenu", "onClick", "END");
		}
		
		public function show():void  {
			this.visible = true;
			isShown = true;
			updateViewPort();
		}
		
		
		public function hide():void		{
			this.visible  = false;
			isShown = false;
		}
		
		
		public function setSize(w:int, h:int):void {
			if(_viewWidth!=w || _viewHeight!=h){
				_viewWidth = w;
				_viewHeight = h;
				updateViewPort();
			}
		}
		
		
		private function disposeButtons():void	{
			UI.disposeBMD(buttonOkBitmap.bitmapData);
			UI.disposeBMD(buttonCancelBitmap.bitmapData);	
		}
		
		private function updateViewPort():void {
			echo("LightboxMenu", "updateViewPort", "START");
			if (!isShown)
				return;
			buttonVerticalSize = _viewHeight / buttonsVericalSizeCoef;
			menuHolder.y = stageRef.stageHeight - buttonVerticalSize + hideOffset;
			disposeButtons();			
			var btnWidth:int = okCallback != null && cancelCallback != null? _viewWidth * .5:_viewWidth;
			
			if(cancelCallback!=null){
				buttonOkBitmap.bitmapData = UI.renderButtonOld(Lang.textOk.toUpperCase(), btnWidth,buttonVerticalSize);
			}
			
			if(okCallback!=null){
				buttonCancelBitmap.bitmapData = UI.renderButtonOld(Lang.textCancel.toUpperCase(), btnWidth+1, buttonVerticalSize);
				buttonOkBitmap.x = okCallback!=null?_viewWidth * .5:0;	
			}
			echo("LightboxMenu", "updateViewPort", "END");
		}
	
		public function dispose():void
		{
			disposeButtons();
			okCallback = null;
			cancelCallback = null;	
		}
		
		public function setCallbacks(cancelCallback:Function=null, okCallback:Function=null):void
		{
			this.okCallback = okCallback;
			this.cancelCallback = cancelCallback;	
			updateViewPort();
			
		}
		
		public function callCancel():void 	{
			if (cancelCallback != null) cancelCallback();
		}
			
		private function getOkCallback():Function {
			return this.okCallback;
		}		
		
		private function getCancelCallback():Function {
			return this.cancelCallback;
		}
		
		public function get hideOffset():int 	{		return _hideOffset;	}		
		public function set hideOffset(value:int):void 
		{
			if (value == _hideOffset) return;
			_hideOffset = value;
			menuHolder.y = stageRef.stageHeight - 100 + hideOffset;
		}
	}
}