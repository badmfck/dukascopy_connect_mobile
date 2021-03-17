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
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author aleksei.leschenko
	 */
	
	public class ScreenPayMyCardDialog extends ScreenPayDialog{

		private var btnAddNewCard:BitmapButton;
		public static const TYPE_ADD_NEW_CARD:String = "ADD_NEW_CARD";
		public function ScreenPayMyCardDialog() { }
		
		override protected function createView():void {
			super.createView();
			btnAddNewCard = new BitmapButton();
			btnAddNewCard.setStandartButtonParams();
			btnAddNewCard.usePreventOnDown = false;
			btnAddNewCard.cancelOnVerticalMovement = true;
			btnAddNewCard.tapCallback = onAddNewCard;
			btnAddNewCard.x = Config.DOUBLE_MARGIN;
			btnAddNewCard.show();

			_view.addChildAt(btnAddNewCard,_view.numChildren-1);


		}

		private function onAddNewCard():void {
			DialogManager.closeDialog();
			doCallBack({type:TYPE_ADD_NEW_CARD});
		}


		override public function deactivateScreen():void {
			super.deactivateScreen();
			btnAddNewCard.deactivate();
		}

		override public function activateScreen():void{
			super.activateScreen();
			btnAddNewCard.activate();

		}
		
		override protected function drawView():void {
			super.drawView();
			var bitmapPlane3:BitmapData = UI.renderButton(Lang.BTN_ADD_NEW_CARD, _width - Config.DOUBLE_MARGIN * 2, Config.FINGER_SIZE, 0xffffff, AppTheme.GREEN_MEDIUM, AppTheme.GREEN_DARK, AppTheme.BUTTON_CORNER_RADIUS);
			btnAddNewCard.setBitmapData(bitmapPlane3, true);
			btnAddNewCard.setOverflow(10, Config.FINGER_SIZE, Config.FINGER_SIZE, 10);
			
			var trueHeight:int = list.height + btnAddNewCard.height + Config.FINGER_SIZE ;
			var trueY:int = int((_height - trueHeight) * .5);
			
			view.graphics.clear();
			view.graphics.beginFill(0xF5F5f5);
			view.graphics.drawRect(0, trueY, _width, trueHeight + Config.DOUBLE_MARGIN*2);
			//view.graphics.drawRoundRect(0, trueY, _width, list.height + Config.FINGER_SIZE, Config.DOUBLE_MARGIN, Config.DOUBLE_MARGIN);
			view.graphics.endFill();

			topBox.y = trueY;
			list.view.y = trueY + Config.FINGER_SIZE;
			list.tapperInstance.setBounds();
			btnAddNewCard.y = list.view.y + list.height + Config.DOUBLE_MARGIN;


			closeBtn.x = _width - closeBtn.width-closeBtn.LEFT_OVERFLOW;
			closeBtn.y = trueY+ (Config.FINGER_SIZE - closeBtn.height)*.5 ;
		}
		
		override public function dispose():void{
			super.dispose();
			if (btnAddNewCard != null)
				btnAddNewCard.dispose();
			btnAddNewCard = null;
		}
	}
}