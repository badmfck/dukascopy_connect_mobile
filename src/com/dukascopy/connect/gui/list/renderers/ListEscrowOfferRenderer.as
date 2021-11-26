package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.data.escrow.EscrowStatus;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.managers.escrow.vo.EscrowOfferVO;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ListEscrowOfferRenderer extends ListEscrowAdsRenderer implements IListRenderer {
		
		public function ListEscrowOfferRenderer() {
			
			super();
		}
		
		override protected function getStatusText(listData:Object):String 
		{
			var itemData:EscrowOfferVO = listData as EscrowOfferVO;
			var result:String = "";
			if (itemData.data != null) {
				switch(itemData.data.status)
				{
					case EscrowStatus.offer_created:
					{
						result = Lang.escrow_offer_status_created;
						break;
					}
					case EscrowStatus.offer_accepted:
					{
						result = Lang.escrow_offer_status_accepted;
						break;
					}
					case EscrowStatus.offer_cancelled:
					{
						result = Lang.escrow_offer_status_cancelled;
						break;
					}
					case EscrowStatus.offer_expired:
					{
						result = Lang.escrow_offer_status_expired;
						break;
					}
					case EscrowStatus.offer_rejected:
					{
						result = Lang.escrow_offer_status_rejected;
						break;
					}
				}
			}
			return result;
		}
		
		override protected function updateItemAlpha(listData:Object):void 
		{
			var itemData:EscrowOfferVO = listData as EscrowOfferVO;
			
			if (itemData.data != null)
			{
				if (itemData.data.status == EscrowStatus.offer_expired ||
					itemData.data.status == EscrowStatus.offer_cancelled ||
					itemData.data.status == EscrowStatus.offer_accepted ||
					itemData.data.status == EscrowStatus.offer_rejected)
					alpha = .5;
				else
					alpha = 1;
			}
			else
			{
				alpha = 1;
				ApplicationErrors.add();
			}
		}
		
		override protected function drawIcon(listData:Object):void {
			
			var itemData:EscrowOfferVO = listData as EscrowOfferVO;
			
			var iconClass:Class = UI.getCryptoIconClass(itemData.data.instrument);
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
			var itemData:EscrowOfferVO = listData as EscrowOfferVO;
			return format_status;
		}
		
		override protected function getPrice(listData:Object):String {
			var itemData:EscrowOfferVO = listData as EscrowOfferVO;
			var res:String = "";
			if (itemData != null && itemData.data != null)
			{
				res = "@" + itemData.data.price + " " + itemData.data.currency;
			}
			
			return res;
		}
		
		override protected function isValidData(listData:Object):Boolean 
		{
			var itemData:EscrowOfferVO = listData as EscrowOfferVO;
			if (itemData != null && (listData as EscrowOfferVO).offer_id != null)
			{
				return true;
			}
			return false;
		}
		
		override protected function getAmount(listData:Object):String {
			var itemData:EscrowOfferVO = listData as EscrowOfferVO;
			
			if (itemData != null && itemData.data != null)
			{
				var result:String = "";
				
				var instrument:String = itemData.data.instrument;
				if (Lang[instrument] != null)
				{
					instrument = Lang[instrument];
				}
				if (itemData.data.direction == TradeDirection.buy) {
					result += "<font color='#" + Color.GREEN.toString(16) + "'>" + Lang.BUY.toUpperCase() + " " + itemData.data.amount + " " + instrument + "</font>";
				} else {
					result += "<font color='#" + Color.RED.toString(16) + "'>" + Lang.sell.toUpperCase() + " " + itemData.data.amount + " " + instrument + "</font>";
				}
			}
			
			return result;
		}
		
		override protected function getTimeText(listData:Object):String {
			var itemData:EscrowOfferVO = listData as EscrowOfferVO;
			var result:String = "";
			if (itemData != null)
			{
				var timeValue:String = DateUtils.getComfortDateRepresentationWithMinutes(itemData.created);
				
				if (itemData.data != null)
				{
					if (itemData.data.direction == TradeDirection.buy) {
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
			var itemData:EscrowOfferVO = listData as EscrowOfferVO;
			
			if (itemData != null && itemData.offer_id != null)
			{
				return true;
			}
			return false;
		}
	}
}