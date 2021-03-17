package com.dukascopy.connect.gui.segmentedControls 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.shapes.BorderBox;
	import com.shapes.Box;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Alexey
	 */
	public class PaySegmentItem extends SegmentedControlItemBase 
	{
		
		private var bg:BorderBox;
		private var label:TextField;
		private var formatStatic:TextFormat;
		private var _icon:DisplayObject;
		
		private var iconBMD:BitmapData;
		private var iconBitmap:Bitmap;
		
		public function PaySegmentItem() 
		{
			super();			
			createView();
		}
		
		private function createView():void 
		{		
			var itemHeight:int = Config.FINGER_SIZE * .8;
			formatStatic = new TextFormat("Tahoma",  itemHeight * .7 - Config.MARGIN * 2, 0xcccccc, false);
			formatStatic.align = TextFormatAlign.CENTER;
			bg = new BorderBox(AppTheme.GREY_MEDIUM,AppTheme.GREY_MEDIUM, _viewWidth, 40,1);
			addChild(bg);			
			label = new TextField();	
			label.border = false;
			label.multiline = false;
			label.selectable = false;
			label.defaultTextFormat = formatStatic;
			addChild(label);
			this.mouseChildren = false;
			
		}
		
		

		override public function setData(data:Object):void	{
			_data = data;
			label.text = _data.label;
			label.height = label.textHeight +1;
			
			if (_data.icon != null) {
				_icon  = _data.icon;
				addChild(_icon);
			}
			onSelectionChange();
			onAutoSizeChange();
			//updateViewPort();
			//trace(_data.id + " data seted", this)
			
		}
		
		
		
		override public function setWidth(w:int):void
		{
			_viewWidth = w;
			updateViewPort();
		}
		
		
		override protected function onSelectionChange():void 
		{
			if (_selected) {
				bg.color = AppTheme.GREY_MEDIUM;// 0xEE4131;
				label.textColor = 0xffffff;
				
			}else {
				bg.color = 0xffffff;
				label.textColor = AppTheme.GREY_MEDIUM;// 0xEE4131;
			}
		}
		
		override protected function onAutoSizeChange():void 
		{
			formatStatic.align = _autosized ? TextFormatAlign.LEFT:TextFormatAlign.CENTER;
			label.autoSize = _autosized?TextFieldAutoSize.LEFT:TextFieldAutoSize.NONE;
			label.wordWrap  = false;
			label.multiline = false;
			label.defaultTextFormat = formatStatic;
			updateViewPort();
		}
		
		
		
		override protected function updateViewPort():void 
		{
			
			if (_autosized) {
				//rerender to auto sized width 
				//set label format to 
				//var ICON_SIZE:int = Config.FINGER_SIZE;
				if (_icon) {
					_icon.x = Config.MARGIN;
					_icon.y  = (_viewHeight - _icon.height ) * .5;					
				}				
				
				label.autoSize = TextFieldAutoSize.LEFT;		
				label.y = int(( _viewHeight - label.height) * .5);
				label.x = _icon != null? _icon.x+_icon.width + Config.MARGIN:Config.MARGIN;
					
				bg.width =	label.x + label.width+Config.MARGIN;
				bg.height = _viewHeight;
				
			}else {
				// render to fit _viewWidth
				bg.width = _viewWidth;
				bg.height = _viewHeight;
				if (_icon) {
					_icon.x = Config.MARGIN;
					_icon.y  = (_viewHeight - _icon.height ) * .5;					
				}				
				
				label.x = _icon != null? _icon.x+_icon.width+Config.MARGIN :Config.MARGIN;		
				label.y = int(( _viewHeight - label.height) * .5);
				label.width = _icon!=null? _viewWidth- Config.FINGER_SIZE - Config.MARGIN*2 : _viewWidth-Config.MARGIN*2;
			
			}
		}
		
		
		
		override public function dispose():void
		{
			_data = null;
			if(bg!=null){
				bg.graphics.clear();
				UI.safeRemoveChild(bg);
			}
			bg = null;
			
			if (label!=null) {
				UI.safeRemoveChild(label);
			}
			label = null;
			
			formatStatic = null;
			
		}
		
		
		
	}

}