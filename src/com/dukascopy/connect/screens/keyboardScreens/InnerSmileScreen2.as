package com.dukascopy.connect.screens.keyboardScreens {
	
	import assets.IconSmileGroupBackspace;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.chatInput.ChatInputAndroid;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListItemSmiles;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.richTextField.RichTextSmilesCodes;
	import com.dukascopy.connect.sys.style.Style;
	import flash.display.Shape;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class InnerSmileScreen2 extends BaseScreen {
		
		private var btn:BitmapButton;
		private var list:List;
		
		private var bg:Shape;
		
		private var colCount:int;
		private var needToUpdate:Boolean = false;
		
		public function InnerSmileScreen2() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			needToUpdate = true;
			_params.title = 'Smiles';
			_params.doDisposeAfterClose = false;
		}
		
		override protected function createView():void {
			super.createView();
			
			bg = new Shape();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, 0, 1, 1);
			bg.graphics.endFill();
			_view.addChild(bg);
			
			list = new List("Smiles");
			list.background = false;
			_view.addChild(list.view);
			
			btn = new BitmapButton();
			btn.setStandartButtonParams();
			btn.show();
			_view.addChild(btn);
		}
		
		override protected function drawView():void {
			bg.width = _width;
			bg.height = _height;
			
			list.setWidthAndHeight(_width - Config.FINGER_SIZE, _height);
			
			var count:int = (_width - Config.FINGER_SIZE) / (Config.FINGER_SIZE * .8);
			if (needToUpdate == true || count != colCount) {
				colCount = count;
				
				var lData:Array = [];
				var colIndex:int = 0;
				var rowIndex:int = 0;
				for (var i:int = 0; i < data.length; i++) {
					if (lData.length == rowIndex)
						lData.push([]);
					lData[rowIndex].push(data[i]);
					colIndex ++;
					if (colIndex == colCount) {
						lData[rowIndex].push(colCount);
						rowIndex ++;
						colIndex = 0;
					}
				}
				if (lData.length != rowIndex)
					lData[rowIndex].push(colCount);
				list.setData(lData, ListItemSmiles);
			}
			
			btn.setBitmapData(UI.renderAsset(new IconSmileGroupBackspace(), Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5, true, "SmileScreen.backspace"));
			var offset:int = Config.FINGER_SIZE * .25;
			btn.setOverflow(offset, offset, offset, offset);
			btn.y = offset;
			btn.x = list.width + offset;
		}
		
		override public function updateBounds():void {
			list.tapperInstance.setBounds();
		}
		
		override public function clearView():void {
			super.clearView();
			
			if (list != null)
				list.dispose();
			list = null;
		}
		
		override public function dispose():void {
			super.dispose();
			UI.destroy(bg);
			bg = null;
			if (list != null)
				list.dispose();
			list = null;
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
			btn.activate();
			btn.tapCallback = removeSmile;
		}
		
		private function removeSmile(e:Event = null):void {
			ChatInputAndroid.S_SMILE_SELECTED.invoke();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
			btn.deactivate();
			btn.tapCallback = null;
		}
		
		private function onItemTap(data:Object, n:int):void {
			var hz:String = list.getItemByNum(n).getLastHitZone();
			if (hz == null)
				return;
			ChatInputAndroid.S_SMILE_SELECTED.invoke(list.data[n][int(hz)]);
			RichTextSmilesCodes.addSmileToRecent(list.data[n][int(hz)]);
		}
	}
}