package com.dukascopy.connect.screens.marketplace 
{
	import assets.FilterIcon;
	import assets.FilterIcon2;
	import assets.GraphIcon;
	import assets.RefreshIcon;
	import assets.RefreshIcon2;
	import assets.RefreshIcon3;
	import assets.RemoveIcon2;
	import assets.VideoIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class MarketplaceControlPanel extends Sprite
	{
		private var _refresh:Function;
		private var _clearFilter:Function;
		private var _onBuy:Function;
		private var _onSell:Function;
		
		private var backClip:Sprite;
		private var bidButton:BitmapButton;
		private var askButton:BitmapButton;
		private var graphButton:BitmapButton;
		private var refreshButton:BitmapButton;
		private var filterButton:BitmapButton;
		private var itemHeight:int;
		private var currentFilter:String;
		private var buyButton:BitmapButton;
		private var sellButton:BitmapButton;
		private var _onCreateSell:Function;
		private var _onCreateBuy:Function;
		private var componentWidth:int;
		
		public function MarketplaceControlPanel() 
		{
			create();
		}
		
		public function set refresh(value:Function):void 
		{
			_refresh = value;
		}
		
		public function set buyClick(value:Function):void 
		{
			_onBuy = value;
		}
		
		public function set createBuy(value:Function):void 
		{
			_onCreateBuy = value;
		}
		
		public function set createSell(value:Function):void 
		{
			_onCreateSell = value;
		}
		
		public function set sellClick(value:Function):void 
		{
			_onSell = value;
		}
		
		public function set clearFilter(value:Function):void 
		{
			_clearFilter = value;
		}
		
		private function create():void 
		{
			backClip = new Sprite();
			addChild(backClip);
			
			bidButton = new BitmapButton();
			bidButton.setStandartButtonParams();
			bidButton.setDownScale(1);
			bidButton.setDownColor(0);
			bidButton.tapCallback = askClick; // TODO - change button name or callback name
			bidButton.disposeBitmapOnDestroy = true;
			bidButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			addChild(bidButton);
			
			askButton = new BitmapButton();
			askButton.setStandartButtonParams();
			askButton.setDownScale(1);
			askButton.setDownColor(0);
			askButton.tapCallback = bidClick; // TODO - change button name or callback name
			askButton.disposeBitmapOnDestroy = true;
			askButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			addChild(askButton);
			
			graphButton = new BitmapButton();
			graphButton.setStandartButtonParams();
			graphButton.setDownScale(1);
			graphButton.setDownColor(0);
			graphButton.tapCallback = graphClick;
			graphButton.disposeBitmapOnDestroy = true;
		//	filterButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			addChild(graphButton);
			
			filterButton = new BitmapButton();
			filterButton.setStandartButtonParams();
			filterButton.setDownScale(1);
			filterButton.setDownColor(0);
			filterButton.tapCallback = filterClick;
			filterButton.disposeBitmapOnDestroy = true;
		//	filterButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			addChild(filterButton);
			
			refreshButton = new BitmapButton();
			refreshButton.setStandartButtonParams();
			refreshButton.setDownScale(1);
			refreshButton.setDownColor(0);
			refreshButton.tapCallback = refreshClick;
			refreshButton.disposeBitmapOnDestroy = true;
			refreshButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			addChild(refreshButton);
			
			buyButton = new BitmapButton();
			buyButton.setStandartButtonParams();
			buyButton.setDownScale(1);
			buyButton.setDownColor(0);
			buyButton.tapCallback = onBuyClick;
			buyButton.disposeBitmapOnDestroy = true;
			buyButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			addChild(buyButton);
			
			sellButton = new BitmapButton();
			sellButton.setStandartButtonParams();
			sellButton.setDownScale(1);
			sellButton.setDownColor(0);
			sellButton.tapCallback = onSellClick;
			sellButton.disposeBitmapOnDestroy = true;
			sellButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			addChild(sellButton);
			
			drawBidButton();
			drawAskButton();
			drawGraphButton();
			drawRefreshButton();
			drawBuyButton();
			drawSellButton();
			drawFilterButton();
		}
		
		private function filterClick():void 
		{
			if (currentFilter != null){
				if (_clearFilter != null){
					_clearFilter();
				}
			}
		}
		
		private function drawSellButton():void 
		{
			var buttonSize:int = Config.FINGER_SIZE * .8;
			
			var container:Sprite = new Sprite();
			container.graphics.beginFill(0x639DC5);
			container.graphics.drawRoundRect(2, 2, buttonSize - 4, buttonSize - 4, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
			
			var text:ImageBitmapData = TextUtils.createTextFieldData(Lang.SELL_noTranslate, buttonSize, 10, 
																	false, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .26, 
																	false, 0xFFFFFF, 0xFFFFFF);
			
			var image:ImageBitmapData = new ImageBitmapData("bidButton", buttonSize, buttonSize);
			image.draw(container, container.transform.matrix, container.transform.colorTransform);
			image.copyPixels(text, text.rect, new Point(Math.round(buttonSize * .5 - text.width * .5), Math.round(buttonSize * .5 - text.height*.5)), null, null, true);
			
			sellButton.setBitmapData(image, true);
			
			text.dispose();
			text = null;
		}
		
		private function drawBuyButton():void 
		{
			var buttonSize:int = Config.FINGER_SIZE * .8;
			
			var container:Sprite = new Sprite();
			container.graphics.beginFill(0x71C65F);
			container.graphics.drawRoundRect(2, 2, buttonSize - 4, buttonSize - 4, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
			
			var text:ImageBitmapData = TextUtils.createTextFieldData(Lang.BUY_noTranslate, buttonSize, 10, 
																	false, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .26, 
																	false, 0xFFFFFF, 0xFFFFFF);
			
			var image:ImageBitmapData = new ImageBitmapData("bidButton", buttonSize, buttonSize);
			image.draw(container, container.transform.matrix, container.transform.colorTransform);
			image.copyPixels(text, text.rect, new Point(Math.round(buttonSize * .5 - text.width * .5), Math.round(buttonSize * .5 - text.height*.5)), null, null, true);
			
			buyButton.setBitmapData(image, true);
			
			text.dispose();
			text = null;
		}
		
		private function onBuyClick():void 
		{
			if (_onBuy != null)
			{
				_onBuy();
			}
		}
		
		private function onSellClick():void 
		{
			if (_onSell != null)
			{
				_onSell();
			}
		}
		
		private function graphClick():void{
			MobileGui.changeMainScreen(ChartsBase, {backScreen:MobileGui.centerScreen.currentScreenClass, backScreenData:MobileGui.centerScreen.currentScreen.data});
		}
		
		private function refreshClick():void{
			if (_refresh != null){
				_refresh();
			}
		}
		
		private function drawGraphButton():void 
		{
			var image:ImageBitmapData;
			var buttonSize:int = Config.FINGER_SIZE * .8;
			
			var container:Sprite = new Sprite();
			
			var signIcon:GraphIcon = new GraphIcon();
			UI.scaleToFit(signIcon, buttonSize * .5, buttonSize * .5);
		//	UI.colorize(signIcon, 0x959066);
			
			var sign:ImageBitmapData = UI.getSnapshot(signIcon);
			
			container.graphics.lineStyle(1, 0xCFCFCF, 1, true);
			container.graphics.beginFill(0xFFFFFF);
			container.graphics.drawRoundRect(2, 2, buttonSize - 4, buttonSize - 4, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
			
			image = new ImageBitmapData("filterButton", buttonSize, buttonSize);
			image.draw(container, container.transform.matrix, container.transform.colorTransform);
			image.copyPixels(sign, sign.rect, new Point(Math.round(buttonSize * .5 - sign.width * .5), Math.round(buttonSize * .5 - sign.height * .5)), null, null, true);
			
			/*if (currentFilter == "my")
			{
				var icon:RemoveIcon2 = new RemoveIcon2();
				UI.scaleToFit(icon, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
				var iconBD:ImageBitmapData = UI.getSnapshot(icon, StageQuality.BEST, "icon");
				image.copyPixels(iconBD, iconBD.rect, new Point(Math.round(buttonSize - iconBD.width), 0), null, null, true);
				iconBD.dispose();
				iconBD = null;
			}*/
			
			graphButton.setBitmapData(image, true);
			
			sign.dispose();
			
			sign = null;
		}
		
		private function drawFilterButton():void 
		{
			
			var image:ImageBitmapData;
			var buttonSize:int = Config.FINGER_SIZE * .8;
			
			var container:Sprite = new Sprite();
			
			var signIcon:FilterIcon2 = new FilterIcon2();
			UI.scaleToFit(signIcon, buttonSize * .5, buttonSize * .5);
			UI.colorize(signIcon, 0x959066);
			
			var sign:ImageBitmapData = UI.getSnapshot(signIcon);
			
			container.graphics.lineStyle(1, 0xCFCFCF, 1, true);
			container.graphics.beginFill(0xFFFFFF);
			container.graphics.drawRoundRect(2, 2, buttonSize - 4, buttonSize - 4, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
			
			image = new ImageBitmapData("filterButton", buttonSize, buttonSize);
			image.draw(container, container.transform.matrix, container.transform.colorTransform);
			image.copyPixels(sign, sign.rect, new Point(Math.round(buttonSize * .5 - sign.width * .5), Math.round(buttonSize * .5 - sign.height * .5)), null, null, true);
					
			if (currentFilter == "my")
			{
				var icon:RemoveIcon2 = new RemoveIcon2();
				UI.scaleToFit(icon, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
				var iconBD:ImageBitmapData = UI.getSnapshot(icon, StageQuality.BEST, "icon");
				image.copyPixels(iconBD, iconBD.rect, new Point(Math.round(buttonSize - iconBD.width), 0), null, null, true);
				iconBD.dispose();
				iconBD = null;
			}
			
			filterButton.setBitmapData(image, true);
			
			sign.dispose();
			
			sign = null;
		}
		
		private function drawRefreshButton():void 
		{
			var buttonSize:int = Config.FINGER_SIZE * .8;
			
			var container:Sprite = new Sprite();
			container.graphics.lineStyle(1, 0xCFCFCF, 1, true);
			container.graphics.beginFill(0xFFFFFF);
			container.graphics.drawRoundRect(2, 2, buttonSize - 4, buttonSize - 4, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
			
			var signIcon:RefreshIcon3 = new RefreshIcon3();
			UI.scaleToFit(signIcon, container.height * .5, container.height * .5);
			UI.colorize(signIcon, 0x434343);
			
			var sign:ImageBitmapData = UI.getSnapshot(signIcon);
			
			var image:ImageBitmapData = new ImageBitmapData("refreshButton", buttonSize, buttonSize);
			image.draw(container, container.transform.matrix, container.transform.colorTransform);
			image.copyPixels(sign, sign.rect, new Point(Math.round(buttonSize * .5 - sign.width * .5), Math.round(buttonSize * .5 - sign.height * .5)), null, null, true);
			refreshButton.setBitmapData(image, true);
			refreshButton.smoothing = false;
			
			sign.dispose();
			
			sign = null;
		}
		
		private function askClick():void 
		{
			if (_onCreateBuy)
			{
				_onCreateBuy();
			}
		}
		
		private function bidClick():void 
		{
			if (_onCreateSell)
			{
				_onCreateSell();
			}
		}
		
		public function draw(componentWidth:int, filter:String):void
		{
			this.componentWidth = componentWidth;
			currentFilter = filter;
			
			itemHeight = Config.FINGER_SIZE * 1.1;
			backClip.graphics.clear();
			backClip.graphics.beginFill(0xF5F5F5);
			backClip.graphics.drawRect(0, 0, componentWidth, itemHeight + Config.APPLE_BOTTOM_OFFSET);
			backClip.graphics.endFill();
			
			backClip.graphics.lineStyle(1, 0xC9C9C9);
			backClip.graphics.moveTo(0, 0);
			backClip.graphics.lineTo(componentWidth, 0);
			
			drawFilterButton();
			
			
			var padding:int = Config.FINGER_SIZE * .1;
			//trace(componentWidth - askButton.width * 7 - padding * 8);
			if (componentWidth - askButton.width * 7 - padding * 8 < 0)
			{
				padding = int(Math.max(1, (componentWidth - askButton.width * 7) / 8));
			}
			
			bidButton.y = int(itemHeight * .5 - bidButton.height * .5);
			askButton.y = int(itemHeight * .5 - askButton.height * .5);
			refreshButton.y = int(itemHeight * .5 - refreshButton.height * .5);
			graphButton.y = int(itemHeight * .5 - graphButton.height * .5);
			filterButton.y = int(itemHeight * .5 - filterButton.height * .5);
			buyButton.y = int(itemHeight * .5 - buyButton.height * .5);
			sellButton.y = int(itemHeight * .5 - sellButton.height * .5);
			
			bidButton.x = padding;
			askButton.x = int(componentWidth - askButton.width - padding);
			refreshButton.x = int(width * .5 - refreshButton.width * .5);
			graphButton.x = int(refreshButton.x - padding - graphButton.width);
			filterButton.x = int(refreshButton.x + refreshButton.width + padding);
			
			buyButton.x = int(bidButton.x + bidButton.width + padding);
			sellButton.x = int(askButton.x - sellButton.width - padding);
		}
		
		private function drawBidButton():void
		{
			var buttonSize:int = Config.FINGER_SIZE * .8;
			
			var container:Sprite = new Sprite();
			container.graphics.lineStyle(1, 0xCFCFCF, 1, true);
			container.graphics.beginFill(0xFFFFFF);
			container.graphics.drawRoundRect(2, 2, buttonSize - 4, buttonSize - 4, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
			
			var sign:ImageBitmapData = TextUtils.createTextFieldData("+", buttonSize, 10, 
																	false, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .26, 
																	false, 0x74A1B4, 0xFFFFFF);
			var text:ImageBitmapData = TextUtils.createTextFieldData(Lang.bid.toUpperCase(), buttonSize, 10, 
																	false, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .26, 
																	false, 0x74A1B4, 0xFFFFFF);
			
			var image:ImageBitmapData = new ImageBitmapData("bidButton", buttonSize, buttonSize);
			image.draw(container, container.transform.matrix, container.transform.colorTransform);
			image.copyPixels(sign, sign.rect, new Point(Math.round(buttonSize * .5 - sign.width * .5), Math.round(buttonSize * .5 - sign.height - Config.FINGER_SIZE * .05)), null, null, true);
			image.copyPixels(text, text.rect, new Point(Math.round(buttonSize * .5 - text.width * .5), Math.round(buttonSize * .5 + Config.FINGER_SIZE * .05)), null, null, true);
			
			bidButton.setBitmapData(image, true);
			
			sign.dispose();
			text.dispose();
			
			sign = null;
			text = null;
			
			/*var textSettings:TextFieldSettings = new TextFieldSettings(Lang.addBid, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x6699FF, 1, Config.FINGER_SIZE * .5);
			bidButton.setBitmapData(buttonBitmap, true);*/
		}
		
		private function drawAskButton():void
		{
			var buttonSize:int = Config.FINGER_SIZE * .8;
			
			var container:Sprite = new Sprite();
			container.graphics.lineStyle(1, 0xCFCFCF, 1, true);
			container.graphics.beginFill(0xFFFFFF);
			container.graphics.drawRoundRect(2, 2, buttonSize - 4, buttonSize - 4, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
			
			var sign:ImageBitmapData = TextUtils.createTextFieldData("+", buttonSize, 10, 
																	false, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .26, 
																	false, 0x85B77A, 0xFFFFFF);
			var text:ImageBitmapData = TextUtils.createTextFieldData(Lang.ask.toUpperCase(), buttonSize, 10, 
																	false, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .26, 
																	false, 0x85B77A, 0xFFFFFF);
			
			var image:ImageBitmapData = new ImageBitmapData("askButton", buttonSize, buttonSize);
			image.draw(container, container.transform.matrix, container.transform.colorTransform);
			image.copyPixels(sign, sign.rect, new Point(Math.round(buttonSize * .5 - sign.width * .5), Math.round(buttonSize * .5 - sign.height - Config.FINGER_SIZE * .05)), null, null, true);
			image.copyPixels(text, text.rect, new Point(Math.round(buttonSize * .5 - text.width * .5), Math.round(buttonSize * .5 + Config.FINGER_SIZE * .05)), null, null, true);
			
			askButton.setBitmapData(image, true);
			
			sign.dispose();
			text.dispose();
			
			sign = null;
			text = null;
			
			/*var textSettings:TextFieldSettings = new TextFieldSettings(Lang.addAsk, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x77C043, 1, Config.FINGER_SIZE * .5);
			askButton.setBitmapData(buttonBitmap, true);*/
		}
		
		public function activate():void
		{
			bidButton.activate();
			askButton.activate();
			refreshButton.activate();
			graphButton.activate();
			buyButton.activate();
			sellButton.activate();
			filterButton.activate();
		}
		
		public function deactivate():void
		{
			bidButton.deactivate();
			askButton.deactivate();
			refreshButton.deactivate();
			graphButton.deactivate();
			buyButton.deactivate();
			sellButton.deactivate();
			filterButton.deactivate();
		}
		
		public function dispose():void
		{
			if (backClip != null)
			{
				UI.destroy(backClip);
				backClip = null;
			}
			if (bidButton != null)
			{
				bidButton.dispose();
				bidButton = null;
			}
			if (askButton != null)
			{
				askButton.dispose();
				askButton = null;
			}
			if (graphButton != null)
			{
				graphButton.dispose();
				graphButton = null;
			}
			if (buyButton != null)
			{
				buyButton.dispose();
				buyButton = null;
			}
			if (sellButton != null)
			{
				sellButton.dispose();
				sellButton = null;
			}
			if (refreshButton != null)
			{
				refreshButton.dispose();
				refreshButton = null;
			}
			if (filterButton != null)
			{
				filterButton.dispose();
				filterButton = null;
			}
			
			_onCreateBuy = null;
			_onCreateSell = null;
			_onBuy = null;
			_onSell = null;
			_refresh = null;
			_clearFilter = null;
		}
		
		public function collapseButtons():void 
		{
			refreshButton.x = int(width * .5 - refreshButton.width * .5);
			graphButton.x = int(refreshButton.x - Config.FINGER_SIZE * .1 - graphButton.width);
			filterButton.x = int(refreshButton.x + refreshButton.width + Config.FINGER_SIZE * .1);
			
			bidButton.y = int(itemHeight * .5 - bidButton.height * .5);
			askButton.y = int(itemHeight * .5 - askButton.height * .5);
			refreshButton.y = int(itemHeight * .5 - refreshButton.height * .5);
			graphButton.y = int(itemHeight * .5 - graphButton.height * .5);
			
			bidButton.x = bidButton.y;
			askButton.x = int(componentWidth - askButton.width - askButton.y);
			
			buyButton.y = int(itemHeight * .5 - buyButton.height * .5);
			sellButton.y = int(itemHeight * .5 - sellButton.height * .5);
			
			buyButton.x = int(bidButton.x + bidButton.width + buyButton.y);
			sellButton.x = int(askButton.x - sellButton.width - sellButton.y);
		}
		
		public function expandButtons(position:int):void 
		{
			askButton.y = bidButton.y = position;
			askButton.x = componentWidth - Config.DIALOG_MARGIN - askButton.width;
			bidButton.x = Config.DIALOG_MARGIN;
			
			sellButton.x = sellButton.y;
			buyButton.x = int(componentWidth - buyButton.width - sellButton.y);
		}
		
		public function getHeight():int 
		{
			return itemHeight + Config.APPLE_BOTTOM_OFFSET;
		}
		
		public function buttonLeftPadding():int 
		{
			return bidButton.x + bidButton.width;
		}
	}
}