package com.dukascopy.connect.screens.keyboardScreens {
	
	import com.adobe.crypto.SHA1;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListItemStickers;
	import com.dukascopy.connect.screens.keyboardScreens.StickersScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.stickerManager.StickerManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Shape;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class InnerStickerScreen2 extends BaseScreen {
		
		private var list:List;
		
		private var bg:Shape;
		
		private var colCount:int;
		private var needToUpdate:Boolean = false;
		private var needToRefreshList:Boolean = false;
		
		public function InnerStickerScreen2() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			needToUpdate = true;
			_params.title = 'Stickers';
			_params.doDisposeAfterClose = false;
			
			StickerManager.S_WAITING_TIMER_ENDS.add(onWaitingTimerEnds);
		}
		
		override protected function createView():void {
			super.createView();
			
			bg = new Shape();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, 0, 1, 1);
			bg.graphics.endFill();
			_view.addChild(bg);
			
			list = new List("Stickers");
			list.background = false;
			_view.addChild(list.view);
		}
		
		override protected function drawView():void {
			bg.width = _width;
			bg.height = _height;
			
			list.setWidthAndHeight(_width, _height);
			
			var count:int = _width / (Config.FINGER_SIZE * 1.8);
			if (needToUpdate == true || count != colCount) {
				colCount = count;
				
				var lData:Array = [];
				var colIndex:int = 0;
				var rowIndex:int = 0;
				for (var i:int = 0; i < data.length; i++) {
					if (lData.length == rowIndex)
						lData.push( { data:[] } );
					lData[rowIndex].data.push(data[i]);
				//	lData[rowIndex]["stickerURL_" + colIndex] = StickerManager.getSticker(data[i].id, data[i].ver);
					colIndex ++;
					if (colIndex == colCount) {
						lData[rowIndex].data.push(colCount);
						rowIndex ++;
						colIndex = 0;
					}
				}
				var links:Array = [];
				/*for (var j:int = 0; j < colCount; j++)
					links.push("stickerURL_" + j);*/
				if (lData.length != rowIndex)
					lData[rowIndex].data.push(colCount);
				list.setData(lData, ListItemStickers, links);
			}
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
			
			StickerManager.S_WAITING_TIMER_ENDS.remove(onWaitingTimerEnds);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
			if (needToRefreshList == true)
				list.refresh();
			needToRefreshList = false;
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
		}
		
		private function onWaitingTimerEnds():void {
			if (_isActivated == false) {
				needToRefreshList = true;
				return;
			}
			if (list == null)
				return;
			list.refresh();
		}
		
		private function onItemTap(data:Object, n:int):void {
			var hz:String = list.getItemByNum(n).getLastHitZone();
			if (hz == null)
				return;
			if (list.data[n].data[int(hz)].wasDown == true)
				return;
			StickerManager.addWaitingSticker(list.data[n].data[int(hz)]);
			StickersScreen.S_STICKER_PRESSED.invoke(Config.BOUNDS + JSON.stringify( { title:Lang.stikerSent, additionalData:list.data[n].data[int(hz)].id + "," + list.data[n].data[int(hz)].ver, type:"sticker", method:"stickerSent" } ));
			StickerManager.addRecent(list.data[n].data[int(hz)]);
		}
	}
}