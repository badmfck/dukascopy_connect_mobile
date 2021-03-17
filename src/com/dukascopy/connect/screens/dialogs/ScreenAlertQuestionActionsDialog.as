package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.chat.BubbleButton;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ScreenAlertQuestionActionsDialog extends ScreenAlertDialog {
		
		private var stopButton:BitmapButton;
		private var infoButton:BitmapButton;
		private var tipsButton:BitmapButton;
		
		public function ScreenAlertQuestionActionsDialog() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			infoButton.setBitmapData(TextUtils.createTextFieldData("<u>" + Lang.moreAboutRules + "</u>",_width - padding*2, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE*.3, true, 0x0000ff, 0xffffff, true, true), true);
			tipsButton.setBitmapData(TextUtils.createTextFieldData("<u>" + "Tips" + "</u>",_width - padding*2, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE*.3, true, 0x0000ff, 0xffffff, true, true), true);
		}
		
		override protected function drawView():void {
			headerHeight = Config.FINGER_SIZE * .85;
			
			positionDrawing = 0;
			
			// TITLE
			
			if (titleBitmap.bitmapData) {
				UI.disposeBMD(titleBitmap.bitmapData);
				titleBitmap.bitmapData = null;
			}
			
			headerLine.graphics.clear();
			
			var isMutiline:Boolean = false;
			//!TODO: rewrite data to new Screen type and remove this strange checking in all screens;
			if ("showFullTitle" in data && Boolean(data.showFullTitle) == true) {
				isMutiline = true;
			}
			
			if (data.title && data.title != "") {
				titleBitmap.bitmapData = TextUtils.createTextFieldData(data.title, 
																		_width - padding * 2 - Config.MARGIN - buttonClose.width, 
																		1,
																		isMutiline, 
																		TextFormatAlign.LEFT,
																		TextFieldAutoSize.NONE,
																		Config.FINGER_SIZE * 0.32,
																		isMutiline,
																		MainColors.DARK_BLUE,
																		MainColors.WHITE,
																		true, false, true);
				titleBitmap.x  = padding;
				
				if (isMutiline) {
					headerHeight = Config.FINGER_SIZE * 0.56 + titleBitmap.height;
					titleBitmap.y = Config.FINGER_SIZE * 0.28;
				} else {
					titleBitmap.y  = int(headerHeight*.5 - titleBitmap.height*.5) + 1;
				}
				
				//positionDrawing += headerHeight + stopButton.height + Config.MARGIN*3; // NOTE: stopButton.height befoere deactivate is 0 and then 23px so it causes visual bug, so dont count it when calculating height
				positionDrawing += headerHeight+ Config.MARGIN*3;
				
				headerLine.graphics.lineStyle(1, MainColors.GREY);
				headerLine.graphics.moveTo(0, 0);
				headerLine.graphics.lineTo(_width - padding * 2, 0);
				headerLine.x = padding;
				headerLine.y = positionDrawing;
				positionDrawing += headerLine.height;
			} else {
				headerHeight = buttonClose.y + buttonClose.height;
				positionDrawing += headerHeight;
			}
			
			contentHeight = (data.title && data.title != "")?
									(padding * 3 + titleBitmap.height):
									(Config.MARGIN * 2.4 + buttonClose.height + padding * 1);
									
									
									
			stopButton.setBitmapData(TextUtils.createTextFieldData("<u>" + Lang.stopChat + "</u>",_width - padding*2, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE*.3, true, 0x0000ff, 0xffffff, true, true), true);
			
			contentHeight += stopButton.height + Config.MARGIN*3;
			
			currentLayout = BUTTONS_NO_LAYOUT;
			resizeButtons(currentLayout);
			
			updateButtonsAreaHeight();
			
			content.view.y = positionDrawing + padding;
			content.view.x = padding;
			
			recreateContent(padding);
			
			var maxContentHeight:int = getMaxContentHeight();
			
			realContentHeight = Math.min(content.itemsHeight + 1, maxContentHeight);
			
			content.setWidthAndHeight(_width - padding * 2, realContentHeight, false);
			
			updateContentHeight();
			
			updateBack();
			updateScrollArea();
			contentBottomPadding = padding;
			repositionButtons();
			
			stopButton.x = padding;
			stopButton.y = container.y + content.view.y + realContentHeight + contentBottomPadding + buttonsAreaHeight + padding;
		
			tipsButton.x = _width - padding-tipsButton.width;
			tipsButton.y = stopButton.y;
				
			infoButton.x = titleBitmap.x;			
			infoButton.y = container.y + titleBitmap.y + titleBitmap.height + Config.MARGIN * 1.3;
			
		}
		
		override protected function createView():void {
			super.createView();
			
			stopButton = new BitmapButton();
			stopButton.setStandartButtonParams();
			stopButton.setDownScale(1);
			stopButton.setDownColor(0xFFFFFF);
			stopButton.tapCallback = onStopButtonClick;
			stopButton.disposeBitmapOnDestroy = true;
			stopButton.show();
			_view.addChild(stopButton);
			stopButton.setOverflow(padding, padding, padding, padding);
			
			infoButton = new BitmapButton();
			infoButton.setStandartButtonParams();
			infoButton.setDownScale(1);
			infoButton.setDownColor(0xFFFFFF);
			infoButton.tapCallback = onInfoButtonClick;
			infoButton.disposeBitmapOnDestroy = true;
			infoButton.show();
			_view.addChild(infoButton);
			infoButton.setOverflow(padding, padding, padding, padding);
			
			tipsButton = new BitmapButton();
			tipsButton.setStandartButtonParams();
			tipsButton.setDownScale(1);
			tipsButton.setDownColor(0xFFFFFF);
			tipsButton.tapCallback = onTipsButtonClick;
			tipsButton.disposeBitmapOnDestroy = true;
			tipsButton.show();
			_view.addChild(tipsButton);
			tipsButton.setOverflow(padding, padding, padding, padding);
		}
		
		private function onInfoButtonClick():void {
			navigateToURL(new URLRequest("http://dukascopy.com"));
		}	
		
		private function onTipsButtonClick():void {
			fireCallbackFunctionWithValue(4);
			DialogManager.closeDialog();
		}
		
		override public function dispose():void {
			super.dispose();
			if (stopButton) {
				stopButton.dispose();
				stopButton = null;
			}
			if (infoButton) {
				infoButton.dispose();
				infoButton = null;
			}
			
			if (tipsButton) {
				tipsButton.dispose();
				tipsButton = null;
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (stopButton)
				stopButton.activate();
			if (infoButton)
				infoButton.activate();
			if (tipsButton)
				tipsButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (stopButton)
				stopButton.deactivate();
			if (infoButton)
				infoButton.deactivate();
			if (tipsButton)
				tipsButton.deactivate();
		}
		
		override protected function updateContentHeight():void {
			contentHeight = (padding * 3 + headerHeight + buttonsAreaHeight + content.itemsHeight + stopButton.height + padding * 2);
		}
		
		private function onStopButtonClick():void {
			fireCallbackFunctionWithValue(3);
		}
	}
}