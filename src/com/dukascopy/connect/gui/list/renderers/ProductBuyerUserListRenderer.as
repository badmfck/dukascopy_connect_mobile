package com.dukascopy.connect.gui.list.renderers 
{
	import assets.ModeratorIcon;
	import assets.OwnerIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.applicationShop.Order;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import flash.display.IBitmapDrawable;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ProductBuyerUserListRenderer extends UserListRenderer
	{
		public function ProductBuyerUserListRenderer() 
		{
			
		}
		
		override protected function create():void 
		{
			super.create();
		}
		
		
		
		override protected function getItemData(itemData:Object):Object {
			return (itemData as Order).receiver;
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}