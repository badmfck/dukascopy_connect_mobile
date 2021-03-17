package com.dukascopy.connect.screens.dialogs.newDialogs {
	
	import assets.SettingsMaskIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.components.selector.MultiSelector;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.screens.dialogs.DatingRegistrationPopup;
	import com.dukascopy.connect.sys.categories.CategoryManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayConfig;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * Класс полностью завершен! Не трогать без спроса!!!
	 * @author Ilya Shcherbakov. Telefision Team RIGA.
	 */
	
	public class ScreenCategoriesPopup extends DialogBaseScreen {
		
		private const BTN_ICON_LEFT_SIZE:int = Config.FINGER_SIZE * 0.36;
		private const OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE *.8;
		
		static private var indexGeneral:int = -1;
		
		private var labelCategories:Bitmap;
		private var selectorCategories:MultiSelector;
		private var btnAnonim:OptionSwitcher;
		private var tfDisclaimer:TextField;
		
		private var btnOk:RoundedButton;
		private var btnCancel:RoundedButton;
		
		private var categoriesReady:Boolean = false;
		private var inputWidth:int;
		
		private var selectedItems:Vector.<SelectorItemData>;
		
		private var preloader:Preloader;
		private var onOKFunction:Function;
		private var fromFilter:Boolean = false;
		
		public function ScreenCategoriesPopup() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			labelCategories = new Bitmap();
			scrollPanel.addObject(labelCategories);
			
			selectorCategories = new MultiSelector();
			selectorCategories.gap = Config.FINGER_SIZE * .15;
			selectorCategories.S_ON_SELECT.add(onCategoriesSelect);
			scrollPanel.addObject(selectorCategories);
			
			btnCancel = new RoundedButton(Lang.textCancel.toUpperCase(), MainColors.BLUE_LIGHT, MainColors.BLUE_MEDIUM, null);
			btnCancel.setStandartButtonParams();
			btnCancel.setDownScale(1);
			btnCancel.cancelOnVerticalMovement = true;
			btnCancel.tapCallback = onCloseTap;
			btnCancel.hide();
			btnCancel.draw();
			container.addChild(btnCancel);
			
			btnOk = new RoundedButton(Lang.textOk.toUpperCase(), MainColors.RED, MainColors.RED_DARK, null);
			btnOk.setStandartButtonParams();
			btnOk.setDownScale(1);
			btnOk.cancelOnVerticalMovement = true;
			btnOk.tapCallback = onOK;
			btnOk.setSizeLimits(btnCancel.width, btnCancel.width);
			btnOk.hide();
			btnOk.draw();
			container.addChild(btnOk);
		}
		
		private function onCategoriesSelect(sid:SelectorItemData):void {
			selectedItems = selectorCategories.getSelectedDataVector();
			var datingFound:Boolean = false;
			if (selectedItems.length == 0) {
				if (fromFilter == false) {
					var val:Vector.<int> = new Vector.<int>();
					val.push(indexGeneral);
					selectorCategories.selectedIndexes = val;
					selectedItems = selectorCategories.getSelectedDataVector();
				}
				hideDisclaimer();
				return;
			} else {
				var l:int;
				var i:int;
				if (fromFilter == true) {
					l = selectedItems.length;
					for (i = 0; i < l; i++) {
						if (selectedItems[i].data.id == Config.CAT_DATING) {
							datingFound = true;
							break;
						}
					}
					if (sid == null) {
						if (datingFound == false)
							hideDisclaimer();
					} else if (datingFound == true && fromFilter == false) {
						selectorCategories.selectLastOnly();
						selectedItems = selectorCategories.getSelectedDataVector();
						if (sid.data.id != Config.CAT_DATING)
							hideDisclaimer();
					}
				} else {
					selectorCategories.selectLastOnly();
					selectedItems = selectorCategories.getSelectedDataVector();
					l = selectedItems.length;
					for (i = 0; i < l; i++) {
						if (selectedItems[i].data.id == Config.CAT_DATING) {
							datingFound = true;
							break;
						}
					}
					if (datingFound == false)
						hideDisclaimer();
				}
			}
			if (sid != null && sid.data.id == Config.CAT_DATING) {
				if (preloader == null) {
					preloader = new Preloader();
					preloader.visible = false;
					preloader.hide();
					preloader.x = _width * .5;
					preloader.y = _height * .5;
					view.addChild(preloader);
				}
				deactivateScreen();
				preloader.show();
				PayManager.S_ACCOUNT_EXISTS.add(onPayAccountChecked);
				PayManager.checkUserStatus();
			}
		}
		
		private function onPayAccountChecked(error:Boolean, val:int):void {
			if (preloader != null)
				preloader.hide();
			activateScreen();
			PayManager.S_ACCOUNT_EXISTS.remove(onPayAccountChecked);
			if (error == true) {
				ToastMessage.display(Lang.textConnectionError);
				removeDatingFromSelected();
				return;
			}
			if (val == 1) {
				preShowDisclaimer();
				return;
			}
			onCloseTap();
			DialogManager.showDialog(DatingRegistrationPopup, {callback:createPaymentsAccount});
		//	DialogManager.alert(Lang.information, Lang.featureNoPaments, createPaymentsAccount, Lang.registrate, Lang.textCancel);
		}
		
		public function preShowDisclaimer():void {
			deactivateScreen();
			if (preloader != null)
				preloader.show();
			CategoryManager.getNeedDisclaimer(onNeedDisclaimerLoaded);
		}
		
		private function onNeedDisclaimerLoaded(data:Object, err:Boolean):void {
			if (_isDisposed == true)
				return;
			if (fromFilter == false)
				showAnanim(data == true);
			if (err == true) {
				showDisclaimer();
				return;
			}
			if (data == true) {
				CategoryManager.setNeedDisclaimer();
				if (preloader != null)
					preloader.hide();
				activateScreen();
				return;
			}
			showDisclaimer();
		}
		
		private function showAnanim(needRedraw:Boolean = false):void {
			//return;
			if (btnAnonim == null) {
				btnAnonim = new OptionSwitcher();
				btnAnonim.create(componentsWidth - scrollPanel.getScrollBarWidth() - Config.MARGIN, OPTION_LINE_HEIGHT, null, Lang.textIncognito, QuestionsManager.getQuestionSecretMode(), false, -1, NaN, 0);
				btnAnonim.onSwitchCallback = onAnonimTap;
				btnAnonim.y = selectorCategories.y + selectorCategories.height + Config.MARGIN;
				btnAnonim.x = componentsWidth - scrollPanel.getScrollBarWidth() - Config.MARGIN - btnAnonim.trueWidth;
			}
			scrollPanel.addObject(btnAnonim);
			if (needRedraw == true)
				drawView();
		}
		
		private function hideAnanim(needRedraw:Boolean = false):void {
			if (btnAnonim != null && btnAnonim.parent != null)
				scrollPanel.removeObject(btnAnonim);
			if (needRedraw == true)
				drawView();
		}
		
		public function showDisclaimer():void {
			if (preloader != null)
				preloader.hide();
			activateScreen();
			createDisclaimerTF();
		}
		
		private function createDisclaimerTF():void {
			if (tfDisclaimer != null) {
				if (tfDisclaimer.parent == null)
					addDisclaimerTF();
				return;
			}
			var tFormat:TextFormat = new TextFormat();
			tFormat.font = Config.defaultFontName;
			tFormat.size = Config.FINGER_SIZE * .3;
			tFormat.color = MainColors.DARK_BLUE;
			
			tfDisclaimer = new TextField();
			tfDisclaimer.defaultTextFormat = tFormat;
			tfDisclaimer.text = Lang.categoryDatingDisclaimer;
			tfDisclaimer.cacheAsBitmap = true;
			tfDisclaimer.multiline = true;
			tfDisclaimer.wordWrap = true;
			tfDisclaimer.selectable = false;
			if (btnAnonim == null)
				tfDisclaimer.y = selectorCategories.y + selectorCategories.height + Config.DOUBLE_MARGIN;
			else
				tfDisclaimer.y = btnAnonim.y + btnAnonim.height + Config.DOUBLE_MARGIN;
			tfDisclaimer.width = componentsWidth - scrollPanel.getScrollBarWidth() - Config.MARGIN;
			tfDisclaimer.height = tfDisclaimer.textHeight + 4;
			addDisclaimerTF();
		}
		
		private function addDisclaimerTF():void {
			scrollPanel.addObject(tfDisclaimer);
			drawView();
			btnOk.setValue(Lang.iAgree.toUpperCase());
		}
		
		private function hideDisclaimer():void {
			hideAnanim();
			var needToRemoveDisclaimer:Boolean = true;
			if (tfDisclaimer == null || tfDisclaimer.parent == null)
				needToRemoveDisclaimer = false;
			hideAnanim(!needToRemoveDisclaimer);
			if (needToRemoveDisclaimer == false)
				return;
			scrollPanel.removeObject(tfDisclaimer);
			drawView();
			btnOk.setValue(Lang.textOk.toUpperCase());
		}
		
		private function removeDatingFromSelected():void {
			if (selectedItems == null || selectedItems.length == 0)
				return;
			var i:int;
			for (i = 0; i < selectedItems.length; i++) {
				if (selectedItems[i].data.id == Config.CAT_DATING) {
					selectedItems.splice(i, 1);
					break;
				}
			}
			var indexes:Vector.<int> = new Vector.<int>();
			var vector:Vector.<SelectorItemData> = QuestionsManager.getQuestionCategories();
			if (vector != null && vector.length != 0) {
				var l:int = CategoryManager.getCategoriesArrayFiltered().length;
				for (i = 0; i < l; i++) {
					if (vector.indexOf(CategoryManager.getCategoriesArrayFiltered()[i]) != -1)
						indexes.push(i);
				}
			}
			selectorCategories.selectedIndexes = indexes;
		}
		
		private function createPaymentsAccount(val:int):void {
			if (val != 1)
				return;			
			MobileGui.showRoadMap();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			onOKFunction = data.onOKFunction;
			fromFilter = data.fromFilter;
			
			if (labelCategories.bitmapData == null)
				labelCategories.bitmapData = createLabel(Lang.selectCategories);
			
			selectorCategories.maxWidth = componentsWidth;
			selectorCategories.y = int(labelCategories.height + Config.MARGIN);
			
			CategoryManager.S_CATEGORIES_LOADED.add(onCategoriesLoaded);
			CategoryManager.loadAllCategories();
			
			btnCancel.x = _width * .5 - btnCancel.width - Config.MARGIN;
			btnOk.x = _width * .5 + Config.MARGIN;
		}
		
		private function onCategoriesLoaded():void {
			categoriesReady = true;
			selectorCategories.dataProvider = CategoryManager.getCategoriesArrayFiltered();
			
			var indexes:Vector.<int> = new Vector.<int>();
			var l:int = selectorCategories.dataProvider.length;
			var i:int;
			
			if (indexGeneral == -1) {
				for (i = 0; i < l; i++) {
					if (selectorCategories.dataProvider[i].data.id == Config.CAT_GENERAL) {
						indexGeneral = i;
						break;
					}
				}
			}
			
			if (fromFilter == true) {
				var arr:Array = QuestionsManager.getCategoriesFilter();
				if (arr != null && arr.length != 0) {
					for (i = 0; i < l; i++) {
						if (arr.indexOf(CategoryManager.getCategoriesArrayFiltered()[i].data.id) != -1)
							indexes.push(i);
					}
				}
			} else {
				var vector:Vector.<SelectorItemData> = QuestionsManager.getQuestionCategories();
				var index:int;
				if (vector != null && vector.length != 0) {
					for (i = 0; i < l; i++) {
						index = vector.indexOf(CategoryManager.getCategoriesArrayFiltered()[i]);
						if (index != -1) {
							if (vector[index].data.id == Config.CAT_DATING)
								showAnanim(true);
							indexes.push(i);
						}
					}
				}
			}
			if (fromFilter == false && indexes.length == 0)
				indexes.push(indexGeneral);
			selectorCategories.selectedIndexes = indexes;
			selectedItems = selectorCategories.getSelectedDataVector();
			if (_isActivated)
				selectorCategories.activate();
			drawView();
			scrollPanel.update();
		}
		
		override protected function drawView():void {
			super.drawView();
			
			btnCancel.y = scrollPanel.view.y + scrollPanel.height + Config.DOUBLE_MARGIN;
			btnOk.y = btnCancel.y;
			
			scrollPanel.update();
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
			return _height - scrollPanel.view.y - Config.DOUBLE_MARGIN * 2 - btnOk.height;
		}
		
		override protected function calculateBGHeight():int {
			return scrollPanel.view.y + scrollPanel.height + Config.DOUBLE_MARGIN * 2 + btnOk.height;
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			if (categoriesReady == true && selectorCategories != null) {
				selectorCategories.alpha = 1;
				selectorCategories.activate();
			}
			if (btnCancel != null) {
				if (btnCancel.getIsShown() == false)
					btnCancel.show(.3, 0, true, 0.9, 0);
				btnCancel.activate();
				btnCancel.alpha = 1;
			}
			if (btnOk != null) {
				if (btnOk.getIsShown() == false)
					btnOk.show(.3, .15, true, 0.9, 0);
				btnOk.activate();
				btnOk.alpha = 1;
			}
			if (btnAnonim != null)
				btnAnonim.activate();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			if (selectorCategories != null) {
				selectorCategories.deactivate();
				selectorCategories.alpha = .7;
			}
			if (btnCancel != null) {
				btnCancel.deactivate();
				btnCancel.alpha = .7;
			}
			if (btnOk != null) {
				btnOk.deactivate();
				btnOk.alpha = .7;
			}
			if (btnAnonim != null)
				btnAnonim.deactivate();
		}
		
		static private function onAnonimTap(value:Boolean):void {
			echo("ScreenCategoriesPopup", "onAnonimTap");
		}
		
		private function onOK():void {
			if (onOKFunction != null) {
				if (fromFilter == true)
					onOKFunction(selectedItems);
				else if (btnAnonim != null)
					onOKFunction(selectedItems, btnAnonim.isSelected);
				else
					onOKFunction(selectedItems);
			}
			if (tfDisclaimer != null && tfDisclaimer.parent != null) {
				CategoryManager.setNeedDisclaimer();
			}
			onCloseTap();
		}
		
		override public function dispose():void {
			super.dispose();
			if (btnCancel != null)
				btnCancel.dispose();
			btnCancel = null;
			if (btnOk != null)
				btnOk.dispose();
			btnOk = null;
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			if (selectorCategories != null)
				selectorCategories.dispose();
			selectorCategories = null;
			if (tfDisclaimer != null)
				tfDisclaimer.text = "";
			tfDisclaimer = null;
			if (btnAnonim != null) {
				if (btnAnonim.parent != null)
					btnAnonim.parent.removeChild(btnAnonim);
				btnAnonim.dispose();
			}
			
			if (labelCategories != null)
			{
				UI.destroy(labelCategories);
				labelCategories = null;
			}
			
			btnAnonim = null;
			
			PayManager.S_ACCOUNT_EXISTS.remove(onPayAccountChecked);
			CategoryManager.S_CATEGORIES_LOADED.remove(onCategoriesLoaded);
			onOKFunction = null;
		}
	}
}