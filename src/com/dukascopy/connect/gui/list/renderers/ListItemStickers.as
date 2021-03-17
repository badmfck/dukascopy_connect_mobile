package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
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
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class ListItemStickers extends BaseRenderer implements IListRenderer{
		
		private var bmps:Array = [];
		
		public function ListItemStickers() {
		}
		
		public function getHeight(data:ListItem, width:int):int {
			return Config.FINGER_SIZE * 1.8;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			
			var stickerBD:ImageBitmapData;
			var margin:int = (width - li.data.data[li.data.data.length - 1] * (Config.FINGER_SIZE * 1.8)) * .5;
			var bmp:Bitmap;
			var hitZones:Array = [];
			var hzSize:int = Config.FINGER_SIZE * 1.8;
			for (var i:int = 0; i < li.data.data.length - 1; i++) {
				if (bmps.length > i) {
					bmp = bmps[i];
					bmp.bitmapData = null;
				} else {
					bmp = new Bitmap();
					
					bmps.push(bmp);
				}
				if (bmp.parent == null)
					addChild(bmp);
				
				//var stickersBmp:ImageBitmapData = li.getLoadedImage('stickerURL_' + i);
				stickerBD = ImageManager.getImageFromCache("sticker_" + li.data.data[i].id);
			//	trace("stickerBD", stickerBD);
				if (stickerBD == null)
				{
					var stickerSprite:Sprite = StickerManager.getLocalStickerVector(li.data.data[i].id, li.data.data[i].ver, Config.FINGER_SIZE * 1.6, Config.FINGER_SIZE * 1.6);
					
					if (stickerSprite != null)
					{
						stickerBD = UI.getSnapshot(stickerSprite, StageQuality.HIGH, "sticker_" + li.data.data[i].id);
						ImageManager.cacheSticker("sticker_" + li.data.data[i].id, stickerBD);
					}
				}
				
				if (stickerBD != null && !stickerBD.isDisposed)
				{
					bmp.bitmapData = stickerBD;
					
					bmp.alpha = 1;
					if (li.data.data[i].wasDown == true)
						bmp.alpha = .3;
					if (li.getLastHitZone(false) != null && int(li.getLastHitZone(false)) == i)
						bmp.alpha = .3;
					
					bmp.x = int(i * hzSize + Config.FINGER_SIZE * .1 + Config.FINGER_SIZE * 1.6*.5 - bmp.width*.5) + margin;
					bmp.y = int(Config.FINGER_SIZE * .1 + Config.FINGER_SIZE * 1.6*.5 - bmp.height*.5);
				}
				
				hitZones.push( { type:i + "", x: i * hzSize + margin, y:0, width:hzSize, height:hzSize } );
			}
			for (i; i < li.data.data[li.data.data.length - 1]; i++) {
				if (i > bmps.length - 1)
					break;
				if (bmps[i] != null && bmps[i].parent != null)
					removeChild(bmps[i]);
			}
			li.setHitZones(hitZones);
			graphics.clear();
			if (highlight == true) {
				if (li.data.data[int(li.getLastHitZone(false))].wasDown == true)
					return this;
				graphics.beginFill(0, .05);
				graphics.drawRect(Number(li.getLastHitZone(false)) * hzSize + margin, 0, hzSize, hzSize);
				graphics.endFill();
			}
			return this;
		}
		
		public function dispose():void {
			graphics.clear();
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}