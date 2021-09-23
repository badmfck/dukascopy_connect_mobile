package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import assets.EscrowAlert;
	import assets.EscrowClock;
	import assets.EscrowFail;
	import assets.EscrowSuccess;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.data.escrow.EscrowScreenNavigation;
	import com.dukascopy.connect.data.escrow.EscrowSettings;
	import com.dukascopy.connect.data.escrow.EscrowStatus;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.NumberFormat;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererEscrow extends Sprite implements IMessageRenderer {
		
		private var back:Shape;
		
		private var title:TextField;
		private var amount:TextField;
		private var price:TextField;
		private var priceAdditional:TextField;
		private var time:TextField;
		
		private var textFormatTitle:TextFormat = new TextFormat();
		private var textFormatAmount:TextFormat = new TextFormat();
		private var textFormatPrice:TextFormat = new TextFormat();
		private var textFormatPriceAdditional:TextFormat = new TextFormat();
		private var textFormatTime:TextFormat = new TextFormat();
		
		private var radiusBack:int;
		private var padding:int;
		private var currentBackColor:Number = 0x525F72;
		
		private var iconTime:Sprite;
		private var iconAlert:Sprite;
		private var iconSuccess:Sprite;
		private var iconFail:Sprite;
		private var iconCoin:Sprite;
		private var mainWidth:int;
		private var leftSideSize:int;
		private var maxTextWidth:int;
		private var paddingV:int;
		private var iconSize:int;
		
		public function ChatMessageRendererEscrow() {
			initTextFormats();
			create();
		}
		
		public function getContentHeight():Number {
			return back.height;
		}
		
		public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData
		{
			return null;
		}
		
		public function getWidth():uint {
			return back.width;
		}
		
		private function initTextFormats():void {
			textFormatTitle.font = Config.defaultFontName;
			textFormatTitle.size = FontSize.TITLE_2;
			textFormatTitle.color = Style.color(Style.COLOR_TEXT);
			textFormatTitle.align = TextFormatAlign.LEFT;
		//	textFormatTitle.bold = true;
			
			textFormatAmount.font = Config.defaultFontName;
			textFormatAmount.size = FontSize.BODY;
			textFormatAmount.color = Style.color(Style.COLOR_TEXT);
			textFormatAmount.align = TextFormatAlign.LEFT;
			
			textFormatPrice.font = Config.defaultFontName;
			textFormatPrice.size = FontSize.SUBHEAD;
			textFormatPrice.color = Style.color(Style.COLOR_TEXT);
			textFormatPrice.align = TextFormatAlign.LEFT;
			
			textFormatPriceAdditional.font = Config.defaultFontName;
			textFormatPriceAdditional.size = FontSize.SUBHEAD;
			textFormatPriceAdditional.color = Style.color(Style.COLOR_SUBTITLE);
			textFormatPriceAdditional.align = TextFormatAlign.LEFT;
			
			textFormatTime.font = Config.defaultFontName;
			textFormatTime.size = FontSize.CAPTION_1;
			textFormatTime.color = Color.WHITE;
			textFormatTime.align = TextFormatAlign.CENTER;
		}
		
		public function updateHitzones(itemHitzones:Array):void {
			itemHitzones.push( { type:HitZoneType.BALLOON, x:x , y:y, width: back.width, height: back.height } );
		}
		
		public function getBackColor():Number {
			return currentBackColor;
		}
		
		private function create():void {
			
			radiusBack = Math.ceil(Config.FINGER_SIZE * .3);
			padding = Config.FINGER_SIZE * .3;
			paddingV = Config.FINGER_SIZE * .2;
			mainWidth = Config.FINGER_SIZE * 5;
			leftSideSize = Config.FINGER_SIZE * 1.17;
			maxTextWidth = mainWidth - leftSideSize - padding * 2;
			iconSize = Config.FINGER_SIZE * .43;
			
			back = new Shape();
			addChild(back);
			
			createTextFields();
			createIcons();
			
			var textPosition:int = leftSideSize + padding;
			
			title.x = textPosition;
			title.y = paddingV;
			amount.x = textPosition;
			price.x = textPosition;
			
			iconTime.x = int(leftSideSize * .5 - iconTime.width * .5);
			iconAlert.x = int(leftSideSize * .5 - iconAlert.width * .5);
			iconFail.x = int(leftSideSize * .5 - iconFail.width * .5);
			iconSuccess.x = int(leftSideSize * .5 - iconSuccess.width * .5);
		}
		
		private function createIcons():void 
		{
			var iconSize:int = Config.FINGER_SIZE * .46;
			iconTime = new EscrowClock();
			addChild(iconTime);
			UI.scaleToFit(iconTime, iconSize, iconSize);
			
			iconSize = Config.FINGER_SIZE * .32;
			iconAlert = new EscrowAlert();
			addChild(iconAlert);
			UI.scaleToFit(iconAlert, iconSize, iconSize);
			
			iconSize = Config.FINGER_SIZE * .5;
			iconFail = new EscrowFail();
			addChild(iconFail);
			UI.scaleToFit(iconFail, iconSize, iconSize);
			
			iconSize = Config.FINGER_SIZE * .64;
			iconSuccess = new EscrowSuccess();
			addChild(iconSuccess);
			UI.scaleToFit(iconSuccess, iconSize, iconSize);
		}
		
		private function createTextFields():void 
		{
			amount = new TextField();
				amount.defaultTextFormat = textFormatAmount;
				amount.text = "1:00";
				amount.height = amount.textHeight + 4;
				amount.width = amount.textWidth + 4 + padding;
				amount.text = "";
				amount.wordWrap = false;
				amount.multiline = false;
			addChild(amount);
			
			title = new TextField();
				title.defaultTextFormat = textFormatTitle;
				title.text = "1:00";
				title.height = title.textHeight + 4;
				title.width = title.textWidth + 4 + padding;
				title.text = "";
				title.wordWrap = true;
				title.multiline = true;
			addChild(title);
			
			price = new TextField();
				price.defaultTextFormat = textFormatPrice;
				price.wordWrap = true;
				price.multiline = true;
			addChild(price);
			
			priceAdditional = new TextField();
				priceAdditional.defaultTextFormat = textFormatPriceAdditional;
				priceAdditional.wordWrap = true;
				priceAdditional.multiline = true;
			addChild(priceAdditional);
			
			time = new TextField();
				time.defaultTextFormat = textFormatTime;
				time.wordWrap = true;
				time.multiline = true;
			addChild(time);
		}
		
		public function getHeight(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem):uint
		{
			if (messageData != null && 
				messageData.systemMessageVO != null && 
				messageData.systemMessageVO.type == ChatSystemMsgVO.TYPE_ESCROW_OFFER && 
				messageData.systemMessageVO.escrow != null)
			{
				setTexts(messageData.systemMessageVO.escrow, maxWidth, messageData);
				return int(price.y + price.height + paddingV);
			}
			else {
			 	return Config.FINGER_SIZE * 1.2;
			}
		}
		
		private function setTexts(data:EscrowMessageData, maxWidth:int, messageData:ChatMessageVO):void 
		{
			title.width = maxTextWidth;
			title.text = getTitleText(data, messageData);
			title.width = title.textWidth + 5;
			title.height = title.textHeight + 5;
			
			amount.width = maxTextWidth - iconSize - Config.FINGER_SIZE * .15;
			amount.text = getAmountText(data);
			amount.textColor = getAmountColor(data.status, messageData);
			amount.width = amount.textWidth + 5;
			amount.height = amount.textHeight + 5;
			
			amount.y = int(title.y + title.height + paddingV * 0.4);
			
			price.width = maxTextWidth;
			price.htmlText = getPriceText(data);
			price.textColor = getAmountColor(data.status, messageData);
			price.width = price.textWidth + 5;
			price.height = price.textHeight + 5;
			
			price.y = int(amount.y + amount.height + paddingV * 0.4);
		}
		
		private function getAmountColor(status:EscrowStatus, messageData:ChatMessageVO):Number 
		{
			var result:Number = Style.color(Style.COLOR_TEXT);
			switch (status)
			{
				case EscrowStatus.offer_created:
				{
					if (EscrowScreenNavigation.isExpired(messageData.systemMessageVO.escrow, messageData.created) && messageData.systemMessageVO.escrow.inactive == false)
					{
						result =  Style.color(Style.COLOR_SUBTITLE);
					}
					
					break;
				}
				case EscrowStatus.offer_rejected:
				{
					result =  Style.color(Style.COLOR_SUBTITLE);
					break;
				}
				case EscrowStatus.offer_cancelled:
				{
					result =  Style.color(Style.COLOR_SUBTITLE);
					break;
				}
			}
			return result;
		}
		
		private function getPriceText(data:EscrowMessageData):String 
		{
			//!TODO: per coin now добавить;
			var result:String = Lang.price_per_coin;
			result = result.replace(Lang.regExtValue, data.price + " " + getCurrency(data));
			
			if (data.status == EscrowStatus.deal_completed ||
				data.status == EscrowStatus.deal_created ||
				data.status == EscrowStatus.deal_mca_hold ||
				data.status == EscrowStatus.paid_crypto)
			{
				result += "<br><br><font color='#24835C'>\n\n" + Lang.tapToUpenForm + "</font>";
			}
			
			return result;
		}
		
		private function getAmountText(data:EscrowMessageData):String 
		{
			return NumberFormat.formatAmount(data.amount, data.instrument);
		}
		
		private function getCurrency(data:EscrowMessageData):String 
		{
			var result:String = data.currency;
			if (Lang[result] != null && Lang[result] != "")
			{
				result = Lang[result];
			}
			return result;
		}
		
		private function getTitleText(data:EscrowMessageData, messageData:ChatMessageVO):String 
		{
			var status:EscrowStatus = data.status;
			var direction:TradeDirection = data.direction;
			
			var result:String = "";
			if (EscrowScreenNavigation.isExpired(messageData.systemMessageVO.escrow, messageData.created) && data.inactive == false)
			{
				if (messageData.systemMessageVO.escrow.status == EscrowStatus.deal_created ||
					messageData.systemMessageVO.escrow.status == EscrowStatus.deal_mca_hold ||
					messageData.systemMessageVO.escrow.status == EscrowStatus.paid_crypto)
				{
					result = Lang.deal_expired;
				}
				else
				{
					result = Lang.offer_expired;
				}
			}
			else
			{
				switch (status)
				{
					case EscrowStatus.offer_expired:
					{
						result = Lang.offer_expired;
						
						break;
					}
					case EscrowStatus.offer_created:
					{
						if (direction == TradeDirection.buy)
						{
							if (data.mca_user_uid == Auth.uid)
							{
								result = Lang.escrow_to_buy;
							}
							else
							{
								result = Lang.escrow_to_buy;
							}
							
						}
						else if(direction == TradeDirection.sell)
						{
							if (data.crypto_user_uid == Auth.uid)
							{
								result = Lang.escrow_to_sell;
							}
							else
							{
								result = Lang.escrow_to_sell;
							}
						}
						
						break;
					}
					case EscrowStatus.offer_accepted:
					{
						if (direction == TradeDirection.buy)
						{
							result = Lang.offer_accepted_by_seller;
						}
						else if(direction == TradeDirection.sell)
						{
							result = Lang.offer_accepted_by_buyer;
						}
						
						break;
					}
					case EscrowStatus.offer_rejected:
					{
						result = Lang.offer_was_rejected;
						
						break;
					}
					case EscrowStatus.offer_cancelled:
					{
						result = Lang.offer_was_cancelled;
						
						break;
					}
					case EscrowStatus.deal_created:
					{
					//	result = Lang.waiting_for_money_hold;
						result = Lang.deal_created;
						
						break;
					}
					case EscrowStatus.deal_mca_hold:
					{
						if (data.mca_user_uid == Auth.uid)
						{
							result = Lang.waiting_for_crypto;
						}
						else
						{
							result = Lang.escrow_tap_deal_form;
						}
						
						break;
					}
					case EscrowStatus.paid_crypto:
					{
						if (direction == TradeDirection.buy)
						{
							if (data.mca_user_uid == Auth.uid)
							{
								result = Lang.escrow_seller_sent_crypto_transaction;
								if (data.transactionId != null)
								{
									result += ":\n" + data.transactionId;
								}
							}
							else
							{
								result = Lang.escrow_waiting_receipt_confirm;
							}
						}
						else if(direction == TradeDirection.sell)
						{
							if (data.crypto_user_uid == Auth.uid)
							{
								result = Lang.escrow_waiting_receipt_confirm;
							}
							else
							{
								result = Lang.escrow_seller_sent_crypto_transaction;
								if (data.transactionId != null)
								{
									result += ":\n" + data.transactionId;
								}
							}
						}
						
						break;
					}
					case EscrowStatus.deal_completed:
					{
						result = Lang.escrow_deal_completed;
						
						break;
					}
				}
			}
			
			return result;
		}
		
		public function draw(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null, minWidth:int = -1):void
		{
			if (messageData != null && 
				messageData.systemMessageVO != null && 
				messageData.systemMessageVO.type == ChatSystemMsgVO.TYPE_ESCROW_OFFER && 
				messageData.systemMessageVO.escrow != null)
			{
				setTexts(messageData.systemMessageVO.escrow, maxWidth, messageData);
				
				var resultHeight:int = price.y + price.height + paddingV;
				
				var leftColor:Number = getSideColor(messageData.systemMessageVO.escrow.status, messageData.systemMessageVO.escrow.direction, messageData);
				
				back.graphics.clear();
				
				back.graphics.beginFill(leftColor);
				back.graphics.drawRoundRectComplex(0, 0, leftSideSize, resultHeight, radiusBack, 0, radiusBack, 0);
				back.graphics.endFill();
				
				back.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				back.graphics.drawRoundRectComplex(leftSideSize, 0, mainWidth - leftSideSize, resultHeight, 0, radiusBack, 0, radiusBack);
				back.graphics.endFill();
				
				iconTime.visible = false;
				iconAlert.visible = false;
				iconFail.visible = false;
				iconSuccess.visible = false;
				
				iconTime.y = Math.max(int(resultHeight * .5 - Config.FINGER_SIZE * .1 - iconTime.height), int(Config.FINGER_SIZE * .2));
				iconAlert.y = int(resultHeight * .5 - iconAlert.height * .5);
				iconFail.y = int(resultHeight * .5 - iconFail.height * .5);
				iconSuccess.y = int(resultHeight * .5 - iconSuccess.height * .5);
				
				if (messageData.systemMessageVO.escrow.inactive == true)
				{
					amount.alpha = 0.4;
					title.alpha = 0.6;
					price.alpha = 0.4;
					if (iconCoin)
					{
						iconCoin.alpha = 0.4;
					}
				}
				else
				{
					amount.alpha = 1;
					title.alpha = 1;
					price.alpha = 1;
					if (iconCoin)
					{
						iconCoin.alpha = 1;
					}
				}
				
				if (messageData.systemMessageVO.escrow.status == EscrowStatus.offer_created)
				{
					iconTime.visible = true;
					time.visible = true;
					
					time.width = leftSideSize - Config.FINGER_SIZE * .1 * 2;
					if (EscrowScreenNavigation.isExpired(messageData.systemMessageVO.escrow, messageData.created) && messageData.systemMessageVO.escrow.inactive == false)
					{
						iconFail.visible = true;
						iconTime.visible = false;
						time.visible = false;
					//	time.text = Lang.offer_expired;
					}
					else
					{
						time.text = gettimeDifference(getMaxTime(messageData.systemMessageVO.escrow.status) * 60 - ((new Date()).time / 1000 - messageData.created));
					}
					
					time.width = time.textWidth + 5;
					time.height = time.textHeight + 5;
					
					time.x = int(leftSideSize * .5 - time.width * .5);
					time.y = int(resultHeight * .5 + Config.FINGER_SIZE * .05);
				}
				else if (messageData.systemMessageVO.escrow.inactive == false && 
						 (messageData.systemMessageVO.escrow.status == EscrowStatus.deal_created || messageData.systemMessageVO.escrow.status == EscrowStatus.deal_mca_hold || messageData.systemMessageVO.escrow.status == EscrowStatus.paid_crypto))
				{
					iconTime.visible = false;
					time.visible = false;
					//!TODO: передать верное время
					if (EscrowScreenNavigation.isExpired(messageData.systemMessageVO.escrow, messageData.created) && messageData.systemMessageVO.escrow.inactive == false)
					{
						iconFail.visible = true;
						UI.colorize(iconSuccess, getIconColor(messageData.systemMessageVO.escrow.status, messageData.systemMessageVO.escrow.direction, messageData));
					}
					else
					{
						iconTime.visible = true;
						time.visible = true;
						
						time.width = leftSideSize - Config.FINGER_SIZE * .1 * 2;
						
						time.text = gettimeDifference(getMaxTime(messageData.systemMessageVO.escrow.status) - ((new Date()).time / 1000 - messageData.created));
						
						time.width = time.textWidth + 5;
						time.height = time.textHeight + 5;
						
						time.x = int(leftSideSize * .5 - time.width * .5);
						time.y = int(resultHeight * .5 + Config.FINGER_SIZE * .05);
					}
				}
				else if (messageData.systemMessageVO.escrow.status == EscrowStatus.offer_expired)
				{
					iconFail.visible = true;
					iconTime.visible = false;
					time.visible = false;
				}
				else if (messageData.systemMessageVO.escrow.inactive == true)
				{
					iconTime.visible = false;
					time.visible = false;
					
					iconSuccess.visible = true;
					UI.colorize(iconSuccess, getIconColor(messageData.systemMessageVO.escrow.status, messageData.systemMessageVO.escrow.direction, messageData));
				}
				else if (messageData.systemMessageVO.escrow.status == EscrowStatus.deal_completed)
				{
					iconTime.visible = false;
					time.visible = false;
					
					iconSuccess.visible = true;
					UI.colorize(iconSuccess, getIconColor(messageData.systemMessageVO.escrow.status, messageData.systemMessageVO.escrow.direction, messageData));
				}
				else if (messageData.systemMessageVO.escrow.status == EscrowStatus.offer_accepted)
				{
					iconTime.visible = false;
					time.visible = false;
					if (EscrowScreenNavigation.isExpired(messageData.systemMessageVO.escrow, messageData.created) && messageData.systemMessageVO.escrow.inactive == false)
					{
						iconFail.visible = true;
						UI.colorize(iconSuccess, getIconColor(messageData.systemMessageVO.escrow.status, messageData.systemMessageVO.escrow.direction, messageData));
					}
					else
					{
						iconSuccess.visible = true;
						UI.colorize(iconSuccess, getIconColor(messageData.systemMessageVO.escrow.status, messageData.systemMessageVO.escrow.direction, messageData));
					}
				}
				else if (messageData.systemMessageVO.escrow.status == EscrowStatus.offer_rejected)
				{
					iconTime.visible = false;
					time.visible = false;
					iconFail.visible = true;
					UI.colorize(iconSuccess, getIconColor(messageData.systemMessageVO.escrow.status, messageData.systemMessageVO.escrow.direction, messageData));
				}
				else if (messageData.systemMessageVO.escrow.status == EscrowStatus.offer_cancelled)
				{
					iconTime.visible = false;
					time.visible = false;
					iconFail.visible = true;
					UI.colorize(iconSuccess, getIconColor(messageData.systemMessageVO.escrow.status, messageData.systemMessageVO.escrow.direction, messageData));
				}
				else
				{
					time.visible = false;
				}
				
				var IconClass:Class = getIconClass(messageData.systemMessageVO.escrow);
				if (IconClass != null)
				{
					if (iconCoin == null || !(iconCoin is IconClass))
					{
						UI.destroy(iconCoin);
						iconCoin = new IconClass() as Sprite;
						UI.scaleToFit(iconCoin, iconSize, iconSize);
						addChild(iconCoin);
						iconCoin.x = leftSideSize + padding;
					}
					iconCoin.y = int(amount.y + amount.height * .5 - iconCoin.height * .5);
					iconCoin.visible = true;
					amount.x = leftSideSize + padding + iconSize + Config.FINGER_SIZE*.15;
				}
				else
				{
					amount.x = leftSideSize + padding;
					if (iconCoin != null)
					{
						iconCoin.visible = false;
					}
				}
			}
		}
		
		private function getMaxTime(status:EscrowStatus):Number 
		{
			if (status == EscrowStatus.offer_created)
			{
				return EscrowSettings.offerMaxTime;
			}
			else if (status == EscrowStatus.deal_created)
			{
				return EscrowSettings.dealMaxTime;
			}
			else if (status == EscrowStatus.deal_mca_hold)
			{
				return EscrowSettings.dealMaxTime;
			}
			else if (status == EscrowStatus.paid_crypto)
			{
				return EscrowSettings.receiptConfirmationTime;
			}
			
			return EscrowSettings.offerMaxTime;
		}
		
		private function getIconColor(status:EscrowStatus, direction:TradeDirection, messageData:ChatMessageVO):Number 
		{
			if (EscrowScreenNavigation.isExpired(messageData.systemMessageVO.escrow, messageData.created) && messageData.systemMessageVO.escrow.inactive == false)
			{
				return Color.GREY_SUPER_LIGHT;
			}
			else
			{
				switch(status)
				{
					case EscrowStatus.offer_accepted:
					{
						if (direction == TradeDirection.buy)
						{
							if (messageData.userUID == Auth.uid)
							{
								return Color.GREEN;
							}
							else
							{
								return Color.RED;
							}
						}
						else if (direction == TradeDirection.sell)
						{
							if (messageData.userUID == Auth.uid)
							{
								return Color.RED;
							}
							else
							{
								return Color.GREEN;
							}
						}
						break;
					}
					case EscrowStatus.offer_rejected:
					{
						return Color.GREY_SUPER_LIGHT;
						break;
					}
					case EscrowStatus.offer_cancelled:
					{
						return Color.GREY_SUPER_LIGHT;
						break;
					}
					case EscrowStatus.deal_created:
					{
						if (messageData.systemMessageVO.escrow.inactive == true)
						{
							return Color.GREY_DARK;
						}
						return Color.WHITE;
						break;
					}
					case EscrowStatus.deal_mca_hold:
					{
						if (messageData.systemMessageVO.escrow.inactive == true)
						{
							return Color.GREY_DARK;
						}
						return Color.WHITE;
						break;
					}
					case EscrowStatus.paid_crypto:
					{
						if (messageData.systemMessageVO.escrow.inactive == true)
						{
							return Color.GREY_DARK;
						}
						return Color.WHITE;
						break;
					}
					case EscrowStatus.deal_completed:
					{
						return Color.BLACK;
						break;
					}
				}
			}
			
			return Color.GREY_SUPER_LIGHT;
		}
		
		private function gettimeDifference(seconds:int):String 
		{
			var result:String;
			if (seconds < 60)
			{
				result = seconds + " " + Lang.sec;
			}
			else
			{
				result = Math.ceil(seconds/60) + " " + Lang.min;
			}
			result += " " + Lang.left;
			return result;
		}
		
		private function getMessageTime(messageData:ChatMessageVO):Number 
		{
			return ((new Date()).time / 1000 - messageData.created) / 60;
		}
		
		private function getIconClass(escrow:EscrowMessageData):Class 
		{
			if (escrow != null && escrow.instrument != null)
			{
				return UI.getCryptoIconClass(escrow.instrument);
			}
			return null;
		}
		
		private function getSideColor(status:EscrowStatus, direction:TradeDirection, messageData:ChatMessageVO):Number 
		{
			if (EscrowScreenNavigation.isExpired(messageData.systemMessageVO.escrow, messageData.created) && messageData.systemMessageVO.escrow.inactive == false)
			{
				return Color.GREY;
			}
			else
			{
				switch(status)
				{
					case EscrowStatus.offer_expired:
					{
						return Color.GREY;
						break;
					}
					case EscrowStatus.offer_created:
					{
						if (direction == TradeDirection.buy)
						{
							if (messageData.userUID == Auth.uid)
							{
								return Color.GREEN;
							}
							else
							{
								return Color.GREEN;
							//	return Color.RED;
							}
						}
						else if (direction == TradeDirection.sell)
						{
							if (messageData.userUID == Auth.uid)
							{
								return Color.GREEN;
							//	return Color.RED;
							}
							else
							{
								return Color.GREEN;
							}
						}
						break;
					}
					case EscrowStatus.offer_accepted:
					{
						if (direction == TradeDirection.buy)
						{
							if (messageData.userUID == Auth.uid)
							{
								return Color.GREEN_10;
							}
							else
							{
								return Color.RED_10;
							}
						}
						else if (direction == TradeDirection.sell)
						{
							if (messageData.userUID == Auth.uid)
							{
								return Color.RED_10;
							}
							else
							{
								return Color.GREEN_10;
							}
						}
						break;
					}
					case EscrowStatus.offer_rejected:
					{
						return Color.GREY;
						break;
					}
					case EscrowStatus.offer_cancelled:
					{
						return Color.GREY;
						break;
					}
					case EscrowStatus.deal_created:
					{
						if (messageData.systemMessageVO.escrow.inactive == true)
						{
							return Color.GREY_LIGHT;
						}
						return Color.GREY_DARK;
						break;
					}
					case EscrowStatus.deal_mca_hold:
					{
						if (messageData.systemMessageVO.escrow.inactive == true)
						{
							return Color.GREY_LIGHT;
						}
						return Color.GREY_DARK;
						break;
					}
					case EscrowStatus.paid_crypto:
					{
						if (messageData.systemMessageVO.escrow.inactive == true)
						{
							return Color.GREY_LIGHT;
						}
						return Color.GREY_DARK;
						break;
					}
					case EscrowStatus.deal_completed:
					{
						return Color.GREY_SUPER_LIGHT;
						break;
					}
				}
			}
			
			return Color.RED;
		}
		
		public function dispose():void {		
			UI.destroy(back);
			back = null;
			
			UI.destroy(amount);
			amount = null;
			
			UI.destroy(title);
			title = null;
			
			UI.destroy(price);
			price = null;
			
			UI.destroy(iconTime);
			iconTime = null;
			
			UI.destroy(iconAlert);
			iconAlert = null;
			
			UI.destroy(iconSuccess);
			iconSuccess = null;
			
			UI.destroy(iconFail);
			iconFail = null;
			
			UI.destroy(time);
			time = null;
			
			UI.destroy(iconCoin);
			iconCoin = null;
			
			textFormatTitle = null;
			textFormatAmount = null;
			textFormatPrice = null;
			textFormatPriceAdditional = null;
			textFormatTime = null;
		}
		
		public function get animatedZone():AnimatedZoneVO {
			return null;
		}
		
		public function get isReadyToDisplay():Boolean {
			return true;
		}
		
		public function getSmallGap(listItem:ListItem):int {
			return ChatMessageRendererBase.smallGap;
		}
	}
}