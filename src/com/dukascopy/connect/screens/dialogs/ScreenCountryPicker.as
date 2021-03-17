package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListCountry;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormat;

	
	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class ScreenCountryPicker extends BaseScreen {
		
		private var list:List
		private var search:Input;
		private var topIBD:ImageBitmapData;
		
		private var topBox:Sprite;
		private var closeBtn:BitmapButton; 
		private var minHeight:int = 300; // Adding for small screens
		
		public function ScreenCountryPicker() { }
		
		override protected function createView():void {
			super.createView();
			
			search = new Input();
			search.view.y = Config.FINGER_SIZE;
			search.setParams(Lang.TEXT_SEARCH_COUNTRY, Input.MODE_INPUT);	
			search.S_CHANGED.add(onChanged);
			_view.addChild(search.view);
			
			list = new List("CountryPicker");
			list.setMask(true);
			list.view.y = Config.FINGER_SIZE + search.view.height;
			_view.addChild(list.view);
			
			topBox = new Sprite();
			_view.addChild(topBox);
			
			closeBtn = new  BitmapButton();
			closeBtn.setBitmapData(UI.getIconByFrame(20, Config.FINGER_SIZE, Config.FINGER_SIZE));
			_view.addChild(closeBtn);
			closeBtn.show();
			closeBtn.tapCallback = onCloseBtnClick;
		}
		
		override public function onBack(e:Event = null):void {
			onCloseBtnClick();
		}
		
		private function onCloseBtnClick():void {
			//trace("Close popup");
			DialogManager.closeDialog();
		}
		
		private function onChanged():void {
			var value:String = search.value.toLowerCase();
			doSearch(value);
		}
		
		private function doSearch(value:String = ""):void {
			if (list == null)
				return;
			var data:Array = list.data as Array;
			if (data == null || value == null)
				return;
			for (var i:int = 0; i < data.length; i++) {
				if (data[i][0].indexOf(value) == 0) {
					list.navigateToItem(i);
					return;
				}
			}
		}
		
		override public function initScreen(data:Object = null):void{
			super.initScreen(data);
			_params.title = 'Select country';
			
			var oldDelimiter:String = "";
			var newDelimiter:String = "";
			var cData:Array = CountriesData.COUNTRIES;
			var cDataNew:Array = [];
			for (var i:int = 0; i < cData.length; i++) {
				newDelimiter = String(cData[i][0]).substr(0, 1).toUpperCase();
				if (newDelimiter != oldDelimiter) {
					oldDelimiter = newDelimiter;
					cDataNew.push([oldDelimiter.toLowerCase(), oldDelimiter]);
				}
				cDataNew.push(cData[i]);
			}
			list.setData(cDataNew, ListCountry);
			cDataNew = null;
			cData = null;
		}
		
		override public function activateScreen():void{
			super.activateScreen();
			search.activate();
			list.activate();
			list.S_ITEM_TAP.add(onItemTap);
			if (closeBtn != null) {
				closeBtn.activate();
			}
			if (CountriesData.getCurrentCountry() != null)
				doSearch(CountriesData.getCurrentCountry()[0]);
		}
		
		private function onItemTap(dataObject:Object, n:int):void {
			if (dataObject.length == 2)
				return;
			DialogManager.closeDialog();
			if (_data && _data.onCountrySelected != null) {
				_data.onCountrySelected(dataObject);
			}
		}
		
		override protected function drawView():void {
			if (_height < minHeight)
				_height = minHeight;
			view.graphics.clear();
			view.graphics.beginFill(0xF5F5f5);
			view.graphics.drawRoundRect(0, 0, _width, _height, Config.DOUBLE_MARGIN, Config.DOUBLE_MARGIN);
			view.graphics.endFill();
			
			search.width = _width;
			list.setWidthAndHeight(_width, _height - Config.FINGER_SIZE_DOUBLE);
			
			topBox.graphics.clear();
			topBox.graphics.beginFill(AppTheme.RED_MEDIUM);
			topBox.graphics.drawRoundRectComplex(0, 0, _width, Config.FINGER_SIZE, Config.MARGIN, Config.MARGIN, 0, 0);
			topBox.graphics.endFill();
			
			// Вынести в глобальные переменные, сделать приватным. нахера же так делать то
			var tf:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE_DOT_25, 0xFFFFFF, true);
			if (topIBD != null && topIBD.isDisposed == false)
				topIBD.dispose();
			topIBD = null;
			topIBD = ImageManager.drawTextFieldToGraphic(topBox.graphics, Config.DOUBLE_MARGIN, Config.MARGIN * 2.5, Lang.selectCountry, _width - Config.DOUBLE_MARGIN, tf);
			tf = null;
			
			closeBtn.x = _width - Config.FINGER_SIZE;
		}
		
		override public function dispose():void {
			super.dispose();
			if (closeBtn != null) {
				closeBtn.deactivate();
				closeBtn.dispose();
				closeBtn = null;
			}			
			search.dispose();
			list.dispose();
			topIBD.disposeNow();
			list = null;
		}
	}
}