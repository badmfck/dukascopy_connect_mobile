package com.dukascopy.connect.screens.dialogs.paidChat 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ContactListRenderer;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.applicationShop.Order;
	import com.dukascopy.connect.sys.applicationShop.Shop;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import fl.motion.Color;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class PaidChatBuyersPopup extends BaseScreen
	{
		protected var container:Sprite;
		private var bg:Shape;
		private var avatarSize:int;
		private var backButton:BitmapButton;
		private var preloader:Preloader;
		private var verticalMargin:Number;
		private var padding:int;
		private var list:List;
		protected var componentsWidth:int;
		private var topBar:TopBarScreen;
		
		public function PaidChatBuyersPopup() {
			
		}
		
		override protected function createView():void {
			super.createView();
			
			topBar = new TopBarScreen();
			view.addChild(topBar);
			
			container = new Sprite();
			
			padding = Config.DOUBLE_MARGIN;
			
			bg = new Shape();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			var round:int = Config.FINGER_SIZE * .3;
			var round3:int = round * 3;
			bg.graphics.drawRect(0, 0, round3, round3);
			bg.scale9Grid = new Rectangle(round, round, round, round);
		//	container.addChild(bg);
			
			avatarSize = Config.FINGER_SIZE*.4;
			
			list = new List("buyers");
			
			container.addChild(list.view);
			list.view.y = topBar.y + topBar.trueHeight;
			
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
			super.onBack();
		}
		
		private function backClick():void {
			onBack();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			componentsWidth = _width - padding * 2;
			drawBackButton();
			var maxHeight:int = _height - topBar.trueHeight - Config.APPLE_BOTTOM_OFFSET - Config.FINGER_SIZE * .6 - backButton.height;
			list.setWidthAndHeight(_width, Config.FINGER_SIZE * 4);
			topBar.setData(Lang.unsuccessChats, true);
			Shop.S_CHAT_BUYERS.add(setListData);
			setListData();
			bg.width = _width;
			bg.height = _height;
		}
		
		private function setListData():void 
		{
			var buyers:Vector.<UserVO> = Shop.getChatBuyers();
			if (buyers != null && list != null)
			{
				list.setData(buyers, ContactListRenderer, ["avatarURL"]);
			//	drawView();
			}
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
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			topBar.drawView(_width);
			verticalMargin = padding;
			
			var position:int;
			
			position = verticalMargin;
			
			position += list.height + Config.FINGER_SIZE * .3;
			
			backButton.y = int(_height - Config.FINGER_SIZE*.3 - Config.APPLE_BOTTOM_OFFSET - backButton.height);
			
			drawBack();
		}
		
		private function drawBack():void 
		{
			
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
			if (topBar != null)
				topBar.activate();
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
			if (topBar != null)
				topBar.deactivate();
		}
		
		private function onItemTap(data:Object, n:int):void
		{
			if (data is UserVO)
			{
				MobileGui.changeMainScreen(UserProfileScreen, {data:(data as UserVO), 
												backScreen:MobileGui.centerScreen.currentScreenClass, 
												backScreenData:MobileGui.centerScreen.currentScreen.data});
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
			if (bg != null) {
				UI.destroy(bg);
				bg = null;
			}
			if (container != null) {
				UI.destroy(container);
				container = null;
			}
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			Shop.S_CHAT_BUYERS.remove(setListData);
		}
	}
}