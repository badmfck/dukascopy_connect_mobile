package com.dukascopy.connect.gui.list.renderers {
	
	import assets.DoneIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.BackgroundModel;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.richTextField.RichTextSmilesCodes;
	import com.dukascopy.connect.sys.stickerManager.StickerManager;
	import com.dukascopy.connect.vo.EntryPointVO;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ListItemBackgrounds extends BaseRenderer implements IListRenderer{
		
		private var bmps:Array = [];
		private var selectedMark:Bitmap;
		private var itemSize:Number;
		private var topPadding:Number;
		private var bottomPadding:Number;
		
		public function ListItemBackgrounds() {
			selectedMark = new Bitmap;
			addChild(selectedMark);
			selectedMark.bitmapData = UI.renderAsset(new DoneIcon(), int(Config.FINGER_SIZE * .5), int(Config.FINGER_SIZE * .5), true, "ListItemBackgrounds.selectedMark");
			selectedMark.smoothing = true;
		}
		
		public function getHeight(data:ListItem, width:int):int
		{
			topPadding = (data.num == 0)?Config.MARGIN * .5:0;
			bottomPadding = (data.num == data.list.data.length - 1)?Config.MARGIN * .5:0;
			return (width - Config.MARGIN * 4) / 3 + Config.MARGIN + topPadding + bottomPadding;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			
			topPadding = (li.num == 0)?Config.MARGIN * .5:0;
			itemSize = (width - Config.MARGIN*4)/ 3;
			
			var bmp:Bitmap;
			var hitZones:Array = [];
			
			for (var i:int = 0; i < li.data.data.length - 1; i++) {
				if (bmps.length > i) {
					bmp = bmps[i];
					bmp.bitmapData.dispose();
					bmp.bitmapData = null;
				} else {
					bmp = new Bitmap(null, "auto");
					
					bmps.push(bmp);
				}
				if (bmp.parent == null)
					addChild(bmp);
				
				var source:ImageBitmapData = Assets.getBackground(li.data.data[i].model.small);
				
				if (source != null && source.isDisposed == false) {
					var rounded:ImageBitmapData = new ImageBitmapData("ListItemBackgrounds.backgroundItem", itemSize, itemSize);
					ImageManager.drawRoundedRectImageToBitmap(rounded, source, itemSize, itemSize, itemSize * .3);
					
					bmps[i].bitmapData = rounded;
					bmps[i].smoothing = true;
					
					bmps[i].x = int(i * (itemSize + Config.MARGIN)) + Config.MARGIN;
					bmps[i].y = int(Config.MARGIN*.5 + topPadding);
				}
				source = null;
				hitZones.push( { type:i + "", x: i * (itemSize + Config.MARGIN) + Config.MARGIN*.5, y:(topPadding), width:(itemSize + Config.MARGIN - 1), height:(itemSize + Config.MARGIN - 1) } );
			}
			for (i; i < li.data.data[li.data.data.length - 1]; i++) {
				if (i > bmps.length - 1)
					break;
				if (bmps[i] != null && bmps[i].parent != null)
				{
				//	(bmps[i] as Bitmap).bitmapData
					removeChild(bmps[i]);
				}	
			}
			li.setHitZones(hitZones);
			updateSelectedMark(li);
			
			return this;
		}
		
		private function updateSelectedMark(li:ListItem):void 
		{
			var selctedItemIndex:int = getSelectedItemIndex(li);
			if (selctedItemIndex != -1)
			{
				selectedMark.visible = true;
				setChildIndex(selectedMark, numChildren - 1);
				selectedMark.x = int(selctedItemIndex * (itemSize + Config.MARGIN) + Config.MARGIN + itemSize - selectedMark.width + selectedMark.width*.2);
				selectedMark.y = int(Config.MARGIN*.5 - selectedMark.height*.2 + topPadding);
			}
			else {
				selectedMark.visible = false;
			}
		}
		
		private function getSelectedItemIndex(li:ListItem):int 
		{
			var index:int = -1;
			var length:int = li.data.data.length - 1;
			for (var i:int = 0; i < length; i++) 
			{
				if ((li.data.data[i].model as BackgroundModel).id == li.data.data[i].currentBackgroundId)
				{
					index = i;
					return index;
				}
			}
			return index;
		}
		
		public function dispose():void {
			graphics.clear();
			if (bmps)
			{
				var length:int = bmps.length;
				for (var i:int = 0; i < length; i++) 
				{
					UI.destroy(bmps[i]);
				}
			}
			bmps = null;
			if (selectedMark)
			{
				UI.destroy(selectedMark);
				selectedMark = null;
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}