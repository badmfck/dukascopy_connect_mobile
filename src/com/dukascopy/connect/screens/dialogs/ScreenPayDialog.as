package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListCountry;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class ScreenPayDialog extends BaseScreen{
		
		protected var list:List
		//private var search:Input;
		private var topIBD:ImageBitmapData;
		
		protected var topBox:Sprite;
		protected var closeBtn:BitmapButton;
		
		protected var additionalBtn:BitmapButton;
		
		public function ScreenPayDialog() { }
		
		override protected function createView():void {
			super.createView();
			
			list = new List("PayPicker");
			list.setMask(true);
			list.view.y = Config.FINGER_SIZE;// + search.view.height;
			_view.addChild(list.view);
			
			topBox = new Sprite();
			_view.addChild(topBox);			
			
			closeBtn = new BitmapButton();
			closeBtn.setBitmapData(UI.renderAsset(new SWFCloseIconThin(), Config.FINGER_SIZE_DOT_35, Config.FINGER_SIZE_DOT_35, true, "ScreenPayDialog.closeBtn"));
			closeBtn.setOverflow(Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_25);
			closeBtn.setStandartButtonParams();
			_view.addChild(closeBtn);
			closeBtn.show();
			closeBtn.tapCallback = onCloseBtnClick;
		}
		
		private function onCloseBtnClick():void {
			DialogManager.closeDialog();
			if (_data && _data.callback != null) {
				if ("additionalData" in _data == true) {
					_data.callback(null, _data.additionalData);
					return;
				}
				_data.callback(null);
			}
		}
		
		override public function initScreen(data:Object = null):void{
			super.initScreen(data);
			_params.title = data.label;
			
			if ("additionalButton" in data == true && data.additionalButton != null) {
				additionalBtn = new BitmapButton("additionalButton");
				additionalBtn.setBitmapData(
					UI.renderButton(
						data.additionalButton.label,
						_width - Config.DOUBLE_MARGIN * 2,
						Config.FINGER_SIZE,
						0xffffff,
						0x00a551,
						0x008c45,
						Style.size(Style.SIZE_BUTTON_CORNER),
						Style.size(Style.SIZE_BUTTON_CORNER)
					),
					true
				);
				
				additionalBtn.tapCallback = onAdditionalButtonTap;
				
				additionalBtn.hide();
				additionalBtn.x = Config.DOUBLE_MARGIN;
				_view.addChild(additionalBtn);
			}
			
			var maxHeight:int = _height - Config.FINGER_SIZE;
			var trueHeight:int = maxHeight;
			if (additionalBtn != null)
			{
				trueHeight -= additionalBtn.height + Config.MARGIN;
			}
			if (trueHeight > list.innerHeight)
				trueHeight = list.innerHeight
			
			list.setWidthAndHeight(_width, trueHeight);
			list.setData(data.data, data.itemClass);
		}
		
		private function onAdditionalButtonTap(E:Event = null):void 
		{
			if (additionalBtn)
			{
				_view.removeChild(additionalBtn);
				additionalBtn = null;
			}
			drawView();
			
			if (data.additionalButton.callback)
			{
				data.additionalButton.callback(list);
			}
		}
		
		override public function activateScreen():void{
			super.activateScreen();
			list.activate();
			list.S_ITEM_TAP.add(onItemTap);
			if (closeBtn != null) {
				closeBtn.activate();
			}
			if (additionalBtn != null) {
				additionalBtn.activate();
				if (additionalBtn.getIsShown() == false)
					additionalBtn.show(.3, .1);
			}
		}
		
		private function onItemTap(dataObject:Object, n:int):void {
			if (dataObject == null) return;
			if (dataObject.hasOwnProperty("length") && dataObject.length == 2 && dataObject.hasOwnProperty(""))
				return;

			DialogManager.closeDialog();
			doCallBack(dataObject);
		}

		protected function doCallBack(data:Object):void {
			if (_data && _data.callback != null) {
				if ("additionalData" in _data == true) {
					_data.callback(data, _data.additionalData);
					return;
				}
				_data.callback(data);
			}
		}

		override protected function drawView():void {
			if (isDisposed == true)
			{
				return;
			}
			var maxHeight:int = _height - Config.FINGER_SIZE;
			
			if (additionalBtn != null)
			{
				maxHeight -= additionalBtn.height + Config.MARGIN;
			}
			
			//search.width = _width;
			if (list.innerHeight > maxHeight)
				list.setWidthAndHeight(_width, maxHeight);
			else 
				list.setWidthAndHeight(_width, list.innerHeight);
			
			topBox.graphics.clear();
			topBox.graphics.beginFill(AppTheme.GREY_LIGHT);
			topBox.graphics.drawRect(0, 0, _width, Config.FINGER_SIZE);
			topBox.graphics.beginFill(AppTheme.GREY_SEMI_LIGHT);
			topBox.graphics.drawRect(Config.DOUBLE_MARGIN, Config.FINGER_SIZE-2, _width-Config.DOUBLE_MARGIN*2, 2);
			//topBox.graphics.drawRoundRectComplex(0, 0, _width, Config.FINGER_SIZE, Config.MARGIN, Config.MARGIN, 0, 0);
			topBox.graphics.endFill();
			
			var tf:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE_DOT_25, AppTheme.GREY_DARK,false);
			if (topIBD != null && topIBD.isDisposed == false)
				topIBD.dispose();
			topIBD = null;
			topIBD = ImageManager.drawTextFieldToGraphic(topBox.graphics, Config.DOUBLE_MARGIN, Config.MARGIN * 2.5, _params.title.toLocaleUpperCase(), _width - Config.DOUBLE_MARGIN, tf);
			tf = null;

			var trueHeight:int = list.height + Config.FINGER_SIZE;
			if (additionalBtn != null)
			{
				trueHeight += additionalBtn.height + Config.MARGIN;
			}
			var trueY:int = int((_height - trueHeight) * .5)

			view.graphics.clear();
			view.graphics.beginFill(0xF5F5f5);
			view.graphics.drawRect(0, trueY, _width, list.height + Config.FINGER_SIZE);
			//view.graphics.drawRoundRect(0, trueY, _width, list.height + Config.FINGER_SIZE, Config.DOUBLE_MARGIN, Config.DOUBLE_MARGIN);
			view.graphics.endFill();
			
			topBox.y = trueY;
			list.view.y = trueY + Config.FINGER_SIZE;
			list.tapperInstance.setBounds();
			
			if (additionalBtn != null)
			{
				additionalBtn.y = list.view.y + list.height + Config.MARGIN;
			}
			
			closeBtn.x = _width - closeBtn.width-closeBtn.LEFT_OVERFLOW;
			closeBtn.y = trueY+ (Config.FINGER_SIZE - closeBtn.height)*.5 ;
		}

		override public function dispose():void{
			super.dispose();
			list.dispose();
			topIBD.disposeNow();
			
			if (additionalBtn){
				additionalBtn.dispose();
				additionalBtn = null;
			}
			list = null;
			if (closeBtn != null) {
				closeBtn.deactivate();
				closeBtn.dispose();
				closeBtn = null;
			}
		}
	}
}