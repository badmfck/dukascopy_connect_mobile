package com.dukascopy.connect.gui.list.renderers 
{
	import assets.ModeratorIcon;
	import assets.OwnerIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.type.UserType;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import flash.display.IBitmapDrawable;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ChannelUserListRenderer extends UserListRenderer
	{
		private var iconModerator:ModeratorIcon;
		private var iconOwner:OwnerIcon;
		
		public function ChannelUserListRenderer() 
		{
			
		}
		
		override protected function create():void 
		{
			super.create();
			
			iconModerator = new ModeratorIcon();
			UI.scaleToFit(iconModerator, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
			addChild(iconModerator);
			
			iconOwner = new OwnerIcon();
			UI.scaleToFit(iconOwner, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
			addChild(iconOwner);
		}
		
		override public function getHeight(item:ListItem, width:int):int
		{
			return Config.FINGER_SIZE;
		}
		
		override protected function getTitleWidth():int 
		{
			var titleWidth:Number = width - nme.x - Config.MARGIN;
			if (iconModerator.visible)
			{
				titleWidth -= Config.FINGER_SIZE * .2 + Config.MARGIN;
			}
			else if (iconOwner.visible)
			{
				titleWidth -= Config.FINGER_SIZE * .2 + Config.MARGIN;
			}
			return titleWidth;
		}
		
		override public function getView(item:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable
		{
			var itemData:ChatUserVO = item.data as ChatUserVO;
			
			iconModerator.x = int(width - iconModerator.width - Config.MARGIN * 2);
			iconModerator.y = int((height - iconModerator.height) * .5);
			
			iconOwner.x = int(width - iconOwner.width - Config.MARGIN * 2);
			iconOwner.y = int((height - iconOwner.height) * .5);
			
			iconModerator.visible = false;
			iconOwner.visible = false;
			
			if (itemData.isChatModerator() && itemData.userVO != null && itemData.userVO.type != UserType.BOT)
			{
				iconModerator.visible = true;
			}
			else if (itemData.isChatOwner())
			{
				iconOwner.visible = true;
			}
			
			return super.getView(item, height, width, highlight);
		}
		
		override public function dispose():void
		{
			if (iconOwner)
			{
				UI.destroy(iconOwner);
				iconOwner = null;
			}
			
			if (iconModerator)
			{
				UI.destroy(iconModerator);
				iconModerator = null;
			}
			
			super.dispose();
		}
	}
}