package com.dukascopy.connect.gui.button {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.uiFactory.UIFactory;
	import com.dukascopy.langs.Lang;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Alexey
	 */
	public class DDButton extends BitmapButton{

		private var _text:String = "...";		
		private var currentBMD:BitmapData;
		private var _viewWidth:int = 0;
		private var _viewHeight:Number = 0;
		
		public function DDButton(callBack:Function,labelText:String=""){
			super();
//			_text = labelText== "" ? Lang.textChoose+"...": labelText;
			updateDefaultLabel();
			setStandartButtonParams();	
			usePreventOnDown = true;
			cancelOnVerticalMovement = true;
			tapCallback = callBack;				
		}

		public function updateDefaultLabel(labelText:String=""):void {
			_text = labelText== "" ? Lang.textChoose+"...": labelText;
			setSize(_viewWidth, _viewHeight);
		}

		public function setSize(w:int, h:int):void {
			if (w < 1 || h < 1)
				return;
				
			var needRedraw:Boolean  = false;			
			if(_viewWidth != w) {
				_viewWidth = w;
				needRedraw = true;				
			}		
			
			if (_viewHeight != h) {
				viewHeight = h;
				needRedraw = true;
			}
				
			if (needRedraw) {
				renderButton();
			}
		}
		
		private function renderButton():void
		{
			UI.disposeBMD(currentBMD);
			currentBMD = UI.renderDropdownButton(_text, _viewWidth, _viewHeight, 
												Style.color(Style.COLOR_TEXT), 
												Style.color(Style.COLOR_BACKGROUND),
												AppTheme.GREY_SEMI_LIGHT, 
												AppTheme.BUTTON_CORNER_RADIUS, 
												Style.color(Style.COLOR_TEXT));
			setBitmapData(currentBMD, true);
		}
		
		public function setText(value:String):void	{
			if (value == _text) return;
			_text = value;
			renderButton();					
		}
		
		override public function dispose():void {		
			UI.disposeBMD(currentBMD);
			currentBMD = null;
			super.dispose();
		}		
		
		public function get viewWidth():int {	return _viewWidth;}		
		public function set viewWidth(value:int):void 
		{
			if (value == _viewWidth) return;
			_viewWidth = value;
			renderButton();
		}		
		override public function get viewHeight():Number {	return _viewHeight;	}		
		override public function set viewHeight(value:Number):void 
		{
			if (value == _viewHeight) return;
			_viewHeight = value;
			renderButton();
		}
		
		
		
		
	}

}