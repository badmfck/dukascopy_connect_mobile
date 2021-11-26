package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.data.escrow.EscrowStatus;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.vo.EscrowDealVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ListEscrowDealRenderer extends ListEscrowAdsRenderer implements IListRenderer {
		
		public function ListEscrowDealRenderer() {
			
			super();
		}
		
		override protected function getStatusText(listData:Object):String 
		{
			var itemData:EscrowDealVO = listData as EscrowDealVO;
			var result:String = "";
			if (itemData != null) {
				switch(itemData.status)
				{
					case EscrowStatus.deal_created.value:
					{
						result = Lang.escrow_deal_status_created;
						break;
					}
					case EscrowStatus.deal_completed.value:
					{
						result = Lang.escrow_deal_status_completed;
						break;
					}
					case EscrowStatus.deal_mca_hold.value:
					{
						result = Lang.escrow_deal_status_mca_hold;
						break;
					}
					case EscrowStatus.offer_expired.value:
					{
						result = Lang.escrow_deal_status_expired;
						break;
					}
					case EscrowStatus.paid_crypto.value:
					{
						result = Lang.escrow_deal_status_paid_crypto;
						break;
					}
					case EscrowStatus.deal_claimed.value:
					{
						result = Lang.escrow_deal_status_claimed;
						break;
					}
					case EscrowStatus.deal_mca_hold_fail.value:
					{
						result = Lang.escrow_deal_status_mca_failed;
						break;
					}
					case EscrowStatus.deal_crypto_send_fail.value:
					{
						result = Lang.escrow_deal_status_failed;
						break;
					}
					case EscrowStatus.deal_crypto_send_wait_investigation.value:
					{
						if (itemData.cryptoUserUID == Auth.uid)
						{
							result = Lang.escrow_deal_crypto_send_investigation_seller;
						}
						else
						{
							result = Lang.escrow_deal_crypto_send_investigation_buyer;
						}
						break;
					}
					case EscrowStatus.deal_canceled.value:
					{
						result = Lang.escrow_deal_status_canceled;
						break;
					}
					case EscrowStatus.deal_resolved.value:
					{
						result = Lang.escrow_deal_status_resolved;
						break;
					}
				}
			}
			return result;
		}
		
		override protected function updateBack(listData:Object):void 
		{
			var itemData:EscrowDealVO = listData as EscrowDealVO;
			if (itemData != null) {
				bg.transform.colorTransform = UI.getColorOverlay();
				if (isActive(itemData))
				{
					bg.transform.colorTransform = UI.getColorOverlay(UI.getBetweenColourByPercent(0.2, Style.color(Style.COLOR_BACKGROUND), Color.GREEN));
				}
				else if (isDealProblem(itemData))
				{
					bg.transform.colorTransform = UI.getColorOverlay(UI.getBetweenColourByPercent(0.2, Style.color(Style.COLOR_BACKGROUND), Color.RED));
				}
			}
		}
		
		private function isDealProblem(itemData:EscrowDealVO):Boolean 
		{
			switch(itemData.status)
			{
				case EscrowStatus.deal_claimed.value:
				{
					return true;
					break;
				}
			}
			return false;
		}
		
		private function isActive(itemData:EscrowDealVO):Boolean 
		{
			switch(itemData.status)
			{
				case EscrowStatus.deal_mca_hold.value:
				{
					if (itemData.cryptoUserUID == Auth.uid)
					{
						return true;
					}
					
					break;
				}
				
				case EscrowStatus.paid_crypto.value:
				{
					if (itemData.mcaUserUID == Auth.uid)
					{
						return true;
					}
					
					break;
				}
				
				case EscrowStatus.deal_crypto_send_fail.value:
				{
					if (itemData.cryptoUserUID == Auth.uid)
					{
						return true;
					}
					
					break;
				}
			}
			return false;
		}
		
		override protected function drawIcon(listData:Object):void {
			
			var itemData:EscrowDealVO = listData as EscrowDealVO;
			
			var iconClass:Class = UI.getCryptoIconClass(itemData.instrument);
			if (iconClass != null) {
				if (icon.bitmapData != null) {
					icon.bitmapData.dispose();
					icon.bitmapData = null;
				}
				
				var iconSource:Sprite = (new iconClass)();
				UI.scaleToFit(iconSource, avatarSize * 2, avatarSize * 2);
				icon.bitmapData = UI.getSnapshot(iconSource);
				iconSource = null;
			}
		}
		
		override protected function getStatusFormat(listData:Object):TextFormat 
		{
			var itemData:EscrowDealVO = listData as EscrowDealVO;
			if (isActive(itemData))
			{
				return format_status_active;
			}
			else if (isDealProblem(itemData))
			{
				return format_status_error;
			}
			return format_status;
		}
		
		override protected function getPrice(listData:Object):String {
			var itemData:EscrowDealVO = listData as EscrowDealVO;
			var res:String = "";
			if (itemData != null && itemData != null)
			{
				res = "@" + itemData.price + " " + itemData.currency;
			}
			
			return res;
		}
		
		override protected function isValidData(listData:Object):Boolean 
		{
			var itemData:EscrowDealVO = listData as EscrowDealVO;
			if (itemData != null && itemData.uid != null)
			{
				return true;
			}
			return false;
		}
		
		override protected function getAmount(listData:Object):String {
			var itemData:EscrowDealVO = listData as EscrowDealVO;
			
			if (itemData != null)
			{
				var result:String = "";
				
				var instrument:String = itemData.instrument;
				if (Lang[instrument] != null)
				{
					instrument = Lang[instrument];
				}
				if (itemData.side == TradeDirection.buy.type.toUpperCase()) {
					result += "<font color='#" + Color.GREEN.toString(16) + "'>" + Lang.BUY.toUpperCase() + " " + itemData.amount + " " + instrument + "</font>";
				} else {
					result += "<font color='#" + Color.RED.toString(16) + "'>" + Lang.sell.toUpperCase() + " " + itemData.amount + " " + instrument + "</font>";
				}
			}
			
			return result;
		}
		
		override protected function getTimeText(listData:Object):String {
			var itemData:EscrowDealVO = listData as EscrowDealVO;
			var result:String = "";
			if (itemData != null)
			{
				var timeValue:String = DateUtils.getComfortDateRepresentationWithMinutes(itemData.created);
				
				if (itemData != null)
				{
					if (itemData.side == TradeDirection.buy.type.toUpperCase()) {
						result += "<font color='#" + Color.GREEN.toString(16) + "'>" + timeValue + "</font>";
					} else {
						result += "<font color='#" + Color.RED.toString(16) + "'>" + timeValue + "</font>";
					}
				}
			}
			
			return result;
		}
		
		override protected function isClickable(listData:Object):Boolean 
		{
			var itemData:EscrowDealVO = listData as EscrowDealVO;
			
			if (itemData != null && itemData.uid != null)
			{
				return true;
			}
			return false;
		}
	}
}