package com.dukascopy.connect.screens.payments.settings {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.payments.settings.ItemSubWithoutSetting;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	public class LimitWithoutSetting extends Sprite {
		
		private var _width:Number = 320;
		private var _header:Bitmap;
		private var itemSubAmount:ItemSubWithoutSetting;
		private var itemSubDaily:ItemSubWithoutSetting;
		private var _isDrawBG:Boolean;
		private var _isShow:Boolean;
		
		public function LimitWithoutSetting() {
			_header = new Bitmap();
			itemSubAmount = new ItemSubWithoutSetting(ItemSubWithoutSetting.PWP_LIMIT_AMOUNT);
			itemSubDaily = new ItemSubWithoutSetting(ItemSubWithoutSetting.PWP_LIMIT_DAILY);
			addChild(_header);
			addChild(itemSubDaily);
			addChild(itemSubAmount);
		}
		
		public function hide():void {
			_isShow = false;
			this.visible = _isShow;
			this.mouseEnabled = _isShow;
			this.mouseChildren = _isShow;
			deactivateScreen();
		}
		
		public function show():void {
			/*if(_isShow == false){
				itemSubAmount.show();
				itemSubDaily.show();
			}*/
			_isShow = true;
			this.visible = _isShow;
			this.mouseEnabled = _isShow;
			this.mouseChildren = _isShow;
			activateScreen();
		}
		
		public function setWidthAndHeight(itemWidth:int):void {
			_isDrawBG = true;
			if (_width == itemWidth)
				return;
			_width = itemWidth;
			itemSubAmount.setWidthAndHeight(itemWidth);
			itemSubDaily.setWidthAndHeight(itemWidth);
			drawTextBitmap();
		}
		
		public function drawView():void {
			var posY:int = Config.DOUBLE_MARGIN;
			_header.y = posY;
			posY = _header.y + _header.height + Config.MARGIN * 2;
			itemSubAmount.y = posY;
			posY = itemSubAmount.y + itemSubAmount.height + Config.MARGIN * 2;
			itemSubDaily.y = posY;
			
			if(_isDrawBG){
				_isDrawBG = false;
			}
		}
		
		public function activateScreen():void {
			if(_isShow)
			{
				itemSubAmount.activateScreen();
				itemSubDaily.activateScreen();
			}
		}
		
		public function deactivateScreen():void {
			itemSubAmount.deactivateScreen();
			itemSubDaily.deactivateScreen();
		}
		
		public function onServerRespond(id:String, err:Boolean):void{
			if(itemSubAmount!=null)
				itemSubAmount.onServerRespond(id, err);
				
			if(itemSubDaily)
				itemSubDaily.onServerRespond(id,err);
		}		
		
		public function dispose():void {
			graphics.clear();
			if (_header)
			{
				removeChild(_header);
				UI.destroy(_header);
				_header = null;
			}
			if(itemSubAmount){
				itemSubAmount.dispose();
				itemSubDaily.dispose();
			}
		}
		
		private function drawTextBitmap():void {
			if(_header.bitmapData!= null) {
				UI.disposeBMD(_header.bitmapData);
			}
			
			_header.bitmapData = UI.renderText( Lang.limitsWithoutSettings, _width - Config.DOUBLE_MARGIN * 2, 1, true, TextFormatAlign.LEFT, 
												TextFieldAutoSize.CENTER, FontSize.BODY, true, 
												Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), true, "ListWithoutSetting.1");
			
			var dayLimit:String = Lang.dailyLimitMaxSwiss;
			var transactionLimit:String = Lang.transactionLimitsMaxSwiss;
			
			itemSubDaily.drawLabel(dayLimit);
			itemSubAmount.drawLabel(transactionLimit);
		}
		
		public function setDefStateEntry():void {
			/*if(itemSubAmount.state == ItemSubWithoutSetting.STATE_WAIT){
				itemSubAmount.show();
			}else if(itemSubDaily.state == ItemSubWithoutSetting.STATE_WAIT){
				itemSubDaily.show();
			}else{
				_isShow = false;
			}*/
		}
	}
}