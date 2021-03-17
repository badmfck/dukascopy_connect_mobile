package com.dukascopy.connect.screens.dialogs.userPopup 
{
	import assets.IconBanPopup;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.UserBanData;
	import com.dukascopy.connect.data.UserPopupData;
	import com.dukascopy.connect.gui.components.selector.Selector;
	import com.dukascopy.connect.gui.components.textEditors.TitleTextEditor;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class BanUserPopup extends UserPopup
	{
		private var selector:Selector;
		private var reason:TitleTextEditor;
		
		public function BanUserPopup() 
		{
			
		}
		
		override protected function preinitialize():void 
		{
			messageText = null;
			buttonRejectText = Lang.textCancel;
			buttonAcceptText = Lang.textBan;
			iconClass = IconBanPopup;
			
			acceptButtonColor = 0xAD1F1E;
			acceptButtonColor2 = 0x8B1718;
		}
		
		override protected function updateResultData():void 
		{
			if ((data as UserPopupData).resultData && ((data as UserPopupData).resultData is UserBanData))
			{
				if (reason.value != reason.prompt)
				{
					((data as UserPopupData).resultData as UserBanData).reason = reason.value;
				}
				
				((data as UserPopupData).resultData as UserBanData).duration = selector.getSelectedData() as String;
			}
		}
		
		override protected function createView():void
		{
			super.createView();
			
			reason = new TitleTextEditor(false);
			container.addChild(reason);
			
			selector = new Selector();
			container.addChild(selector);
		}
		
		private function drawReason(positionY:int):void 
		{
			reason.draw(_width - padding * 2);
			reason.prompt = Lang.reasonForBan;
			reason.x = padding;
			reason.y = positionY;
		}
		
		override protected function drawCustomContent(positionY:Number):void 
		{
			drawReason(positionY);
			position += reason.height + Config.MARGIN * 2;
			
			drawSelector(position);
			position += selector.height + Config.MARGIN * 2;
		}
		
		private function drawSelector(positionY:Number):void 
		{
			selector.maxWidth = _width - padding * 2;
			selector.x = padding;
			selector.y = positionY;
			
			var selectorData:Vector.<SelectorItemData> = new Vector.<SelectorItemData>();
			selectorData.push(new SelectorItemData(Lang.textHour, UserBanData.DURATION_HOUR));
			selectorData.push(new SelectorItemData(Lang.textDay, UserBanData.DURATION_DAY));
			selectorData.push(new SelectorItemData(Lang.textMonth, UserBanData.DURATION_MONTH));
			selectorData.push(new SelectorItemData(Lang.textPermanent, UserBanData.DURATION_PERMANENT));
			
			selector.dataProvider = selectorData;
		}
		
		override public function activateScreen():void
		{
			super.activateScreen();
			
			selector.activate();
			reason.activate();
		}
		
		override public function deactivateScreen():void
		{
			if (isDisposed)
			{
				return;
			}
			super.deactivateScreen();
			
			selector.deactivate();
			reason.deactivate();
		}
		
		override public function dispose():void
		{
			if (isDisposed)
			{
				return;
			}
			super.dispose();
			
			if (selector)
			{
				selector.dispose();
				selector = null;
			}
			
			if (reason)
			{
				reason.dispose();
				reason = null;
			}
		}
	}
}