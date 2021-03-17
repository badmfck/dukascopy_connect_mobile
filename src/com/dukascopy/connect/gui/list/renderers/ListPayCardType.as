package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.screens.payments.card.CardCommon;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ListPayCardType extends ListLinkWithIcon {
		
		public function ListPayCardType() {
			super();
		}
		
		override protected function getData(li:ListItem):Object 
		{
			var data:Object = new Object();
			if (li.data != null && "title" in li.data)
			{
				data.label = li.data.title;
				if (data.label != null && Lang[data.label] != null)
				{
					data.label = Lang[data.label];
				}
			}
			
			if ("type" in li.data == true)
			{
				data.icon = CardCommon.getCardIconClassByType(li.data.type.toLowerCase());
			}
			data.iconColor = -1;
			
			return data;
		}
	}
}