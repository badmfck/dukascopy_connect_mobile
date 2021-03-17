package com.dukascopy.connect.gui.list.renderers.trade
{
	
	import assets.IconAttention2;
	import assets.IconOk2;
	import assets.WaitIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrderStatus;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.BaseRenderer;
	import com.dukascopy.connect.gui.list.renderers.IListRenderer;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.langs.Lang;
	import flash.display.IBitmapDrawable;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TradingOfferStatusRenderer extends BaseRenderer implements IListRenderer
	{
		
		private var tfPrice:TextField;
		private var tfCoins:TextField;
		private var tfMoney:TextField;
		private var tfResult:TextField;
		
		private var padding:int = Config.FINGER_SIZE * .3;
		private var itemHeight:int = Config.FINGER_SIZE * 1.4;
		private var LINE_HEIGHT:int = Config.FINGER_SIZE;
		private var paddingH:int = Config.FINGER_SIZE * .35;
		private var paddingV:int = Config.FINGER_SIZE * .1;
		private var format:TextFormat = new TextFormat(Config.defaultFontName, LINE_HEIGHT * .32, 0x5C6977);
		private var formatCoins:TextFormat = new TextFormat(Config.defaultFontName, LINE_HEIGHT * .32, 0x8699AD);
		private var formatMoney:TextFormat = new TextFormat(Config.defaultFontName, LINE_HEIGHT * .28, 0x8699AD);
		private var formatSuccess:TextFormat = new TextFormat(Config.defaultFontName, LINE_HEIGHT * .26, 0x89BF65);
		private var formatFail:TextFormat = new TextFormat(Config.defaultFontName, LINE_HEIGHT * .26, 0x980000);
		private var iconFailed:IconAttention2;
		private var iconSuccess:IconOk2;
		private var iconWait:WaitIcon;
		
		public function TradingOfferStatusRenderer()
		{
			
			tfPrice = new TextField();
			tfPrice.defaultTextFormat = format;
			tfPrice.text = "Pp";
			tfPrice.height = tfPrice.textHeight + 4;
			tfPrice.multiline = false;
			tfPrice.wordWrap = false;
			tfPrice.x = paddingH;
			tfPrice.y = paddingV;
			addChild(tfPrice);
			
			tfCoins = new TextField();
			tfCoins.defaultTextFormat = formatCoins;
			tfCoins.text = "Pp";
			tfCoins.height = tfCoins.textHeight + 4;
			tfCoins.multiline = false;
			tfCoins.wordWrap = false;
			tfCoins.y = paddingV;
			addChild(tfCoins);
			
			tfMoney = new TextField();
			tfMoney.defaultTextFormat = formatMoney;
			tfMoney.text = "Pp";
			tfMoney.height = tfMoney.textHeight + 4;
			tfMoney.multiline = false;
			tfMoney.wordWrap = false;
			tfMoney.y = int(Config.FINGER_SIZE * .54);
			addChild(tfMoney);
			
			tfResult = new TextField();
			tfResult.defaultTextFormat = formatSuccess;
			tfResult.text = "Pp";
			tfResult.height = tfResult.textHeight + 4;
			tfResult.multiline = true;
			tfResult.wordWrap = true;
			tfResult.y = paddingV;
			tfResult.y = int(Config.FINGER_SIZE * .9);
			addChild(tfResult);
			
			iconFailed = new IconAttention2();
			UI.scaleToFit(iconFailed, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
			addChild(iconFailed);
			
			iconSuccess = new IconOk2();
			UI.scaleToFit(iconSuccess, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
			addChild(iconSuccess);
			
			iconWait = new WaitIcon();
			UI.scaleToFit(iconWait, Config.FINGER_SIZE * .34, Config.FINGER_SIZE * .34);
			addChild(iconWait);
			
			iconFailed.y = int(itemHeight * .5 - iconFailed.height * .5);
			iconSuccess.y = int(itemHeight * .5 - iconSuccess.height * .5);
			iconWait.y = int(itemHeight * .5 - iconWait.height * .5);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int
		{
			setData(data.data as TradingOrderStatus, width, data.num + 1);
			return int(tfResult.y + tfResult.height + Config.FINGER_SIZE * .1);
		}
		
		public function getView(li:ListItem, h:int, widthValue:int, highlight:Boolean = false):IBitmapDrawable
		{
			iconFailed.visible = false;
			iconSuccess.visible = false;
			iconWait.visible = false;
			
			var data:TradingOrderStatus = li.data as TradingOrderStatus;
			
			graphics.clear();
			
			graphics.beginFill(0, .2);
			graphics.drawRect(paddingH, h - 1, widthValue - paddingH * 2, 1);
			graphics.endFill();
			
			setData(data, widthValue, li.num + 1);
			
			return this;
		}
		
		private function setData(data:TradingOrderStatus, widthValue:int, num:int):void 
		{
			tfCoins.width = widthValue;
			tfMoney.width = widthValue;
			tfResult.width = widthValue;
			
			tfPrice.text = num.toString() + ".    @" + data.order.priceString;
			tfPrice.width = widthValue - tfPrice.x - padding;
			
			tfCoins.text = data.quantity;
			tfCoins.width = tfCoins.textWidth + 4;
			tfCoins.x = int(widthValue - tfCoins.width - Config.FINGER_SIZE * 1.3);
			
			tfMoney.text = data.money;
			tfMoney.width = tfMoney.textWidth + 4;
			tfMoney.x = int(widthValue - tfMoney.width - Config.FINGER_SIZE * 1.3);
			
			var resultText:String = "";
			if (data.status == TradingOrderStatus.STATUS_NEW)
			{
				resultText = "";
				iconWait.visible = true;
				iconWait.x = int(widthValue - Config.FINGER_SIZE * .35 - paddingH - iconWait.width * .5);
			}
			else if (data.status == TradingOrderStatus.STATUS_FAILED)
			{
				resultText = Lang.failed + ": " + data.errorText;
				iconFailed.visible = true;
				iconFailed.x = int(widthValue - Config.FINGER_SIZE * .35 - paddingH - iconFailed.width * .5);
			}
			else if (data.status == TradingOrderStatus.STATUS_PROCESS)
			{
				resultText = Lang.inProcess;
				iconWait.visible = true;
				iconWait.x = int(widthValue - Config.FINGER_SIZE * .35 - paddingH - iconWait.width * .5);
			}
			else if (data.status == TradingOrderStatus.STATUS_SUCCESS)
			{
				resultText = Lang.success;
				iconSuccess.visible = true;
				iconSuccess.x = int(widthValue - Config.FINGER_SIZE * .35 - paddingH - iconSuccess.width * .5);
			}
			
			tfResult.text = resultText;
			
			if (data.status == TradingOrderStatus.STATUS_FAILED)
			{
				tfResult.setTextFormat(formatFail);
			}
			else if (data.status == TradingOrderStatus.STATUS_PROCESS)
			{
				tfResult.setTextFormat(formatSuccess);
			}
			else if (data.status == TradingOrderStatus.STATUS_SUCCESS)
			{
				tfResult.setTextFormat(formatSuccess);
			}
			
			tfResult.width = Math.min(tfResult.textWidth + 10, widthValue - Config.FINGER_SIZE * 2);
			tfResult.x = int(widthValue - tfResult.width - Config.FINGER_SIZE * 1.3);
			
			tfResult.height = tfResult.textHeight + 4;
		}
		
		public function dispose():void
		{
			graphics.clear();
			
			if (tfPrice != null)
				tfPrice.text = "";
			tfPrice = null;
			
			if (tfCoins != null)
				tfCoins.text = "";
			tfCoins = null;
			
			if (tfMoney != null)
				tfMoney.text = "";
			tfMoney = null;
			
			if (tfResult != null)
				tfResult.text = "";
			tfResult = null;
			
			format = null;
			formatCoins = null;
			formatMoney = null;
			formatSuccess = null;
			formatFail = null;
			format = null;
			
			if (iconFailed != null)
				UI.destroy(iconFailed);
			iconFailed = null;
			
			if (iconSuccess != null)
				UI.destroy(iconSuccess);
			iconSuccess = null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean
		{
			return true;
		}
	}
}