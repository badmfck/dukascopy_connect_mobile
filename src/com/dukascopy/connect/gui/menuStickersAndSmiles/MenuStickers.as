package com.dukascopy.connect.gui.menuStickersAndSmiles {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.stickerManager.StickerManager;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class MenuStickers extends MenuStickersAndSmiles {
		
		private var loadedStickers:Array;
		private var iconSize:int;
		private var iconOffset:int;
		
		public function MenuStickers() {
			super();
		}
		
		override protected function initData():void	{
			elementSize = Config.FINGER_SIZE_DOUBLE - Config.MARGIN;
			iconSize = elementSize * .8;
			iconOffset = (elementSize - iconSize) >> 1;
		}
		
		public function setData(data:Array):void {
			source = data;
			calcTotalPages();
		}
		
		private function clear():void {
			if (loadedStickers == null)
				return;
			while (loadedStickers.length > 0) {
				if (loadedStickers[0] == null) {
					loadedStickers.splice(0, 1);
					continue;
				}
				if (loadedStickers[0][0] != null)
					loadedStickers[0][0].graphics.clear();
				loadedStickers[0][0] = null;
				if (loadedStickers[0][1] != null)
					loadedStickers[0][1].dispose();
				loadedStickers[0][1] = null;
				if (loadedStickers[0][2] != "")
					ImageManager.unloadImage(loadedStickers[0][2]);
				loadedStickers[0][2] = "";
				loadedStickers[0] = null;
				loadedStickers.splice(0, 1);
			}
			loadedStickers = null;
		}
		
		/**
		 * Draw smiles for specified page to the target shape
		 * @param	target:Shape - shape to be drawn
		 * @param	pageNum:int - page to be used to draw
		 */
		override protected function makePage(target:Sprite, pageNum:int):void {
			if (source == null)
				return;
			onPageChanging(target);
			
			var firstElement:int = pageNum * allCount;
			if (firstElement > source.length - 1)
				firstElement = source.length - 1 - allCount;
			if (firstElement < 0)
				firstElement = 0;
			
			var lastElement:int = firstElement + allCount;
			if (lastElement > source.length - 1)
				lastElement = source.length;
			
			var iH:int = 0;
			var iV:int = 0;
			
			target.graphics.clear();
			target.graphics.beginFill(0, 0);
			target.graphics.drawRect(0, 0, _width, rowCount * elementSize);
			target.graphics.endFill();
			
			var stickerItem:Shape;
			for (var i:int = firstElement; i < lastElement; i++) {
				var link:String = StickerManager.getSticker(source[i].id, source[i].ver);
				if (loadedStickers != null) {
					for (var j:int = 0; j < loadedStickers.length; j++)	{
						if (loadedStickers[j][2] == link) {
							stickerItem = loadedStickers[j][0];
							break;
						}
					}
				}
				if (stickerItem == null) {
					stickerItem = new Shape();
					stickerItem.graphics.beginFill(0, .1);
					stickerItem.graphics.drawRect(iconOffset, iconOffset, iconSize, iconSize);
					stickerItem.graphics.endFill();
					
					loadedStickers ||= [];
					j = loadedStickers.push([stickerItem, null, link]) - 1;
				}
				
				stickerItem.x = hOffset + iH * elementSize;
				stickerItem.y = iV * elementSize;
				target.addChild(stickerItem);
				
				if (loadedStickers[j][1] != null && !loadedStickers[j][1].isDisposed) {
					onImageLoaded(link, loadedStickers[j][1]);
				} else {
					StickerManager.getSticker(source[i].id, source[i].ver, onImageLoaded);
				}
				
				iH++;
				if (iH >= columnCount) {
					iH = 0;
					iV++;
				}
				stickerItem = null;
			}
		}
		
		// TODO - CHECK FOR STICKER EXISTS
		private function onImageLoaded(link:String, image:ImageBitmapData):void {
			if (loadedStickers == null)
				return;
			for (var i:int = 0; i < loadedStickers.length; i++)	{
				if (loadedStickers[i][2] == link) {
					loadedStickers[i][1] = image;
					loadedStickers[i][0].graphics.clear();
					ImageManager.drawGraphicImage(loadedStickers[i][0].graphics, iconOffset, iconOffset, iconSize, iconSize, image, ImageManager.SCALE_INNER_PROP);
					return;
				}
			}
			link = "";
			image = null;
		}
		
		private function onPageChanging(target:Sprite = null):void {
			if (target != null)
				while (target.numChildren > 0)
					target.removeChildAt(0);
			if (loadedStickers != null)
				for (var i:int = 0; i < loadedStickers.length; i++)
					if (loadedStickers[1] == null)
						ImageManager.unloadImage(loadedStickers[i][2]);
		}
		
		override public function dispose():void {
			clear();
			super.dispose();
		}
	}
}