package com.dukascopy.connect.gui.tabs {
	
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.Style;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision A.G.
	 */
	
	public class TabsItemSmileSticker {
		
		public var _iconScale:Number = .5;
		public var _bmdScale:Number = .7;
		
		private var _id:String;
		private var _name:String;
		private var _selection:Boolean;
		private var _icon:MovieClip;
		private var _ibmd:ImageBitmapData;
		private var _iconIBMD:ImageBitmapData;
		
		private var src:Sprite;
		private var iconBMP:Bitmap;
		
		private var bmp:Bitmap;
		private var bmd:ImageBitmapData;
		
		private var width:int = 0;
		private var height:int = 0;
		
		public function TabsItemSmileSticker(name:String, id:String, selection:Boolean = false, icon:MovieClip = null, ibmd:ImageBitmapData = null) {
			_selection = selection;
			_id = id;
			_name = name;
			_icon = icon;
			_ibmd = ibmd;
			
			createView();
		}
		
		private function createView():void {
			src = new Sprite();
			bmp = new Bitmap(null, "auto", true);
			iconBMP = new Bitmap(null, "auto", true);
			src.addChild(iconBMP);
		}
		
		public function rebuild(width:int = 0, height:int = 0):void {
			if (src == null)
				return;
			if (height < 0)
				height = 1;
			
			src.graphics.clear();
			if (_selection == false) {
				src.graphics.beginFill(0, 0);
				src.graphics.drawRect(0, 0, width - 1, height);
				src.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				src.graphics.drawRect(width - 1, 0, 1, height);
			} else {
				src.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				src.graphics.drawRect(0, 0, width, height);
			}
			src.graphics.endFill();
			
			var scaling:Number;
			var iconHeight:int;
			var iconWidth:int;
			if (_icon != null) {
				
				
				
				scaling = int(height * _iconScale) / _icon.height;
				iconHeight = height * _iconScale;
				iconWidth = _icon.width * scaling;
				if (_icon.width != iconWidth || _icon.height != iconHeight) {
					_icon.height = iconHeight;
					_icon.width = iconWidth;
					if (_iconIBMD != null && _iconIBMD.isDisposed == false)
						_iconIBMD.disposeNow();
					_iconIBMD = UI.getSnapshot(_icon, StageQuality.HIGH, "TabsItemSmileSticker." + id);
				}
				
				iconBMP.bitmapData = _iconIBMD;
				iconBMP.x = (width-iconWidth) * .5;
				iconBMP.y = (height-iconHeight) * .5;
				iconBMP.smoothing = true;
				
				
			} else {
				if(_ibmd!=null){
					scaling = int(height * _bmdScale) / _ibmd.height;// _ibmd null viletaet
					iconHeight = height * _bmdScale;
					iconWidth = _ibmd.width * scaling;
					if (_iconIBMD != null && _iconIBMD.isDisposed == false)
						_iconIBMD.disposeNow();
					//_iconIBMD = ImageManager.resize(_ibmd, iconWidth, iconHeight, ImageManager.SCALE_PORPORTIONAL, false, true);
					
					iconBMP.bitmapData = _ibmd;
					iconBMP.width = iconWidth;
					iconBMP.height = iconHeight;
					iconBMP.x = (width-iconWidth) * .5;
					iconBMP.y = (height-iconHeight) * .5;
					iconBMP.smoothing = true;
				}
			
			}
			
			
			
			
			if (bmd != null)
				bmd.dispose();
			bmd = new ImageBitmapData("TabsItemSmileStocker." + id, width, height);
			bmd.drawWithQuality(src, null, null, null, null, false, StageQuality.HIGH);
			
			
			//bmd.drawWithQuality(_iconIBMD, null, null, null, null, StageQuality.HIGH);
			//bmd.copyPixels(_iconIBMD, _iconIBMD.rect, new Point(int((width - _iconIBMD.width) * .5), int((height - _iconIBMD.height) * .5)), null, null, true);
			bmp.bitmapData = bmd;
			bmp.smoothing = true;
		}
		
		public function dispose():void {
			_id = "";
			_name = "";
			_selection = false;
			
			if (src != null)
				src.graphics.clear();
			src = null;
			
			if (bmd != null)
				bmd.dispose();
			bmd = null;
			
			if (bmp != null && bmp.bitmapData != null)
				bmp.bitmapData.dispose();
			bmp = null;
			
			_icon = null;
			
			if (_iconIBMD != null && _iconIBMD.isDisposed == false)
				_iconIBMD.disposeNow();
			_iconIBMD = null;
		}
		
		public function set selection(val:Boolean):void {
			_selection = val;
		}
		
		public function get id():String { return _id; }
		public function get selection():Boolean { return _selection; }
		public function get name():String { return _name; }
		
		public function getView():Bitmap { return bmp; }
	}
}