package com.dukascopy.connect.screens.dialogs.paymentDialogs.elements 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.chat.CircleAvatar;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.vo.users.UserVO;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class UserSelectClip extends Sprite
	{
		private var avatar:CircleAvatar;
		private var title:TextField;
		private var line:Bitmap;
		
		public function UserSelectClip() 
		{
			avatar = new CircleAvatar();
			addChild(avatar);
			
			var format:TextFormat = new TextFormat();
			format.size = Config.FINGER_SIZE * .3;
			format.color = 0x47515B;
			format.font = Config.defaultFontName;
			
			title = new TextField();
			title.selectable = false;
			title.defaultTextFormat = format;
			title.text = "Pp";
			title.height = title.textHeight + 4;
			title.text = "";
			title.wordWrap = false;
			title.multiline = false;
			addChild(title);
			
			line = new Bitmap();
			addChild(line);
		}
		
		public function draw(user:UserVO, itemWidth:int, itemHeight:int, avatarSize:int):void
		{
			line.bitmapData = UI.getHorizontalLine(0x33CC00, itemWidth);
			line.y = int(itemHeight - line.height);
			
			title.x = int(avatar.x + avatarSize * 2 + Config.MARGIN * 1.58);
			title.y = int(itemHeight * .5 - title.height * .5);
			title.width = itemWidth - avatarSize * 2 - Config.MARGIN * 1.58;
			title.text = user.getDisplayName();
			avatar.setData(user, avatarSize);
			avatar.y = int(itemHeight * .5 - avatarSize);
		}
		
		public function dispose():void 
		{
			if (avatar != null)
			{
				avatar.dispose();
				avatar = null;
			}
			if (title != null)
			{
				UI.destroy(title);
				title = null;
			}
			if (line != null)
			{
				UI.destroy(line);
				line = null;
			}
		}
	}
}