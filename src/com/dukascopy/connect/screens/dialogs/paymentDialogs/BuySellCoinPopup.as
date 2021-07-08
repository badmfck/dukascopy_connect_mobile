package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.OrderScreenData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.coinMarketplace.PaymentsAccountsProvider;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrderRequest;
	import com.dukascopy.connect.data.coinMarketplace.TradingResponse;
	import com.dukascopy.connect.data.screenAction.IAction;
	import com.dukascopy.connect.data.screenAction.customActions.TradeCoinsAction;
	import com.dukascopy.connect.gui.components.ComissionView;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.trade.MarketplaceRendererOrderSingle;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.dialogs.newDialogs.DialogBaseScreen;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.CoinComissionChecker;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power1;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class BuySellCoinPopup extends DialogBaseScreen
	{
		static public const STATE_START:String = "stateStart";
		static public const STATE_SUCCESS:String = "stateSuccess";
		
		private var backButton:BitmapButton;
		private var nextButton:BitmapButton;
		
		private var padding:int;
		private var inputCoins:InputField;
		private var inputMoney:InputField;
		
		private var screenData:OrderScreenData;
		private var orders:Array;
		private var titleBitmap:Bitmap;
		private var horizontalLoader:HorizontalPreloader;
		private var state:String;
		private var locked:Boolean;
		private var animation:Sprite;
		private var resultTitle:Bitmap;
		private var coinTitle:Bitmap;
		private var moneyTitle:Bitmap;
		private var hLine1:Bitmap;
		private var hLine2:Bitmap;
		private var currentRequest:TradingOrderRequest;
		private var coinValueImage:Bitmap;
		private var moneyValueImage:Bitmap;
		private var allCoinsValueImage:Bitmap;
		private var currentAction:IAction;
		private var accounts:PaymentsAccountsProvider;
		private var renderer:MarketplaceRendererOrderSingle;
		private var badPrice:Bitmap;
		private var incomeText:Bitmap;
		private var rendererData:TradingOrder;
		private var _lastCommissionCallID:String;
		private var commisionText:ComissionView;
		private var comission:CoinComissionChecker;
		
		public function BuySellCoinPopup()
		{
			
		}
		
		override protected function createView():void
		{
			super.createView();
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(nextButton);
			
			inputMoney = new InputField(2);
			inputMoney.onSelectedFunction = onInputSelected;
			inputMoney.onChangedFunction = onChangeInputMoney;
			scrollPanel.addObject(inputMoney);
			
			inputCoins = new InputField(4);
			inputCoins.onSelectedFunction = onInputSelected;
			inputCoins.onChangedFunction = onChangeInputCoins;
			scrollPanel.addObject(inputCoins);
			
			titleBitmap = new Bitmap();
			container.addChild(titleBitmap);
			
			badPrice = new Bitmap();
			scrollPanel.addObject(badPrice);
			
			incomeText = new Bitmap();
			scrollPanel.addObject(incomeText);
			
			horizontalLoader = new HorizontalPreloader(0xF6951D);
			container.addChild(horizontalLoader);
			
			renderer = new MarketplaceRendererOrderSingle();
			container.addChild(renderer);
			
			commisionText = new ComissionView();
			scrollPanel.addObject(commisionText);
		}
		
		private function onChangeInputMoney():void 
		{
			inputCoins.value = (Math.floor(inputMoney.value / parseFloat(getPrice()) * 10000) / 10000);
			if (checkDataValid() == true)
			{
				loadComission();
			}
		}
		
		private function onChangeInputCoins():void 
		{
			var initial:Number = inputCoins.value * parseFloat(getPrice());
			
			/*var result:Number = getFormat(initial, 2);
			if (result == 0)
			{
				result = getFormat(initial, 4);
			}
			if (result == 0)
			{
				result = getFormat(initial, 6);
			}*/
			inputMoney.value = initial;
			if (checkDataValid() == true)
			{
				loadComission();
			}
		}
		
		private function getFormat(value:Number, decimal:int):Number 
		{
			var k:Number = Math.pow(10,decimal);
			return Math.floor(value * k) / k;
		}
		
		override public function isModal():Boolean 
		{
			return locked == true;
		}
		
		private function onInputSelected():void 
		{
			
		}
		
		private function onChangeInputPrice():void 
		{
			checkDataValid();
		}
		
		private function checkDataValid():Boolean 
		{
			var invalid:Boolean = false;
			if (screenData.type == TradingOrder.SELL)
			{
				if (inputCoins.value > getMaxCoins())
				{
					inputCoins.invalid();
					invalid = true;
				}
				else if (
					isNaN(inputCoins.value) || 
					(
						orders != null && 
						orders.length > 0 && 
						orders[0] != null && 
						(orders[0] as TradingOrder).fillOrKill && 
						inputCoins.value < (orders[0] as TradingOrder).quantity))
				{
					inputCoins.invalid();
					invalid = true;
				}
				else
				{
					inputCoins.valid();
				}
				
				if (isNaN(inputMoney.value) || getMaxMoney() < inputMoney.value || inputMoney.value < 0.01)
				{
					invalid = true;
					inputMoney.invalid();
				}
				else
				{
					inputMoney.valid();
				}
				
				if (invalid)
				{
					nextButton.deactivate();
					nextButton.alpha = 0.5;
				}
				else
				{
					nextButton.activate();
					nextButton.alpha = 1;
				}
			}
			else if (screenData.type == TradingOrder.BUY)
			{
				if (isNaN(inputCoins.value) || inputCoins.value > getMaxCoins())
				{
					invalid = true;
				}
				
				if (isNaN(inputCoins.value) || 
					(
						orders != null && 
						orders.length > 0 && 
						orders[0] != null && 
						(orders[0] as TradingOrder).fillOrKill && 
						inputCoins.value < (orders[0] as TradingOrder).quantity))
				{
					invalid = true;
				}
				
				if (inputMoney.value < 0.01)
				{
					invalid = true;
				}
				
				if (invalid)
				{
					inputMoney.invalid();
					inputCoins.invalid();
					nextButton.deactivate();
					nextButton.alpha = 0.5;
				}
				else
				{
					inputMoney.valid();
					inputCoins.valid();
					nextButton.activate();
					nextButton.alpha = 1;
				}
			}
			
			inputMoney.valid();
			inputCoins.valid();
			nextButton.activate();
			nextButton.alpha = 1;
			
			return !invalid;
		}
		
		private function nextClick():void {
			
			if (state == STATE_START && screenData.callback != null && screenData.resultSignal != null)
			{
				if (inputMoney.value < 100)
				{
					processTransaction();
				}
				else
				{
					DialogManager.alert(Lang.textAttention, Lang.largeOrderWarning, onLargeTransactionResponse, Lang.textOk, Lang.CANCEL);
				}
			}
			else if(state == STATE_SUCCESS)
			{
				ServiceScreenManager.closeView();
			}
		}
		
		private function onLargeTransactionResponse(val:int):void 
		{
			if (val == 1)
			{
				processTransaction();
			}
		}
		
		private function processTransaction():void 
		{
			var price:Number;
			var orderSide:String;
			if (screenData != null && screenData.orders != null && screenData.orders.length > 0 && screenData.orders[0] != null)
			{
				price = (screenData.orders[0] as TradingOrder).price;
				orderSide = (screenData.orders[0] as TradingOrder).side;
			}
			
			var maxCoins:Number = getMaxCoins();
			var moneyToPay:Number = maxCoins * parseFloat(getPrice());
			
			if (!isNaN(price) && orderSide == TradingOrder.BUY)
			{
				PayManager.callGetSystemOptions(function():void {
					if (isDisposed)
					{
						return;
					}
					if (!isNaN(inputMoney.value) && PayManager.systemOptions != null && !isNaN(PayManager.systemOptions.coinMinFiatValue) && inputMoney.value < PayManager.systemOptions.coinMinFiatValue)
					{
						var text:String = Lang.minimumLotAmount;
						text = LangManager.replace(Lang.regExtValue, text, PayManager.systemOptions.coinMinFiatValue.toString());
						ToastMessage.display(text);
					}
					else
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
							makeTransaction();
						}
					}
				} );
			}
			else
			{
				makeTransaction();
			}
		}
		
		private function onCommissionPopup(val:int):void 
		{
			if (val != 1)
				return;
			makeTransaction();
		}
		
		private function makeTransaction():void 
		{
			horizontalLoader.start();
			
			locked = true;
			
			TweenMax.to(inputCoins, 0.3, {alpha:0.5, delay:0.5});
			TweenMax.to(inputMoney, 0.3, {alpha:0.5, delay:0.5});
			TweenMax.to(nextButton, 0.3, {alpha:0.5, delay:0.5});
			TweenMax.to(backButton, 0.3, {alpha:0.5, delay:0.5});
			
			deactivateScreen();
			
			var order:TradingOrderRequest = new TradingOrderRequest();
			order.orders = orders;
			order.quantity = inputCoins.value;
			
			currentRequest = order;
			
			currentAction = new TradeCoinsAction(currentRequest, screenData.resultSignal, screenData.callback);
			currentAction.getFailSignal().add(onTradeFail);
			currentAction.getSuccessSignal().add(onTradeSuccess);
			currentAction.execute();
		}
		
		private function onTradeFail(message:String = null):void 
		{
			currentAction = null;
			
			if (isDisposed)
			{
				return;
			}
			if (message != null)
			{
				ToastMessage.display(message);
			}
			
			unlock();
			
			TweenMax.to(inputCoins, 0.3, {alpha:1});
			TweenMax.to(inputMoney, 0.3, {alpha:1});
			TweenMax.to(nextButton, 0.3, {alpha:1});
			TweenMax.to(backButton, 0.3, {alpha:1});
		}
		
		private function unlock():void 
		{
			locked = false;
			
			horizontalLoader.stop();
			
			TweenMax.killTweensOf(inputCoins);
			TweenMax.killTweensOf(inputMoney);
			TweenMax.killTweensOf(nextButton);
			TweenMax.killTweensOf(backButton);
			
			activateScreen();
		}
		
		private function onTradeSuccess(response:TradingResponse):void 
		{
			currentAction = null;
			
			if (isDisposed)
			{
				return;
			}
			
			updateMarketplcae();
			
			state = STATE_SUCCESS;
			
			unlock();
			
			if (animation == null)
			{
				animation = new Sprite();
				container.addChild(animation);
			}
			container.setChildIndex(horizontalLoader, container.numChildren - 1);
			
			animation.graphics.clear();
			animation.scaleX = animation.scaleY = 1;
			animation.graphics.beginFill(0xD9E5F0);
			animation.graphics.drawRect(0, 0, _width, 5);
			animation.graphics.endFill();
			
			
			if (screenData.type == TradingOrder.SELL)
			{
				PHP.call_statVI("coinBuy", response.credit_amount.toString());
			}
			else
			{
				PHP.call_statVI("coinSell", response.debit_amount.toString());
			}
			
			TweenMax.to(animation, 0.4, {height:bg.height, onUpdate:updateAnimator, onComplete:showContent, onCompleteParams:[response], ease:Power1.easeOut});
			
			activateScreen();
		}
		
		private function updateMarketplcae():void 
		{
			if (screenData != null && screenData.refresh != null)
			{
				screenData.refresh();
			}
		}
		
		private function showContent(response:TradingResponse):void 
		{
			var coinsTitleValue:String;
			var moneyTitleValue:String;
			
			var coinsValue:String;
			var moneyValue:String;
			
			var currencyCoin:String;
			var currencyMoney:String;
			var allCoinsText:String;
			
			if (screenData != null && screenData.type == TradingOrder.BUY)
			{
				currencyCoin = response.debit_currency;
				if (Lang[currencyCoin] != null)
				{
					currencyCoin = Lang[currencyCoin];
				}
				coinsTitleValue = Lang.sold + ":";
				coinsValue = parseFloat(response.debit_amount.toFixed(4)).toString() + " " + currencyCoin;
				
				currencyMoney = response.credit_currency;
				
				moneyTitleValue = Lang.youReceived + ":";
				moneyValue = parseFloat(response.credit_amount.toFixed(2)).toString() + " " + currencyMoney;
			}
			else
			{
				currencyCoin = response.credit_currency;
				if (Lang[currencyCoin] != null)
				{
					currencyCoin = Lang[currencyCoin];
				}
				coinsTitleValue = Lang.bought + ":";
				coinsValue = parseFloat(response.credit_amount.toFixed(4)).toString() + " " + currencyCoin;
				
				currencyMoney = response.debit_currency;
				
				moneyTitleValue = Lang.cost + ":";
				moneyValue = parseFloat(response.debit_amount.toFixed(2)).toString() + " " + currencyMoney;
				allCoinsText = Lang.of + " " + parseFloat(getMaxCoins().toFixed(4)).toString() + " " + currencyCoin;
			}
			
			inputCoins.visible = false;
			inputMoney.visible = false;
			backButton.visible = false;
			
			scrollPanel.removeObject(inputCoins);
			scrollPanel.removeObject(inputMoney);
			
			resultTitle = new Bitmap();
			scrollPanel.addObject(resultTitle);
			drawResultTitle(Lang.transactionComplete);
			
			hLine1 = new Bitmap();
			hLine1.bitmapData = UI.getHorizontalLine(2, 0xCCCCCC, componentsWidth);
			scrollPanel.addObject(hLine1);
			
			hLine2 = new Bitmap();
			hLine2.bitmapData = UI.getHorizontalLine(2, 0xCCCCCC, componentsWidth);
			scrollPanel.addObject(hLine2);
			
			coinTitle = new Bitmap();
			scrollPanel.addObject(coinTitle);
			drawCoinTitle(coinsTitleValue);
			
			coinValueImage = new Bitmap();
			scrollPanel.addObject(coinValueImage);
			drawCoinValue(coinsValue);
			
			allCoinsValueImage = new Bitmap();
			if (allCoinsText != null)
			{
				scrollPanel.addObject(allCoinsValueImage);
				drawAllCoinsValue(allCoinsText);
			}
			
			moneyValueImage = new Bitmap();
			scrollPanel.addObject(moneyValueImage);
			drawMoneyValue(moneyValue);
			
			moneyTitle = new Bitmap();
			scrollPanel.addObject(moneyTitle);
			drawMoneyTitle(moneyTitleValue);
			
			var position:int = 0;
			
			resultTitle.y = position;
			position += resultTitle.height + vPadding * .8;
			
			hLine1.y = position;
			position += vPadding * 1;
			
			coinTitle.y = position;
			coinValueImage.y = position;
			
			if (screenData != null && screenData.type == TradingOrder.SELL)
			{
				position += coinTitle.height + vPadding * .4;
				allCoinsValueImage.y = position;
				position += allCoinsValueImage.height + vPadding * .9;
			}
			else
			{
				position += coinTitle.height + vPadding * .9;
			}
			
			hLine2.y = position;
			position += vPadding * 1;
			
			moneyTitle.y = position;
			moneyValueImage.y = position;
			
			resultTitle.x = hPadding;
			hLine1.x = hPadding;
			hLine2.x = hPadding;
			coinTitle.x = hPadding;
			moneyTitle.x = hPadding;
			
			coinValueImage.x = int(componentsWidth + hPadding - coinValueImage.width);
			allCoinsValueImage.x = int(componentsWidth + hPadding - allCoinsValueImage.width);
			moneyValueImage.x = int(componentsWidth + hPadding - moneyValueImage.width);
			
			drawNextButton(Lang.close);
			nextButton.x = int(_width * .5 - nextButton.width * .5);
			
			scrollPanel.update();
			
			TweenMax.to(animation, 0.4, {height:1, onUpdate:updateAnimatorShow, onComplete:onContentShown, delay:0.1, ease:Power1.easeOut});
		}
		
		private function drawCoinValue(value:String):void 
		{
			coinValueImage.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .32, false, Color.GREEN, 
															Style.color(Style.COLOR_BACKGROUND), false, true);
		}
		
		private function drawAllCoinsValue(value:String):void 
		{
			allCoinsValueImage.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .28, false, Style.color(Style.COLOR_SUBTITLE), 
															Style.color(Style.COLOR_BACKGROUND), false, true);
		}
		
		private function drawMoneyValue(value:String):void 
		{
			moneyValueImage.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .32, false, Style.color(Style.COLOR_SUBTITLE), 
															Style.color(Style.COLOR_BACKGROUND), false, true);
		}
		
		
		private function drawCoinTitle(value:String):void 
		{
			coinTitle.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .32, false, Style.color(Style.COLOR_TEXT),
															Style.color(Style.COLOR_BACKGROUND), false, true);
		}
		
		private function drawMoneyTitle(value:String):void 
		{
			moneyTitle.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .32, false, Style.color(Style.COLOR_TEXT), 
															Style.color(Style.COLOR_BACKGROUND), false, true);
		}
		
		private function drawResultTitle(value:String):void 
		{
			resultTitle.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .32, false, Style.color(Style.COLOR_TEXT), 
															Style.color(Style.COLOR_BACKGROUND), false, true);
		}
		
		
		private function onContentShown():void 
		{
			if (animation)
			{
				animation.visible = false;
			}
		}
		
		private function updateAnimatorShow():void 
		{
			if (animation != null)
			{
				animation.y = bg.y + bg.height - animation.height;
			}
		}
		
		private function updateAnimator():void 
		{
			if (animation != null)
			{
				animation.y = bg.y;
			}
		}
		
		private function backClick():void {
			rejectPopup();
		}
		
		private function rejectPopup():void 
		{
			ServiceScreenManager.closeView();
		}
		
		override public function onBack(e:Event = null):void
		{
			rejectPopup();
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		private function collapse(value:Array):Array
		{
			var result:Array = new Array();
			var length:int = value.length;
			var lastItem:TradingOrder;
			var stackItem:TradingOrder;
			for (var i:int = 0; i < length; i++) 
			{
				if (lastItem != null && lastItem is TradingOrder && value[i] is TradingOrder && value[i] != null && lastItem.side == value[i].side && lastItem.price == value[i].price)
				{
					if (lastItem.suboffers == null)
					{
						stackItem = new TradingOrder();
						stackItem.quantity = lastItem.quantity;
						stackItem.price = lastItem.price;
						stackItem.quantityString = lastItem.quantityString;
						stackItem.priceString = lastItem.priceString;
						stackItem.currency = lastItem.currency;
						stackItem.coin = lastItem.coin;
						stackItem.side = lastItem.side;
						
						stackItem.addSuboffer(lastItem);
						result.removeAt(result.length - 1);
						result.push(stackItem);
						lastItem = stackItem;
					}
					lastItem.quantity += value[i].quantity;
					lastItem.quantityString = parseFloat(lastItem.quantity.toFixed(4)).toString();
					lastItem.addSuboffer(value[i]);
				}
				else
				{
					if (value[i] is TradingOrder)
					{
						lastItem = value[i];
						result.push(lastItem);
					}
					else
					{
						result.push(value[i]);
					}
				}
			}
			return result;
		}
		
		override public function initScreen(data:Object = null):void
		{
			if (data != null)
			{
				data.title = null;
			}
			
			if (data != null && data is OrderScreenData)
			{
				screenData = data as OrderScreenData;
				
				if (screenData.orders != null)
				{
					var localOrders:Array = new Array();
					if (screenData.orders.length > 0)
					{
						var l:int = screenData.orders.length;
						for (var i:int = 0; i < l; i++) 
						{
							if ((screenData.orders[i] as TradingOrder).own == false)
							{
								localOrders.push(screenData.orders[i]);
							}
						}
					}
					orders = localOrders;
				}
				
				var rendererWidth:int = _width - Config.FINGER_SIZE * 2.3;
				
				if (orders != null)
				{
					var order:TradingOrder;
					if (orders.length > 0)
					{
						var collapsed:Array = collapse(orders);
						if (collapsed != null && collapsed.length > 0)
						{
							order = collapsed[0];
						}
						if (order != null)
						{
							rendererData = order;
							renderer.draw(order, rendererWidth, null);
						//	renderer.x = int(_width * .5 - renderer.getWidth() * .5);
							renderer.x = int(Config.FINGER_SIZE * .3);
							renderer.y = (Config.FINGER_SIZE * .2);
							
							titleBitmap.visible = false;
						}
						else
						{
							ApplicationErrors.add();
							renderer.visible = false;
						}
					}
				}
				
				if (screenData.type == TradingOrder.BUY)
				{
				//	topBar.setColor(0xD9E5F0);
					topBar.setColor(0xFFFFFF);
					if (renderer.visible == true)
					{
						topBar.setHeight(int(renderer.getHeight(rendererData, rendererWidth, null) + Config.FINGER_SIZE * .4));
					}
					else
					{
						topBar.setHeight(int(Config.FINGER_SIZE * 1.5));
					}
				}
				else
				{
				//	topBar.setColor(0xD3F0CC);
					topBar.setColor(0xFFFFFF);
					if (renderer.visible == true)
					{
						topBar.setHeight(int(renderer.getHeight(rendererData, rendererWidth, null) + Config.FINGER_SIZE * .4));
					}
					else
					{
						topBar.setHeight(int(Config.FINGER_SIZE * 1.5));
					}
				}
			}
			
			super.initScreen(data);
			
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
			horizontalLoader.y = topBar.y + Config.FINGER_SIZE * 1.3;
			
			padding = Config.DIALOG_MARGIN;			
			
			accounts = new PaymentsAccountsProvider(onAccountsDataReady);
			
			drawTitle();
			inputMoney.x = hPadding;
			inputCoins.x = hPadding;
			
			var buttonText:String;
			if (screenData.type == TradingOrder.SELL)
			{
				buttonText = Lang.BUY;
			}
			else
			{
				buttonText = Lang.sell;
			}
			
			drawNextButton(buttonText);
			drawBackButton();
			
			drawNotBestPrice();
			
			if (accounts.ready == true && accounts.coinsAccounts != null && accounts.moneyAccounts != null)
			{
				construct();
			}
			else
			{
				drawStartValues();
				horizontalLoader.start();
				accounts.getData();
			}
			
			state = STATE_START;
			if (checkDataValid() == true)
			{
				loadComission();
			}
		}
		
		private function drawNotBestPrice():void 
		{
			var description:String;
			if (rendererData != null)
			{
				if (screenData.type == TradingOrder.SELL)
				{
					if (!isNaN(screenData.bestBuyPrice) && screenData.bestBuyPrice != 0 && screenData.bestBuyPrice != Number.POSITIVE_INFINITY &&
						screenData.bestBuyPrice < rendererData.price)
					{
						description = Lang.badPriceDescription;
					//	description = LangManager.replace(Lang.regExtValue, description, inputPrice.value.toString());
						description = LangManager.replace(Lang.regExtValue, description, "@ " + screenData.bestBuyPrice.toString() + " EUR");
						
					}
				}
				else
				{
					if (!isNaN(screenData.bestSellPrice) && screenData.bestSellPrice != 0 && screenData.bestSellPrice != Number.POSITIVE_INFINITY &&
						screenData.bestSellPrice > rendererData.price)
					{
						description = Lang.badPriceDescription;
					//	description = LangManager.replace(Lang.regExtValue, description, inputPrice.value.toString());
						description = LangManager.replace(Lang.regExtValue, description, "@ " + screenData.bestSellPrice.toString() + " EUR");
					}
				}
			}
			
			if (screenData.type == TradingOrder.BUY)
			{
				incomeText.visible = true;
				drawIncome();
				drawCommision();
			}
			
			if (description != null)
			{
				badPrice.visible = true;
				drawBadPrice(description);
			}
			else
			{
				badPrice.visible = false;
			}
		}
		
		private function loadComission():void 
		{
			if (screenData.type == TradingOrder.BUY)
			{
				if (rendererData != null)
				{
					drawCommision();
					horizontalLoader.start();
					if (comission == null)
					{
						comission = new CoinComissionChecker(onComission);
					}
					var order:TradingOrder = new TradingOrder();
					order.quantity = inputCoins.value;
					order.price = rendererData.price;
					comission.execute([order], inputCoins.value);
				}
			}
		}
		
		private function onComission(commissionData:Object):void 
		{
			if (isDisposed == true) {
				return;
			}
			horizontalLoader.stop();
			
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
			commisionText.draw(componentsWidth, commissionData);
			
			if (comission != null && !isNaN(comission.getValue()))
			{
				drawIncome(getIncome(comission.getValue()) + " EUR");
			}
			drawView();
		}
		
		private function getIncome(commissionValue:Number):Number 
		{
			if (comission != null)
			{
				return Math.round((inputMoney.value - commissionValue) * 1000) / 1000;
			}
			return Math.round((inputMoney.value) * 1000) / 1000;
		}
		
		private function drawIncome(text:String = null):void 
		{
			var displayText:String = Lang.totalEstimatedEarn + ": ";
			if (text != null)
			{
				displayText += text;
			}
			
			incomeText.bitmapData = TextUtils.createTextFieldData(
																	displayText, 
																	_width - Config.DIALOG_MARGIN*2, 
																	10, 
																	true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	FontSize.BODY, 
																	true, 
																	Style.color(Style.COLOR_TEXT), 
																	Style.color(Style.COLOR_BACKGROUND), false, false, true);
			incomeText.x = Config.DIALOG_MARGIN;
			drawView();
		}
		
		private function drawBadPrice(text:String):void 
		{
			if (badPrice.bitmapData != null)
			{
				badPrice.bitmapData.dispose();
				badPrice.bitmapData = null;
			}
			
			badPrice.bitmapData = TextUtils.createTextFieldData(
																	text, 
																	_width - Config.DIALOG_MARGIN*2, 
																	10, 
																	true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .28, 
																	true, 
																	0xFF0000, 
																	0xFF0000, false, false, true);
			badPrice.x = Config.DIALOG_MARGIN;
		}
		
		private function drawStartValues():void 
		{
			var moneyTitleString:String;
			var coinsTitleString:String;
			
			if (screenData.type == TradingOrder.SELL)
			{
				moneyTitleString = Lang.amountToPay;
				coinsTitleString = Lang.dukacoinsToBuy;
			}
			else
			{
				moneyTitleString = Lang.amountToGet;
				coinsTitleString = Lang.coinsToSell;
			}
			
			inputMoney.draw(componentsWidth, moneyTitleString, 0, null, "EUR");
			inputCoins.draw(componentsWidth, coinsTitleString, 0, Lang.minimum + ": 0.01 EUR", "DUK+");
			
			updatePositions();
		}
		
		private function drawTitle():void 
		{
			var price:ImageBitmapData = TextUtils.createTextFieldData(
																	getPrice(), 
																	_width, 
																	10, 
																	false, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .55, 
																	false, 
																	0x47515B, 
																	topBar.getColor(), false, false, true);
			var priceTitle:ImageBitmapData = TextUtils.createTextFieldData(
																	Lang.priceForCoin, 
																	_width, 
																	10, 
																	false, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .28, 
																	false, 
																	0x47515B, 
																	topBar.getColor(), false, false, true);
			var titleBD:ImageBitmapData = new ImageBitmapData("title", Math.max(price.width, priceTitle.width), price.height + Config.FINGER_SIZE * .15 + priceTitle.height);
			titleBD.copyPixels(price, price.rect, new Point(int(titleBD.width * .5 - price.width * .5), 0), null, null, true);
			titleBD.copyPixels(priceTitle, priceTitle.rect, new Point(int(titleBD.width * .5 - priceTitle.width * .5), int(price.height + Config.FINGER_SIZE * .15)), null, null, true);
			price.dispose();
			priceTitle.dispose();
			titleBitmap.bitmapData = titleBD;
			titleBitmap.x = int(_width * .5 - titleBitmap.width * .5);
			titleBitmap.y = topBar.y + Config.FINGER_SIZE * 1.5 * .5 - titleBitmap.height * .5;
		}
		
		private function onAccountsDataReady():void 
		{
			horizontalLoader.stop();
			construct();
			drawView();
		}
		
		private function construct():void 
		{
			var maxCoinsAvaliable:String;
			if (accounts.coinsAccounts != null && accounts.coinsAccounts.length > 0)
			{
				var currency:String = accounts.coinsAccounts[0].COIN;
				if (Lang[currency] != null)
				{
					currency = Lang[currency];
				}
				
				if (screenData.type == TradingOrder.SELL)
				{
					maxCoinsAvaliable = Lang.maximum + ": " + parseFloat(getMaxCoins().toFixed(4)).toString() + " " + currency;
				}
				else
				{
					if (orders != null)
					{
						maxCoinsAvaliable = Lang.avaliable + ": " + accounts.coinsAccounts[0].BALANCE + " " + currency + ", " + Lang.maximum + ": " + parseFloat(getMaxCoins().toFixed(4)).toString() + " " + currency;
					}
				}
			}
			
			var maxEurosAvaliable:String;
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
					maxEurosAvaliable = Lang.avaliable + ": " + euroAcc.BALANCE + " " + euroAcc.CURRENCY;
				}	
			}
			
			var startPriceValue:Number = 5;
			var startQuantityValue:Number = 1;
			
			if (screenData.type == TradingOrder.SELL)
			{
				var maxCoins:Number = getMaxCoins();
				var moneyToPay:Number = maxCoins * parseFloat(getPrice());
				var maxMoney:Number = getMaxMoney();
				if (moneyToPay > maxMoney)
				{
					moneyToPay = maxMoney;
					maxCoins = moneyToPay / parseFloat(getPrice());
				}
				
				startPriceValue = moneyToPay;
				startQuantityValue = Math.floor(maxCoins * 10000) / 10000;
			}
			else
			{
				startQuantityValue = Math.min(getAvaliableCoins(), getMaxCoins());
				startPriceValue = startQuantityValue * parseFloat(getPrice());
			}
			
			var moneyTitleString:String;
			var coinsTitleString:String;
			
			if (screenData.type == TradingOrder.SELL)
			{
				moneyTitleString = Lang.amountToPay;
				coinsTitleString = Lang.dukacoinsToBuy;
			}
			else
			{
				moneyTitleString = Lang.amountToGet;
				coinsTitleString = Lang.coinsToSell;
				maxEurosAvaliable = null;
			}
			
		//	startPriceValue = NaN;
		//	startQuantityValue = NaN;
			
			if (orders.length == 1 && (orders[0] as TradingOrder).fillOrKill)
			{
				startQuantityValue = (orders[0] as TradingOrder).quantity;
				if (isActivated)
				{
					inputMoney.deactivate();
					inputCoins.deactivate();
				}
			}
			
			inputMoney.draw(componentsWidth, moneyTitleString, startPriceValue, maxEurosAvaliable, "EUR");
			inputCoins.draw(componentsWidth, coinsTitleString, startQuantityValue, maxCoinsAvaliable, "DUK+");
			
			onChangeInputCoins();
		}
		
		override protected function onCloseTap():void {
			if (_isDisposed == true)
				return;
			if (locked)
			{
				return;
			}
			onBack();
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
		
		private function getMaxCoins():Number 
		{
			if (orders != null)
			{
				var sum:Number = 0;
				for (var j:int = 0; j < orders.length; j++) 
				{
					sum += (orders[j] as TradingOrder).quantity;
				}
				return sum;
			}
			return 0;
		}
		
		private function getAvaliableCoins():Number 
		{
			if (accounts != null && accounts.coinsAccounts != null && accounts.coinsAccounts.length > 0 && accounts.coinsAccounts[0] != null)
			{
				return parseFloat(accounts.coinsAccounts[0].BALANCE);
			}
			return 0;
		}
		
		private function getPrice():String 
		{
			if (screenData != null && screenData.orders != null && screenData.orders.length > 0 && screenData.orders[0] != null)
			{
				return (screenData.orders[0] as TradingOrder).priceString + " " + (screenData.orders[0] as TradingOrder).currency;
			}
			return "";
		}
		
		private function updatePositions():void 
		{
			var position:int = Config.FINGER_SIZE * .2;
			position = 0;
			if (screenData.type == TradingOrder.SELL || screenData.type == TradingOrder.BUY)
			{
				inputCoins.y = position;
				position += Math.max(inputMoney.getHeight(), inputCoins.getHeight()) + Config.FINGER_SIZE * .4;
				
				inputMoney.y = position;
				position += Math.max(inputMoney.getHeight(), inputMoney.getHeight()) + Config.FINGER_SIZE * .3;
			}
			
			if (commisionText.height > 0)
			{
				commisionText.x = hPadding;
				commisionText.y = position;
				position += commisionText.height + Config.FINGER_SIZE * .4;
			}
			
			if (incomeText.visible == true)
			{
				incomeText.y = position;
				position += incomeText.height + Config.FINGER_SIZE * .3;
			}
			
			if (badPrice.visible == true)
			{
				badPrice.y = position;
				position += badPrice.height + Config.FINGER_SIZE * .3;
			}
			
			backButton.x = Config.DIALOG_MARGIN;
			if (state == STATE_SUCCESS)
			{
				nextButton.x = int(_width * .5 - nextButton.width * .5);
			}
			else
			{
				nextButton.x = backButton.x + backButton.width + Config.MARGIN;
			}
		}
		
		override protected function getMaxContentHeight():int {
			return _height - scrollPanel.view.y - vPadding * 2 - nextButton.height;
		}
		
		override protected function calculateBGHeight():int {
			var value:int = scrollPanel.view.y + scrollPanel.height + vPadding * 2 + nextButton.height;
			return value;
		}
		
		private function drawNextButton(text:String):void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawBackButton():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0x657280, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0xFFFFFF, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			backButton.setBitmapData(buttonBitmap, true);
		}
		
		override protected function drawView():void
		{
			if (_isDisposed == true)
				return;
			
			updatePositions();
			
			super.drawView();
			
			horizontalLoader.y = topBar.y + Config.FINGER_SIZE * 1.3;
			backButton.y = nextButton.y = scrollPanel.view.y + scrollPanel.height + vPadding;
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			if (locked == true)
			{
				return;
			}
			
			super.activateScreen();
			
			backButton.activate();
			nextButton.activate();
			
			if (isEditable())
			{
				inputMoney.activate();
				inputCoins.activate();
			}
			
			checkDataValid();
		}
		
		private function isEditable():Boolean 
		{
			if (orders.length == 1 && (orders[0] as TradingOrder).fillOrKill)
			{
				return false;
			}
			return true;
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			backButton.deactivate();
			nextButton.deactivate();
			
			inputMoney.deactivate();
			inputCoins.deactivate();
		}
		
		override public function dispose():void
		{
			TweenMax.killTweensOf(animation);
			TweenMax.killTweensOf(inputCoins);
			TweenMax.killTweensOf(inputMoney);
			TweenMax.killTweensOf(nextButton);
			TweenMax.killTweensOf(backButton);
			
			if (_isDisposed == true)
				return;
			super.dispose();
			
			Overlay.removeCurrent();
			rendererData = null;
			
			if (comission != null)
			{
				comission.dispose();
				comission = null;
			}
			if (commisionText != null)
			{
				commisionText.dispose();
				commisionText = null;
			}
			if (currentAction != null)
			{
				currentAction.getFailSignal().remove(onTradeFail);
				currentAction.getSuccessSignal().remove(onTradeSuccess);
				currentAction.dispose();
				currentAction = null;
			}
			if (renderer != null)
			{
				renderer.dispose();
				renderer = null;
			}
			if (badPrice != null)
			{
				UI.destroy(badPrice);
				badPrice = null;
			}
			if (incomeText != null)
			{
				UI.destroy(incomeText);
				incomeText = null;
			}
			if (accounts != null)
			{
				accounts.dispose();
				accounts = null;
			}
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (inputCoins != null)
			{
				inputCoins.dispose();
				inputCoins = null;
			}
			if (inputMoney != null)
			{
				inputMoney.dispose();
				inputMoney = null;
			}
			if (titleBitmap != null)
			{
				UI.destroy(titleBitmap);
				titleBitmap = null;
			}
			if (animation != null)
			{
				UI.destroy(animation);
				animation = null;
			}
			if (resultTitle != null)
			{
				UI.destroy(resultTitle);
				resultTitle = null;
			}
			if (coinTitle != null)
			{
				UI.destroy(coinTitle);
				coinTitle = null;
			}
			if (moneyTitle != null)
			{
				UI.destroy(moneyTitle);
				moneyTitle = null;
			}
			if (hLine1 != null)
			{
				UI.destroy(hLine1);
				hLine1 = null;
			}
			if (hLine2 != null)
			{
				UI.destroy(hLine2);
				hLine2 = null;
			}
			if (coinValueImage != null)
			{
				UI.destroy(coinValueImage);
				coinValueImage = null;
			}
			if (moneyValueImage != null)
			{
				UI.destroy(moneyValueImage);
				moneyValueImage = null;
			}
			if (allCoinsValueImage != null)
			{
				UI.destroy(allCoinsValueImage);
				allCoinsValueImage = null;
			}
			
			currentRequest = null;
			screenData = null;
		}
	}
}