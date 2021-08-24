package com.dukascopy.connect.gui.list.renderers.bankAccountElements {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.BaseRenderer;
	import com.dukascopy.connect.gui.list.renderers.IListRenderer;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BACardDetailsSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BACardSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BACryptoDealSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BACryptoRDSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BACryptoSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BAEMenuForBankMessageSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BAETextForBankMessageSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BAInvestmentDetailSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BAInvestmentSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BALimitSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BAOtherAccSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BAWalletSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BankAccountElementSectionBase;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BAOperationTransactionSection;
	import com.dukascopy.connect.gui.tabs.NewTabs;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.payments.vo.AccountLimit;
	import com.dukascopy.connect.sys.payments.vo.AccountLimitVO;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.BankMessageVO;
	import com.dukascopy.langs.Lang;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ListBankMessage extends BaseRenderer implements IListRenderer {
		
		private var trueHeight:int;
		
		private var avatar:Sprite;
		private var avatarBankIBMD:ImageBitmapData;
		private var avatarSize:int = Config.FINGER_SIZE * .33;
		private var avatarSizeDouble:int = avatarSize * 2;
		
		private var sectionText:BAETextForBankMessageSection;
		
		private var menuSections:Array/*BAEMenuForBankMessageSection*/;
		private var buttonSections:Array/*BAEMenuForBankMessageSection*/;
		private var walletSections:Array/*BAWalletSection*/;
		private var cryptoSections:Array/*BACryptoSection*/;
		private var cardSections:Array/*BACardSection*/;
		private var limitSections:Array/*BALimitSection*/;
		private var investmentsSections:Array/*BAInvestmentSection*/;
		private var investmentDetailsSections:Array/*BAInvestmentDetailsSection*/;
		private var cryptoDealsSections:Array/*BACryptoDealSection*/;
		private var cryptoRDSections:Array/*BACryptoRDSection*/;
		private var operationTransactionSections:Array/*BAOperationTransactionSection*/;
		private var bestPriceSections:Array/*BALimitSection*/;
		private var otherAccSections:Array/*BAOtherAccSection*/;
		private var fatCatzSections:Array/*BALimitSection*/;
		private var detailsSections:Array/*BALimitSection*/;
		private var tradeStatSections:Array/*BALimitSection*/;
		
		private var horizoltalMenu:Boolean;
		private var horizoltalButtons:Boolean;
		private var menuCount:int;
		private var tapped:Boolean;
		
		public function ListBankMessage() {
			sectionText = new BAETextForBankMessageSection();
			sectionText.setFitToContent();
			
			avatarBankIBMD = UI.renderAsset(new SWFSwissAvatar(), avatarSizeDouble, avatarSizeDouble, true, "ListBankMessage.avatarBank");
			
			avatar = new Sprite();
			avatar.x = Config.MARGIN;
			
			ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarBankIBMD, ImageManager.SCALE_PORPORTIONAL);
		}
		
		public function getHeight(li:ListItem, width:int):int {
			setData(li, width);
			return trueHeight + ((li.num == 0) ? Config.DOUBLE_MARGIN + Config.FINGER_SIZE_DOT_5 : Config.FINGER_SIZE_DOT_5);
		}
		
		private function setData(li:ListItem, width:int):void {
			tapped = false;
			
			var bmVO:BankMessageVO = li.data as BankMessageVO;
			
			var sectionWidth:int = width - Config.FINGER_SIZE;
			var sectionMenuWidth:int = sectionWidth - sectionText.getBirdSize() * 2 - Config.FINGER_SIZE;
			if (bmVO.mine == false)
				sectionWidth -= Config.FINGER_SIZE;
			
			trueHeight = 0;
			if (sectionText.setData(bmVO, "text") == true) {
				sectionText.setWidth(sectionWidth);
				sectionText.setMine(bmVO.mine);
				sectionText.fillData(li);
				trueHeight += sectionText.getTrueHeight();
				if (sectionText.parent == null)
					addChild(sectionText);
			} else if (sectionText.parent != null) {
				sectionText.parent.removeChild(sectionText);
			}
			
			trueHeight += createLimits(bmVO, sectionMenuWidth);
			trueHeight += createWallets(bmVO, sectionMenuWidth);
			trueHeight += createCrypto(bmVO, sectionMenuWidth);
			trueHeight += createInvestments(bmVO, sectionMenuWidth);
			trueHeight += createInvestmentsDetails(bmVO, sectionMenuWidth);
			trueHeight += createCards(bmVO, sectionMenuWidth);
			trueHeight += createCryptoDeals(bmVO, sectionMenuWidth);
			trueHeight += createCryptoRDDeals(bmVO, sectionMenuWidth);
			trueHeight += createBestPrice(bmVO, sectionMenuWidth);
			trueHeight += createFatCatz(bmVO, sectionMenuWidth);
			trueHeight += createDetails(bmVO, sectionMenuWidth);
			trueHeight += createOtherAcc(bmVO, sectionMenuWidth);
			trueHeight += createAccStat(bmVO, sectionMenuWidth);
			trueHeight += createOperTrans(bmVO, sectionMenuWidth);
			
			var maxWidthForH:int;
			var maxWidth:int;
			var currentWidth:int;
			var j:int;
			var oldtrueHeight:int;
			horizoltalMenu = false;
			var i:int = 0;
			var l:int = 0;
			if (bmVO.menu != null && bmVO.menu.length != 0) {
				if (sectionText.parent != null)
					trueHeight += Config.MARGIN;
				oldtrueHeight = trueHeight;
				menuSections ||= [];
				l = bmVO.menu.length;
				var trueLength:int;
				var menuSection:BAEMenuForBankMessageSection;
				for (i = 0; i < l; i++) {
					menuSection = null;
					if (bmVO.menu[i].disabled == true)
						continue;
					if (menuSections.length > trueLength)
						menuSection = menuSections[trueLength];
					if (menuSection == null)
						menuSection = menuSections[menuSections.push(new BAEMenuForBankMessageSection()) - 1];
					menuSection.setIndex(i);
					if ("textColor" in bmVO.menu[i] == false && bmVO.buttons != null)
						bmVO.menu[i]['textColor'] = Style.color(Style.COLOR_TEXT);
					menuSection.setData(bmVO.menu[i], "text");
					menuSection.alpha = 1;
					if (bmVO.menu[i].tapped == true)
						tapped = true;
					menuSection.setWidth(sectionMenuWidth);
					menuSection.fillData(li);
					trueHeight += menuSection.getTrueHeight();
					if (menuSection.parent == null)
						addChild(menuSection);
					currentWidth = menuSection.getTextfieldWithPaddingWidth();
					if (currentWidth > maxWidth)
						maxWidth = currentWidth;
					trueLength++;
				}
				maxWidthForH = sectionMenuWidth / trueLength;
				if (maxWidthForH > maxWidth && bmVO.menuLayout!="vertical") {
					horizoltalMenu = true;
					trueHeight = oldtrueHeight + menuSections[0].getTrueHeight();
					maxWidth = maxWidthForH;
				}
				if (horizoltalMenu == true)
					for (j = 0; j < i; j++)
						menuSections[j].setContentWidth(maxWidth);
			}
			if (menuSections != null && menuSections.length != 0) {
				i = trueLength;
				for (i; i < menuSections.length; i++) {
					if (menuSections[i].parent != null)
						menuSections[i].parent.removeChild(menuSections[i]);
				}
			}
			i = 0;
			maxWidth = 0;
			horizoltalButtons = false;
			if (bmVO.buttons != null && bmVO.buttons.length != 0) {
				buttonSections ||= [];
				l = bmVO.buttons.length;
				maxWidthForH = (sectionMenuWidth - Config.MARGIN * (l - 1)) / l;
				if (trueHeight > 0)
					oldtrueHeight = trueHeight;
				var buttonSection:BAEMenuForBankMessageSection;
				for (i = 0; i < l; i++) {
					buttonSection = null;
					if (buttonSections.length > i)
						buttonSection = buttonSections[i];
					if (buttonSection == null)
						buttonSection = buttonSections[buttonSections.push(new BAEMenuForBankMessageSection()) - 1];
					buttonSection.setData(bmVO.buttons[i], "text");
					buttonSection.alpha = 1;
					if (bmVO.buttons[i].tapped == true)
						tapped = true;
					buttonSection.setWidth(sectionMenuWidth);
					buttonSection.fillData(li);
					trueHeight += buttonSection.getTrueHeight() + Config.MARGIN;
					if (buttonSection.parent == null)
						addChild(buttonSection);
					currentWidth = buttonSection.getTextfieldWithPaddingWidth();
					if (currentWidth > maxWidth)
						maxWidth = currentWidth;
				}
				if (maxWidthForH > maxWidth) {
					horizoltalButtons = true;
					trueHeight = oldtrueHeight + buttonSections[0].getTrueHeight() + Config.MARGIN;
					maxWidth = maxWidthForH;
				}
				if (horizoltalButtons == true)
					for (j = 0; j < i; j++)
						buttonSections[j].setContentWidth(maxWidth);
			}
			if (buttonSections != null && buttonSections.length != 0) {
				for (i; i < buttonSections.length; i++) {
					if (buttonSections[i].parent != null)
						buttonSections[i].parent.removeChild(buttonSections[i]);
				}
			}
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			setData(li, width);
			graphics.clear();
			
			var cHeight:int;
			var sectionY:int = ((li.num == 0) ? Config.MARGIN : 0);
			var startY:int;
			
			if (sectionText.parent != null) {
				sectionText.y = sectionY;
				sectionText.setFirst(true);
				sectionText.setLast(true);
				sectionText.draw();
				if (li.data.mine) {
					if (avatar != null && avatar.parent != null)
						avatar.parent.removeChild(avatar);
					sectionText.x = width - sectionText.getTrueWidth();
				} else {
					if (avatar != null && avatar.parent == null)
						addChild(avatar);
					avatar.y = sectionY + sectionText.height - avatarSizeDouble;
					sectionText.x = Config.FINGER_SIZE;
				}
				sectionY += sectionText.getTrueHeight();
			}
			var hitZones:Array;
			var i:int;
			var l:int;
			var sectionX:int = sectionText.getBirdSize() + Config.FINGER_SIZE;
			hitZones = li.getHitZones();
			hitZones ||= [];
			hitZones.length = 0;
			sectionY = selectItem(
				walletSections,
				li.data.item,
				sectionX,
				sectionY,
				hitZones,
				(li.data.item != null && li.data.item.type == "walletSelectWithoutTotal") ? HitZoneType.WALLET_SELECT : HitZoneType.WALLET,
				"ACCOUNT_NUMBER"
			);
			if (otherAccSections != null && otherAccSections.length != 0 && otherAccSections[0].parent != null) {
				if (sectionY != 0)
					sectionY += Config.MARGIN;
				l = otherAccSections.length;
				graphics.beginFill(0xFFFFFF, (tapped == true) ? .4 : 1);
				graphics.drawRoundRect(
					sectionX,
					sectionY,
					otherAccSections[0].getWidth(),
					otherAccSections[i].getHeight() * l,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE
				);
				graphics.endFill();
				for (i = 0; i < l; i++) {
					if (tapped == true)
						otherAccSections[i].alpha = .4;
					otherAccSections[i].y = sectionY;
					otherAccSections[i].x = sectionX;
					if (otherAccSections[i].isTotal == false){
						hitZones.push( {
							type: HitZoneType.OTHER_ACCOUNT,
							param: i,
							index:i,
							x: otherAccSections[i].x,
							y: sectionY, 
							width: otherAccSections[i].getWidth(),
							height: otherAccSections[i].getHeight()
						} );
					}
					sectionY += otherAccSections[i].getHeight();
				}
			}
			if (cryptoSections != null && cryptoSections.length != 0 && cryptoSections[0].parent != null) {
				cHeight = 0;
				if (sectionY != 0)
					sectionY += Config.MARGIN;
				l = cryptoSections.length;
				for (i = 0; i < l; i++) {
					if (tapped == true)
						cryptoSections[i].alpha = .4;
					cryptoSections[i].y = sectionY;
					cryptoSections[i].x = sectionX;
					if (cryptoSections[i].isTotal == false) {
						hitZones.push( {
							type: HitZoneType.CRYPTO,
							param: i,
							index:i,
							x: cryptoSections[i].x,
							y: sectionY, 
							width: cryptoSections[i].getWidth(),
							height: cryptoSections[i].getHeight()
						} );
					}
					sectionY += cryptoSections[i].getHeight();
					cHeight += cryptoSections[i].getHeight();
				}
				graphics.beginFill(0xFFFFFF, (tapped == true) ? .4 : 1);
				graphics.drawRoundRect(
					sectionX,
					sectionY - cHeight,
					cryptoSections[0].getWidth(),
					cHeight,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE
				);
				graphics.endFill();
			}
			if (cryptoRDSections != null && cryptoRDSections.length != 0 && cryptoRDSections[0].parent != null) {
				if (sectionY != 0)
					sectionY += Config.MARGIN;
				l = cryptoRDSections.length;
				graphics.beginFill(0xFFFFFF, (tapped == true) ? .4 : 1);
				graphics.drawRoundRect(
					sectionX,
					sectionY,
					cryptoRDSections[0].getWidth(),
					cryptoRDSections[i].getHeight() * l,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE
				);
				graphics.endFill();
				for (i = 0; i < l; i++) {
					if (tapped == true)
						cryptoRDSections[i].alpha = .4;
					cryptoRDSections[i].y = sectionY;
					cryptoRDSections[i].x = sectionX;
					if (cryptoRDSections[i].isTotal == false){
						hitZones.push( {
							type: HitZoneType.CRYPTO_RD,
							param: i,
							data: cryptoRDSections[i].data,
							index:i,
							x: cryptoRDSections[i].x,
							y: sectionY, 
							width: cryptoRDSections[i].getWidth(),
							height: cryptoRDSections[i].getHeight()
						} );
					}
					sectionY += cryptoRDSections[i].getHeight();
				}
			}
			if (operationTransactionSections != null && operationTransactionSections.length != 0 && operationTransactionSections[0].parent != null) {
				if (sectionY != 0)
					sectionY += Config.MARGIN;
				l = operationTransactionSections.length;
				var startSY:int = sectionY;
				var trueH:int;
				for (i = 0; i < l; i++) {
					operationTransactionSections[i].y = sectionY;
					operationTransactionSections[i].x = sectionX;
					sectionY += operationTransactionSections[i].getHeight();
					trueH += operationTransactionSections[i].getHeight();
				}
				graphics.beginFill(0xFFFFFF, 1);
				graphics.drawRoundRect(
					sectionX,
					startSY,
					operationTransactionSections[0].getWidth(),
					trueH,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE
				);
				graphics.endFill();
			}
			if (investmentDetailsSections != null && investmentDetailsSections.length != 0 && investmentDetailsSections[0].parent != null) {
				if (sectionY != 0)
					sectionY += Config.MARGIN;
				l = investmentDetailsSections.length;
				
				graphics.beginFill(0xFFFFFF, (tapped == true) ? .4 : 1);
				graphics.drawRoundRect(
					sectionX,
					sectionY,
					investmentDetailsSections[0].getWidth(),
					investmentDetailsSections[0].getHeight() * l,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE
				);
				graphics.endFill();
				
				for (i = 0; i < l; i++) {
					if (tapped == true)
						investmentDetailsSections[i].alpha = .4;
					investmentDetailsSections[i].y = sectionY;
					investmentDetailsSections[i].x = sectionX;
					hitZones.push( {
						type: HitZoneType.INVESTMENT_ITEM,
						param: i,
						index:i,
						x: investmentDetailsSections[i].x,
						y: sectionY, 
						width: investmentDetailsSections[i].getWidth(),
						height: investmentDetailsSections[i].getHeight()
					} );
					sectionY += investmentDetailsSections[i].getHeight();
				}
			}
			sectionY = selectItem(investmentsSections, li.data.item, sectionX, sectionY, hitZones, HitZoneType.INVESTMENT_ITEM, "ACCOUNT_NUMBER");
			sectionY = selectItem(cardSections, li.data.item, sectionX, sectionY, hitZones, HitZoneType.CARD);
			sectionY = selectItem(cryptoDealsSections, li.data.item, sectionX, sectionY, hitZones, HitZoneType.CRYPTO_DEAL);
			if (limitSections != null && limitSections.length != 0 && limitSections[0].parent != null) {
				if (sectionY != 0)
					sectionY += Config.MARGIN;
				l = limitSections.length;
				graphics.beginFill(0xFFFFFF, (tapped == true) ? .4 : 1);
				startY = sectionY;
				for (i = 0; i < l; i++) {
					if (tapped == true)
						limitSections[i].alpha = .4;
					limitSections[i].y = sectionY;
					limitSections[i].x = sectionX;
					sectionY += limitSections[i].getHeight();
				}
				graphics.drawRoundRect(
					sectionX,
					startY,
					limitSections[0].getWidth(),
					sectionY - startY,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE
				);
				graphics.endFill();
			}
			if (bestPriceSections != null && bestPriceSections.length != 0 && bestPriceSections[0].parent != null) {
				if (sectionY != 0)
					sectionY += Config.MARGIN;
				l = bestPriceSections.length;
				graphics.beginFill(0xFFFFFF, (tapped == true) ? .4 : 1);
				graphics.drawRoundRect(
					sectionX,
					sectionY,
					bestPriceSections[0].getWidth(),
					bestPriceSections[i].getHeight() * l,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE
				);
				graphics.endFill();
				for (i = 0; i < l; i++) {
					if (tapped == true)
						bestPriceSections[i].alpha = .4;
					bestPriceSections[i].y = sectionY;
					bestPriceSections[i].x = sectionX;
					sectionY += bestPriceSections[i].getHeight();
				}
			}
			if (fatCatzSections != null && fatCatzSections.length != 0 && fatCatzSections[0].parent != null) {
				if (sectionY != 0)
					sectionY += Config.MARGIN;
				l = fatCatzSections.length;
				graphics.beginFill(0xFFFFFF, (tapped == true) ? .4 : 1);
				var startFCY:int = sectionY;
				for (i = 0; i < l; i++) {
					if (tapped == true)
						fatCatzSections[i].alpha = .4;
					fatCatzSections[i].y = sectionY;
					fatCatzSections[i].x = sectionX;
					sectionY += fatCatzSections[i].getHeight();
				}
				graphics.drawRoundRect(
					sectionX,
					startFCY,
					fatCatzSections[0].getWidth(),
					sectionY - startFCY,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE
				);
				graphics.endFill();
			}
			if (detailsSections != null && detailsSections.length != 0 && detailsSections[0].parent != null) {
				if (sectionY != 0)
					sectionY += Config.MARGIN;
				l = detailsSections.length;
				graphics.beginFill(0xFFFFFF, (tapped == true) ? .4 : 1);
				startFCY = sectionY;
				for (i = 0; i < l; i++) {
					if (tapped == true)
						detailsSections[i].alpha = .4;
					detailsSections[i].y = sectionY;
					detailsSections[i].x = sectionX;
					sectionY += detailsSections[i].getHeight();
				}
				graphics.drawRoundRect(
					sectionX,
					startFCY,
					detailsSections[0].getWidth(),
					sectionY - startFCY,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE,
					BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE
				);
				graphics.endFill();
			}
			if (tradeStatSections != null && tradeStatSections.length != 0 && tradeStatSections[0].parent != null) {
				if (sectionY != 0)
					sectionY += Config.MARGIN;
				l = tradeStatSections.length;
				graphics.beginFill(0xFFFFFF, (tapped == true) ? .4 : 1);
				var startTSY:int = sectionY;
				for (i = 0; i < l; i++) {
					if (tapped == true)
						tradeStatSections[i].alpha = .4;
					tradeStatSections[i].y = sectionY;
					tradeStatSections[i].x = sectionX;
					sectionY += tradeStatSections[i].getHeight();
					if (tradeStatSections[i].getAdditionalHeight() != 0) {
						graphics.drawRoundRect(
							sectionX,
							startTSY,
							tradeStatSections[0].getWidth(),
							sectionY - startTSY,
							BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE,
							BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE
						);
						sectionY += tradeStatSections[i].getAdditionalHeight();
						startTSY = sectionY;
					}
				}
				graphics.endFill();
			}
			if (menuSections != null && menuSections.length != 0 && menuSections[0].parent != null) {
				if (sectionY != 0)
					sectionY += Config.MARGIN;
				menuSections[0].setFirst(true);
				l = menuSections.length;
				for (i = 0; i < l; i++) {
					if (menuSections[i].parent != null) {
						if (tapped == true && menuSections[i].getData().tapped != true)
							menuSections[i].alpha = .4;
						menuSections[i].setHorizontal(horizoltalMenu);
						menuSections[i].draw();
						menuSections[i].y = sectionY;
						menuSections[i].x = sectionX;
						hitZones.push( {
							type: HitZoneType.BOT_MENU,
							param: menuSections[i]["getIndex"](),
							index:i,
							x: menuSections[i].x,
							y: sectionY, 
							width: menuSections[i].getContentWidth(),
							height: menuSections[i].getTrueHeight()
						} );
						if (horizoltalMenu == false)
							sectionY += menuSections[i].getTrueHeight();
						else
							sectionX += menuSections[i].getContentWidth();
					} else {
						break;
					}
				}
				menuSections[i - 1].setLast(true);
				menuSections[i - 1].draw();
				if (horizoltalMenu == true)
					sectionY += menuSections[0].getTrueHeight();
			}
			sectionX = sectionText.getBirdSize() + Config.FINGER_SIZE;
			if (buttonSections != null && buttonSections.length != 0 && buttonSections[0].parent != null) {
				l = buttonSections.length;
				if (sectionY != 0)
					sectionY += Config.MARGIN;
				for (i = 0; i < l; i++) {
					if (tapped == true && buttonSections[i].getData().tapped != true)
						buttonSections[i].alpha = .4;
					buttonSections[i].setFirst(true);
					buttonSections[i].setLast(true);
					buttonSections[i].setHorizontal(horizoltalMenu);
					if (buttonSections[i].parent != null) {
						buttonSections[i].draw();
						buttonSections[i].y = sectionY;
						buttonSections[i].x = sectionX;
						hitZones.push( {
							type: HitZoneType.BOT_MENU_BUTTON,
							param: i,
							index:i,
							x: buttonSections[i].x,
							y: sectionY, 
							width: buttonSections[i].getContentWidth(),
							height: buttonSections[i].getTrueHeight()
						} );
						if (horizoltalButtons == false)
							sectionY += buttonSections[i].getTrueHeight() + Config.MARGIN;
						else
							sectionX += buttonSections[i].getTrueWidth() + Config.MARGIN;
					} else {
						break;
					}
				}
				buttonSections[i - 1].setLast(true);
				buttonSections[i - 1].draw();
			}
			// Add avatar hitozne
			hitZones.push( {
				type: HitZoneType.AVATAR,
				param:i,
				index:i,
				x: avatar.x,
				y: avatar.y, 
				width: avatarSizeDouble,
				height: avatarSizeDouble
			} );
			
			li.setHitZones(hitZones);
			
			return this;
		}
		
		private function selectItem(sections:Array, data:Object, sx:int, sy:int, hitZones:Array, hitZonesType:String, field:String = null):int {
			if (sections == null || sections.length == 0 || sections[0].parent == null)
				return sy;
			if (sy != 0)
				sy += Config.MARGIN;
			if (data != null && "param" in data == true && data.param != null)
				data = data.param;
			var l:int = sections.length;
			var i:int;
			graphics.beginFill(0xFFFFFF, (tapped == true) ? .4 : 1);
			graphics.drawRoundRect(
				sx,
				sy,
				sections[0].getWidth(),
				sections[i].getHeight() * l,
				BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE,
				BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE
			);
			graphics.endFill();
			for (i = 0; i < l; i++) {
				if (tapped == true) {
					if (sections[i].getData() != data) {
						sections[i].alpha = .4;
					} else {
						graphics.beginFill(0xFFFFFF);
						if (i == 0) {
							if (i == sections.length - 1) {
								graphics.drawRoundRect(
									sx,
									sy,
									sections[0].getWidth(),
									sections[i].getHeight(),
									BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE,
									BankAccountElementSectionBase.CORNER_RADIUS_DOUBLE
								);
							} else {
								graphics.drawRoundRectComplex(
									sx,
									sy,
									sections[0].getWidth(),
									sections[i].getHeight(),
									BankAccountElementSectionBase.CORNER_RADIUS,
									BankAccountElementSectionBase.CORNER_RADIUS,
									0,
									0
								);
							}
						} else if (i == sections.length - 1) {
							graphics.drawRoundRectComplex(
								sx,
								sy,
								sections[0].getWidth(),
								sections[i].getHeight(),
								0,
								0,
								BankAccountElementSectionBase.CORNER_RADIUS,
								BankAccountElementSectionBase.CORNER_RADIUS
							);
						} else {
							graphics.drawRect(
								sx,
								sy,
								sections[0].getWidth(),
								sections[i].getHeight()
							);
						}
					}
				}
				sections[i].x = sx;
				sections[i].y = sy;
				if ("isTotal" in sections[i] == false || sections[i].isTotal == false) {
					hitZones.push( {
						type: hitZonesType,
						param: (field == null) ? i : sections[i].data[field],
						index:i,
						x: sections[i].x,
						y: sy, 
						width: sections[i].getWidth(),
						height: sections[i].getHeight()
					} );
				}
				sy += sections[i].getHeight();
			}
			graphics.endFill();
			return sy;
		}
		
		override public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData {
			var zones:Array = listItem.getHitZones();
			var data:Object = listItem.data;
			getView(listItem, getHeight(listItem, listItem.width), listItem.width, false);
			
			var result:HitZoneData = new HitZoneData();
			
			const MENU_BUTTON:String = "botMenuButton";
			const MENU:String = "botMenu";
			const CARD:String = "card";
			const WALLET:String = "wallet";
			const INVESTMENT:String = "investmentItem";
			const WALLET_SELECT:String = "walletSelect";
			
			if (zones != null && itemTouchPoint != null && data != null && data is BankMessageVO) {
				var messageData:BankMessageVO = data as BankMessageVO;
				if (messageData.disabled == true) {
					result.disabled = true;
					return result;
				}
				var l:int = zones.length;
				var zone:Object;
				var selectedIndex:int = -1;
				for (var i:int = 0; i < l; i++) {
					zone = zones[i];
					if (zone.x <= itemTouchPoint.x && zone.y <= itemTouchPoint.y && zone.x + zone.width >= itemTouchPoint.x && zone.y + zone.height >= itemTouchPoint.y) {
						selectedIndex = zones[i].index;
						break;
					}
				}
				if (selectedIndex != -1) {
					var length:int;
					var item:Sprite;
					zone = zones[i];
					if (zone.type == INVESTMENT) {
						result.radius = BankAccountElementSectionBase.CORNER_RADIUS;
						var investmentsNum:int = 0;
						length = zones.length;
						for (var j:int = 0; j < length; j++) {
							if (zones[j].type == INVESTMENT) {
								investmentsNum ++; 
							}
						}
						if (accountsNum == 1) {
							result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
						} else if (selectedIndex == 0) {
							result.type = HitZoneType.MENU_FIRST_ELEMENT;
						} else if (selectedIndex == investmentsNum - 1) {
							result.type = HitZoneType.MENU_LAST_ELEMENT;
						} else {
							result.type = HitZoneType.MENU_MIDDLE_ELEMENT;
						}
						if (investmentsSections != null && investmentsSections.length > selectedIndex) {
							item = investmentsSections[selectedIndex];
						}
						if (item != null) {
							result.x = item.x;
							result.y = item.y;
							result.width = (item as BAInvestmentSection).getWidth();
							result.height = (item as BAInvestmentSection).getHeight();
							return result;
						}
					}
					if (zone.type == WALLET || zone.type == WALLET_SELECT) {
						result.radius = BankAccountElementSectionBase.CORNER_RADIUS;
						var accountsNum:int = 0;
						length = zones.length;
						for (var j2:int = 0; j2 < length; j2++) {
							if (zones[j2].type == WALLET) {
								accountsNum ++;
							}
						}
						if (accountsNum == 1) {
							result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
						} else if (selectedIndex == 0) {
							result.type = HitZoneType.MENU_FIRST_ELEMENT;
						} else if (selectedIndex == accountsNum - 1) {
							result.type = HitZoneType.MENU_LAST_ELEMENT;
						} else {
							result.type = HitZoneType.MENU_MIDDLE_ELEMENT;
						}
						if (walletSections != null && walletSections.length > selectedIndex) {
							item = walletSections[selectedIndex];
						}
						if (item != null) {
							result.x = item.x;
							result.y = item.y;
							result.width = (item as BAWalletSection).getWidth();
							result.height = (item as BAWalletSection).getHeight();
							return result;
						}
					} else if (zone.type == CARD && messageData.additionalData != null && messageData.additionalData.length > selectedIndex) {
						result.radius = BankAccountElementSectionBase.CORNER_RADIUS;
						if (messageData.additionalData.length == 1) {
							result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
						} else if (selectedIndex == 0) {
							result.type = HitZoneType.MENU_FIRST_ELEMENT;
						} else if (selectedIndex == messageData.additionalData.length - 1) {
							result.type = HitZoneType.MENU_LAST_ELEMENT;
						} else {
							result.type = HitZoneType.MENU_MIDDLE_ELEMENT;
						}
						if (cardSections != null && cardSections.length > selectedIndex) {
							item = cardSections[selectedIndex];
						}
						if (item != null) {
							result.x = item.x;
							result.y = item.y;
							result.width = (item as BACardSection).getWidth();
							result.height = (item as BACardSection).getHeight();
							return result;
						}
					}
					
					else if (zone.type == MENU_BUTTON && messageData.buttons != null && messageData.buttons.length > selectedIndex)
					{
						result.radius = BankAccountElementSectionBase.CORNER_RADIUS;
						result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
						
						if (buttonSections != null && buttonSections.length > selectedIndex)
						{
							item = buttonSections[selectedIndex];
						}
						
						if (item != null)
						{
							result.x = item.x;
							result.y = item.y;
							result.width = item.width;
							result.height = item.height;
							return result;
						}
					}
					
					else if (zone.type == MENU && messageData.menu != null && messageData.menu.length > selectedIndex)
					{
						var itemsNum:int = 0;
						l = messageData.menu.length;
						for (var k:int = 0; k < l; k++) 
						{
							if ("disabled" in messageData.menu[k] && messageData.menu[k].disabled == true)
							{
								
							}
							else
							{
								itemsNum ++;
							}
						}
						
						result.radius = BankAccountElementSectionBase.CORNER_RADIUS;
						if (itemsNum == 1)
						{
							result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
						}
						else if (selectedIndex == 0)
						{
							if (horizoltalMenu == true)
								result.type = HitZoneType.MENU_HORIZONTAL_FIRST_ELEMENT;
							else
								result.type = HitZoneType.MENU_FIRST_ELEMENT;
						}
						else if (selectedIndex == itemsNum - 1)
						{
							if (horizoltalMenu == true)
								result.type = HitZoneType.MENU_HORIZONTAL_LAST_ELEMENT;
							else
								result.type = HitZoneType.MENU_LAST_ELEMENT;
						}
						else{
							result.type = HitZoneType.MENU_MIDDLE_ELEMENT;
						}
						
						if (menuSections != null && menuSections.length > selectedIndex)
						{
							item = menuSections[selectedIndex];
						}
						
						if (item != null)
						{
							result.x = item.x;
							result.y = item.y;
							result.width = item.width;
							result.height = item.height;
							return result;
						}
					}
				}
			}
			
			result.disabled = true;
			return result;
		}
		
		
		
		public function get isTransparent():Boolean {
			return true;
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  SECTIONS  -->  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  LIMITS  -->  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function createLimits(bmVO:BankMessageVO, sectionMenuWidth:int):int {
			removeLimits();
			var res:int;
			if (bmVO.item == null)
				return res;
			if (bmVO.item.type != "showLimits")
				return res;
			if (BankManager.getAccountInfo() == null ||
				BankManager.getAccountInfo().limits == null ||
				BankManager.getAccountInfo().limits.length == 0)
					return res;
			res = Config.MARGIN;
			limitSections ||= [];
			var limitSection:BALimitSection;
			var l:int = BankManager.getAccountInfo().limits.length;
			for (var i:int = 0; i < l; i++) {
				limitSection = new BALimitSection();
				limitSection.setData(BankManager.getAccountInfo().limits[i], sectionMenuWidth);
				addChild(limitSection);
				limitSections.push(limitSection);
			}
			if (limitSection != null) {
				limitSection.clearGraphics();
				res += l * limitSection.getHeight();
			}
			return res;
		}
		
		private function removeLimits():void {
			if (limitSections == null || limitSections.length == 0)
				return;
			var limitSection:BALimitSection;
			while (limitSections.length > 0) {
				limitSection = limitSections.shift();
				if (limitSection.parent != null)
					limitSection.parent.removeChild(limitSection);
				limitSection.dispose();
			}
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  LIMITS | BEST PRICE  -->  /////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function createBestPrice(bmVO:BankMessageVO, sectionMenuWidth:int):int {
			removeBestPrice();
			var res:int;
			if (bmVO.item == null)
				return res;
			if (bmVO.item.type != "cryptoBestPrice")
				return res;
			var bestPrice:AccountLimitVO = BankManager.getBestPrice(bmVO.item.value);
			if (bestPrice == null)
				return res;
			res = Config.MARGIN;
			bestPriceSections ||= [];
			var bestPriceSection:BALimitSection;
			bestPriceSection = new BALimitSection();
			bestPriceSection.setData(bestPrice, sectionMenuWidth);
			addChild(bestPriceSection);
			bestPriceSections.push(bestPriceSection);
			if (bestPriceSection != null) {
				bestPriceSection.clearGraphics();
				res += bestPriceSection.getHeight();
			}
			return res;
		}
		
		private function removeBestPrice():void {
			if (bestPriceSections == null || bestPriceSections.length == 0)
				return;
			var bestPriceSection:BALimitSection;
			while (bestPriceSections.length > 0) {
				bestPriceSection = bestPriceSections.shift();
				if (bestPriceSection.parent != null)
					bestPriceSection.parent.removeChild(bestPriceSection);
				bestPriceSection.dispose();
			}
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  BEST PRICE | FAT CATZ  -->  ///////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function createFatCatz(bmVO:BankMessageVO, sectionMenuWidth:int):int {
			removeFatCatz();
			var res:int;
			if (bmVO.item == null)
				return res;
			if (bmVO.item.type != "fatCatz")
				return res;
			if (bmVO.additionalData == null)
				return res;
			var fatCatzVOs:Array = [];
			res = Config.MARGIN;
			fatCatzVOs.push(
				new AccountLimitVO(
					[
						AccountLimit.TYPE_FC_BALANCE,
						NaN,
						bmVO.additionalData.balance.substr(0, bmVO.additionalData.balance.length - 5),
						"DCO"
					]
				)
			);
			if (bmVO.additionalData.is_fc == true) {
				fatCatzVOs.push(
					new AccountLimitVO(
						[
							AccountLimit.TYPE_FC_EXPECTED_INCOME,
							NaN,
							Number(bmVO.additionalData.expected_income_projected.substr(0, bmVO.additionalData.expected_income_projected.length - 4)),
							"EUR"
						]
					)
				);
				fatCatzVOs.push(
					new AccountLimitVO(
						[
							AccountLimit.TYPE_FC_ANNUAL_RETURN_FC,
							NaN,
							bmVO.additionalData.annual_return.substr(0, bmVO.additionalData.annual_return.length - 2),
							"%"
						]
					)
				);
				fatCatzVOs.push(
					new AccountLimitVO(
						[
							AccountLimit.TYPE_FC_CLIENT_CODE,
							NaN,
							NaN,
							bmVO.additionalData.fc_code
						]
					)
				);
			} else {
				fatCatzVOs.push(
					new AccountLimitVO(
						[
							AccountLimit.TYPE_FC_CURRENT_BALANCE,
							NaN,
							bmVO.additionalData.current_balance.substr(0, bmVO.additionalData.current_balance.length - 5),
							"DCO"
						]
					)
				);
			}
			
			fatCatzSections = [];
			var fatCatzSection:BALimitSection;
			for (var i:int = 0; i < fatCatzVOs.length; i++) {
				fatCatzSection = new BALimitSection();
				fatCatzSection.setData(fatCatzVOs[i], sectionMenuWidth);
				addChild(fatCatzSection);
				fatCatzSections.push(fatCatzSection);
				res += fatCatzSection.getHeight();
			}
			if (fatCatzSection != null)
				fatCatzSection.clearGraphics();
			return res;
		}
		
		private function removeFatCatz():void {
			if (fatCatzSections == null || fatCatzSections.length == 0)
				return;
			var fatCatzSection:BALimitSection;
			while (fatCatzSections.length > 0) {
				fatCatzSection = fatCatzSections.shift();
				if (fatCatzSection.parent != null)
					fatCatzSection.parent.removeChild(fatCatzSection);
				fatCatzSection.dispose();
			}
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  FAT CATZ | OPERATION DETAILS  -->  ////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function createDetails(bmVO:BankMessageVO, sectionMenuWidth:int):int {
			removeDetails();
			var res:int;
			if (bmVO.item == null)
				return res;
			if (bmVO.item.type != "operationDetails")
				return res;
			if (bmVO.additionalData == null)
				return res;
			var detailsVOs:Array = [];
			res = Config.MARGIN;
			detailsVOs.push(
				new AccountLimitVO(
					[
						AccountLimit.FIELD_DETAILS_TYPE,
						NaN,
						NaN,
						bmVO.additionalData.TYPE.charAt(0) + bmVO.additionalData.TYPE.toLowerCase().substr(1)
					]
				)
			);
			if ("CODE_SECURED" in bmVO.additionalData && bmVO.additionalData.CODE_SECURED == true) {
				detailsVOs.push(
					new AccountLimitVO(
						[
							AccountLimit.FIELD_DETAILS_SECURED,
							NaN,
							NaN,
							"True"
						]
					)
				);
			}
			detailsVOs.push(
				new AccountLimitVO(
					[
						AccountLimit.FIELD_DETAILS_UID,
						NaN,
						NaN,
						bmVO.additionalData.UID
					]
				)
			);
			detailsVOs.push(
				new AccountLimitVO(
					[
						AccountLimit.FIELD_DETAILS_AMOUNT,
						NaN,
						Number(bmVO.additionalData.AMOUNT),
						bmVO.additionalData.CURRENCY
					]
				)
			);
			detailsVOs.push(
				new AccountLimitVO(
					[
						AccountLimit.FIELD_DETAILS_STATUS,
						NaN,
						NaN,
						bmVO.additionalData.STATUS.charAt(0) + bmVO.additionalData.STATUS.toLowerCase().substr(1)
					]
				)
			);
			var dt:Date = new Date();
			dt.setTime(Number(bmVO.additionalData.CREATED_TS) * 1000);
			detailsVOs.push(
				new AccountLimitVO(
					[
						AccountLimit.FIELD_DETAILS_CREATED,
						NaN,
						NaN,
						dt.toLocaleString()
					]
				)
			);
			dt.setTime(Number(bmVO.additionalData.UPDATED_TS) * 1000);
			detailsVOs.push(
				new AccountLimitVO(
					[
						AccountLimit.FIELD_DETAILS_UPDATED,
						NaN,
						NaN,
						dt.toLocaleString()
					]
				)
			);
			dt = null;
			detailsVOs.push(
				new AccountLimitVO(
					[
						AccountLimit.FIELD_DETAILS_DESC,
						NaN,
						NaN,
						bmVO.additionalData.DESCRIPTION
					]
				)
			);
			if (bmVO.additionalData.FEE_CURRENCY != null) {
				detailsVOs.push(
					new AccountLimitVO(
						[
							AccountLimit.FIELD_DETAILS_FEE,
							NaN,
							bmVO.additionalData.FEE_AMOUNT,
							bmVO.additionalData.FEE_CURRENCY
						]
					)
				);
			}
			if (bmVO.additionalData.FROM != null) {
				detailsVOs.push(
					new AccountLimitVO(
						[
							AccountLimit.FIELD_DETAILS_FROM,
							NaN,
							NaN,
							bmVO.additionalData.FROM
						]
					)
				);
			}
			if (bmVO.additionalData.TO != null) {
				detailsVOs.push(
					new AccountLimitVO(
						[
							AccountLimit.FIELD_DETAILS_TO,
							NaN,
							NaN,
							bmVO.additionalData.TO
						]
					)
				);
			}
			if (bmVO.additionalData.MESSAGE != null) {
				detailsVOs.push(
					new AccountLimitVO(
						[
							AccountLimit.FIELD_DETAILS_MESSAGE,
							NaN,
							NaN,
							bmVO.additionalData.MESSAGE
						]
					)
				);
			}
			detailsSections = [];
			var detailsSection:BALimitSection;
			for (var i:int = 0; i < detailsVOs.length; i++) {
				detailsSection = new BALimitSection();
				detailsSection.setData(detailsVOs[i], sectionMenuWidth);
				addChild(detailsSection);
				detailsSections.push(detailsSection);
				res += detailsSection.getHeight();
			}
			if (detailsSection != null)
				detailsSection.clearGraphics();
			return res;
		}
		
		private function removeDetails():void {
			if (detailsSections == null || detailsSections.length == 0)
				return;
			var detailsSection:BALimitSection;
			while (detailsSections.length > 0) {
				detailsSection = detailsSections.shift();
				if (detailsSection.parent != null)
					detailsSection.parent.removeChild(detailsSection);
				detailsSection.dispose();
			}
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  OPERATION DETAILS | ACCOUNT STAT  -->  ////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function createAccStat(bmVO:BankMessageVO, sectionMenuWidth:int):int {
			removeAccStat();
			var res:int;
			if (bmVO.item == null)
				return res;
			if (bmVO.item.type != "showTradeStat")
				return res;
			if (bmVO.additionalData == null ||
				bmVO.additionalData.length == 0)
					return res;
			res = Config.MARGIN;
			var tradeStatVOs:Array = [];
			for (var j:int = 0; j < bmVO.additionalData.length; j++) {
				if ("ACCOUNT_NUMBER" in bmVO.additionalData[j] == true) {
					tradeStatVOs.push(
						new AccountLimitVO(
							[
								AccountLimit.TYPE_COIN_TOTAL,
								NaN,
								bmVO.additionalData[j].BALANCE,
								bmVO.additionalData[j].COIN,
								true
							]
						)
					);
					continue;
				}
				if (bmVO.item.value != bmVO.additionalData[j].period)
					continue;
				tradeStatVOs.push(
					new AccountLimitVO(
						[
							AccountLimit["TYPE_COIN_STAT_TRADES_" + bmVO.additionalData[j].side],
							NaN,
							bmVO.additionalData[j].count
						]
					)
				);
				tradeStatVOs.push(
					new AccountLimitVO(
						[
							AccountLimit["TYPE_COIN_STAT_TOTAL_" + bmVO.additionalData[j].side + ((bmVO.item.value == "ACTIVE_ORDERS") ? "_ACTIVE" : "")],
							NaN,
							bmVO.additionalData[j].quantity,
							bmVO.additionalData[j].coin
						]
					)
				);
				tradeStatVOs.push(
					new AccountLimitVO(
						[
							AccountLimit["TYPE_COIN_STAT_AVG_PRICE_" + bmVO.additionalData[j].side],
							NaN,
							bmVO.additionalData[j].avg_price,
							bmVO.additionalData[j].currency,
							true
						]
					)
				);
			}
			tradeStatSections = [];
			var tradeStatSection:BALimitSection;
			for (var i:int = 0; i < tradeStatVOs.length; i++) {
				tradeStatSection = new BALimitSection();
				tradeStatSection.setData(tradeStatVOs[i], sectionMenuWidth);
				addChild(tradeStatSection);
				tradeStatSections.push(tradeStatSection);
				res += tradeStatSection.getHeight();
				if (tradeStatVOs[i].marginBottom == true) {
					res += Config.MARGIN;
					tradeStatSection.clearGraphics();
				}
			}
			res -= Config.MARGIN;
			if (tradeStatSection != null)
				tradeStatSection.clearGraphics();
			return res;
		}
		
		private function removeAccStat():void {
			if (tradeStatSections == null || tradeStatSections.length == 0)
				return;
			var tradeStatSection:BALimitSection;
			while (tradeStatSections.length > 0) {
				tradeStatSection = tradeStatSections.shift();
				if (tradeStatSection.parent != null)
					tradeStatSection.parent.removeChild(tradeStatSection);
				tradeStatSection.dispose();
			}
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  ACCOUNT STAT | WALLETS  -->  //////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function createWallets(bmVO:BankMessageVO, sectionMenuWidth:int):int {
			removeWallets();
			var res:int;
			if (bmVO.item == null)
				return res;
			var walletSection:BAWalletSection;
			if (bmVO.item.type == "showWallet" && bmVO.additionalData != null) {
				res = Config.MARGIN;
				walletSections ||= [];
				walletSection = new BAWalletSection();
				walletSection.setData(bmVO.additionalData, sectionMenuWidth);
				addChild(walletSection);
				walletSections.push(walletSection);
				if (bmVO.item.tapped == true)
					tapped = true;
				res += walletSection.getHeight();
				walletSection.clearGraphics();
				return res;
			}
			if (bmVO.item.type != "walletSelect" && bmVO.item.type != "walletSelectAll" && bmVO.item.type != "walletSelectWithoutTotal")
				return res;
			if (bmVO.additionalData == null ||
				bmVO.additionalData.length == 0)
					return res;
			res = Config.MARGIN;
			walletSections ||= [];
			var l:int = bmVO.additionalData.length;
			var count:int;
			for (var i:int = 0; i < l; i++) {
				if (bmVO.item.type != "walletSelectAll" && Number(bmVO.additionalData[i].BALANCE) == 0)
					continue;
				count++;
				walletSection = new BAWalletSection();
				walletSection.setData(bmVO.additionalData[i], sectionMenuWidth);
				addChild(walletSection);
				walletSections.push(walletSection);
			}
			if (bmVO.item.tapped == true)
				tapped = true;
			if (bmVO.item.type == "walletSelectWithoutTotal") {
				if (count == 0)
					bmVO.text = bmVO.item.textZeroAcc;
			} else {
				if (bmVO.item.value == "MCA") {
					if (BankManager.totalAccounts != null) {
						walletSection = new BAWalletSection();
						walletSection.setData(BankManager.totalAccounts, sectionMenuWidth);
						walletSection.isTotal = true;
						addChild(walletSection);
						walletSections.push(walletSection);
						l++;
					}
				}
			}
			if (walletSection != null) {
				res += count * walletSection.getHeight();
				walletSection.clearGraphics();
			}
			return res;
		}
		
		private function removeWallets():void {
			if (walletSections == null || walletSections.length == 0)
				return;
			var walletSection:BAWalletSection;
			while (walletSections.length > 0) {
				walletSection = walletSections.shift();
				if (walletSection.parent != null)
					walletSection.parent.removeChild(walletSection);
				walletSection.dispose();
			}
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  WALLETS | OPERATION TRANSACTIONS  -->  ////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function createOperTrans(bmVO:BankMessageVO, sectionMenuWidth:int):int {
			removeOperTrans();
			var res:int;
			if (bmVO.item == null)
				return res;
			if (bmVO.item.type != "operationTransactions" ||
				bmVO.additionalData == null ||
				bmVO.additionalData.length == 0)
					return res;
			var otSection:BAOperationTransactionSection;
			res = Config.MARGIN;
			operationTransactionSections ||= [];
			var l:int = bmVO.additionalData.length;
			for (var i:int = 0; i < l; i++) {
				otSection = new BAOperationTransactionSection();
				otSection.setData(bmVO.additionalData[i], sectionMenuWidth);
				addChild(otSection);
				operationTransactionSections.push(otSection);
			}
			if (otSection != null) {
				res += l * otSection.getHeight();
				otSection.clearGraphics();
			}
			return res;
		}
		
		private function removeOperTrans():void {
			if (operationTransactionSections == null || operationTransactionSections.length == 0)
				return;
			var otSection:BAOperationTransactionSection;
			while (operationTransactionSections.length > 0) {
				otSection = operationTransactionSections.shift();
				if (otSection.parent != null)
					otSection.parent.removeChild(otSection);
				otSection.dispose();
			}
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  OPERATION TRANSACTIONS | OTHER ACCOUNTS  -->  /////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function createOtherAcc(bmVO:BankMessageVO, sectionMenuWidth:int):int {
			removeOtherAcc();
			var res:int;
			if (bmVO.item == null)
				return res;
			if (bmVO.item.type != "otherAccSelect")
				return res;
			if (bmVO.additionalData == null ||
				bmVO.additionalData.length == 0)
					return res;
			res = Config.MARGIN;
			otherAccSections ||= [];
			var otherAccSection:BAOtherAccSection;
			var l:int = bmVO.additionalData.length;
			for (var i:int = 0; i < l; i++) {
				otherAccSection = new BAOtherAccSection();
				otherAccSection.setData(bmVO.additionalData[i], sectionMenuWidth);
				addChild(otherAccSection);
				otherAccSections.push(otherAccSection);
			}
			if (otherAccSection != null) {
				res += l * otherAccSection.getHeight();
				otherAccSection.clearGraphics();
			}
			return res;
		}
		
		private function removeOtherAcc():void {
			if (otherAccSections == null || otherAccSections.length == 0)
				return;
			var otherAccSection:BAOtherAccSection;
			while (otherAccSections.length > 0) {
				otherAccSection = otherAccSections.shift();
				if (otherAccSection.parent != null)
					otherAccSection.parent.removeChild(otherAccSection);
				otherAccSection.dispose();
			}
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  WALLETS | CRYPTO DEALS  -->  //////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function createCryptoDeals(bmVO:BankMessageVO, sectionMenuWidth:int):int {
			removeCryptoDeals();
			var res:int;
			if (bmVO.item == null)
				return res;
			if (bmVO.item.type != "cryptoOfferSelect" && bmVO.item.type != "cryptoOfferShow")
				return res;
			var i:int;
			var l:int;
			if (bmVO.additionalData == null) {
				if (bmVO.item.type == "cryptoOfferSelect") {
					var temp:Array;
					if ("value" in bmVO.item) {
						if (bmVO.item.value == 0)
							temp = BankManager.getCryptoDealAccounts(1);
						else
							temp = BankManager.getCryptoDealAccounts(2);
					} else
						temp = BankManager.getCryptoDealAccounts();
					if (temp == null || temp.length == 0)
						return res;
					bmVO.additionalData = temp;
				} else {
					bmVO.additionalData = [BankManager.getCryptoDealByUID(bmVO.item.value)];
				}
			}
			if (bmVO.item.tapped == true)
				tapped = true;
			res = Config.MARGIN;
			cryptoDealsSections ||= [];
			var cryptoDealSection:BACryptoDealSection;
			l = bmVO.additionalData.length;
			for (i = 0; i < l; i++) {
				cryptoDealSection = new BACryptoDealSection();
				cryptoDealSection.setData(bmVO.additionalData[i], sectionMenuWidth);
				addChild(cryptoDealSection);
				cryptoDealsSections.push(cryptoDealSection);
			}
			if (cryptoDealSection != null) {
				res += l * cryptoDealSection.getHeight();
				cryptoDealSection.clearGraphics();
			}
			return res;
		}
		
		private function removeCryptoDeals():void {
			if (cryptoDealsSections == null || cryptoDealsSections.length == 0)
				return;
			var cryptoDealSection:BACryptoDealSection;
			while (cryptoDealsSections.length > 0) {
				cryptoDealSection = cryptoDealsSections.shift();
				if (cryptoDealSection.parent != null)
					cryptoDealSection.parent.removeChild(cryptoDealSection);
				cryptoDealSection.dispose();
			}
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  CRYPTO DEALS | CRYPTO  -->  ///////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function createCrypto(bmVO:BankMessageVO, sectionMenuWidth:int):int {
			removeCrypto();
			var res:int;
			if (bmVO.item == null)
				return res;
			if (bmVO.item.type != "cryptoSelect")
				return res;
			if (BankManager.getCryptoAccounts() == null ||
				BankManager.getCryptoAccounts().length == 0)
					return res;
			res = Config.MARGIN;
			cryptoSections ||= [];
			var cryptoSection:BACryptoSection;
			var array:Array = BankManager.getCryptoAccounts();
			var l:int;
			var i:int
			if (array != null) {
				l = array.length;
				for (i = 0; i < l; i++) {
					cryptoSection = new BACryptoSection();
					cryptoSection.setData(array[i], sectionMenuWidth);
					res += cryptoSection.getHeight();
					addChild(cryptoSection);
					cryptoSections.push(cryptoSection);
				}
			}
			array = BankManager.getCryptoBCAccounts();
			if (array != null) {
				l = array.length;
				for (i = 0; i < l; i++) {
					cryptoSection = new BACryptoSection();
					cryptoSection.setData(array[i], sectionMenuWidth);
					res += cryptoSection.getHeight();
					addChild(cryptoSection);
					cryptoSections.push(cryptoSection);
				}
			}
			if (cryptoSection != null)
				cryptoSection.clearGraphics();
			return res;
		}
		
		private function removeCrypto():void {
			if (cryptoSections == null || cryptoSections.length == 0)
				return;
			var cryptoSection:BACryptoSection;
			while (cryptoSections.length > 0) {
				cryptoSection = cryptoSections.shift();
				if (cryptoSection.parent != null)
					cryptoSection.parent.removeChild(cryptoSection);
				cryptoSection.dispose();
			}
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  CRYPTO | CRYPTO REWARDS DEPOSITE  -->  ////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function createCryptoRDDeals(bmVO:BankMessageVO, sectionMenuWidth:int):int {
			removeCryptoRD();
			var res:int;
			if (bmVO.item == null)
				return res;
			var cryptoRDSection:BACryptoRDSection;
			if (bmVO.item.type != "cryptoRewardsDeposites") {
				if (bmVO.item.type == "showRD") {
					res = Config.MARGIN;
					cryptoRDSections ||= [];
					cryptoRDSection = new BACryptoRDSection();
					cryptoRDSection.setData(bmVO.additionalData, sectionMenuWidth);
					cryptoRDSections.push(cryptoRDSection);
					cryptoRDSection.clearGraphics();
					addChild(cryptoRDSection);
					res += cryptoRDSection.getHeight();
					return res;
				}
				return res;
			}
			if (BankManager.getCryptoRDs() == null ||
				BankManager.getCryptoRDs().length == 0)
					return res;
			res = Config.MARGIN;
			cryptoRDSections ||= [];
			var cryptoRDs:Array = BankManager.getCryptoRDs();
			var l:int = cryptoRDs.length;
			for (var i:int = 0; i < l; i++) {
				if ("value" in bmVO.item == true) {
					if (cryptoRDs[i].status != bmVO.item.value)
						continue;
				} else if (cryptoRDs[i].status != "ACTIVE") {
					continue;
				}
				cryptoRDSection = new BACryptoRDSection();
				cryptoRDSection.setData(cryptoRDs[i], sectionMenuWidth);
				addChild(cryptoRDSection);
				cryptoRDSections.push(cryptoRDSection);
			}
			if (cryptoRDSection != null) {
				res += cryptoRDSections.length * cryptoRDSection.getHeight();
				cryptoRDSection.clearGraphics();
			}
			return res;
		}
		
		private function removeCryptoRD():void {
			if (cryptoRDSections == null || cryptoRDSections.length == 0)
				return;
			var cryptoRDSection:BACryptoRDSection;
			while (cryptoRDSections.length > 0) {
				cryptoRDSection = cryptoRDSections.shift();
				if (cryptoRDSection.parent != null)
					cryptoRDSection.parent.removeChild(cryptoRDSection);
				cryptoRDSection.dispose();
			}
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  CRYPTO | INVESTMENTS  -->  ////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function createInvestments(bmVO:BankMessageVO, sectionMenuWidth:int):int {
			removeInvestments();
			var res:int;
			if (bmVO.item == null)
				return res;
			res = Config.MARGIN;
			var investmentSection:BAInvestmentSection;
			var i:int = 0;
			if (bmVO.item.type == "investmentSelect" || bmVO.item.type == "investmentSelectAll" || bmVO.item.type == "paymentsInvestmentsSell") {
				if (bmVO.item.tapped == true)
					tapped = true;
				investmentsSections ||= [];
				var l:int = BankManager.getInvestmentsArray() != null ? BankManager.getInvestmentsArray().length : 0;
				var count:int = 0;
				for (i = 0; i < l; i++) {
					if (bmVO.item.type == "investmentSelect" || bmVO.item.type == "paymentsInvestmentsSell") {
						if (Number(BankManager.getInvestmentsArray()[i].BALANCE) == 0)
							continue;
					}
					count++;
					investmentSection = new BAInvestmentSection();
					investmentSection.setData(BankManager.getInvestmentsArray()[i], sectionMenuWidth);
					addChild(investmentSection);
					investmentsSections.push(investmentSection);
				}
				investmentSection = new BAInvestmentSection();
				var totalObj:Object = BankManager.getInvestmentsTotal();
				totalObj.ACCOUNT_NUMBER = totalObj.IBAN;
				totalObj.INSTRUMENT = totalObj.CURRENCY;
				investmentSection.setData(totalObj, sectionMenuWidth);
				investmentSection.isTotal = true;
				investmentSection.clearGraphics();
				addChild(investmentSection);
				investmentsSections.push(investmentSection);
				count++;
				if (investmentSection != null)
					res += count * investmentSection.getHeight();
			} else if (bmVO.item.type == "showInvestment" && bmVO.item.selection != null) {
				var investmentObject:Object = BankManager.getInvestmentByAccount(bmVO.item.selection);
				if (investmentObject != null) {
					cardSections ||= [];
					investmentSection = new BAInvestmentSection();
					investmentSection.setData(investmentObject, sectionMenuWidth);
					addChild(investmentSection);
					investmentsSections ||= [];
					investmentsSections.push(investmentSection);
					if (investmentSection != null) {
						investmentSection.clearGraphics();
						res += investmentSection.getHeight();
					}
				} else
					return 0;
			} else
				return 0;
			return res;
		}
		
		private function removeInvestments():void {
			if (investmentsSections == null || investmentsSections.length == 0)
				return;
			var investmentSection:BAInvestmentSection;
			while (investmentsSections.length > 0) {
				investmentSection = investmentsSections.shift();
				if (investmentSection.parent != null)
					investmentSection.parent.removeChild(investmentSection);
				investmentSection.dispose();
			}
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  INVESTMENTS | INVESTMENTS DETAILS  -->  ///////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function createInvestmentsDetails(bmVO:BankMessageVO, sectionMenuWidth:int):int {
			removeInvestmentDetails();
			var res:int;
			if (bmVO.item == null)
				return res;
			if (bmVO.item.type == "showInvestmentDetails" && bmVO.item.selection != null) {
				var investmentDetailsStorage:Object = BankManager.getInvestmentsDetails();
				if (investmentDetailsStorage == null)
					return 0;
				var detail:Object = investmentDetailsStorage[bmVO.item.selection];
				if (detail == null)
					return 0;
				res = Config.MARGIN;
				investmentDetailsSections ||= [];
				var investmentDetailsSection:BAInvestmentDetailSection;
				var listData:Array = [
					{ itype: "detail", title: Lang.textInvestmentQuantity, amount: detail.AMOUNT, currency: detail.INSTRUMENT },
					{ itype: "detail", title: Lang.textAveragePurchasePrice, amount: Number(Math.round(Number(detail.AVG_OPEN_PRICE) * 100)/100).toFixed(2), currency: detail.REFERENCE_CURRENCY },
					{ itype: "detail", title: Lang.textInvestmentAmount, amount: detail.REFERENCE_AMOUNT, currency: detail.REFERENCE_CURRENCY },
					{ itype: "detail", title: Lang.textCurrentProfitAndLoss, amount: detail.CURRENT_PL, currency: detail.REFERENCE_CURRENCY },
					{ itype: "detail", title: Lang.textCurrentInvestmentAmount, amount: Number(detail.REFERENCE_AMOUNT) + Number(detail.CURRENT_PL), currency: detail.REFERENCE_CURRENCY }
				];
				for (var i:int = 0; i < listData.length; i++) {
					investmentDetailsSection = new BAInvestmentDetailSection();
					investmentDetailsSection.setData(listData[i], sectionMenuWidth);
					addChild(investmentDetailsSection);
					investmentDetailsSections.push(investmentDetailsSection);
					res += investmentDetailsSection.getHeight();
				}
				if (investmentDetailsSection != null)
					investmentDetailsSection.clearGraphics();
				listData = null;
			}
			return res;
		}
		
		private function removeInvestmentDetails():void {
			if (investmentDetailsSections == null || investmentDetailsSections.length == 0)
				return;
			var investmentDetailSection:BAInvestmentDetailSection;
			while (investmentDetailsSections.length > 0) {
				investmentDetailSection = investmentDetailsSections.shift();
				if (investmentDetailSection.parent != null)
					investmentDetailSection.parent.removeChild(investmentDetailSection);
				investmentDetailSection.dispose();
			}
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  INVESTMENTS DETAILS | CARDS  -->  /////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function createCards(bmVO:BankMessageVO, sectionMenuWidth:int):int {
			removeCards();
			var res:int;
			if (bmVO.item == null)
				return res;
			if (bmVO.item.type == "showCardDetails" && bmVO.additionalData != null) {
				res = Config.MARGIN;
				var cardSectionDetails:BACardDetailsSection = new BACardDetailsSection();
				cardSectionDetails.setData(bmVO.additionalData, sectionMenuWidth);
				addChild(cardSectionDetails);
				cardSections.push(cardSectionDetails);
				if (cardSectionDetails != null) {
					cardSectionDetails.clearGraphics();
					res += cardSectionDetails.getHeight();
				}
			} else {
				var cardSection:BACardSection;
				if (bmVO.additionalData == null)
					return res;
				if (bmVO.item.type == "cardSelect") {
					if (bmVO.item.tapped == true)
						tapped = true;
					res = Config.MARGIN;
					cardSections ||= [];
					var l:int = bmVO.additionalData.length;
					for (var i:int = 0; i < l; i++) {
						cardSection = new BACardSection();
						cardSection.setData(bmVO.additionalData[i], sectionMenuWidth);
						addChild(cardSection);
						cardSections.push(cardSection);
					}
					if (cardSection != null) {
						cardSection.clearGraphics();
						res += l * cardSection.getHeight();
					}
				} else if (bmVO.item.type == "showCard") {
					res = Config.MARGIN;
					cardSections ||= [];
					cardSection = new BACardSection();
					cardSection.setData(bmVO.additionalData, sectionMenuWidth);
					addChild(cardSection);
					cardSections.push(cardSection);
					if (cardSection != null) {
						cardSection.clearGraphics();
						res += cardSection.getHeight();
					}
				}
			}
			return res;
		}
		
		private function removeCards():void {
			if (cardSections == null || cardSections.length == 0)
				return;
			var cardSection:BACardSection;
			while (cardSections.length > 0) {
				cardSection = cardSections.shift();
				if (cardSection.parent != null)
					cardSection.parent.removeChild(cardSection);
				cardSection.dispose();
			}
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  CARDS  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  SECTIONS  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function removeMenuSections():void {
			if (menuSections == null || menuSections.length == 0)
				return;
			var menuSection:BAEMenuForBankMessageSection;
			while (menuSections.length > 0) {
				menuSection = menuSections.shift();
				if (menuSection.parent != null)
					menuSection.parent.removeChild(menuSection);
				menuSection.dispose();
			}
		}
		
		private function removeButtonSections():void {
			if (buttonSections == null || buttonSections.length == 0)
				return;
			var buttonSection:BAEMenuForBankMessageSection;
			while (buttonSections.length > 0) {
				buttonSection = buttonSections.shift();
				if (buttonSection.parent != null)
					buttonSection.parent.removeChild(buttonSection);
				buttonSection.dispose();
			}
		}
		
		public function dispose():void {
			
			if (sectionText != null)
			{
				sectionText.dispose();
				sectionText = null;
			}
			
			removeButtonSections();
			buttonSections = null;
			
			removeCryptoRD();
			cryptoRDSections = null;
			
			removeOperTrans();
			operationTransactionSections = null;
			
			removeMenuSections();
			menuSections = null;
			
			removeFatCatz();
			fatCatzSections = null;
			
			removeDetails();
			detailsSections = null;
			
			removeOtherAcc();
			otherAccSections = null;
			
			removeBestPrice();
			bestPriceSections = null;
			
			removeLimits();
			limitSections = null;
			
			removeWallets();
			walletSections = null;
			
			removeCrypto();
			cryptoSections = null;
			
			removeInvestments();
			investmentsSections = null;
			
			removeInvestmentDetails();
			investmentDetailsSections = null;
			
			removeCards();
			cardSections = null;
			
			removeCryptoDeals();
			cryptoDealsSections = null;
			
			if (avatarBankIBMD != null)
			{
				avatarBankIBMD.dispose();
				avatarBankIBMD = null;
			}
			
			if (avatar != null)
			{
				UI.destroy(avatar);
				avatar = null;
			}
		}
	}
}