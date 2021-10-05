package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.data.escrow.EscrowStatus;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.gui.lightbox.UI;
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
				var timeValue:String = DateUtils.getComfortDateRepresentationWithMinutes(new Date(itemData.created));
				
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