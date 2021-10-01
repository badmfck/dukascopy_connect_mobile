package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.managers.escrow.vo.EscrowOfferVO;
	import com.dukascopy.langs.Lang;
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
			if (itemData.status) {
				result = Lang.escrow_offer_closed;
			}
			return result;
		}
		
		override protected function getStatusFormat(listData:Object):TextFormat 
		{
			var itemData:EscrowOfferVO = listData as EscrowOfferVO;
			
			/*if (itemData.mine && itemData.answersCount > 0)
				return format6;
			else
				return format_status;
			
			if (itemData.status == EscrowAdsVO.STATUS_RESOLVED || itemData.status == EscrowAdsVO.STATUS_CLOSED) {
				return format_status;
			}*/
			
			return null;
		}
		
		override protected function getPrice(listData:Object):String {
			var itemData:EscrowOfferVO = listData as EscrowOfferVO;
			
			/*var res:String = "@" + itemData.price + " " + itemData.currency;
			var percent:String = itemData.percent;
			if (percent != null)
				res += ", <font color='#BEBEBE'>MKT " + percent + "</font>";
			return res;*/
			
			return "";
		}
		
		override protected function getAmount(listData:Object):String {
			var itemData:EscrowOfferVO = listData as EscrowOfferVO;
			
			/*var result:String = "";
			if (itemData.side == "buy") {
				result += "<font color='#" + Color.GREEN.toString(16) + "'>" + Lang.BUY.toUpperCase() + " " + itemData.amount + " " + itemData.crypto + "</font>";
			} else {
				result += "<font color='#" + Color.RED.toString(16) + "'>" + Lang.sell.toUpperCase() + " " + itemData.amount + " " + itemData.crypto + "</font>";
			}
			if (itemData.mine == true) {
				textFieldAmount.htmlText = textFieldAmount.htmlText + " (" + Lang.mine.toUpperCase() + ")";
			}
			return result;*/
			
			return "";
		}
		
		override protected function getTimeText(listData:Object):String {
			var itemData:EscrowOfferVO = listData as EscrowOfferVO;
			
			/*var date:Date = new Date(Number(itemData.created * 1000));
			
			var timeValue:String = DateUtils.getComfortDateRepresentationWithMinutes(date);
			var result:String = "";
			if (itemData.side == "buy") {
				result += "<font color='#" + Color.GREEN.toString(16) + "'>" + timeValue + "</font>";
			} else {
				result += "<font color='#" + Color.RED.toString(16) + "'>" + timeValue + "</font>";
			}
			
			return result;*/
			
			return "";
		}
		
		override protected function isClickable(listData:Object):Boolean 
		{
			var itemData:EscrowOfferVO = listData as EscrowOfferVO;
			
			if (itemData != null && itemData.id != 0)
			{
				return true;
			}
			return false;
		}
	}
}