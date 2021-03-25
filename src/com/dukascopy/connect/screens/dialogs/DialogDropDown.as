package com.dukascopy.connect.screens.dialogs {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListDropdown;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class DialogDropDown extends BaseScreen {
		private var topBox:Sprite;
		private var closeBtn:BitmapButton;
		private var list:List;
		
		private var textFormat:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE_DOT_25, 0xFFFFFF, true);
		private var topIBD:ImageBitmapData;
		private var callBack:Function=null;
		
		public function DialogDropDown() {
			
		}
		
		override protected function createView():void {
			super.createView();
			topBox = new Sprite();
			_view.addChild(topBox);
			
			closeBtn = new  BitmapButton();
			closeBtn.setBitmapData(UI.getIconByFrame(20, Config.FINGER_SIZE, Config.FINGER_SIZE));
			_view.addChild(closeBtn);
			closeBtn.show();
			closeBtn.tapCallback = onCloseBtnClick;
			
			list = new List("DropDown");
			list.setMask(true);
			list.view.y = Config.FINGER_SIZE;
			_view.addChild(list.view);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			list.activate();
			list.S_ITEM_TAP.add(onItemTap);
			if (closeBtn != null)
				closeBtn.activate();
		}
		
		private function onItemTap(data:Object, num:int):void {
			if (callBack != null)
				callBack(data);
			DialogManager.closeDialog();
		}
		
		private function onCloseBtnClick():void {
			DialogManager.closeDialog();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			callBack = null;
			if("callBack" in data)
				callBack  = data.callBack;
			
			if("title" in data)
				_params.title  = data.title;
			
			var items:Array = null;
			if("items" in data)
				items = data.items;
			
			var itemClass:Class = ListDropdown;
			if("itemClass" in data)
				itemClass = data.itemClass;
			
			var fieldLinkNames:Array = null; 
			if("fieldLinkNames" in data)
				fieldLinkNames = data.fieldLinkNames;
				
			var side:String = null;
			if("side" in data)
				side = data.side;
				
			if(items!=null)
				list.setData(items, itemClass, fieldLinkNames, side);
		}
		
		override protected function drawView():void {
			
			view.graphics.clear();
			view.graphics.beginFill(0xF5F5f5);
			view.graphics.drawRoundRect(0, 0, _width, _height, Config.DOUBLE_MARGIN, Config.DOUBLE_MARGIN);
			view.graphics.endFill();
			
			topBox.graphics.clear();
			topBox.graphics.beginFill(AppTheme.RED_MEDIUM);
			topBox.graphics.drawRoundRectComplex(0, 0, _width, Config.FINGER_SIZE, Config.MARGIN, Config.MARGIN, 0, 0);
			topBox.graphics.endFill();
			
			list.setWidthAndHeight(_width, _height - Config.FINGER_SIZE);
			
			closeBtn.x = _width - Config.FINGER_SIZE;
			
			
			if (topIBD != null && topIBD.isDisposed == false)
				topIBD.dispose();
			topIBD = null;
			topIBD = ImageManager.drawTextFieldToGraphic(topBox.graphics, Config.DOUBLE_MARGIN, Config.MARGIN * 2.5, _params.title, _width - Config.DOUBLE_MARGIN, textFormat);
			
		}
		
		override public function dispose():void {
			super.dispose();
			if(topBox!=null)
				topBox.graphics.clear();
			topBox=null;
			if (closeBtn != null)
				closeBtn.dispose();
			closeBtn = null;
			
			if (list != null)
				list.dispose();
			list = null;
		
			textFormat = null;
			if (topIBD != null)
				topIBD.dispose();
			topIBD = null;
			callBack=null;
		}
		
	}

}