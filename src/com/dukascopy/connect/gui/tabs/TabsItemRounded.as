package com.dukascopy.connect.gui.tabs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.data.TabsColorSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class TabsItemRounded {
		
		private var _id:String;
		private var _name:String;
		private var _selection:Boolean;
		private var _end:String;
		
		private var src:Sprite;
		private var tf:TextField;
		private var ta:TextFormat;
		private var bmp:Bitmap;
		private var bmd:ImageBitmapData;
		
		private var width:int = 0;
		private var height:int = 0;
		private var icon:Bitmap;
		public static const LEFT:String = "l";
		public static const RIGHT:String = "r";

		public function TabsItemRounded(name:String, id:String, selection:Boolean = false, end:String = "") {
			_selection = selection;
			_id = id;
			_name = name;
			_end = end;
			
			createView();
		}
		
		private function createView():void {
			tf = new TextField();
			tf.multiline = false;
			tf.wordWrap = false;
			var fontSize:int = Config.FINGER_SIZE * .25;
			if (fontSize < 9)
				fontSize = 9;
			if (ta == null)
				ta = new TextFormat("Tahoma", fontSize);
			if (_name == "911") {
				_name = "911 ";
				ta.italic = true;
			}
			ta.align = TextFormatAlign.CENTER;
			tf.defaultTextFormat = ta;
			if (src==null)
				src = new Sprite();
			src.addChild(tf);
			
			bmp = new Bitmap(null, "auto", true);
		}
		
		public function rebuild(colorSettings:TabsColorSettings, width:int = 0, height:int = 0, widthByText:Boolean = false):void {
			if (tf == null)
				return;
			if (height < 0)
				height = 1;
			if (_name != null && _name != ""){
				tf.text = _name;
				tf.visible = true;
			} else
				tf.visible = false;
			
			if (_name != null && LocalAvatars.isLocal(_name) == true)
			{
				tf.visible = false;
				if (icon == null)
				{
					icon = new Bitmap();
					src.addChild(icon);
				}
				if (icon.bitmapData != null)
				{
					icon.bitmapData.dispose();
					icon.bitmapData = null;
				}
				
				icon.bitmapData = LocalAvatars.getAvatar(_name, Config.FINGER_SIZE * .3);
				icon.x = int(width * .5 - icon.width * .5);
				icon.y = int(height * .5 - icon.height * .5);
			}
			
			if (widthByText == true && tf.visible == true)
				width = tf.textWidth + 4 + FilterTabs.CORNER_RADIUS * 2;
			tf.width = width;
			tf.height = tf.textHeight + 4;
			tf.y = int((height - tf.height) * .5);
			
			var tl:int =  0;
			var tr:int =  0;
			var bl:int =  0;
			var br:int =  0;
			if (_end == LEFT)
				tl = bl = FilterTabs.CORNER_RADIUS;
			else if (_end == RIGHT)
				tr = br = FilterTabs.CORNER_RADIUS;
			
			src.graphics.clear();
			if (_selection) {
				tf.textColor = colorSettings.tabTextSelectedColor;
				
				src.graphics.beginFill(colorSettings.tabBackgroundBorderSelectedColor);
				src.graphics.drawRoundRectComplex(0, 0, width, height, tl, tr, bl, br);
				src.graphics.beginFill(colorSettings.tabBackgroundSelectedColor);
				src.graphics.drawRoundRectComplex(1, 1, width - 2, height - 2, tl, tr, bl, br);
				
				if (icon != null)
				{
					UI.colorize(icon, colorSettings.tabTextSelectedColor);
				}
			} else {
				tf.textColor = colorSettings.tabTextColor;
				src.graphics.beginFill(colorSettings.tabBackgroundBorderColor);
				src.graphics.drawRoundRectComplex(0, 0, width, height, tl, tr, bl, br);
				src.graphics.beginFill(colorSettings.tabBackgroundColor);
				if (tr == 0)
					src.graphics.drawRoundRectComplex(1, 1, width - 1, height - 2, tl, tr, bl, br);
				else 
					src.graphics.drawRoundRectComplex(1, 1, width - 2, height - 2, tl, tr, bl, br);
				
				if (icon != null)
				{
					UI.colorize(icon, colorSettings.tabTextColor);
				}
			}
			
			if (bmd != null)
				bmd.dispose();
			bmd = new ImageBitmapData("TabsItemRounded." + id, width, height);
			bmd.drawWithQuality(src, null, null, null, null, false, StageQuality.HIGH);
			bmp.bitmapData = bmd;
		}
		
		public function dispose():void {
			_id = "";
			_name = "";
			_selection = false;
			_end = "";
			
			if (src != null)
				src.graphics.clear();
			src = null;
			
			if (tf != null)
				tf.text = "";
			tf = null;
			ta = null;
			
			if (icon != null)
			{
				UI.destroy(icon);
				icon = null;
			}
			
			if (bmd != null)
				bmd.dispose();
			bmd = null;
			
			if (bmp != null && bmp.bitmapData != null)
				bmp.bitmapData.dispose();
			bmp = null;
		}
		
		public function set selection(val:Boolean):void {
			_selection = val;
		}
		
		public function get id():String { return _id; }
		public function get selection():Boolean { return _selection; }
		public function get end():String { return _end; }
		public function get name():String { return _name; }
		
		public function set name(val:String):void { _name = val; }
		
		public function getView():Bitmap { return bmp; }
	}
}