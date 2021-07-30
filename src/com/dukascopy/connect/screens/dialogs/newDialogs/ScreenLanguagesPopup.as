package com.dukascopy.connect.screens.dialogs.newDialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.components.selector.MultiSelector;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.categories.CategoryManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * Класс полностью завершен! Не трогать без спроса!!!
	 * @author Ilya Shcherbakov. Telefision Team RIGA.
	 */
	
	public class ScreenLanguagesPopup extends DialogBaseScreen {
		
		private var labelCategories:Bitmap;
		private var selectorCategories:MultiSelector;
		
		private var btnOk:BitmapButton;
		private var btnCancel:BitmapButton;
		
		private var categoriesReady:Boolean = false;
		private var inputWidth:int;
		
		private var selectedItems:Vector.<SelectorItemData>;
		
		public function ScreenLanguagesPopup() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			labelCategories = new Bitmap();
			labelCategories.x = hPadding;
			scrollPanel.addObject(labelCategories);
			
			selectorCategories = new MultiSelector();
			selectorCategories.x = hPadding;
			selectorCategories.gap = Config.FINGER_SIZE * .15;
			selectorCategories.S_ON_SELECT.add(onCategoriesSelect);
			scrollPanel.addObject(selectorCategories);
			
			btnCancel = new BitmapButton();
			btnCancel.setStandartButtonParams();
			btnCancel.cancelOnVerticalMovement = true;
			btnCancel.setDownScale(1);
			btnCancel.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			btnCancel.setDownColor(0);
			btnCancel.tapCallback = onCloseTap;
			btnCancel.disposeBitmapOnDestroy = true;
			btnCancel.hide();
			container.addChild(btnCancel);
			
			btnOk = new BitmapButton();
			btnOk.setStandartButtonParams();
			btnOk.cancelOnVerticalMovement = true;
			btnOk.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			btnOk.setDownScale(1);
			btnOk.setDownColor(0);
			btnOk.hide();
			btnOk.tapCallback = onOK;
			btnOk.disposeBitmapOnDestroy = true;
			container.addChild(btnOk);
		}
		
		private function onCategoriesSelect(sid:SelectorItemData):void {
			selectedItems = selectorCategories.getSelectedDataVector();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			categoriesReady = CategoryManager.getCategoriesLoaded();
			onCategoriesLoaded();
			
			if (labelCategories.bitmapData == null)
				labelCategories.bitmapData = createLabel(Lang.selectCategories);
			
			selectorCategories.maxWidth = componentsWidth;
			selectorCategories.y = int(labelCategories.height + Config.MARGIN);
			
			var buttonWidth:int = (_width - hPadding * 2 - Config.MARGIN * 2) * .5;
			
			var textSettings_ok:TextFieldSettings = new TextFieldSettings(Lang.textOk.toUpperCase(), 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap_ok:ImageBitmapData = TextUtils.createbutton(textSettings_ok, Color.GREEN, 1, -1, NaN, buttonWidth);
			btnOk.setBitmapData(buttonBitmap_ok, true);
			
			var textSettings_cancel:TextFieldSettings = new TextFieldSettings(Lang.textCancel, 0x5D6A77, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap_cancel:ImageBitmapData = TextUtils.createbutton(textSettings_cancel, 0x6B7A8A, 0, -1, 0x999999, buttonWidth);
			btnCancel.setBitmapData(buttonBitmap_cancel, true);
			
			btnCancel.x = _width * .5 - btnCancel.width - Config.MARGIN;
			btnOk.x = _width * .5 + Config.MARGIN;
			
			selectedItems = null;// QuestionsManager.getQuestionLanguages();
		}
		
		private function onCategoriesLoaded():void {
			selectorCategories.dataProvider = CategoryManager.getLanguagesArrayFiltered();
			
			var indexes:Vector.<int> = new Vector.<int>();
			var vector:Vector.<SelectorItemData> = null;//QuestionsManager.getQuestionLanguages();
			if (vector != null && vector.length != 0) {
				var l:int = CategoryManager.getLanguagesArrayFiltered().length;
				for (var i:int = 0; i < l; i++) {
					if (vector.indexOf(CategoryManager.getLanguagesArrayFiltered()[i]) != -1)
						indexes.push(i);
				}
			}
			selectorCategories.selectedIndexes = indexes;
			
			if (_isActivated) {
				selectorCategories.activate();
			}
			drawView();
			scrollPanel.update();
		}
		
		override protected function drawView():void {
			super.drawView();
			
			btnCancel.y = scrollPanel.view.y + scrollPanel.height + vPadding;
			btnOk.y = btnCancel.y;
		}
		
		private function createLabel(val:String):ImageBitmapData {
			var ibmd:ImageBitmapData = UI.renderTextShadowed(
				val,
				inputWidth,
				Config.FINGER_SIZE,
				false,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .23,
				false,
				0xFFFFFF,
				0x000000,
				AppTheme.GREY_MEDIUM,
				true,
				1,
				false
			);
			return ibmd;
		}
		
		override protected function getMaxContentHeight():int {
			return _height - scrollPanel.view.y - vPadding * 2 - btnOk.height;
		}
		
		override protected function calculateBGHeight():int {
			return scrollPanel.view.y + scrollPanel.height + vPadding * 2 + btnOk.height;
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			selectorCategories.activate();
			if (btnCancel.getIsShown() == false)
				btnCancel.show(.3, 0, true, 0.9, 0);
			if (btnOk.getIsShown() == false)
				btnOk.show(.3, .15, true, 0.9, 0);
			btnCancel.activate();
			btnOk.activate();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			if (selectorCategories != null)
				selectorCategories.deactivate();
		}
		
		private function onOK():void {
			//QuestionsManager.saveLanguages(selectedItems);
			onCloseTap();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (btnOk != null)
				btnOk.dispose();
			btnOk = null;
			if (btnCancel != null)
				btnCancel.dispose();
			btnCancel = null;
			
			if (selectorCategories != null)
				selectorCategories.dispose();
			selectorCategories = null;
			
			if (labelCategories != null)
				UI.destroy(labelCategories);
			labelCategories = null;
			
			selectedItems = null;
			
			Overlay.removeCurrent();
		}
	}
}