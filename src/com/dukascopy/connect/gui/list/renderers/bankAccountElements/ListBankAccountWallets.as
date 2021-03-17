package com.dukascopy.connect.gui.list.renderers.bankAccountElements {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.BaseRenderer;
	import com.dukascopy.connect.gui.list.renderers.IListRenderer;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BAWalletSection;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.langs.Lang;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ListBankAccountWallets extends BaseRenderer implements IListRenderer {
		
		protected const CORNER_RADIUS:int = Config.FINGER_SIZE / 2.5;
		
		private var moreContainer:Sprite;
		private var moreIcon:SWFArrowUpDown;
		private var moreTF:TextField;
		private var userTF:TextField;
		
		private var walletSections:Array/*BAWalletSection*/;
		private var walletsXPosition:int = int(Config.FINGER_SIZE * .33) * 2 + Config.DOUBLE_MARGIN + int(int(Config.FINGER_SIZE / 2.5) * .7) + 1;
		private var walletsRightOffset:int;
		
		private var trueHeight:int;
		private var moreHeight:int;
		private var tfUserHeight:Number;
		
		public function ListBankAccountWallets() {
			var baws:BAWalletSection = new BAWalletSection();
			baws.x = walletsXPosition;
			addChild(baws);
			walletSections = [baws];
			
			userTF = new TextField();
			userTF.autoSize = TextFieldAutoSize.LEFT;
			userTF.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, 0x363D4D);
			userTF.multiline = false;
			userTF.wordWrap = false;
			userTF.text = Lang.allAccounts.toUpperCase();
			userTF.x = walletsXPosition + int(Config.FINGER_SIZE / 2.5) - 2;
			userTF.y = Config.MARGIN;
			tfUserHeight = userTF.textHeight + 4;
			
			moreTF = new TextField();
			moreTF.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, 0x22546B);
			moreTF.multiline = false;
			moreTF.wordWrap = false;
			moreTF.text = "00:00";
			walletsRightOffset = moreTF.textWidth + 4 + int(int(Config.FINGER_SIZE / 2.5) * .7) + Config.MARGIN;
			moreTF.text = "";
		}
		
		public function getHeight(li:ListItem, width:int):int {
			var additionalHeight:int;
			if (li.num == 0 ||
				li.list.getElementByNumID(li.num - 1).renderer is ListBankAccount == true ||
				li.list.getElementByNumID(li.num - 1).renderer is ListBankEmpty == true)
					additionalHeight = tfUserHeight + Config.DOUBLE_MARGIN;
			if (li.data.opened == false)
				return walletSections[0].getHeight() + additionalHeight;
			return (walletSections[0].getHeight()) * li.data.accounts.length + additionalHeight;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			var hitZones:Array = li.getHitZones();
			hitZones ||= [];
			hitZones.length = 0;
			
			var additionalHeight:int;
			if (li.num == 0 ||
				li.list.getElementByNumID(li.num - 1).renderer is ListBankAccount == true ||
				li.list.getElementByNumID(li.num - 1).renderer is ListBankEmpty == true) {
					if (userTF.parent == null)
						addChild(userTF);
					additionalHeight = tfUserHeight + Config.DOUBLE_MARGIN;
			} else {
				if (userTF.parent != null)
					removeChild(userTF);
			}
			
			var sectionWidth:int = width - walletsXPosition - walletsRightOffset;
			walletSections[0].setData(li.data.accounts[0], sectionWidth);
			walletSections[0].y = additionalHeight;
			
			if (li.data.accounts.length > 1) {
				if (li.data.opened == false)
					createMore(li.data.accounts.length - 1, width, h);
				else
					createMore(0, width, h);
				hitZones.push( {
					type: HitZoneType.WALLETS_MORE,
					x: width - walletsRightOffset - Config.FINGER_SIZE,
					y: (li.data.opened == false) ? additionalHeight : (li.data.accounts.length -1) * walletSections[0].getHeight() + additionalHeight, 
					width: walletSections[0].getHeight(),
					height: walletSections[0].getHeight(),
					param: 0
				} );
			}
			
			var widthHZ:int = width - walletsXPosition - walletsRightOffset;
			var widthHZSmall:int = widthHZ - Config.FINGER_SIZE;
			var i:int;
			var l:int;
			hitZones.push( {
					type: HitZoneType.WALLET,
					x: walletsXPosition,
					y: additionalHeight, 
					width: (li.data.accounts.length > 1 && li.data.opened == false) ? widthHZSmall : widthHZ,
					height: walletSections[0].getHeight(),
					param: 0
			} );
			if (li.data.opened == false) {
				l = walletSections.length;
				if (l > 1)
					for (i = 1; i < l; i++)
						if (walletSections[i].parent != null)
							walletSections[i].parent.removeChild(walletSections[i]);
			} else {
				l = li.data.accounts.length;
				if (l > 1) {
					var baws:BAWalletSection;
					for (i = 1; i < l; i++) {
						if (walletSections.length > i) {
							walletSections[i].setData(li.data.accounts[i], sectionWidth);
							if (walletSections[i].parent == null)
								addChild(walletSections[i]);
						} else {
							baws = new BAWalletSection();
							baws.setData(li.data.accounts[i], sectionWidth);
							baws.x = walletsXPosition;
							addChild(baws);
							walletSections.push(baws);
						}
						walletSections[i].y = int((walletSections[0].getHeight()) * i) + additionalHeight;
						hitZones.push( {
							type: HitZoneType.WALLET,
							x: walletsXPosition,
							y: walletSections[i].y, 
							width: (li.data.opened == true && i == walletSections.length - 1) ? widthHZSmall : widthHZ,
							height: walletSections[0].getHeight(),
							param: i
						} );
					}
				}
			}
			
			li.setHitZones(hitZones);
			
			drawBG(
				width,
				h,
				li.data.opened,
				(li.num == 0 || li.list.getElementByNumID(li.num - 1).renderer is ListBankAccount == true || li.list.getElementByNumID(li.num - 1).renderer is ListBankEmpty == true),
				additionalHeight
			);
			
			return this;
		}
		
		private function createMore(val:int, w:int, h:int):void {
			if (moreContainer == null) {
				moreContainer = new Sprite();
					moreTF.x = int(Config.MARGIN * .5);
				moreContainer.addChild(moreTF);
					moreIcon = new SWFArrowUpDown();
					UI.scaleToFit(moreIcon, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2);
					UI.colorize(moreIcon, 0x3D6785);
				moreContainer.addChild(moreIcon);
				addChild(moreContainer);
			}
			var moreWidth:int = 0;
			if (val != 0) {
				moreTF.text = "+" + val;
				moreWidth = moreTF.textWidth + 4 + Config.MARGIN * .5;
				moreIcon.y = moreTF.y + moreTF.getLineMetrics(0).ascent + 2 - moreIcon.height;
				moreIcon.gotoAndStop(2);
			} else {
				moreTF.text = "";
				moreIcon.y = int((moreHeight - moreIcon.height) * .5);
				moreIcon.gotoAndStop(1);
			}
			var vPadding:int = Config.FINGER_SIZE * .01;
			if (moreHeight == 0) {
				moreHeight = moreTF.textHeight + 4 + vPadding * 2;
				if (moreIcon != null) {
					moreIcon.y = int((moreHeight - moreIcon.height) * .5) + Config.FINGER_SIZE * .01;
				}
			}
			moreIcon.x = moreTF.x + moreWidth;
			moreContainer.graphics.clear();
			moreContainer.graphics.beginFill(0, .1);
			moreContainer.graphics.drawRoundRect(0, 0, moreIcon.x + moreIcon.width + Config.MARGIN * .5, moreHeight, moreHeight, moreHeight);
			moreContainer.graphics.endFill();
			moreContainer.x = int(w - walletsRightOffset - (moreIcon.x + moreIcon.width + Config.MARGIN * .5) - Config.MARGIN);
			moreContainer.y = int(h - int((walletSections[0].getHeight() - moreHeight) * .5) - moreHeight);
		}
		
		private function drawBG(w:int, h:int, isOpened:Boolean, topCorner:Boolean, additionalH:int):void {
			graphics.clear();
			if (additionalH != 0) {
				graphics.beginFill(0, .1);
				graphics.drawRect(0, 0, w, 1);
			}
			graphics.beginFill((isOpened == true) ? 0xE0E8EB : 0xFFFFFF);
			graphics.drawRoundRectComplex(
				walletsXPosition,
				additionalH,
				w - walletsXPosition - walletsRightOffset,
				h - additionalH,
				(topCorner == true) ? CORNER_RADIUS : 0,
				(topCorner == true) ? CORNER_RADIUS : 0,
				0,
				0
			);
			graphics.endFill();
		}
		
		override public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData {
			const WALLET:String = "wallet";
			var zones:Array = listItem.getHitZones();
			var data:Object = listItem.data;
			getView(listItem, getHeight(listItem, listItem.width), listItem.width, false);
			var result:HitZoneData = new HitZoneData();
			if (zones != null && itemTouchPoint != null && data != null) {
				var l:int = zones.length;
				var zone:Object;
				var selectedIndex:int = -1;
				for (var i:int = 0; i < l; i++) {
					zone = zones[i];
					if (zone.x <= itemTouchPoint.x && zone.y <= itemTouchPoint.y && zone.x + zone.width >= itemTouchPoint.x && zone.y + zone.height >= itemTouchPoint.y) {
						selectedIndex = zones[i].param;
						break;
					}
				}
				if (selectedIndex != -1)
				{
					var length:int;
					var item:Sprite;
					
					zone = zones[i];
					
					if (zone.type == WALLET)
					{
						result.radius = CORNER_RADIUS;
						
						var accountsNum:int = data.accounts.length;
						
						if (accountsNum == 1)
						{
							result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
						}
						else if (selectedIndex == 0)
						{
						//	result.type = HitZoneType.MENU_FIRST_ELEMENT;
							result.type = HitZoneType.MENU_MIDDLE_ELEMENT;
						}
						else if (selectedIndex == accountsNum - 1)
						{
						//	result.type = HitZoneType.MENU_LAST_ELEMENT;
							result.type = HitZoneType.MENU_MIDDLE_ELEMENT;
						}
						else{
							result.type = HitZoneType.MENU_MIDDLE_ELEMENT;
						}
						
						if (walletSections != null && walletSections.length > selectedIndex)
						{
							item = walletSections[selectedIndex];
						}
						
						if (item != null && item is BAWalletSection)
						{
							result.x = item.x;
							result.y = item.y;
							result.width = (item as BAWalletSection).getWidth();
							result.height = (item as BAWalletSection).getHeight();
							return result;
						}
					}
				}
			}
			
			return result;
		}
		
		public function dispose():void {
			if (moreContainer != null)
			{
				UI.destroy(moreContainer);
				moreContainer = null;
			}
			if (moreIcon != null)
			{
				UI.destroy(moreIcon);
				moreIcon = null;
			}
			if (moreTF != null)
			{
				UI.destroy(moreTF);
				moreTF = null;
			}
			if (userTF != null)
			{
				UI.destroy(userTF);
				userTF = null;
			}
			if (walletSections != null)
			{
				var l:int = walletSections.length;
				for (var i:int = 0; i < l; i++) 
				{
					(walletSections[i]).dispose();
				}
				walletSections = null;
			}
		}
		
		public function get isTransparent():Boolean {
			return true;
		}
	}
}