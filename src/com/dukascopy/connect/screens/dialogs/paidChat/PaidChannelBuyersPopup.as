package com.dukascopy.connect.screens.dialogs.paidChat 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.chat.CircleAvatar;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ProductBuyerUserListRenderer;
	import com.dukascopy.connect.gui.list.renderers.UserListRenderer;
	import com.dukascopy.connect.gui.list.renderers.UserListRenderer;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.Order;
	import com.dukascopy.connect.sys.applicationShop.Shop;
	import com.dukascopy.connect.sys.applicationShop.product.ShopProduct;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class PaidChannelBuyersPopup extends BaseScreen
	{
		protected var container:Sprite;
		private var bg:Shape;
		private var channelName:Bitmap;
		private var titleField:Bitmap;
		private var avatar:CircleAvatar;
		private var product:ShopProduct;
		private var avatarSize:int;
		private var accountText:Bitmap;
		private var backButton:BitmapButton;
		private var preloader:Preloader;
		private var verticalMargin:Number;
		private var padding:int;
		private var list:List;
		protected var componentsWidth:int;
		
		public function PaidChannelBuyersPopup() {
			
		}
		
		override protected function createView():void {
			super.createView();
			container = new Sprite();
			
			padding = Config.DOUBLE_MARGIN;
			
			bg = new Shape();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			var round:int = Config.FINGER_SIZE * .3;
			var round3:int = round * 3;
			bg.graphics.drawRect(0, 0, round3, round3);
			bg.scale9Grid = new Rectangle(round, round, round, round);
			container.addChild(bg);
			
			avatarSize = Config.FINGER_SIZE*.4;
			
			avatar = new CircleAvatar();
			container.addChild(avatar);
			
			channelName = new Bitmap();
			container.addChild(channelName);
			
			titleField = new Bitmap();
			container.addChild(titleField);
			
			accountText = new Bitmap();
			container.addChild(accountText);
			
			list = new List("buyers");
			container.addChild(list.view);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			container.addChild(backButton);
			
			_view.addChild(container);
		}
		
		private function showPreloader():void {
			var color:Color = new Color();
			color.setTint(0xFFFFFF, 0.7);
			container.transform.colorTransform = color;
			
			if (preloader == null)
			{
				preloader = new Preloader();
			}
			preloader.x = _width * .5;
			preloader.y = _height * .5;
			view.addChild(preloader);
			preloader.show();
		}
		
		override public function onBack(e:Event = null):void
		{
			DialogManager.closeDialog();
		}
		
		private function backClick():void {
			onBack();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		private function drawAvatar():void {
			avatar.x = padding;
			avatar.y = padding;
			avatar.setData(null, avatarSize, false, false, product.avatarURL);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			if (data != null && "product" in data && data.product != null && data.product is ShopProduct) {
				product = data.product as ShopProduct;
			}
			
			if (product == null) {
				onBack();
				ApplicationErrors.add("empty model");
				return;
			}
			list.setWidthAndHeight(_width, Config.FINGER_SIZE * 4);
			
			componentsWidth = _width - padding * 2;
			
			drawAvatar();
			
			if (product.targetData != null && product.targetData is ChatVO && (product.targetData as ChatVO).title != null)
			{
				drawChannelName((product.targetData as ChatVO).title);
			}
			
			drawTitle((product.targetData as ChatVO).settings.info);
			
			drawBackButton();
			
			Shop.S_PRODUCTS_BUYERS.add(setListData);
			setListData(product.id);
			
		}
		
		private function setListData(productId:Number):void 
		{
			if (product != null && product.id == productId)
			{
				var buyers:Vector.<Order> = Shop.getProductBuyers(product);
				if (buyers != null && list != null)
				{
					list.setData(buyers, ProductBuyerUserListRenderer, ["avatarURL"]);
				//	drawView();
				}
			}
		}
		
		private function drawTitle(text:String):void {
			if (titleField.bitmapData != null) {
				titleField.bitmapData.dispose();
				titleField.bitmapData = null;
			}
			titleField.x = padding;
			
			titleField.bitmapData = TextUtils.createTextFieldData(Lang.channelSubscribers, componentsWidth, 10, 
															true, TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, 
															true, 0x30383C, 0xFFFFFF);
		}
		
		private function hidePreloader():void {
			container.transform.colorTransform = new ColorTransform();
			
			if (preloader != null)
			{
				preloader.hide();
				if (preloader.parent)
				{
					preloader.parent.removeChild(preloader);
				}
			}
		}
		
		private function drawBackButton():void {
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 0, Config.FINGER_SIZE * .8, 0x666666, (componentsWidth - padding) * .5);
			backButton.setBitmapData(buttonBitmap, true);
			backButton.x = int(_width * .5 - backButton.width * .5);
		}
		
		private function drawAccountText(text:String):void {
			return;
			if (accountText.bitmapData != null) {
				accountText.bitmapData.dispose();
				accountText.bitmapData = null;
			}
			accountText.bitmapData = TextUtils.createTextFieldData(text, componentsWidth, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, true, 0xABB8C1, 0xffffff, false);
			
			accountText.x = int(componentsWidth * .5 - accountText.width * .5);
		}
		
		private function drawChannelName(text:String):void {
			if (channelName.bitmapData != null) {
				channelName.bitmapData.dispose();
				channelName.bitmapData = null;
			}
			
			channelName.bitmapData = TextUtils.createTextFieldData(
																	text, 
																	componentsWidth - avatarSize * 2 - padding * 3, 
																	10, true, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .33, 
																	true, 0x3E4756, 0xE7F0FF, false);
			
			channelName.x = int(avatar.x + avatarSize * 2 + padding);
			channelName.y = avatar.y;
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			verticalMargin = padding;
			
			var position:int;
			
			position = verticalMargin;
			
			titleField.y = position;
			position += titleField.height + verticalMargin * 2;
			
			avatar.y = position;
			channelName.y = int(avatar.y + avatarSize - channelName.height * .5);
			position = Math.max(channelName.y + channelName.height, avatar.y + avatarSize * 2) + verticalMargin;
			
			list.view.y = position;
			position += list.height + verticalMargin;
			
			backButton.y = position;
			
			drawBack();
			
			container.y = int(_height * .5 - bg.height * .5);
		}
		
		private function drawBack():void 
		{
			var positionBack:int = 0;
			var radius:int = Config.FINGER_SIZE * .1;
			bg.graphics.clear();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			positionBack += verticalMargin * 2 + titleField.height;
			bg.graphics.drawRoundRectComplex(0, 0, _width, positionBack, radius, radius, 0, 0);
			bg.graphics.endFill();
			
			bg.graphics.beginFill(0xE7F0FF);
			bg.graphics.drawRect(0, positionBack, _width, verticalMargin * 2 + avatarSize * 2);
			positionBack += verticalMargin * 2 + avatarSize * 2;
			bg.graphics.endFill();
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRoundRectComplex(0, positionBack, _width, backButton.height + verticalMargin * 2 + list.height, 0, 0, radius, radius);
			bg.graphics.endFill();
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			backButton.activate();
			
			if (list != null)
			{
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			backButton.deactivate();
			
			if (list != null)
			{
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
		}
		
		private function onItemTap(data:Object, n:int):void
		{
			if (data is Order)
			{
				if ((data as Order).receiver != null && (data as Order).receiver.uid != Auth.uid)
				{
					MobileGui.changeMainScreen(UserProfileScreen, {data:(data as Order).receiver, 
													backScreen:MobileGui.centerScreen.currentScreenClass, 
													backScreenData:MobileGui.centerScreen.currentScreen.data});
				}
			}
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			super.dispose();
			
			if (preloader != null) {
				preloader.dispose();
				preloader = null;
			}
			if (list != null) {
				list.dispose();
				list = null;
			}
			if (backButton != null) {
				backButton.dispose();
				backButton = null;
			}
			if (accountText != null) {
				UI.destroy(accountText);
				accountText = null;
			}
			if (avatar != null) {
				avatar.dispose();
				avatar = null;
			}
			if (titleField != null) {
				UI.destroy(titleField);
				titleField = null;
			}
			if (channelName != null) {
				UI.destroy(channelName);
				channelName = null;
			}
			if (bg != null) {
				UI.destroy(bg);
				bg = null;
			}
			if (container != null) {
				UI.destroy(container);
				container = null;
			}
			
			Shop.S_PRODUCTS_BUYERS.remove(setListData);
			product = null;
		}
	}
}