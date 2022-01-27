package com.dukascopy.connect.gui.list.renderers {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.button.InviteContactButton;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.uiFactory.UIFactory;
	import com.dukascopy.connect.vo.users.adds.PhonebookUserVO;
	import com.dukascopy.langs.Lang;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class ContactListRenderer extends UserListRenderer {
		
		protected var iconInSystem:IconLogoCircle;
		protected var inviteButton:InviteContactButton;
		protected var alreadyInvited:BitmapButton;
		protected var tfInvited:TextField;
		
		public function ContactListRenderer() { }
		
		override protected function create():void {
			super.create();
			
			inviteButton = new InviteContactButton(null, (Lang.textInvite + "!"));
			inviteButton.setOverflow(Config.MARGIN, Config.MARGIN, Config.MARGIN, Config.MARGIN);
			inviteButton.draw();
			inviteButton.visible = false;
			addChild(inviteButton);
			
			createAlreadyInvitedClip();
			
			iconInSystem = new IconLogoCircle();
			iconInSystem.width = Config.FINGER_SIZE * 0.28;
			iconInSystem.height = Config.FINGER_SIZE * 0.28;
			iconInSystem.visible = false;
			addChild(iconInSystem);
		}
		
		protected function createAlreadyInvitedClip():void {
			alreadyInvited = new BitmapButton();
			addChild(alreadyInvited);
			
			var box:Sprite = new Sprite();
			var tf:TextField = UIFactory.createTextField(Config.FINGER_SIZE*.2);
			tf.textColor = 0x7E95A8;
			box.addChild(tf);
			
			var mainHeight:int = Config.MARGIN * 2.8;
			tf.text = Lang.textInvited;
			tf.x = int(Config.MARGIN * 2);
			tf.y = int((mainHeight - tf.height) * .5);
			tf.autoSize = TextFieldAutoSize.LEFT;
			var mainWidth:int = int(tf.width + Config.MARGIN * 4);
			
			box.graphics.clear();
			box.graphics.beginFill(0xF7F9FA, 1);
			box.graphics.drawRoundRect(0, 0, mainWidth, mainHeight - 1, Config.MARGIN, Config.MARGIN);
			box.graphics.endFill();
			
			alreadyInvited.setBitmapData(UI.getSnapshot(box, StageQuality.HIGH, "ListPhones.AlreadyInvitedBox"));
			alreadyInvited.setOverflow(Config.MARGIN, Config.MARGIN, Config.MARGIN, Config.MARGIN);
			
			UI.destroy(tf);
			UI.destroy(box);
			
			tf = null;
			box = null;
		}
		
		override protected function getTitleWidth():int {
			var titleWidth:Number = width - nme.x - Config.MARGIN;
			if (inviteButton.visible)
				titleWidth -= inviteButton.width + Config.MARGIN;
			else if (alreadyInvited.visible)
				titleWidth -= alreadyInvited.width + Config.MARGIN;
			else if (iconInSystem.visible)
				titleWidth -= iconInSystem.width + Config.MARGIN;
			return titleWidth;
		}
		
		override public function getView(item:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			var itemData:Object = getItemData(item.data);
			
			inviteButton.visible = false;
			alreadyInvited.visible = false;
			
			if (itemData != null)
			{
				if("uid" in itemData && itemData.uid != null && itemData.uid != "" && itemData.uid != "0") {
					iconInSystem.visible = true;
					iconInSystem.x = int(width - iconInSystem.width - Config.MARGIN);
					iconInSystem.y = int((height - iconInSystem.height) * .5);
				} else
					iconInSystem.visible = false;
				if (itemData is PhonebookUserVO) {
					if (itemData.uid == null || itemData.uid == "" || itemData.uid == "0") {
						if ((itemData as PhonebookUserVO).invited)
							showInvitedMark(width, height);
						else
							showInviteButton(width, height);
					}
				}
			}
			
			return super.getView(item, height, width, highlight);
		}
		
		override protected function setHitZones(item:ListItem):void {
			var hitZones:Vector.<HitZoneData> = new Vector.<HitZoneData>();
			var itemData:Object = getItemData(item.data);
			if (itemData is PhonebookUserVO) {
				if (itemData.uid == null || itemData.uid == "" || itemData.uid == "0") {
					
					var hz:HitZoneData;
					
					if (!(itemData as PhonebookUserVO).invited)
					{
						hz = new HitZoneData();
						hz.type = HitZoneType.INVITE_BUTTON;
						hz.x = inviteButton.x;
						hz.y = inviteButton.y;
						hz.width = inviteButton.getWidth();
						hz.height = inviteButton.getHeight();
						hitZones.push(hz);
					}
					else
					{
						hz = new HitZoneData();
						hz.type = HitZoneType.INVITE_BUTTON;
						hz.x = alreadyInvited.x;
						hz.y = alreadyInvited.y;
						hz.width = alreadyInvited.width;
						hz.height = alreadyInvited.height;
						hitZones.push(hz);
					}
				}
			}
			if (hitZones.length > 0)
				item.setHitZones(hitZones);
		}
		
		override public function dispose():void {
			if (alreadyInvited != null) {
				alreadyInvited.dispose();	
				UI.destroy(alreadyInvited);
			}
			alreadyInvited = null;
			if (inviteButton != null)
				inviteButton.dispose();
			inviteButton = null;
			UI.destroy(iconInSystem);
			iconInSystem = null;
			if (tfInvited != null)
				tfInvited.text = "";
			tfInvited = null;
			super.dispose();
		}
		
		private function showInvitedMark(itemWidth:int, itemHeight:int):void {
			alreadyInvited.visible = true;
			alreadyInvited.x = int(itemWidth - alreadyInvited.width - Config.MARGIN);
			alreadyInvited.y = int((itemHeight - alreadyInvited.height) * .5);
		}
		
		protected function showInviteButton(itemWidth:int, itemHeight:int):void {
			inviteButton.visible = true;
			inviteButton.x = int(itemWidth - inviteButton.width - Config.MARGIN);
			inviteButton.y = int((itemHeight - inviteButton.height) * .5);
		}

		public function hideBack():void
		{
			if (bg != null && contains(bg))
			{
				removeChild(bg);
			}
		}
	}
}