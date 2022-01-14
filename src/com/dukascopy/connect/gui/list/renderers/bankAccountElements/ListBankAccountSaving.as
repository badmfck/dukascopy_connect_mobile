package com.dukascopy.connect.gui.list.renderers.bankAccountElements {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.BaseRenderer;
	import com.dukascopy.connect.gui.list.renderers.IListRenderer;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BAOtherAccSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BAWalletSection;
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
	
	public class ListBankAccountSaving extends BaseRenderer implements IListRenderer {
		
		protected const CORNER_RADIUS:int = Config.FINGER_SIZE / 2.5;
		
		private var moreContainer:Sprite;
		private var moreIcon:SWFArrowUpDown;
		private var moreTF:TextField;
		private var userTF:TextField;
		
		private var walletSections:Array/*BAWalletSection*/;
		private var xPosition:int = int(Config.FINGER_SIZE * .33) * 2 + Config.DOUBLE_MARGIN + int(int(Config.FINGER_SIZE / 2.5) * .7) + 1;
		private var rightOffset:int;
		
		private var trueHeight:int;
		private var moreHeight:int;
		private var tfUserHeight:Number;
		
		public function ListBankAccountSaving() {
			var basas:BAWalletSection = new BAWalletSection();
			basas.x = xPosition;
			addChild(basas);
			walletSections = [basas];
			
			userTF = new TextField();
			userTF.autoSize = TextFieldAutoSize.LEFT;
			userTF.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, 0x7DA0BB);
			userTF.multiline = false;
			userTF.wordWrap = false;
			userTF.text = Lang.allSavingsAccounts.toUpperCase();
			userTF.x = xPosition + int(Config.FINGER_SIZE / 2.5) - 2;
			userTF.y = Config.MARGIN;
			tfUserHeight = userTF.textHeight + 4;
			addChild(userTF);
			
			moreTF = new TextField();
			moreTF.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .20, 0x22546B);
			moreTF.multiline = false;
			moreTF.wordWrap = false;
			moreTF.text = "00:00";
			rightOffset = moreTF.textWidth + 4 + int(int(Config.FINGER_SIZE / 2.5) * .7) + Config.MARGIN;
			moreTF.text = "";
		}
		
		public function getHeight(li:ListItem, width:int):int {
			var sectionWidth:int = width - xPosition - rightOffset;
			if (li.data.opened == false) {
				walletSections[0].setData(li.data.accounts[0], sectionWidth);
				return walletSections[0].getHeight() + tfUserHeight + Config.MARGIN * 2;
			}
			var res:int = tfUserHeight + Config.MARGIN * 2;
			for (var i:int = 0; i < li.data.accounts.length; i++) {
				walletSections[0].setData(li.data.accounts[i], sectionWidth);
				res += walletSections[0].getHeight();
			}
			return res;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			var additionalHeight:int = tfUserHeight + Config.DOUBLE_MARGIN;
			
			var hitZones:Vector.<HitZoneData> = li.getHitZones();
			if (hitZones == null)
				hitZones = new Vector.<HitZoneData>();
			hitZones.length = 0;
			
			var sectionWidth:int = width - xPosition - rightOffset;
			walletSections[0].setData(li.data.accounts[0], sectionWidth);
			walletSections[0].y = additionalHeight;
			
			var widthHZ:int = width - xPosition - rightOffset;
			var widthHZSmall:int = widthHZ - Config.FINGER_SIZE;
			var i:int;
			var l:int;
			
			var hz:HitZoneData = new HitZoneData();
			hz.type = HitZoneType.WALLET;
			hz.param = "0";
			hz.x = xPosition;
			hz.y = additionalHeight;
			hz.width = (li.data.accounts.length > 1 && li.data.opened == false) ? widthHZSmall : widthHZ;
			hz.height = walletSections[0].getHeight();
			
			hitZones.push(hz);
			if (li.data.opened == false) {
				l = walletSections.length;
				if (l > 1)
					for (i = 1; i < l; i++)
						if (walletSections[i].parent != null)
							walletSections[i].parent.removeChild(walletSections[i]);
				walletSections[0].clearGraphics();
			} else {
				l = li.data.accounts.length;
				if (l > 1) {
					var basas:BAWalletSection;
					var pos:int = walletSections[0].getHeight();
					for (i = 1; i < l; i++) {
						if (walletSections.length > i) {
							walletSections[i].setData(li.data.accounts[i], sectionWidth);
							if (walletSections[i].parent == null)
								addChild(walletSections[i]);
						} else {
							basas = new BAWalletSection();
							basas.setData(li.data.accounts[i], sectionWidth);
							basas.x = xPosition;
							addChild(basas);
							walletSections.push(basas);
						}
						walletSections[i].y = pos + additionalHeight;
						pos += walletSections[i].getHeight();
						
						hz = new HitZoneData();
							hz.type = HitZoneType.WALLET;
							hz.param = i.toString();
							hz.x = xPosition;
							hz.y = walletSections[i].y;
							hz.width = (li.data.opened == true && i == walletSections.length - 1) ? widthHZSmall : widthHZ;
							hz.height = walletSections[i].getHeight();
						hitZones.push(hz);
					}
				}
				walletSections[walletSections.length - 1].clearGraphics();
			}
			
			if (li.data.accounts.length > 1) {
				if (li.data.opened == false)
					createMore(li.data.accounts.length - 1, width, h);
				else
					createMore(0, width, h, li.data.accounts.length - 1);
				
				hz = new HitZoneData();
				hz.type = HitZoneType.WALLETS_MORE;
				hz.param = "0";
				hz.x = width - rightOffset - Config.FINGER_SIZE;
				hz.y = (li.data.opened == false) ? additionalHeight : h - walletSections[li.data.accounts.length - 1].getHeight();
				hz.width = walletSections[0].getHeight();
				hz.height = (li.data.opened == false) ? walletSections[0].getHeight() : walletSections[li.data.accounts.length - 1].getHeight();
				hitZones.push(hz);
			}
			
			li.setHitZones(hitZones);
			
			drawBG(width, h, li.data.opened, additionalHeight + Config.MARGIN);
			
			return this;
		}
		
		private function createMore(val:int, w:int, h:int, itemIndex:int = 0):void {
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
			if (moreHeight == 0)
			{
				moreHeight = moreTF.textHeight + 4 + vPadding * 2;
				if (moreIcon != null)
				{
					moreIcon.y = int((moreHeight - moreIcon.height) * .5) + Config.FINGER_SIZE * .01;
				}
			}
			moreIcon.x = moreTF.x + moreWidth;
			moreContainer.graphics.clear();
			moreContainer.graphics.beginFill(0, .1);
			moreContainer.graphics.drawRoundRect(0, 0, moreIcon.x + moreIcon.width + Config.MARGIN * .5, moreHeight, moreHeight, moreHeight);
			moreContainer.graphics.endFill();
			moreContainer.x = int(w - rightOffset - (moreIcon.x + moreIcon.width + Config.MARGIN * .5) - Config.MARGIN);
			moreContainer.y = int(h - int((walletSections[itemIndex].getHeight() - moreHeight) * .5) - moreHeight) - Config.MARGIN;
		}
		
		private function drawBG(w:int, h:int, isOpened:Boolean, additionalH:int):void {
			graphics.clear();
			if (additionalH != 0) {
				graphics.beginFill(0, .1);
				graphics.drawRect(0, 0, w, 1);
			}
			graphics.beginFill((isOpened == true) ? 0xE0E8EB : 0xFFFFFF);
			graphics.drawRoundRectComplex(
				xPosition,
				additionalH - Config.MARGIN,
				w - xPosition - rightOffset,
				h - additionalH + Config.MARGIN,
				CORNER_RADIUS,
				CORNER_RADIUS,
				0,
				0
			);
			graphics.endFill();
		}
		
		override public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData
		{
			const WALLET:String = "wallet";
			
			var zones:Vector.<HitZoneData> = listItem.getHitZones();
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
						selectedIndex = parseInt(zones[i].param);
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
						
						var accountsNum:int = data.accounts;
						
						if (accountsNum == 1)
						{
							result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
						}
						else if (selectedIndex == 0)
						{
							result.type = HitZoneType.MENU_FIRST_ELEMENT;
						}
						else if (selectedIndex == accountsNum - 1)
						{
							result.type = HitZoneType.MENU_LAST_ELEMENT;
						}
						else{
							result.type = HitZoneType.MENU_MIDDLE_ELEMENT;
						}
						
						if (walletSections != null && walletSections.length > selectedIndex)
						{
							item = walletSections[selectedIndex];
						}
						
						if (item != null && item is BAOtherAccSection)
						{
							result.x = item.x;
							result.y = item.y;
							result.width = (item as BAOtherAccSection).getWidth();
							result.height = (item as BAOtherAccSection).getHeight();
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