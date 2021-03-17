package com.dukascopy.connect.gui.list.renderers 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.vo.users.adds.ContactSearchVO;
	import flash.display.IBitmapDrawable;
	/**
	 * ...
	 * @author Anton Bodrychenko
	 */
	public class ListPhonebook extends ListPhonesSearch
	{
		
		public function ListPhonebook() 
		{
			
		}
		
		override public function getView(data:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable
		{
			super.getView(data, height, width, highlight);
			
			
			fxnme.textColor = Color.RED;
			var _data:Object = getItemData(data.data);
			if ("phone" in _data)
			{
				nme.text = _data.phone;
			}
			if ("name" in _data)
			{
				fxnme.text = _data.name;
			}
			nme.width = nme.textWidth+Config.DOUBLE_MARGIN;
			fxnme.visible = true;
			nme.y = int(avatar.y - Config.MARGIN*0.5);
			fxnme.y =  nme.y + nme.textHeight;
			
			if (data.data is ContactSearchVO)
			if (data.data is ContactSearchVO)
			{
				highlightMatchingText((data.data as ContactSearchVO).searchText);
			}
			
			return this;
		}
		
		override protected function checkOnlineStatus(uid:String):void 
		{
			
			
		}
		/*override protected function createAlreadyInvitedClip():void 
		{
			
		}*/
		override protected function showInviteButton(itemWidth:int, itemHeight:int):void 
		{
			
		}
		
	}

}