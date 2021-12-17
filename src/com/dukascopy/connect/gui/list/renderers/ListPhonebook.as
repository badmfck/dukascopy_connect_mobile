package com.dukascopy.connect.gui.list.renderers 
{
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import flash.display.IBitmapDrawable;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ListPhonebook extends UserListRenderer
	{
		
		public function ListPhonebook() 
		{
			
		}
		
		override public function getView(data:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable
		{
			super.getView(data, height, width, highlight);
			
			fxnme.textColor = Color.RED;
			var _data:Object = getItemData(data.data);
			if ("phone" in _data && _data.phone != null)
			{
				fxnme.text = _data.phone;
			}
			
			nme.textColor = Style.color(Style.COLOR_TEXT);
			fxnme.textColor = Style.color(Style.COLOR_SUBTITLE);
			nme.y = int((height - (nme.height + fxnme.height)) * .5);
			fxnme.y = int(nme.y + nme.height);
			
			fxnme.visible = true;
			
			return this;
		}
	}
}