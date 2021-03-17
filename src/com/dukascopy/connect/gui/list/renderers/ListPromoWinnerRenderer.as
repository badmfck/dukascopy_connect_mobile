package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.promoEvent.PromoEventWinner;
	import com.dukascopy.connect.gui.components.AvatarView;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ContactListRenderer;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.vo.users.adds.BotVO;
	import com.dukascopy.langs.Lang;
	import flash.display.IBitmapDrawable;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ListPromoWinnerRenderer extends ContactListRenderer {
		
		private var format:flash.text.TextFormat;
		private var formatCount:flash.text.TextFormat;
		private var countText:flash.text.TextField;
		private var formatTime:flash.text.TextFormat;
		private var timeText:flash.text.TextField;
		private var date:Date;
		
		public function ListPromoWinnerRenderer() { }
		
		override protected function create():void {
			super.create();
			
			formatCount = new TextFormat();
			formatCount.font = Config.defaultFontName;
			formatCount.size = Config.FINGER_SIZE * .44;
			formatCount.color = AppTheme.GREEN_MEDIUM;
			
			formatTime = new TextFormat();
			formatTime.font = Config.defaultFontName;
			formatTime.size = Config.FINGER_SIZE * .24;
			formatTime.color = AppTheme.GREY_MEDIUM;
			
			countText = new TextField();
				countText.defaultTextFormat = formatCount;
				countText.text = "Pp";
				countText.height = countText.textHeight + 4;
				countText.text = "";
				countText.wordWrap = false;
				countText.multiline = false;
			addChild(countText);
			
			timeText = new TextField();
				timeText.defaultTextFormat = formatTime;
				timeText.text = "Pp";
				timeText.height = timeText.textHeight + 4;
				timeText.text = "";
				timeText.wordWrap = false;
				timeText.multiline = false;
			addChild(timeText);
			
			date = new Date();
		}
		
		override protected function getItemData(itemData:Object):Object {
			if (itemData is PromoEventWinner)
			{
				return (itemData as PromoEventWinner).user;
			}
			
			return itemData;
		}
		
		override public function getView(item:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			super.getView(item, height, width, highlight)
			countText.visible = false;
			timeText.visible = false;
			
			if (item.data is PromoEventWinner)
			{
				nme.y = int((height - nme.height) * .5);
				fxnme.visible = false;
				iconInSystem.visible = false;
				
				var winData:PromoEventWinner = item.data as PromoEventWinner;
				
				var currency:String;
				if (winData.currency == TypeCurrency.EUR)
				{
					currency = "€";
				}
				else{
					currency = winData.currency;
				}
				
				date.setTime(winData.win_time * 1000);
				
				timeText.width = width;
				
				timeText.text = DateUtils.getComfortDateRepresentationOnlyDate(date);
				timeText.width = timeText.textWidth + 4;
				timeText.visible = true;
				timeText.height = timeText.textHeight + 4;
				timeText.x = int(width - timeText.width - Config.DOUBLE_MARGIN);
				timeText.y = int(Config.MARGIN * .5);
				
				countText.width = width * .5;
				if (winData.amount == 0)
				{
					countText.text = Lang.iphoneX;
				}
				else{
					countText.text = winData.amount + currency;
				}
				countText.width = countText.textWidth + 4;
				countText.y = int(timeText.y + timeText.height);
				countText.x = int(width - countText.width - Config.DOUBLE_MARGIN);
				countText.visible = true;
				
				nme.width = width - avatarSize * 2 - Config.FINGER_SIZE - countText.width;
			}
			
			return this;
		}
		
		override public function dispose():void {
			
			super.dispose();
			
			formatCount = null;
			formatCount = null;
			date = null;
			
			if (countText != null)
				UI.destroy(countText);
			countText = null;
			
			if (timeText != null)
				UI.destroy(timeText);
			countText = null;
		}
	}
}