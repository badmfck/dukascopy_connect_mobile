package com.dukascopy.connect.gui.list.renderers 
{
	import assets.ModeratorIcon;
	import assets.OwnerIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import flash.display.IBitmapDrawable;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ChannelBannedUserListRenderer extends UserListRenderer
	{
		private var subtitleTextFormat:TextFormat;
		
		public function ChannelBannedUserListRenderer() 
		{
			
		}
		
		override protected function create():void 
		{
			super.create();
			
			subtitleTextFormat = new TextFormat();
			subtitleTextFormat.color = AppTheme.GREY_DARK;
			subtitleTextFormat.size = Config.FINGER_SIZE * .2;
			fxnme.defaultTextFormat = subtitleTextFormat;
		}
		
		override public function getHeight(item:ListItem, width:int):int
		{
			return Config.FINGER_SIZE;
		}
		
		override protected function getTitleWidth():int 
		{
			var titleWidth:Number = width - nme.x - Config.MARGIN;
			return titleWidth;
		}
		
		override public function getView(item:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable
		{
			super.getView(item, height, width, highlight);
			
			var itemData:ChatUserVO = item.data as ChatUserVO;
			
			nme.y = int((height - (nme.height + fxnme.height)) * .5);	
			fxnme.y = int(nme.y + nme.height);
			
			var date:String;
			
			if (itemData.banData.banEndTime == 0)
			{
				date = Lang.permanentBan;
			}
			else
			{
				var dateBaned:Date = new Date();
				dateBaned.setTime(itemData.banData.banEndTime*1000);
				
				var nextDay:Date = new Date();
				nextDay.setHours(0);
				nextDay.setMinutes(0);
				nextDay.setSeconds(0);
				nextDay.setMilliseconds(0);
				nextDay.setDate(nextDay.getDate() + 1);
				
				var currentDate:Date = new Date();
				
				if (nextDay.getTime() - currentDate.getTime() > dateBaned.getTime() - currentDate.getTime())
				{
					date = Lang.bannedTill + dateBaned.toLocaleTimeString();
				}
				else
				{
					date = Lang.bannedTill + dateBaned.toLocaleString();
				}
			}
			
			fxnme.text = date;
			
			fxnme.visible = true;
			
			return this;
		}
		
		override public function dispose():void
		{
			if (subtitleTextFormat)
			{
				subtitleTextFormat = null;
			}
			super.dispose();
		}
	}
}