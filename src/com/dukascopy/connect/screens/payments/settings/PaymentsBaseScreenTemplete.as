/**
 * Created by aleksei.leschenko on 28.03.2017.
 */
package com.dukascopy.connect.screens.payments.settings {


	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.components.groupList.item.vo.VOItemGL;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.theme.AppTheme;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;

	public class PaymentsBaseScreenTemplete extends PaymentsBaseScreen {


		public function PaymentsBaseScreenTemplete() {
			super();
		}
		override public function initScreen(data:Object = null):void {
			resetTitleText();

			super.initScreen(data);
		}

		override protected function createView():void {
			super.createView();
			//
		}
		override protected function createIcon():void {
			var HELP_SETT:BitmapData = createIconByMCandName(new SWFSettingsIcon_notification(), "PaymentsSettingsScreen.HELP_BMD", true, AppTheme.RED_MEDIUM);
			iconTitle = new Bitmap(HELP_SETT);

			iconTitle.x = _width - Config.DOUBLE_MARGIN;
			iconTitle.y = titleBitmap.y;
			boxTop.addChild(iconTitle);

			/*settingsButton.hide();
			 settingsButton.show(.3);
			 settingsButton.activate();*/
		}

		override protected function addScrollPanel():void {
			// Add scroll panel
			super.addScrollPanel();
			_view.addChild(scrollPanel.view);
		}

		private function callbackItemGroupList(vo:VOItemGL):void {
			if(vo==null)
			{
				//error func logic
				return;
			}

		}

		private function createIconByMCandName(mc:Sprite, nameIcon:String, isBlock = false, color:uint = 0xFFFFFF):BitmapData {
			var topBarBtnSize:Number = Config.FINGER_SIZE * .4;
			if (isBlock) {
				var myColorTransform:ColorTransform = new ColorTransform();
				myColorTransform.color = color /**/;
				mc.transform.colorTransform = myColorTransform;
			}
			return UI.renderAsset(mc, topBarBtnSize, topBarBtnSize, true, nameIcon);
		}

		override public function setWidthAndHeight(width:int, height:int):void {
			//
			super.setWidthAndHeight(width,height);
		}

		override protected function drawView():void {
			if(iconTitle){
				iconTitle.x = _width - Config.DOUBLE_MARGIN;
				iconTitle.y = titleBitmap.y;
			}
			//
			super.drawView();
		}

		override public function drawViewLang():void {
			resetTitleText();
			super.drawViewLang();
		}

		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;
			//your code
			//
		}

		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			//your code
			//
		}

		override public function clearView():void {
			super.clearView();
		}

		override public function dispose():void {
			super.dispose();
			//your code

		}

		override public function onBack(e:Event = null):void {
			super.onBack(e);
			//
		}

		override protected function resetTitleText():void {
			txtTitle = "";
		}
		// WEB VIEW METHODS ==============================================================================
		// ===============================================================================================

		override protected function showWebView(url:String, isMyCard:Boolean = false):void {
			super.showWebView(url,isMyCard);
		}
	}
}
