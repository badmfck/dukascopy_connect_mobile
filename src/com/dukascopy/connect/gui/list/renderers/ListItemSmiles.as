package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.richTextField.RichTextSmilesCodes;
	import com.dukascopy.connect.vo.EntryPointVO;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class ListItemSmiles extends BaseRenderer implements IListRenderer{
		
		private var bmps:Array = [];
		
		public function ListItemSmiles() {
			
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			return Config.FINGER_SIZE * .8;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			var margin:int = (width - li.data[li.data.length - 1] * Config.FINGER_SIZE * .8) * .5;
			var bmp:Bitmap;
			var hitZones:Vector.<HitZoneData> = new Vector.<HitZoneData>();
			for (var i:int = 0; i < li.data.length - 1; i++) {
				if (bmps.length > i)
					bmp = bmps[i];
				else {
					bmp = new Bitmap(null, "auto");
					bmp.x = int(i * Config.FINGER_SIZE * .8 + Config.FINGER_SIZE * .05) + margin;
					bmp.y = int(Config.FINGER_SIZE * .05);
					bmps.push(bmp);
				}
				if (bmp.parent == null)
					addChild(bmp);
				bmp.bitmapData = RichTextSmilesCodes.getSmileByCode(li.data[i][0].toString(16));
				bmp.smoothing = true;
				bmp.width = Config.FINGER_SIZE * .7;
				bmp.height = Config.FINGER_SIZE * .7;
				
				var hz:HitZoneData = new HitZoneData();
				hz.type = i + "";
				hz.x = bmp.x;
				hz.y = bmp.y;
				hz.width = bmp.width;
				hz.height = bmp.height;
				hitZones.push(hz);
			}
			for (i; i < li.data[li.data.length - 1]; i++) {
				if (i > bmps.length - 1)
					break;
				if (bmps[i] != null && bmps[i].parent != null)
					removeChild(bmps[i]);
			}
			li.setHitZones(hitZones);
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