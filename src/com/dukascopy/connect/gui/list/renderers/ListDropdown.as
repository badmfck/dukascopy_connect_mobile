package com.dukascopy.connect.gui.list.renderers {
	import com.dukascopy.connect.Config;
	import flash.display.IBitmapDrawable;
	import com.dukascopy.connect.gui.list.ListItem;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class ListDropdown extends BaseRenderer implements IListRenderer{
		
		private var padding:int = Config.FINGER_SIZE * .3;
		private var itemHeight:int = Config.FINGER_SIZE;
		private var format:TextFormat = new TextFormat("Tahoma", itemHeight * .28);
		private var tfValue:TextField = new TextField();
		private var _isTransparent:Boolean = true;
		
		
		public function ListDropdown() {
			tfValue = new TextField();
			tfValue.height = itemHeight;
			tfValue.defaultTextFormat = format;
			tfValue.text = '`Q|^,';
			tfValue.height = tfValue.textHeight + 4;
			tfValue.y = (itemHeight - tfValue.height) * .5;
			tfValue.x = padding;
			tfValue.text = '';
			addChild(tfValue);
			
			
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			return itemHeight;
		}
		
		public function getView(li:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			tfValue.width = width;
			if (li.data is String){
				tfValue.text = li.data as String;
			}else if (li.data is Object) {
				if (li.data is Array)
					tfValue.text = li.data[0] as String;
				else if("name" in li.data)
					tfValue.text = li.data.name as String;
				else {
					for (var n:String in li.data) {
						tfValue.text = li.data[n] as String;
						break;
					}
				}
			}else {
				tfValue.text = li.data as String;
			}
				
			tfValue.width = width - padding * 2;	
			
			graphics.clear();
			graphics.beginFill(0x0, .1);
			graphics.drawRect(0, itemHeight - 1, width, 1);
				
			return this;
		}
		
		public function get isTransparent():Boolean {
			return _isTransparent;
		}
		
		public function dispose():void {
			format = null;
			tfValue.text="";
			tfValue = null;
		}
		
	}

}