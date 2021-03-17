package com.dukascopy.connect.gui.list.renderers 
{
	import assets.StatusCompleteIcon;
	import assets.StatusPendingIcon;
	import assets.StatusRejectcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.ReferralProgramInviteData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.promocodes.ReferralProgram;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.langs.Lang;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ListReferralInviteRenderer extends UserListRenderer 
	{
		private var iconPending:StatusPendingIcon;
		private var iconComplete:StatusCompleteIcon;
		private var iconReject:assets.StatusRejectcon;
		
		private var iconSize:int;
		private var remindButton:Sprite;
		private var buttonTextFormat:TextFormat;
		private var buttonText:TextField;
		
		public function ListReferralInviteRenderer() {
			super();
			
			iconPending = new StatusPendingIcon();
			iconComplete = new StatusCompleteIcon();
			iconReject = new StatusRejectcon();
			
			iconSize = Config.FINGER_SIZE * .4;
			
			UI.scaleToFit(iconPending, iconSize, iconSize);
			UI.scaleToFit(iconComplete, iconSize, iconSize);
			UI.scaleToFit(iconReject, iconSize, iconSize);
			
			addChild(iconPending);
			addChild(iconComplete);
			addChild(iconReject);
			
			remindButton = new Sprite();
			addChild(remindButton);
			
			buttonText = new TextField();
				buttonText.selectable = false;
				buttonTextFormat = new TextFormat();
				buttonTextFormat.font = Config.defaultFontName;
				buttonTextFormat.size = Config.FINGER_SIZE * .24;
				buttonTextFormat.color = 0xFFFFFF;
				buttonText.defaultTextFormat = buttonTextFormat;
				buttonText.text = Lang.remind;
				buttonText.width = buttonText.textWidth + 4;
				buttonText.height = buttonText.textHeight + 4;
				buttonText.wordWrap = false;
				buttonText.multiline = false;
			remindButton.addChild(buttonText);
			
			remindButton.graphics.beginFill(AppTheme.GREEN_MEDIUM);
			
			var vPadding:int = Config.FINGER_SIZE * .05;
			var hPadding:int = Config.FINGER_SIZE * .1;
			
			remindButton.graphics.drawRoundRect(0, 0, buttonText.width + hPadding * 2, buttonText.height + vPadding * 2, Config.FINGER_SIZE * .1, Config.FINGER_SIZE * .1);
			buttonText.x = hPadding;
			buttonText.y = vPadding;
		}
		
		override protected function setHitZones(item:ListItem):void {
			var hitZones:Array = new Array();
			hitZones.push( { type:HitZoneType.INVITE_BUTTON, x:remindButton.x - Config.DOUBLE_MARGIN, y:remindButton.y - Config.DOUBLE_MARGIN, width:remindButton.width + Config.DOUBLE_MARGIN * 2, height:remindButton.height + Config.DOUBLE_MARGIN * 2 } );
			item.setHitZones(hitZones);
		}
		
		override public function getView(item:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			
			iconPending.visible = false;
			iconComplete.visible = false;
			iconReject.visible = false;
			remindButton.visible = false;
			
			if (item.data is ReferralProgramInviteData) {
				if ((item.data as ReferralProgramInviteData).status == ReferralProgram.INVITE_STATUS_COMPLETED) {
					iconComplete.x = int(width - iconSize - Config.DOUBLE_MARGIN);
					iconComplete.y = int(height * .5 - iconSize * .5);
					iconComplete.visible = true;
				}
				else if((item.data as ReferralProgramInviteData).status == ReferralProgram.INVITE_STATUS_REJECTED) {
					iconReject.x = int(width - iconSize - Config.DOUBLE_MARGIN);
					iconReject.y = int(height * .5 - iconSize * .5);
					iconReject.visible = true;
				}
				else {
					iconPending.x = int(width - iconSize - Config.DOUBLE_MARGIN);
					iconPending.y = int(height * .5 - iconSize * .5);
					iconPending.visible = true;
					
					remindButton.visible = true;
					
					if ((item.data as ReferralProgramInviteData).reminded == true)
					{
						remindButton.alpha = 0.6;
					}
					else
					{
						remindButton.alpha = 1;
					}
					remindButton.x = int(iconPending.x - Config.MARGIN - remindButton.width);
					remindButton.y = int(height * .5 - remindButton.height * .5);
				}
			}
			
			return super.getView(item, height, width, highlight);
		}
		
		override protected function getItemData(itemData:Object):Object {
			return itemData.user;
		}
		
		override public function dispose():void {
			
			if (iconPending) {
				UI.destroy(iconPending);
				iconPending = null;
			}
			
			if (iconComplete) {
				UI.destroy(iconComplete);
				iconComplete = null;
			}
			
			if (iconReject) {
				UI.destroy(iconReject);
				iconReject = null;
			}
			
			if (remindButton != null) {
				UI.destroy(remindButton);
				remindButton = null;
			}
			
			if (buttonText != null) {
				UI.destroy(buttonText);
				buttonText = null;
			}
			
			buttonTextFormat = null;
			
			super.dispose();
		}
	}
}