package com.dukascopy.connect.gui.list.renderers {
	
	import assets.BotInfoIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.components.AvatarView;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ContactListRenderer;
	import com.dukascopy.connect.gui.megaText.MegaText;
	import com.dukascopy.connect.sys.bot.BotManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.users.adds.BotVO;
	import com.dukascopy.langs.Lang;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ListBotRenderer extends ContactListRenderer {
		
	//	private var ownerAvatar:AvatarView;
	//	private var avatarSizeOwner:Number;
	//	private var ownerText:flash.text.TextField;
		private var format:TextFormat;
	//	private var formatCount:flash.text.TextFormat;
	//	private var countText:flash.text.TextField;
		private var infoButton:Sprite;
		private var descriptionText:MegaText;
		private var formatDescription:TextFormat;
		
		public function ListBotRenderer() { }
		
		override protected function create():void {
			super.create();
			
			format = new TextFormat();
			format.font = Config.defaultFontName;
			format.size = Config.FINGER_SIZE * .24;
			format.color = Style.color(Style.COLOR_TITLE);
			
			formatDescription = new TextFormat();
			formatDescription.font = Config.defaultFontName;
			formatDescription.size = Config.FINGER_SIZE * .24;
			formatDescription.color = Style.color(Style.COLOR_SUBTITLE);
			
			/*formatCount = new TextFormat();
			formatCount.font = Config.defaultFontName;
			formatCount.size = Config.FINGER_SIZE * .24;
			formatCount.color = AppTheme.GREY_MEDIUM;
			
			avatarSizeOwner = Config.FINGER_SIZE * .2;
			
			ownerAvatar = new AvatarView(avatarSizeOwner);
			ownerAvatar.x = nme.x;
			addChild(ownerAvatar);
			
			ownerText = new TextField();
				ownerText.defaultTextFormat = format;
				ownerText.text = "Pp";
				ownerText.height = ownerText.textHeight + 4;
				ownerText.text = "";
				ownerText.x = int(ownerAvatar.x + avatarSizeOwner * 2 + Config.FINGER_SIZE * .1);
				ownerText.wordWrap = false;
				ownerText.multiline = false;
			addChild(ownerText);
			
			countText = new TextField();
				countText.defaultTextFormat = formatCount;
				countText.text = "Pp";
				countText.height = countText.textHeight + 4;
				countText.text = "";
				countText.x = int(ownerAvatar.x + avatarSizeOwner * 2 + Config.FINGER_SIZE * .1);
				countText.wordWrap = false;
				countText.multiline = false;
			addChild(countText);*/
			
			descriptionText = new MegaText();
			descriptionText.x = nme.x;
			addChild(descriptionText);
			
			infoButton = new (Style.icon(Style.ICON_INFO));
			UI.colorize(infoButton, Style.color(Style.ICON_RIGHT_COLOR));
			UI.scaleToFit(infoButton, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
			addChild(infoButton);
		}
		
		override protected function setHitZones(item:ListItem):void {
			if (item.data is BotVO) {
				var hitZones:Array = new Array();
				/*hitZones.push( {
					type:HitZoneType.BOT_OWNER, 
					x:ownerAvatar.x - Config.FINGER_SIZE*.05 + x,
					y:ownerAvatar.y -  Config.FINGER_SIZE*.05 + y, 
					width:(Config.FINGER_SIZE * .1 + avatarSizeOwner*2 + Config.FINGER_SIZE*.1 + ownerText.width),
					height:(Config.FINGER_SIZE * .1 + avatarSizeOwner*2)
				} );*/
				
				if (infoButton != null)
				{
					hitZones.push( {
						type:HitZoneType.BOT_INFO, 
						x:infoButton.x - Config.FINGER_SIZE*.3 + x,
						y:infoButton.y -  Config.FINGER_SIZE*.3 + y, 
						width:(Config.FINGER_SIZE * .3 + infoButton.width + Config.FINGER_SIZE * .3),
						height:(height)
					} );
				}
				
				item.setHitZones(hitZones);
			}
		}
		
		override public function getView(item:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			
			super.getView(item, height, width, highlight)
		//	ownerAvatar.visible = false;
		//	ownerText.visible = false;
		//	countText.visible = false;
			descriptionText.visible = false;
			
			nme.textColor = Style.color(Style.COLOR_TITLE);
			avatar.alpha = 1;
			nme.alpha = 1;
			descriptionText.alpha = 1;
			
			if (infoButton != null)
			{
				infoButton.visible = false;
			}
			
			var itemData:Object = getItemData(item.data);
			if (itemData is BotVO)
			{
				if ((itemData as BotVO).group == BotManager.GROUP_OTHER)
				{
					avatar.alpha = 0.3;
					nme.alpha = 0.4;
					descriptionText.alpha = 0.5;
				}
				
				if ((itemData as BotVO).description != null)
				{
					descriptionText.visible = true;
					descriptionText.setText(
					width - infoButton.width - Config.MARGIN * 4 - avatar.x - avatarSize * 2, 
					(itemData as BotVO).description, 
					//(cVO.unreaded > 0) ? 0xA4AFB9 : (Auth.uid == cVO.messageWriterUID) ? 0xA4AFB9 : 0xA4AFB9, 
					formatDescription.color as Number, 
					int(formatDescription.size),
					"#FFFFFF",
					1.5, 2
				);
				if (descriptionText.getTextField().numLines > 2) {
					descriptionText.setText(
						width - infoButton.width - Config.MARGIN * 4 - avatar.x - avatarSize * 2, 
						(itemData as BotVO).description.substr(0, descriptionText.getTextField().getLineLength(0) + descriptionText.getTextField().getLineLength(1) - 2) + "..", 
						formatDescription.color as Number, 
						int(formatDescription.size),
						"#FFFFFF",
						1.5, 2
					);
				}
					nme.y = int( height * .5 - (nme.height + descriptionText.height) * .5);
					descriptionText.y = int(nme.y + nme.height);
				}
				else{
					nme.y = int((height - nme.height) * .5);
				}
				
				fxnme.visible = false;
				iconInSystem.visible = false;
				
				/*countText.visible = false;
				countText.width = width * .5;
				countText.text = Lang.uses + ": " + (itemData as BotVO).chatCnt.toString();
				countText.width = countText.textWidth + 4;
				countText.y = int(height * .5 - countText.height * .5);
				countText.x = int(width - countText.width - Config.DOUBLE_MARGIN);*/
				
				infoButton.visible = true;
				infoButton.x = int(width - Config.DIALOG_MARGIN - infoButton.width);
				infoButton.y = int(height * .5 - infoButton.height * .5);
			}
			
			return this;
		}
		
		override public function dispose():void {
			format = null;
			formatDescription = null;
			/*formatCount = null;
			if (ownerAvatar != null)
				ownerAvatar.dispose();
			ownerAvatar = null;
			if (ownerText != null)
				UI.destroy(ownerText);
			ownerText = null;
			if (countText != null)
				UI.destroy(countText);
			countText = null;*/
			if (descriptionText != null)
			{
				descriptionText.dispose();
				descriptionText = null;
			}
			if (infoButton != null)
				UI.destroy(infoButton);
			infoButton = null;
		}
	}
}