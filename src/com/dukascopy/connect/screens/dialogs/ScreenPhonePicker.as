package com.dukascopy.connect.screens.dialogs 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListPhonebook;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.text.TextFormat;

	/**
	 * ...
	 * @author Anton Bodrychenko
	 */
	public class ScreenPhonePicker extends BaseScreen
	{
		private var list:List
		private var search:Input;
		private var topIBD:ImageBitmapData;
		
		private var topBox:Sprite;
		private var closeBtn:BitmapButton; 
		private var minHeight:int = 300;
		private var cData:Array;
		
		public function ScreenPhonePicker() 
		{
			
		}
		
		override protected function createView():void {
			super.createView();
			
			search = new Input();
			search.view.y = Config.FINGER_SIZE;
			search.setParams(Lang.textSearch+"...", Input.MODE_INPUT);
			//search.setMode(Input.MODE_INPUT);
			//search.setLabelText('Search country...');			
			search.S_CHANGED.add(onChanged);
			_view.addChild(search.view);
			
			list = new List("PhonePicker");
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
		private function onCloseBtnClick():void 
		{
			DialogManager.closeDialog();
		}
		
		private function onChanged():void {
			var value:String = search.value.toLowerCase();
			doSearch(value);
		}
		
		private function doSearch(value:String = ""):void {
			if (list == null)
				return;

			list.setData(PhonebookManager.filterBy(cData, value, ["name", "phone"]), ListPhonebook);
			for (var i:int = 0; i < data.length; i++) {
				//if (data[i][0].indexOf(value) == 0) {
				//	list.navigateToItem(i);
				//	return;
				//}
			}
		}
		
		override public function initScreen(data:Object = null):void{
			super.initScreen(data);
			_params.title = 'Select contact';
			
			var oldDelimiter:String = "";
			var newDelimiter:String = "";
			cData = PhonebookManager.getMyPhones(false);
			list.setData(cData, ListPhonebook);
		}
		
		override public function activateScreen():void{
			super.activateScreen();
			search.activate();
			list.activate();
			list.S_ITEM_TAP.add(onItemTap);
			if (closeBtn != null) {
				closeBtn.activate();
			}
			
		}
		
		private function onItemTap(dataObject:Object, n:int):void {
			//if (dataObject.length == 2)
				//return;
			if (_data && _data.onPhoneSelected != null) {
				_data.onPhoneSelected("+" + dataObject.phone);
			}
			DialogManager.closeDialog();
		}
		
		override protected function drawView():void {
			if (_height < minHeight)_height = minHeight;
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
			topIBD = ImageManager.drawTextFieldToGraphic(topBox.graphics, Config.DOUBLE_MARGIN, Config.MARGIN * 2.5, Lang.selectPhone, _width - Config.DOUBLE_MARGIN, tf);
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
			cData = null;

		}
	}

}