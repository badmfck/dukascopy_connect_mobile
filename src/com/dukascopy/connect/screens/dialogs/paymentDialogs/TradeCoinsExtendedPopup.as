package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import assets.BigRefreshButton;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.coinMarketplace.CoinBestProposal;
	import com.dukascopy.connect.data.coinMarketplace.PaymentsAccountsProvider;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrderRequest;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrderStatus;
	import com.dukascopy.connect.data.coinMarketplace.TradingResponse;
	import com.dukascopy.connect.data.screenAction.customActions.TradeCoinsAction;
	import com.dukascopy.connect.gui.components.ComissionView;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.trade.TradingOfferStatusRenderer;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.CoinComissionChecker;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power1;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class TradeCoinsExtendedPopup extends BaseScreen {
		
		static public const STATE_START:String = "stateStart";
		static public const STATE_SUCCESS:String = "stateSuccess";
		static public const STATE_PROGRESS:String = "stateProgress";
		
		private var container:Sprite;
		private var bg:Shape;
		private var acceptButton:BitmapButton;
		private var backButton:BitmapButton;
		private var preloader:HorizontalPreloader;
		private var componentsWidth:int;
		private var amountTitle:Bitmap;
		private var lotsTitle:Bitmap;
		private var screenLocked:Boolean;
		private var verticalMargin:int;
		private var tradeSide:String;
		private var inputCoins:InputField;
		private var accounts:PaymentsAccountsProvider;
		private var padding:int;
		private var lotsValue:Bitmap;
		private var bestProposal:CoinBestProposal;
		private var currentProposal:Array;
		private var averagePriceTitle:Bitmap;
		private var bestPriceTitle:Bitmap;
		private var worstPriceTitle:Bitmap;
		private var averagePriceValue:Bitmap;
		private var bestPriceValue:Bitmap;
		private var worstPriceValue:Bitmap;
		private var priceLimitSwitch:OptionSwitcher;
		private var inputLimitPrice:InputField;
		private var totalMoneyValue:Bitmap;
		private var state:String;
		private var avaliableMoneyValue:Bitmap;
		private var currentTotalMoney:Number;
		private var refreshButton:BitmapButton;
		private var currentAction:TradeCoinsAction;
		private var currentRequest:TradingOrderRequest;
		private var ordersList:List;
		private var orderStatuses:Array;
		private var animation:Sprite;
		private var mainTitle:Bitmap;
		private var locked:Boolean;
		private var mainTitleRight:Bitmap;
		private var inAnimationShow:Boolean;
		private var inAnimationHide:Boolean;
		private var finalSumTitle:Bitmap;
		private var finalSumValue:Bitmap;
		private var finalPriceTitle:Bitmap;
		private var finalPriceValue:Bitmap;
		private var finalStartValue:Bitmap;
		private var finalAmountTitle:Bitmap;
		private var finalAmountValue:Bitmap;
		private var titleBMP:Bitmap;
		private var scrollPanel:ScrollPanel;
		private var constructed:Boolean;
		private var commisionText:ComissionView;
		private var _lastCommissionCallID:String;
		private var commissionText:String;
		private var comission:CoinComissionChecker;
		
		public function TradeCoinsExtendedPopup() {
			
		}
		
		override protected function createView():void {
			super.createView();
			container = new Sprite();
			
			bg = new Shape();
			container.addChild(bg);
			
			scrollPanel = new ScrollPanel();
				scrollPanel.background = false;
			container.addChild(scrollPanel.view);
			
			titleBMP = new Bitmap();
			titleBMP.y = int(Config.FINGER_SIZE * .3);
			titleBMP.x = Config.DIALOG_MARGIN;
			container.addChild(titleBMP);
			
			amountTitle = new Bitmap();
			container.addChild(amountTitle);
			
			lotsTitle = new Bitmap();
			scrollPanel.addObject(lotsTitle);
			
			lotsValue = new Bitmap();
			scrollPanel.addObject(lotsValue);
			
			averagePriceTitle = new Bitmap();
			scrollPanel.addObject(averagePriceTitle);
			
			bestPriceTitle = new Bitmap();
			scrollPanel.addObject(bestPriceTitle);
			
			worstPriceTitle = new Bitmap();
			scrollPanel.addObject(worstPriceTitle);
			
			averagePriceTitle = new Bitmap();
			scrollPanel.addObject(averagePriceTitle);
			
			bestPriceValue = new Bitmap();
			scrollPanel.addObject(bestPriceValue);
			
			worstPriceValue = new Bitmap();
			scrollPanel.addObject(worstPriceValue);
			
			averagePriceValue = new Bitmap();
			scrollPanel.addObject(averagePriceValue);
			
			totalMoneyValue = new Bitmap();
			scrollPanel.addObject(totalMoneyValue);
			
			avaliableMoneyValue = new Bitmap();
			scrollPanel.addObject(avaliableMoneyValue);
			
			mainTitle = new Bitmap();
			container.addChild(mainTitle);
			
			mainTitleRight = new Bitmap();
			container.addChild(mainTitleRight);
			
			finalSumTitle = new Bitmap();
			container.addChild(finalSumTitle);
			
			finalSumValue = new Bitmap();
			container.addChild(finalSumValue);
			
			finalStartValue = new Bitmap();
			container.addChild(finalStartValue);
			
			finalPriceTitle = new Bitmap();
			container.addChild(finalPriceTitle);
			
			finalPriceValue = new Bitmap();
			container.addChild(finalPriceValue);
			
			finalAmountTitle = new Bitmap();
			container.addChild(finalAmountTitle);
			
			finalAmountValue = new Bitmap();
			container.addChild(finalAmountValue);
			
			acceptButton = new BitmapButton();
			acceptButton.setStandartButtonParams();
			acceptButton.setDownScale(1);
			acceptButton.setDownColor(0);
			acceptButton.tapCallback = nextClick;
			acceptButton.disposeBitmapOnDestroy = true;
			acceptButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(acceptButton);
			
			refreshButton = new BitmapButton();
			refreshButton.setStandartButtonParams();
			refreshButton.setDownScale(1);
			refreshButton.setDownColor(0);
			refreshButton.tapCallback = refreshClick;
			refreshButton.disposeBitmapOnDestroy = true;
			refreshButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			scrollPanel.addObject(refreshButton);
			
			var icon:BigRefreshButton = new BigRefreshButton();
			UI.scaleToFit(icon, Config.FINGER_SIZE * .8, Config.FINGER_SIZE * .8);
			refreshButton.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "TradeCoinsExtendedPopup.refreshButton"));
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
			
			inputCoins = new InputField(4);
			inputCoins.onSelectedFunction = onInputSelected;
			inputCoins.onChangedFunction = onChangeInputCoins;
			container.addChild(inputCoins);
			
			inputLimitPrice = new InputField(2);
			inputLimitPrice.onSelectedFunction = onInputSelected;
			inputLimitPrice.onChangedFunction = onChangeLimit;
			scrollPanel.addObject(inputLimitPrice);
			inputLimitPrice.alpha = 0.5;
			
			priceLimitSwitch = new OptionSwitcher();
			priceLimitSwitch.onSwitchCallback = switchLimit;
			scrollPanel.addObject(priceLimitSwitch);
			
			preloader = new HorizontalPreloader(0xF6951D);
			container.addChild(preloader);
			
			commisionText = new ComissionView();
			scrollPanel.addObject(commisionText);
			
			view.addChild(container);
		}
		
		private function refreshClick():void 
		{
			preloader.start();
			bestProposal.refresh();
		}
		
		private function onChangeLimit():void 
		{
			updateValues();
		}
		
		private function switchLimit(selected:Boolean):void 
		{
			priceLimitSwitch.isSelected = selected;
			updateValues();
			
			if (selected)
			{
				inputLimitPrice.activate();
				inputLimitPrice.alpha = 1;
			}
			else
			{
				inputLimitPrice.deactivate();
				inputLimitPrice.alpha = 0.5;
			}
		}
		
		private function loadComission():void 
		{
			if (tradeSide == TradingOrder.SELL)
			{
				if (comission == null)
				{
					comission = new CoinComissionChecker(onComission);
				}
				comission.execute(currentProposal, inputCoins.value);
				
				drawCommision();
			}
		}
		
		private function onComission(commissionData:Object):void 
		{
			if (commissionData is String)
			{
				ToastMessage.display(commissionData as String);
			}
			else
			{
				drawCommision(commissionData);
			}
		}
		
		private function drawCommision(commissionData:Object = null):void 
		{
			if (isDisposed == true)
			{
				return;
			}
			
			commisionText.draw(componentsWidth, commissionData);
			
			if (comission != null && !isNaN(comission.getValue()))
			{
				drawTotalMoney(currentTotalMoney - comission.getValue());
			}
			
			drawView();
		}
		
		private function onChangeInputCoins():void 
		{
			if (tradeSide == TradingOrder.SELL)
			{
				if (inputCoins.value > getAvaliableCoins())
				{
					inputCoins.invalid();
				}
				else
				{
					inputCoins.valid();
				}
			}
			
			updateValues();
		}
		
		private function onInputSelected():void 
		{
			
		}
		
		override public function onBack(e:Event = null):void {
			if (screenLocked == false) {
				ServiceScreenManager.closeView();
			}
		}
		
		private function backClick():void {
			onBack();
		}
		
		private function onLargeTransactionResponse(val:int):void 
		{
			if (val == 1)
			{
				TweenMax.delayedCall(1, checkAdditionalCommission, null, true);
			}
		}
		
		private function checkAdditionalCommission():void 
		{
			if (tradeSide == TradingOrder.SELL)
			{
				if (comission != null && comission.lowLoquidityComission != null)
				{
					var lowCommissionText:String =  Lang.coinCommistionM2New.replace("%@1", String(comission.low_liquidity_eur_per_coin));
					lowCommissionText = lowCommissionText.replace("%@2", String(comission.low_liquidity_price_limit));
					lowCommissionText = lowCommissionText.replace("%@3", String(comission.lowLoquidityComission));
					DialogManager.alert(Lang.information, lowCommissionText, onCommissionPopup, Lang.iAgreeCreateOrder, Lang.iDontAgree);
				}
				else
				{
					toBuyingState();
				}
			}
			else
			{
				toBuyingState();
			}
		}
		
		private function showAdditionalCommissionAlert(undercomissionAmount:Number):void 
		{
			var text:String = Lang.coinCommistionM1New.replace("@1", Math.round(undercomissionAmount * .2 * 100) / 100);
			text = text.replace("@2", ConfigManager.config.COINS_CSC_LLF_PRICE_LIMIT);
			DialogManager.alert(Lang.information, text, onCommissionPopup, Lang.iAgreeCreateOrder, Lang.iDontAgree);
		}
		
		private function onCommissionPopup(val:int):void 
		{
			if (val != 1)
				return;
			toBuyingState();
		}	
		
		private function nextClick():void {
			if (state == STATE_START)
			{
				if (currentProposal != null && currentProposal.length > 0)
				{
					if (currentTotalMoney < 100)
					{
						checkAdditionalCommission();
					}
					else
					{
						DialogManager.alert(Lang.textAttention, Lang.largeOrderWarning, onLargeTransactionResponse, Lang.textOk, Lang.CANCEL);
					}
				}
			}
			else if(state == STATE_SUCCESS)
			{
				SoftKeyboard.closeKeyboard();
				ServiceScreenManager.closeView();
			}
		}
		
		private function updateAnimator():void 
		{
			if (animation != null)
			{
				animation.y = bg.y;
			}
		}
		
		private function updateAnimatorShow():void 
		{
			if (animation != null)
			{
				animation.y = bg.y + bg.height - animation.height;
			}
		}
		
		private function toBuyingState():void 
		{
			state = STATE_PROGRESS;
			if (animation == null)
			{
				animation = new Sprite();
				container.addChild(animation);
			}
			
			animation.graphics.clear();
			animation.scaleX = animation.scaleY = 1;
			animation.graphics.beginFill(0xD9E5F0);
			animation.graphics.drawRect(0, 0, _width, 5);
			animation.graphics.endFill();
			
			lockScreen();
			
			animation.y = bg.y;
			
			inAnimationHide = true;
			TweenMax.to(animation, 0.4, {height:bg.height, onUpdate:updateAnimator, onComplete:showContent, ease:Power1.easeOut});
		}
		
		private function lockScreen():void 
		{
			locked = false;
			deactivateItems();
		}
		
		private function unlockScreen():void 
		{
			locked = false;
			if (isActivated)
			{
				activateItems();
			}
		}
		
		private function showContent():void 
		{
			inAnimationHide = false;
			
			if (isDisposed)
			{
				return;
			}
			
			amountTitle.visible = false;
			inputCoins.visible = false;
			lotsTitle.visible = false;
			lotsValue.visible = false;
			refreshButton.visible = false;
			averagePriceTitle.visible = false;
			averagePriceValue.visible = false;
			bestPriceTitle.visible = false;
			bestPriceValue.visible = false;
			worstPriceTitle.visible = false;
			worstPriceValue.visible = false;
			inputLimitPrice.visible = false;
			priceLimitSwitch.visible = false;
			totalMoneyValue.visible = false;
			avaliableMoneyValue.visible = false;
			titleBMP.visible = false;
			scrollPanel.view.visible = false;
			scrollPanel.removeObject(commisionText);
			
			var headerSize:int = Config.FINGER_SIZE * .85;
			
			ordersList = new List("TradeCoinsExtendedPopup");
			ordersList.view.y = Config.FINGER_SIZE * .85;
			ordersList.setMask(true);
			ordersList.background = true;
			ordersList.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			
			drawView();
			
			var l:int = currentProposal.length;
			var item:TradingOrderStatus;
			orderStatuses = new Array();
			for (var i:int = 0; i < l; i++) 
			{
				item = new TradingOrderStatus(currentProposal[i] as TradingOrder);
				orderStatuses.push(item);
			}
			
			ordersList.setData(orderStatuses, TradingOfferStatusRenderer);
			container.addChild(ordersList.view);
			
			container.setChildIndex(animation, container.numChildren - 1);
			
			var targetHeight:int = bg.height;
			/*bg.graphics.clear();
			bg.graphics.beginFill(0xD9E5F0);
			bg.graphics.drawRect(0, 0, _width, headerSize);
			bg.graphics.endFill();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGRIUND));
			bg.graphics.drawRect(0, headerSize, _width, targetHeight - headerSize);
			bg.graphics.endFill();*/
			
			drawTitle(tradeSide == TradingOrder.BUY?Lang.alreadyBought:Lang.alreadySold);
			mainTitle.x = padding;
			mainTitle.y = int(headerSize * .5 - mainTitle.height * .5);
			mainTitle.visible = true;
			
		//	preloader.y = Config.FINGER_SIZE;
			container.setChildIndex(preloader, container.numChildren - 1);
			
			drawTitleRight(0, l);
			
			mainTitleRight.y = mainTitle.y;
			
			inAnimationShow = true;
			
			drawAcceptButton(Lang.close);
			backButton.visible = false;
			backButton.deactivate();
			acceptButton.x = int(_width * .5 - acceptButton.width * .5);
			
			TweenMax.to(animation, 0.4, {height:0, onUpdate:updateAnimatorShow, onComplete:contentShown, ease:Power1.easeOut});
		}
		
		private function drawTitleRight(done:int, total:int):void 
		{
			if (mainTitleRight.bitmapData != null)
			{
				mainTitleRight.bitmapData.dispose();
				mainTitleRight.bitmapData = null;
			}
			
			mainTitleRight.bitmapData = TextUtils.createTextFieldData(done.toString() + "/" + total.toString(), componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .30, false, Style.color(Style.COLOR_TEXT), 
															Style.color(Style.COLOR_BACKGROUND), false, true);
			mainTitleRight.x = int(_width - mainTitleRight.width - padding);
		}
		
		private function drawTitle(value:String):void 
		{
			mainTitle.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .30, false, Style.color(Style.COLOR_TEXT), 
															Style.color(Style.COLOR_BACKGROUND), false, true);
		}
		
		private function contentShown():void 
		{
			inAnimationShow = false;
			
			if (isDisposed)
			{
				return;
			}
			
			unlockScreen();
			
			if (_isActivated)
			{
				ordersList.activate();
			}
			
			startTransactions();
		}
		
		private function startTransactions():void 
		{
			preloader.start();
			
			var order:TradingOrderRequest = new TradingOrderRequest();
			
			order.orders = currentProposal;
			order.quantity = inputCoins.value;
			
			currentRequest = order;
			
			if (ordersList != null && ordersList.data != null && (ordersList.data is Array) && (ordersList.data as Array).length > 0)
			{
				((ordersList.data as Array)[0] as TradingOrderStatus).status = TradingOrderStatus.STATUS_PROCESS;
				ordersList.updateItemByIndex(0, true, true, true);
			}
			
			currentAction = new TradeCoinsAction(currentRequest, data.resultSignal, data.callback, onOrderResult);
			currentAction.getFailSignal().add(onTradeFail);
			currentAction.getSuccessSignal().add(onTradeSuccess);
			currentAction.execute();
		}
		
		private function onOrderResult(success:Boolean, index:int, errorText:String = null, transactionData:Object = null):void 
		{
			if (isDisposed)
			{
				return;
			}
			
			drawTitleRight(index + 1, currentRequest.orders.length);
			if (ordersList != null && ordersList.data != null && ordersList.data is Array)
			{
				if ((ordersList.data as Array).length > index)
				{
					if (success == true)
					{
						((ordersList.data as Array)[index] as TradingOrderStatus).status = TradingOrderStatus.STATUS_SUCCESS;
						
						
						var quantity:String = "0.0000 DUK+";
						var money:String = "0.00 EUR";
						var currency:String = "";
						
						if (transactionData)
						{
							if (tradeSide == TradingOrder.BUY)
							{
								currency = transactionData.credit_currency;
								if (Lang[currency] != null)
								{
									currency = Lang[currency];
								}
								quantity = transactionData.credit_amount + " " + currency;
								money = transactionData.debit_amount + " " + transactionData.debit_currency;
							}
							else
							{
								currency = transactionData.debit_currency;
								if (Lang[currency] != null)
								{
									currency = Lang[currency];
								}
								quantity = transactionData.debit_amount + " " + currency;
								money = transactionData.credit_amount + " " + transactionData.credit_currency;
							}
						}
						
						((ordersList.data as Array)[index] as TradingOrderStatus).money = money;
						((ordersList.data as Array)[index] as TradingOrderStatus).quantity = quantity;
					}
					else
					{
						((ordersList.data as Array)[index] as TradingOrderStatus).status = TradingOrderStatus.STATUS_FAILED;
						if (errorText != null)
						{
							((ordersList.data as Array)[index] as TradingOrderStatus).errorText = errorText;
						}
					}
					
					if ((ordersList.data as Array).length > index + 1)
					{
						((ordersList.data as Array)[index + 1] as TradingOrderStatus).status = TradingOrderStatus.STATUS_PROCESS;
					}
					
					ordersList.updateItemByIndex(index, true, true, true);
					ordersList.scrollToIndex(index + 1, 0, 0.7);
				}
			}
		}
		
		private function updateMarketplace():void 
		{
			if (data != null && data.refreshDataFunction != null)
			{
				data.refreshDataFunction();
			}
		}
		
		private function onTradeFail(message:String = null):void 
		{
			updateMarketplace();
			
			preloader.stop();
			currentAction = null;
			
			state = STATE_SUCCESS;
			
			if (isDisposed)
			{
				return;
			}
			if (message != null)
			{
			//	ToastMessage.display(message);
			}
			
			lockScreen();
			
			showFinalAnimation(0, 0, 0);
			
			unlockScreen();
		}
		
		private function showFinalAnimation(value:Number, price:Number, resultMoney:Number):void 
		{
			drawFinalSumTitle();
			drawFinalSumValue(value);
			drawFinalStartValue(currentRequest.quantity);
			
			drawFinalPriceTitle();
			
			var priceValue:Number;
			if (value == 0)
			{
				priceValue = 0;
			}
			else
			{
				priceValue = price/resultMoney;
			}
			drawFinalPriceValue(priceValue);
			
			drawFinalAmountTitle();
			drawFinalAmountValue(resultMoney);
			
			finalSumTitle.alpha = 0;
			finalSumValue.alpha = 0;
			finalStartValue.alpha = 0;
			finalPriceTitle.alpha = 0;
			finalPriceValue.alpha = 0;
			finalAmountTitle.alpha = 0;
			finalAmountValue.alpha = 0;
			
			TweenMax.to(finalSumTitle, 0.3, {alpha:1, delay:0.7});
			TweenMax.to(finalSumValue, 0.3, {alpha:1, delay:0.7});
			TweenMax.to(finalStartValue, 0.3, {alpha:1, delay:0.7});
			TweenMax.to(finalPriceTitle, 0.3, {alpha:1, delay:0.7});
			TweenMax.to(finalPriceValue, 0.3, {alpha:1, delay:0.7});
			TweenMax.to(finalAmountTitle, 0.3, {alpha:1, delay:0.7});
			TweenMax.to(finalAmountValue, 0.3, {alpha:1, delay:0.7});
			
			if (ordersList.height > ordersList.itemsHeight)
			{
				ordersList.deactivate();
			//	ordersList.setWidthAndHeight(_width, ordersList.itemsHeight);
			}
			
			var mh:int = Math.min(getMaxContentHeight() - Config.FINGER_SIZE * 2.5, ordersList.itemsHeight + Config.FINGER_SIZE * .2);
			ordersList.setWidthAndHeight(_width, mh);
			
			acceptButton.y = Math.max(Config.FINGER_SIZE * 2.5 + ordersList.view.y + ordersList.height, bg.height - Config.FINGER_SIZE * .3 - acceptButton.height);
			
			var listHeight:Object = new Object();
			listHeight.height = ordersList.height;
			
			finalSumTitle.y = int(ordersList.view.y + ordersList.height + Config.FINGER_SIZE * .3);
			finalSumValue.y = finalSumTitle.y;
			finalStartValue.y = int(finalSumValue.y + finalSumValue.height + Config.FINGER_SIZE * .2);
			
			finalPriceTitle.y = int(finalStartValue.y + finalStartValue.height + Config.FINGER_SIZE * .2);
			finalPriceValue.y = finalPriceTitle.y;
			
			finalAmountTitle.y = int(finalPriceTitle.y + finalPriceTitle.height + Config.FINGER_SIZE * .2);
			finalAmountValue.y = finalAmountTitle.y;
			
			finalSumTitle.x = padding;
			finalPriceTitle.x = padding;
			finalAmountTitle.x = padding;
			
			var targetHeight:Number = Math.min(acceptButton.y - Config.FINGER_SIZE * 2.5 - ordersList.view.y, ordersList.height);
			
			unlockScreen();
		//	TweenMax.to(listHeight, 0.5, {delay:0.5, height:targetHeight, onUpdate:finalAnimationUpdate, onUpdateParams:[listHeight], onComplete:onFinalAnimationComplete, ease:Power1.easeOut});
		}
		
		private function drawFinalAmountValue(value:Number):void 
		{
			if (finalAmountValue.bitmapData != null)
			{
				finalAmountValue.bitmapData.dispose();
				finalAmountValue.bitmapData = null;
			}
			
			var prefix:String = "";
			if (tradeSide == TradingOrder.BUY)
			{
				prefix = "-";
			}
			var color:uint;
			if (tradeSide == TradingOrder.BUY)
			{
				color = 0x9b504a;
			}
			else
			{
				color = 0x529354;
			}
			
			finalAmountValue.bitmapData = TextUtils.createTextFieldData(prefix + parseFloat(value.toFixed(2)).toString() + " " + TypeCurrency.EUR, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .28, false, color, 
															0xFFFFFF, false, true);
			finalAmountValue.x = int(_width - finalAmountValue.width - padding);
		}
		
		private function drawFinalPriceValue(value:Number):void 
		{
			if (finalPriceValue.bitmapData != null)
			{
				finalPriceValue.bitmapData.dispose();
				finalPriceValue.bitmapData = null;
			}
			
			finalPriceValue.bitmapData = TextUtils.createTextFieldData("@ " + parseFloat(value.toFixed(2)).toString(), componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .28, false, 0x6D7C8C, 
															0xFFFFFF, false, true);
			finalPriceValue.x = int(_width - finalPriceValue.width - padding);
		}
		
		private function drawFinalSumValue(value:Number):void 
		{
			if (finalSumValue.bitmapData != null)
			{
				finalSumValue.bitmapData.dispose();
				finalSumValue.bitmapData = null;
			}
			
			finalSumValue.bitmapData = TextUtils.createTextFieldData(parseFloat(value.toFixed(4)).toString() + " DUK+", componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .34, false, 0x318A01, 
															0xFFFFFF, false, true);
			finalSumValue.x = int(_width - finalSumValue.width - padding);
		}
		
		private function drawFinalStartValue(value:Number):void 
		{
			if (finalStartValue.bitmapData != null)
			{
				finalStartValue.bitmapData.dispose();
				finalStartValue.bitmapData = null;
			}
			
			finalStartValue.bitmapData = TextUtils.createTextFieldData(Lang.of + " " + parseFloat(value.toFixed(4)).toString() + " DUK+", componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .28, false, 0x6D7C8C, 
															0xFFFFFF, false, true);
			finalStartValue.x = int(_width - finalStartValue.width - padding);
		}
		
		private function drawFinalAmountTitle():void 
		{
			if (finalAmountTitle.bitmapData != null)
			{
				finalAmountTitle.bitmapData.dispose();
				finalAmountTitle.bitmapData = null;
			}
			
			finalAmountTitle.bitmapData = TextUtils.createTextFieldData(Lang.amount + ":", componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .28, false, 0x6D7C8C, 
															0xFFFFFF, false, true);
		}
		
		private function drawFinalPriceTitle():void 
		{
			if (finalPriceTitle.bitmapData != null)
			{
				finalPriceTitle.bitmapData.dispose();
				finalPriceTitle.bitmapData = null;
			}
			
			finalPriceTitle.bitmapData = TextUtils.createTextFieldData(Lang.averagePrice + ":", componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .28, false, 0x6D7C8C, 
															0xFFFFFF, false, true);
		}
		
		private function drawFinalSumTitle():void 
		{
			if (finalSumTitle.bitmapData != null)
			{
				finalSumTitle.bitmapData.dispose();
				finalSumTitle.bitmapData = null;
			}
			
			var text:String;
			if (tradeSide == TradingOrder.BUY)
			{
				text = Lang.succesfullyBought;
			}
			else
			{
				text = Lang.succesfullySold;
			}
			
			finalSumTitle.bitmapData = TextUtils.createTextFieldData(text + ":", componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .34, false, Style.color(Style.COLOR_TEXT), 
															Style.color(Style.COLOR_BACKGROUND), false, true);
		}
		
		private function onFinalAnimationComplete():void 
		{
			if (isDisposed)
			{
				return;
			}
			unlockScreen();
		}
		
		private function finalAnimationUpdate(listHeight:Object):void 
		{
			if (isDisposed)
			{
				return;
			}
			if (ordersList != null)
			{
				ordersList.setWidthAndHeight(_width, listHeight.height);
				ordersList.scrollBottom();
			}
			finalSumTitle.y = int(ordersList.view.y + ordersList.height + Config.FINGER_SIZE * .3);
			finalSumValue.y = finalSumTitle.y;
			finalStartValue.y = int(finalSumValue.y + finalSumValue.height + Config.FINGER_SIZE * .2);
			finalPriceTitle.y = int(finalStartValue.y + finalStartValue.height + Config.FINGER_SIZE * .2);
			finalPriceValue.y = finalPriceTitle.y;
			finalAmountTitle.y = int(finalPriceTitle.y + finalPriceTitle.height + Config.FINGER_SIZE * .2);
			finalAmountValue.y = finalAmountTitle.y;
		}
		
		private function onTradeSuccess(response:TradingResponse):void 
		{
			updateMarketplace();
			
			preloader.stop();
			currentAction = null;
			
			if (isDisposed)
			{
				return;
			}
			
			state = STATE_SUCCESS;
			
			showFinalAnimation(tradeSide == TradingOrder.BUY?response.credit_amount:response.debit_amount, response.price, tradeSide == TradingOrder.SELL?response.credit_amount:response.debit_amount);
			
			unlockScreen();
		}
		
		private function getAvaliableCoins():Number 
		{
			if (accounts != null && accounts.coinsAccounts != null && accounts.coinsAccounts.length > 0 && accounts.coinsAccounts[0] != null)
			{
				return parseFloat(accounts.coinsAccounts[0].BALANCE);
			}
			return 0;
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			if (data != null && "type" in data && data.type != null)
			{
				tradeSide = data.type;
			}
			
			padding = Config.DIALOG_MARGIN;
			componentsWidth = _width - padding * 2;
			
			bestProposal = new CoinBestProposal(onProposalResult, data.dataProvider, data.refreshDataFunction, data.updateDataSignal);
			accounts = new PaymentsAccountsProvider(onAccountsDataReady);
			
			state = STATE_START;
			
			drawTitleBlue();
			
			drawAmountTitle();
			drawLotsTitle();
			drawAveragePriceTitle();
			drawBestPriceTitle();
			drawWorstPriceTitle();
			drawTotalMoney(0);
			
			drawAcceptButton(tradeSide == TradingOrder.BUY?Lang.BUY:Lang.sell.toUpperCase());
			drawBackButton();
			acceptButton.deactivate();
			
			priceLimitSwitch.create(componentsWidth - priceLimitSwitch.padding * 2, Config.FINGER_SIZE * .8, null, Lang.limitWorstPrice, false, true, 0x47515B, Config.FINGER_SIZE * .3, 0);
			
			preloader.setSize(_width, int(Config.FINGER_SIZE * .07));
			
			if (accounts.ready == true)
			{
				construct();
			}
			else
			{
				construct();
				drawInitialValues();
				preloader.start();
				accounts.getData();
			}
		}
		
		private function drawTitleBlue():void 
		{
			var text:String;
			if (tradeSide == TradingOrder.BUY)
			{
				text = Lang.buyAtMarketPrice;
			}
			else
			{
				text = Lang.sellAtMarketPrice;
			}
			
			titleBMP.bitmapData = TextUtils.createTextFieldData(
																	text, 
																	componentsWidth, 
																	10, 
																	false, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .32, 
																	false, 
																	0x5D6A77, 
																	0xD9E5F0, false, false, true);
		}
		
		private function drawInitialValues():void 
		{
			var maxCoinsAvaliable:String;
			if (tradeSide == TradingOrder.SELL)
			{
				maxCoinsAvaliable = Lang.avaliable + ": " + getAvaliableCoins() + " " + getCoinsCurrency();
			}
			
			var maxValue:Number = Math.min(1, getAvaliableCoins());
			if (tradeSide == TradingOrder.BUY)
			{
				maxValue = 1;
			}
			
			inputCoins.draw(componentsWidth - amountTitle.width - Config.MARGIN, null, null, null, "DUK+");
			inputCoins.y = amountTitle.y - inputCoins.contentPosition;
			inputLimitPrice.draw(componentsWidth, null, 0, null, null, 0xF5F5F5);
		}
		
		private function onProposalResult(proposal:Array):void 
		{
			preloader.stop(false);
			
			if (state != STATE_START)
			{
				return;
			}
			
			currentProposal = proposal;
			
			var avaliableCoins:Number = 0;
			var currentQantity:Number = 0;
			var minPrice:Number = 100000000000000;
			var maxPrice:Number = 0;
			var totalMoney:Number = 0;
			var prices:Array = new Array();
			
			var targetQuantity:Number = inputCoins.value;
			var nextQuantity:Number;
			var order:TradingOrder;
			
			var l:int;
			if (proposal != null)
			{
				l = proposal.length;
				for (var i:int = 0; i < l; i++) 
				{
					order = proposal[i] as TradingOrder;
					nextQuantity = Math.min(targetQuantity - currentQantity, order.quantity)
					prices.push([order.price, nextQuantity]);
					currentQantity += nextQuantity;
					if (minPrice > order.price)
					{
						minPrice = order.price;
					}
					if (maxPrice < order.price)
					{
						maxPrice = order.price;
					}
					totalMoney += nextQuantity * order.price;
				}
			}
			
			var averagePrice:Number = 0;
			
			if (prices.length > 0)
			{
				for (var j:int = 0; j < l; j++) 
				{
					averagePrice += prices[j][0] * prices[j][1] / currentQantity;
				}
			}
			
			var coinsValue:String = parseFloat(currentQantity.toFixed(4)).toString() + " " + getCoinsCurrency();
			var averagePriceValue:String = "@ " + parseFloat(averagePrice.toFixed(2)).toString();
			var bestPriceValue:String = "@ " + parseFloat(((tradeSide == TradingOrder.BUY)?minPrice:maxPrice).toFixed(2)).toString();
			var worstPriceValue:String = "@ " + parseFloat(((tradeSide == TradingOrder.SELL)?minPrice:maxPrice).toFixed(2)).toString();
			
			if (proposal == null || proposal.length == 0)
			{
				coinsValue = " ";
				averagePriceValue = " ";
				bestPriceValue = " ";
				worstPriceValue = " ";
			}
			
			var color:Number;
			if (averagePriceValue == bestPriceValue && bestPriceValue == worstPriceValue)
			{
				color = 0xD3D7DC;
			}
			else
			{
				color = 0x7A8B9C;
			}
			
			currentTotalMoney = totalMoney;
			
			drawAvaliableLots(coinsValue);
			drawAveragePrice(averagePriceValue);
			drawBestPrice(bestPriceValue, color);
			drawWorstPrice(worstPriceValue, color);
			drawTotalMoney(totalMoney);
			
			drawView();
			
			if (tradeSide == TradingOrder.BUY)
			{
				if (getMaxMoney() < totalMoney)
				{
					acceptButton.alpha = 0.5;
					acceptButton.deactivate();
				}
				else
				{
					acceptButton.alpha = 1;
					acceptButton.activate();
				}
			}
			else
			{
				if (getAvaliableCoins() < inputCoins.value)
				{
					acceptButton.alpha = 0.5;
					acceptButton.deactivate();
				}
				else
				{
					acceptButton.alpha = 1;
					acceptButton.activate();
				}
			}
			
			if (totalMoney < 0.01)
			{
				acceptButton.alpha = 0.5;
				acceptButton.deactivate();
				
			}
			if (acceptButton.alpha == 0.5)
			{
				inputCoins.invalid();
			}
			else
			{
				inputCoins.valid();
			}
			
			loadComission();
		}
		
		private function getFormat(value:Number, decimal:int):Number 
		{
			var k:Number = Math.pow(10,decimal);
			return Math.floor(value * k) / k;
		}
		
		private function drawTotalMoney(value:Number):void 
		{
			var result:Number = getFormat(value, 2);
			if (result == 0)
			{
				result = getFormat(value, 4);
			}
			if (result == 0)
			{
				result = getFormat(value, 6);
				if (result == 0)
				{
					result = 0;
				}
			}
			
			var color:Number = 0x47515B;
			
			var text:String;
			if (tradeSide == TradingOrder.BUY)
			{
				if (getMaxMoney() < result)
				{
					color = 0x980000;
				}
				
				text = Lang.totalEstimatedCost + ": "  + result.toString() + " " + TypeCurrency.EUR;
			}
			else
			{
				text = Lang.totalEstimatedEarn + ": "  + result.toString() + " " + TypeCurrency.EUR;
			}
			
			if (totalMoneyValue.bitmapData != null)
			{
				totalMoneyValue.bitmapData.dispose();
				totalMoneyValue.bitmapData = null;
			}
			totalMoneyValue.bitmapData = TextUtils.createTextFieldData(text, componentsWidth, 10, true, 
															TextFormatAlign.RIGHT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .28, true, color, 
															0xFFFFFF, false, true);
			totalMoneyValue.x = Config.DIALOG_MARGIN;
		}
		
		private function drawWorstPrice(value:String, color:Number):void 
		{
			if (worstPriceValue.bitmapData != null)
			{
				worstPriceValue.bitmapData.dispose();
				worstPriceValue.bitmapData = null;
			}
			
			worstPriceValue.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .30, false, color, 
															0xFFFFFF, false, true);
			worstPriceValue.x = int(_width - worstPriceValue.width - padding);
			worstPriceValue.y = worstPriceTitle.y;
		}
		
		private function drawBestPrice(value:String, color:Number):void 
		{
			if (bestPriceValue.bitmapData != null)
			{
				bestPriceValue.bitmapData.dispose();
				bestPriceValue.bitmapData = null;
			}
			
			bestPriceValue.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .30, false, color, 
															0xFFFFFF, false, true);
			bestPriceValue.x = int(_width - bestPriceValue.width - padding);
			bestPriceValue.y = bestPriceTitle.y;
		}
		
		private function drawAveragePrice(value:String):void 
		{
			if (averagePriceValue.bitmapData != null)
			{
				averagePriceValue.bitmapData.dispose();
				averagePriceValue.bitmapData = null;
			}
			
			averagePriceValue.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .30, false, 0x7A8B9C, 
															0xFFFFFF, false, true);
			averagePriceValue.x = int(_width - averagePriceValue.width - padding);
			averagePriceValue.y = averagePriceTitle.y;
		}
		
		private function drawAvaliableLots(value:String):void 
		{
			if (lotsValue.bitmapData != null)
			{
				lotsValue.bitmapData.dispose();
				lotsValue.bitmapData = null;
			}
			
			lotsValue.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .34, false, 0x318A01, 
															0xFFFFFF, false, true);
			lotsValue.x = int(_width - lotsValue.width - padding);
			lotsValue.y = lotsTitle.y;
		}
		
		private function onAccountsDataReady():void 
		{
			if (constructed == true)
			{
				return;
			}
			constructed = true;
			preloader.stop();
			construct();
			drawView();
		}
		
		private function construct():void 
		{
			if (tradeSide == TradingOrder.BUY)
			{
				drawAvaliableMoney();
			}
			
			var maxCoinsAvaliable:String;
			if (tradeSide == TradingOrder.SELL)
			{
				maxCoinsAvaliable = Lang.avaliable + ": " + getAvaliableCoins() + " " + getCoinsCurrency();
			}
			
			var maxValue:Number = Math.min(1, getAvaliableCoins());
			if (tradeSide == TradingOrder.BUY)
			{
				maxValue = 1;
			}
			maxValue = NaN;
			
			priceLimitSwitch.create(componentsWidth, Config.FINGER_SIZE * .8, null, Lang.limitWorstPrice, false, true, 0x47515B, Config.FINGER_SIZE * .3);
			inputCoins.draw(componentsWidth - amountTitle.width - Config.MARGIN, null, maxValue, maxCoinsAvaliable, getCoinsCurrency());
			inputCoins.y = amountTitle.y - inputCoins.contentPosition;
			inputLimitPrice.draw(componentsWidth, null, 0, null, null, 0xF5F5F5);
			
		//	inputCoins.setDefaultText(Lang.enterAmount);
			
			updateValues();
		}
		
		private function getMaxMoney():Number 
		{
			if (accounts.moneyAccounts != null && accounts.moneyAccounts.length > 0)
			{
				var euroAcc:Object;
				var length:int = accounts.moneyAccounts.length;
				for (var i:int = 0; i < length; i++) 
				{
					if (accounts.moneyAccounts[i] != null && accounts.moneyAccounts[i].CURRENCY == TypeCurrency.EUR)
					{
						euroAcc = accounts.moneyAccounts[i];
						break;
					}
				}
				if (euroAcc != null)
				{
					return parseFloat(euroAcc.BALANCE);
				}
			}
			return 0;
		}
		
		private function drawAvaliableMoney():void 
		{
			avaliableMoneyValue.bitmapData = TextUtils.createTextFieldData(Lang.avaliable + ": " + getMaxMoney() + " " + TypeCurrency.EUR, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .26, false, 0x7A8B9C, 
															0xFFFFFF, false, true);
			avaliableMoneyValue.x = int(padding);
		}
		
		private function drawWorstPriceTitle():void 
		{
			worstPriceTitle.bitmapData = TextUtils.createTextFieldData(Lang.worstPrice + ":", componentsWidth - Config.FINGER_SIZE*1.9, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .30, true, 0x7A8B9C, 
															0xFFFFFF, false, true);
		}
		
		private function drawBestPriceTitle():void 
		{
			bestPriceTitle.bitmapData = TextUtils.createTextFieldData(Lang.bestPrice + ":", componentsWidth - Config.FINGER_SIZE*1.9, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .30, true, 0x7A8B9C, 
															0xFFFFFF, false, true);
		}
		
		private function drawAveragePriceTitle():void 
		{
			averagePriceTitle.bitmapData = TextUtils.createTextFieldData(Lang.averagePrice + ":", componentsWidth - Config.FINGER_SIZE*1.9, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .30, true, 0x7A8B9C, 
															0xFFFFFF, false, true);
		}
		
		private function updateValues():void 
		{
			var val:Number = inputCoins.value;
			if (isNaN(val))
			{
				val = 0;
			}
			var limit:Number = NaN;
			if (priceLimitSwitch.isSelected)
			{
				limit = inputLimitPrice.value;
			}
			if (limit == 0)
			{
				limit = NaN;
			}
			if (state == STATE_START)
			{
				bestProposal.getProposal(tradeSide, val, limit);
			}
		}
		
		private function drawLotsTitle():void 
		{
			lotsTitle.bitmapData = TextUtils.createTextFieldData(Lang.avaliableLots + ":", componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .34, false, 0x47515B, 
															0xFFFFFF, false, true);
		}
		
		private function getCoinsCurrency():String 
		{
			if (accounts != null && accounts.coinsAccounts != null && accounts.coinsAccounts.length > 0 && accounts.coinsAccounts[0] != null)
			{
				var currency:String = accounts.coinsAccounts[0].COIN;
				if (Lang[currency] != null)
				{
					currency = Lang[currency];
				}
				return currency;
			}
			return "";
		}
		
		private function drawAcceptButton(text:String):void 
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			acceptButton.setBitmapData(buttonBitmap, true);
			acceptButton.x = int(acceptButton.width + Config.DIALOG_MARGIN * 2);
		}
		
		private function drawBackButton():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 0, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			backButton.setBitmapData(buttonBitmap);
			backButton.x = Config.DIALOG_MARGIN;
		}
		
		protected function getMaxContentHeight():int
		{
			if (state == STATE_START)
			{
				return _height - scrollPanel.view.y - Config.MARGIN - backButton.height - Config.FINGER_SIZE * .5;
			}
			else
			{
				return _height - ordersList.view.y - Config.MARGIN - backButton.height - Config.FINGER_SIZE * .5;
			}
		}
		
		override protected function drawView():void 
		{
			if (_isDisposed == true)
				return;
			
			var headerHeight:int = Config.FINGER_SIZE * .85;
			var inputHeight:int = inputCoins.getHeight() + Config.FINGER_SIZE * .6;
			preloader.y = headerHeight;
			verticalMargin = Config.MARGIN * 1.5;
			
			var startPos:int = titleBMP.height + Config.FINGER_SIZE * .6;
			
			if (state == STATE_START)
			{
				scrollPanel.view.y = headerHeight + inputHeight;
				
				var position:int = 0;
				
				amountTitle.x = padding;
				lotsTitle.x = padding;
				amountTitle.x = padding;
				
				priceLimitSwitch.x = padding - priceLimitSwitch.padding;
				
				inputLimitPrice.x = padding;
				inputCoins.x = int(_width - padding - inputCoins.width);
				
				bestPriceTitle.x = int(padding + Config.FINGER_SIZE * 1.1);
				averagePriceTitle.x = int(padding + Config.FINGER_SIZE * 1.1);
				worstPriceTitle.x = int(padding + Config.FINGER_SIZE * 1.1);
				
				amountTitle.y = Config.FINGER_SIZE * .3 + startPos;
				inputCoins.y = Config.FINGER_SIZE * .3 + startPos - inputCoins.contentPosition;
			//	position += Math.max(amountTitle.height, inputCoins.getHeight()) + Config.FINGER_SIZE * .03;
				
				var bdDrawPosition:int = Config.FINGER_SIZE;
				
				position += Config.FINGER_SIZE * .3;
				
				lotsTitle.y = position;
				lotsValue.y = lotsTitle.y;
				position += lotsTitle.height + Config.FINGER_SIZE * .3;
				
				averagePriceTitle.y = position;
				averagePriceValue.y = averagePriceTitle.y;
				position += Config.FINGER_SIZE * .4 + Config.FINGER_SIZE * .0;
				if (position < averagePriceTitle.y + averagePriceTitle.height + Config.FINGER_SIZE*.3)
				{
					position = averagePriceTitle.y + averagePriceTitle.height + Config.FINGER_SIZE * .3;
				}
				
				bestPriceTitle.y = position;
				bestPriceValue.y = bestPriceTitle.y;
				position += Config.FINGER_SIZE * .4 + Config.FINGER_SIZE * .0;
				if (position < bestPriceTitle.y + bestPriceTitle.height + Config.FINGER_SIZE*.3)
				{
					position = bestPriceTitle.y + bestPriceTitle.height + Config.FINGER_SIZE * .3;
				}
				
				worstPriceTitle.y = position;
				worstPriceValue.y = worstPriceTitle.y;
				position += Config.FINGER_SIZE * .4 + Config.FINGER_SIZE * .0;
				
				priceLimitSwitch.y = position;
				position += priceLimitSwitch.height + Config.FINGER_SIZE * .1;
				
				inputLimitPrice.y = position - Config.FINGER_SIZE * .2;
				position += inputLimitPrice.height + Config.FINGER_SIZE * .1;
				
				if (commisionText.height > 0)
				{
					commisionText.x = Config.DIALOG_MARGIN;
					commisionText.y = position;
					position += commisionText.height + Config.FINGER_SIZE * .4;
				}
				
				totalMoneyValue.y = position;
				
				if (tradeSide == TradingOrder.BUY)
				{
					position += totalMoneyValue.height + Config.FINGER_SIZE * .2;
					avaliableMoneyValue.y = position;
					position += avaliableMoneyValue.height + Config.FINGER_SIZE * .4;
				}
				else
				{
					position += totalMoneyValue.height + Config.FINGER_SIZE * .4;
				}
				
				refreshButton.x = padding;
				refreshButton.y = int(bestPriceTitle.y + bestPriceTitle.height * .5 - refreshButton.height * .5);
				
				position += acceptButton.height + verticalMargin * 1.8;
				
				bg.graphics.clear();
				
				bg.graphics.beginFill(0xD9E5F0);
				bg.graphics.drawRect(0, 0, _width, headerHeight);
				bg.graphics.endFill();
				
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, headerHeight, _width, inputHeight);
				bg.graphics.endFill();
				
				bg.graphics.beginFill(0xF5F5F5);
				
				var maxContentHeight:int = getMaxContentHeight();
				maxContentHeight = Math.min(maxContentHeight, scrollPanel.itemsHeight + 1);
				scrollPanel.setWidthAndHeight(_width, maxContentHeight);
				scrollPanel.update();
				scrollPanel.updateObjects();
				
				acceptButton.y = int(scrollPanel.view.y + scrollPanel.height + Config.FINGER_SIZE * .3);
				backButton.y = int(scrollPanel.view.y + scrollPanel.height + Config.FINGER_SIZE * .3);
				
			//	trace("RESIZE", scrollPanel.height, maxContentHeight);
				
				bg.graphics.drawRect(0, scrollPanel.view.y, _width, scrollPanel.height + backButton.height + Config.FINGER_SIZE * .6);
				bg.graphics.endFill();
				
				container.y = int(_height - scrollPanel.height - headerHeight - inputHeight - Config.FINGER_SIZE * .6 - backButton.height);
			}
			else if(state == STATE_PROGRESS)
			{
				var headerSize:int = Config.FINGER_SIZE;
				if (ordersList != null)
				{
					ordersList.view.y = headerHeight;
					var maxContentHeightList:int = getMaxContentHeight();
					//trace(maxContentHeightList);
					ordersList.setWidthAndHeight(_width, maxContentHeightList);
					
					
					bg.graphics.clear();
					
					bg.graphics.beginFill(0xD9E5F0);
					bg.graphics.drawRect(0, 0, _width, headerHeight);
					bg.graphics.endFill();
					
					bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
					
					bg.graphics.drawRect(0, ordersList.view.y, _width, ordersList.height + backButton.height + Config.FINGER_SIZE * .6);
					
					bg.graphics.endFill();
					
					acceptButton.y = bg.height - Config.FINGER_SIZE * .3 - acceptButton.height;
					
					container.y = int(_height - ordersList.height - headerHeight - Config.FINGER_SIZE * .6 - backButton.height);
				}
			}
		}
		
		private function drawAmountTitle():void 
		{
			var value:String = "";
			if (tradeSide == TradingOrder.BUY)
			{
				value = Lang.amountToBuy + ":";
			}
			else if (tradeSide == TradingOrder.SELL)
			{
				value = Lang.amountToSell + ":";
			}
			else
			{
				ApplicationErrors.add();
			}
			
			amountTitle.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .34, false, 0x47515B, 
															0xFFFFFF, false, true);
		}
		
		override public function isModal():Boolean 
		{
			return locked == true;
		}
		
		override public function activateScreen():void 
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			if (locked == false)
			{
				activateItems();
			}
			if (state == STATE_START)
			{
				scrollPanel.enable();
			}
		}
		
		private function activateItems():void 
		{
			if (state == STATE_START)
			{
				backButton.activate();
			}
			
			if (state != STATE_START || getMaxMoney() >= currentTotalMoney)
			{
				acceptButton.activate();
			}
			
			inputCoins.activate();
			
			if (priceLimitSwitch.isSelected)
			{
				inputLimitPrice.activate();
			}
			else
			{
				inputLimitPrice.deactivate();
			}
			priceLimitSwitch.activate();
			refreshButton.activate();
			if (ordersList != null)
			{
				ordersList.activate();
			}
		}
		
		override public function deactivateScreen():void 
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			scrollPanel.disable();
			
			deactivateItems();
		}
		
		private function deactivateItems():void 
		{
			acceptButton.deactivate();
			backButton.deactivate();
			inputCoins.deactivate();
			priceLimitSwitch.deactivate();
			priceLimitSwitch.deactivate();
			refreshButton.deactivate();
			if (ordersList != null)
			{
				ordersList.deactivate();
			}
		}
		
		protected function onCloseTap():void 
		{
			DialogManager.closeDialog();
		}
		
		override public function dispose():void 
		{
			if (_isDisposed == true)
				return;
			super.dispose();
			
			TweenMax.killTweensOf(finalSumTitle);
			TweenMax.killTweensOf(finalSumValue);
			TweenMax.killTweensOf(finalStartValue);
			TweenMax.killTweensOf(animation);
			TweenMax.killTweensOf(finalPriceTitle);
			TweenMax.killTweensOf(finalPriceValue);
			
			if (currentAction != null)
			{
				currentAction.getFailSignal().remove(onTradeFail);
				currentAction.getSuccessSignal().remove(onTradeSuccess);
				currentAction.dispose();
				currentAction = null;
			}
			
			if (comission != null)
			{
				comission.dispose();
				comission = null;
			}
			
			Overlay.removeCurrent();
			
			if (commisionText != null)
			{
				commisionText.dispose();
				commisionText = null;
			}
			if (titleBMP != null)
			{
				UI.destroy(titleBMP);
				titleBMP = null;
			}
			if (amountTitle != null)
			{
				UI.destroy(amountTitle);
				amountTitle = null;
			}
			if (preloader != null)
			{
				preloader.dispose();
				preloader = null;
			}
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
			}
			if (acceptButton != null)
			{
				acceptButton.dispose();
				acceptButton = null;
			}
			if (bg != null)
			{
				UI.destroy(bg);
				bg = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (lotsTitle != null)
			{
				UI.destroy(lotsTitle);
				lotsTitle = null;
			}
			if (lotsValue != null)
			{
				UI.destroy(lotsValue);
				lotsValue = null;
			}
			if (averagePriceTitle != null)
			{
				UI.destroy(averagePriceTitle);
				averagePriceTitle = null;
			}
			
			if (worstPriceTitle != null)
			{
				UI.destroy(worstPriceTitle);
				worstPriceTitle = null;
			}
			if (bestPriceTitle != null)
			{
				UI.destroy(bestPriceTitle);
				bestPriceTitle = null;
			}
			if (averagePriceValue != null)
			{
				UI.destroy(averagePriceValue);
				averagePriceValue = null;
			}
			if (bestPriceValue != null)
			{
				UI.destroy(bestPriceValue);
				bestPriceValue = null;
			}
			if (worstPriceValue != null)
			{
				UI.destroy(worstPriceValue);
				worstPriceValue = null;
			}
			if (totalMoneyValue != null)
			{
				UI.destroy(totalMoneyValue);
				totalMoneyValue = null;
			}
			if (avaliableMoneyValue != null)
			{
				UI.destroy(avaliableMoneyValue);
				avaliableMoneyValue = null;
			}
			if (inputCoins != null)
			{
				inputCoins.dispose();
				inputCoins = null;
			}
			if (accounts != null)
			{
				accounts.dispose();
				accounts = null;
			}
			if (bestProposal != null)
			{
				bestProposal.dispose();
				bestProposal = null;
			}
			if (priceLimitSwitch != null)
			{
				priceLimitSwitch.dispose();
				priceLimitSwitch = null;
			}
			if (inputLimitPrice != null)
			{
				inputLimitPrice.dispose();
				inputLimitPrice = null;
			}
			if (refreshButton != null)
			{
				refreshButton.dispose();
				refreshButton = null;
			}
			if (ordersList != null)
			{
				ordersList.dispose();
				ordersList = null;
			}
			if (animation != null)
			{
				UI.destroy(animation);
				animation = null;
			}
			if (mainTitle != null)
			{
				UI.destroy(mainTitle);
				mainTitle = null;
			}
			if (mainTitleRight != null)
			{
				UI.destroy(mainTitleRight);
				mainTitleRight = null;
			}
			if (finalSumTitle != null)
			{
				UI.destroy(finalSumTitle);
				finalSumTitle = null;
			}
			if (finalSumValue != null)
			{
				UI.destroy(finalSumValue);
				finalSumValue = null;
			}
			if (finalPriceTitle != null)
			{
				UI.destroy(finalPriceTitle);
				finalPriceTitle = null;
			}
			if (finalAmountTitle != null)
			{
				UI.destroy(finalAmountTitle);
				finalAmountTitle = null;
			}
			if (finalAmountValue != null)
			{
				UI.destroy(finalAmountValue);
				finalAmountValue = null;
			}
			if (finalStartValue != null)
			{
				UI.destroy(finalStartValue);
				finalStartValue = null;
			}
			if (currentAction != null)
			{
				currentAction.getFailSignal().remove(onTradeFail);
				currentAction.getSuccessSignal().remove(onTradeSuccess);
				currentAction.dispose();
				currentAction = null;
			}
			if (currentRequest != null)
			{
				currentRequest.dispose();
				currentRequest = null;
			}
			if (scrollPanel != null)
				scrollPanel.dispose();
			scrollPanel = null;
			
			currentProposal = null;
			orderStatuses = null;
		}
	}
}