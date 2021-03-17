package com.dukascopy.connect.gui.list.renderers.bankAccountElements {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.BaseRenderer;
	import com.dukascopy.connect.gui.list.renderers.IListRenderer;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BABalanceSection;
	import com.dukascopy.connect.sys.bankManager.BankManager;
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
	
	public class ListBankAccountBalance extends BaseRenderer implements IListRenderer {
		
		protected const CORNER_RADIUS:int = Config.FINGER_SIZE / 2.5;
		
		private var moreContainer:Sprite;
		private var moreIcon:SWFArrowUpDown;
		private var moreTF:TextField;
		
		private var walletSections:Array/*BABalanceSection*/;
		private var walletsXPosition:int = int(Config.FINGER_SIZE * .33) * 2 + Config.DOUBLE_MARGIN + int(int(Config.FINGER_SIZE / 2.5) * .7) + 1;
		private var walletsRightOffset:int;
		
		private var trueHeight:int;
		private var moreHeight:int;
		
		public function ListBankAccountBalance() {
			var bais:BABalanceSection = new BABalanceSection();
			bais.x = walletsXPosition;
			addChild(bais);
			walletSections = [bais];
			
			moreTF = new TextField();
			moreTF.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, 0x22546B);
			moreTF.multiline = false;
			moreTF.wordWrap = false;
			moreTF.text = "00:00";
			walletsRightOffset = moreTF.textWidth + 4 + int(int(Config.FINGER_SIZE / 2.5) * .7) + Config.MARGIN;
			moreTF.text = "";
		}
		
		public function getHeight(li:ListItem, width:int):int {
			if (li.data.opened == false)
				return walletSections[0].getHeight() + Config.DOUBLE_MARGIN;
			var c:int = 1;
			if (BankManager.getTotalAll() != null)
				c = BankManager.getTotalAll().length;
			return (walletSections[0].getHeight()) * c + Config.DOUBLE_MARGIN;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			var hitZones:Array = li.getHitZones();
			hitZones ||= [];
			hitZones.length = 0;
			
			var sectionWidth:int = width - walletsXPosition - walletsRightOffset;
			walletSections[0].setData(li.data, sectionWidth);
			walletSections[0].y = 0;
			
			var moreFnc:Function = BankManager.getTotalAll;
			if ("moreFnc" in li.data && li.data.moreFnc != null)
				moreFnc = li.data.moreFnc;
			var c:int = 1;
			if (moreFnc() != null && moreFnc().length != 0)
				c = moreFnc().length;
			
			if (c > 1) {
				if (li.data.opened == false)
					createMore(c - 1, width, h - Config.DOUBLE_MARGIN);
				else
					createMore(0, width, h - Config.DOUBLE_MARGIN);
				hitZones.push( {
					type: HitZoneType.WALLETS_MORE,
					x: width - walletsRightOffset - Config.FINGER_SIZE,
					y: (li.data.opened == false) ? 0 : (c - 1) * walletSections[0].getHeight(), 
					width: walletSections[0].getHeight(),
					height: walletSections[0].getHeight(),
					param: 0
				} );
			} else if (moreContainer.parent != null) {
				moreContainer.parent.removeChild(moreContainer);
			}
			
			hitZones.push( {
				type: HitZoneType.WALLET,
				x: 0,
				y: 0,
				width: width,
				height: h,
				param: 0
			} );
			
			var widthHZ:int = width - walletsXPosition - walletsRightOffset;
			var widthHZSmall:int = widthHZ - Config.FINGER_SIZE;
			var i:int;
			var l:int;
			if (li.data.opened == false) {
				l = walletSections.length;
				walletSections[i].clearGraphics();
				if (l > 1)
					for (i = 1; i < l; i++)
						if (walletSections[i].parent != null)
							walletSections[i].parent.removeChild(walletSections[i]);
			} else {
				l = c;
				if (l > 1) {
					var bais:BABalanceSection;
					for (i = 0; i < l; i++) {
						if (walletSections.length > i) {
							walletSections[i].setData(BankManager.getTotalAll()[i], sectionWidth);
							if (walletSections[i].parent == null)
								addChild(walletSections[i]);
						} else {
							bais = new BABalanceSection();
							bais.setData(BankManager.getTotalAll()[i], sectionWidth);
							bais.x = walletsXPosition;
							addChild(bais);
							walletSections.push(bais);
						}
						walletSections[i].y = int((walletSections[0].getHeight()) * i);
					}
				}
				walletSections[walletSections.length - 1].clearGraphics();
			}
			
			li.setHitZones(hitZones);
			
			drawBG(
				width,
				h - Config.DOUBLE_MARGIN,
				li.data.opened
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
			}
			addChild(moreContainer);
			var moreWidth:int = 0;
			moreTF.text = "+1";
			var vPadding:int = Config.FINGER_SIZE * .01;
			if (moreHeight == 0)
			{
				moreHeight = moreTF.textHeight + 4 + vPadding * 2;
			}
			moreTF.text = "";
			if (val != 0) {
				moreIcon.gotoAndStop(2);
				moreIcon.y = int((moreHeight - moreIcon.height) * .5) + Config.FINGER_SIZE * .01;
			} else {
				moreIcon.gotoAndStop(1);
				moreIcon.y = int((moreHeight - moreIcon.height) * .5);
			}
			moreIcon.x = moreTF.x + moreWidth;
			moreContainer.graphics.clear();
			moreContainer.graphics.beginFill(0, .1);
			moreContainer.graphics.drawRoundRect(0, 0, moreIcon.x + moreIcon.width + Config.MARGIN * .5, moreHeight, moreHeight, moreHeight);
			moreContainer.graphics.endFill();
			moreContainer.x = int(w - walletsRightOffset - (moreIcon.x + moreIcon.width + Config.MARGIN * .5) - Config.MARGIN);
			moreContainer.y = int(h - int((walletSections[0].getHeight() - moreHeight) * .5) - moreHeight);
		}
		
		private function drawBG(w:int, h:int, isOpened:Boolean):void {
			graphics.clear();
			graphics.beginFill((isOpened == true) ? 0xE0E8EB : 0xFFFFFF);
			graphics.drawRoundRectComplex(
				walletsXPosition,
				0,
				w - walletsXPosition - walletsRightOffset,
				h,
				0,
				0,
				CORNER_RADIUS,
				CORNER_RADIUS
			);
			graphics.beginFill(0x8F8F8F);
			graphics.drawRect(walletsXPosition, 0, w - walletsXPosition - walletsRightOffset, 1);
			graphics.endFill();
		}
		
		override public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData
		{
			const WALLET:String = "wallet";
			
			var zones:Array = listItem.getHitZones();
			var data:Object = listItem.data;
			getView(listItem, getHeight(listItem, listItem.width), listItem.width, false);
			
			var result:HitZoneData = new HitZoneData();
			
			if (zones != null && itemTouchPoint != null && data != null)
			{
				var l:int = zones.length;
				var zone:Object;
				var selectedIndex:int = -1;
				for (var i:int = 0; i < l; i++) 
				{
					zone = zones[i];
					
					if (zone.x <= itemTouchPoint.x && zone.y <= itemTouchPoint.y && zone.x + zone.width >= itemTouchPoint.x && zone.y + zone.height >= itemTouchPoint.y)
					{
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
						
						var accountsNum:int = 0;
						var l2:int = zones.length;
						for (var j:int = 0; j < l2; j++) 
						{
							if (zones[j].type == WALLET)
							{
								accountsNum ++;
							}
						}
						
						
						if (accountsNum == 1)
						{
							result.type = HitZoneType.MENU_LAST_ELEMENT;
						}
						else if (selectedIndex == 0)
						{
						//	result.type = HitZoneType.MENU_FIRST_ELEMENT;
							result.type = HitZoneType.MENU_MIDDLE_ELEMENT;
						}
						else if (selectedIndex == accountsNum - 1)
						{
							result.type = HitZoneType.MENU_LAST_ELEMENT;
						}
						else{
							result.type = HitZoneType.MENU_MIDDLE_ELEMENT;
						}
						
						var totalHeight:int = 0;
						
						
						if (walletSections != null && walletSections.length > selectedIndex)
						{
							var l3:int = walletSections.length;
							var minX:int = 1000;
							var minY:int = 1000;
							var resultWidth:int = 0;
							for (var k:int = 0; k < l3; k++) 
							{
								item = walletSections[k];
								if (item != null && item is BABalanceSection)
								{
									if (minX > item.x)
									{
										minX = item.x;
									}
									if (minY > item.y)
									{
										minY = item.y;
									}
									if (resultWidth < (item as BABalanceSection).getWidth())
									{
										resultWidth = (item as BABalanceSection).getWidth()
									}
									
									totalHeight += (item as BABalanceSection).getHeight();
								}
							}
							
						}
						
						result.x = minX;
						result.y = minY;
						result.width = resultWidth;
						result.height = totalHeight;
						
						return result;
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
			
			if (walletSections != null)
			{
				var l:int = walletSections.length;
				for (var j:int = 0; j < l; j++) 
				{
					walletSections[j].dispose();
				}
				walletSections = null;
			}
		}
		
		public function get isTransparent():Boolean {
			return true;
		}
	}
}