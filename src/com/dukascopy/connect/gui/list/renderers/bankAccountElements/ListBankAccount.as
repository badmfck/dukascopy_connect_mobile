package com.dukascopy.connect.gui.list.renderers.bankAccountElements {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.BaseRenderer;
	import com.dukascopy.connect.gui.list.renderers.IListRenderer;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BAEAccountSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BAEChatSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BAEFromToSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BAETextSection;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BankAccountElementSectionBase;
	import com.dukascopy.connect.screens.BankBotChatScreen;
	import com.dukascopy.connect.screens.MyAccountScreen;
	import com.dukascopy.connect.sys.GlobalDate;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ListBankAccount extends BaseRenderer implements IListRenderer {
		
		private const COLOR_GRAY_DARK:uint = 0x373E4E;
		private const COLOR_GRAY_LIGHT:uint = 0x7DA0BB;
		
		private const COLOR_GRAY_DARK_STRING:String = "#373E4E";
		private const COLOR_GRAY_LIGHT_STRING:String = "#7DA0BB";
		
		private var avatarNAIBMD:ImageBitmapData;
		private var avatarBankIBMD:ImageBitmapData;
		
		private var avatarSize:int = Config.FINGER_SIZE * .33;
		private var avatarSizeDouble:int = avatarSize * 2;
		
		private var trueHeight:int;
		private var tfUserHeight:int;
		private var tfTimeWidth:int;
		
		private var avatar:Sprite;
		private var tfUser:TextField;
		private var tfTime:TextField;
		private var tfComments:TextField;
		private var tfAmount:TextField;
		private var tfTimeEnd:TextField;
		private var addCircle:Shape;
		private var addTF:TextField;
		
		private var sectionAccount:BAEAccountSection;
		private var sectionFromTo:BAEFromToSection;
		private var sectionText:BAETextSection;
		private var sectionChat:BAEChatSection;
		
		private var sections:Array;
		
		private const FONT_SIZE_NORMAL:int = Config.FINGER_SIZE * .22;
		private const FONT_SIZE_SMALL:int = Config.FINGER_SIZE * .18;
		
		public function ListBankAccount() {
			avatarNAIBMD = UI.renderAsset(new SWFNAAvatar(), avatarSizeDouble, avatarSizeDouble, true, "ListBankAccount.avatarNA");
			avatarBankIBMD = UI.renderAsset(new SWFSwissAvatar(), avatarSizeDouble, avatarSizeDouble, true, "ListBankAccount.avatarBank");
			
			sectionAccount = new BAEAccountSection();
			sectionFromTo = new BAEFromToSection();
			sectionText = new BAETextSection();
			sectionChat = new BAEChatSection();
			
			avatar = new Sprite();
			avatar.x = Config.MARGIN;
			
			tfUser = new TextField();
			tfUser.autoSize = TextFieldAutoSize.LEFT;
			tfUser.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, 0x363D4D);
			tfUser.multiline = false;
			tfUser.wordWrap = false;
			tfUser.text = "Q";
			tfUser.x = Config.DOUBLE_MARGIN + avatarSizeDouble + sectionAccount.getCornerEnd() - 2;
			tfUser.text = "|";
			tfUserHeight = tfUser.textHeight + 4;
			tfUser.text = "";
			addChild(tfUser);
			
			tfTime = new TextField();
			tfTime.autoSize = TextFieldAutoSize.LEFT;
			tfTime.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, COLOR_GRAY_DARK);
			tfTime.multiline = false;
			tfTime.wordWrap = false;
			tfTime.text = "00:00";
			tfTimeWidth = tfTime.textWidth + 4;
			tfTime.text = "";
			addChild(tfTime);
			
			tfAmount = new TextField();
			tfAmount.autoSize = TextFieldAutoSize.LEFT;
			tfAmount.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, COLOR_GRAY_DARK);
			tfAmount.multiline = false;
			tfAmount.wordWrap = false;
			addChild(tfAmount);
			
			tfTimeEnd = new TextField();
			tfTimeEnd.autoSize = TextFieldAutoSize.LEFT;
			tfTimeEnd.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, COLOR_GRAY_DARK);
			tfTimeEnd.multiline = false;
			tfTimeEnd.wordWrap = false;
			tfTimeEnd.text = "00:00";
			tfTimeEnd.width = tfTimeEnd.textWidth + 4;
			tfTimeEnd.text = "";
			addChild(tfTimeEnd);
			
			tfComments = new TextField();
			tfComments.x = Config.DOUBLE_MARGIN + avatarSizeDouble + sectionAccount.getCornerEnd() - 2;
			tfComments.autoSize = TextFieldAutoSize.LEFT;
			tfComments.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2);
			tfComments.multiline = false;
			tfComments.wordWrap = false;
			addChild(tfComments);
			
			addCircle = new Shape();
			addCircle.graphics.beginFill(0);
			addCircle.graphics.drawCircle(0, 0, 10);
			addCircle.graphics.endFill();
			
			addTF = new TextField();
			addTF.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.CENTER);
			addTF.multiline = false;
			addTF.wordWrap = false;
			addTF.text = "0";
			addTF.height = addTF.textHeight + 4;
			addTF.text = "";
		}
		
		public function getHeight(li:ListItem, width:int):int {
			if (li.data.opened == true)
				return 0;
			setData(li, width);
			if (MobileGui.centerScreen.currentScreenClass == BankBotChatScreen)
				return trueHeight + ((li.num == 0) ? Config.MARGIN + Config.FINGER_SIZE_DOT_5 : Config.FINGER_SIZE_DOT_5);
			return trueHeight + ((li.num == 0) ? Config.DOUBLE_MARGIN : Config.MARGIN);
		}
		
		private function setData(li:ListItem, width:int):void {
			if (li.data.opened == true)
				return;
			trueHeight = 0;
			if (li.num == 0)
				trueHeight = Config.MARGIN;
			trueHeight += tfUserHeight * 2 + Config.DOUBLE_MARGIN;
			sections ||= [];
			sections.length = 0;
			if (li.data.user != null && li.data.user is UserVO == false) {
				li.data.user = UsersManager.getUserByUID(li.data.user.uid);
			}
			var sectionWidth:int = width - (avatarSizeDouble + Config.DOUBLE_MARGIN) - (tfTimeWidth + Config.MARGIN);
			if (sectionChat.setData(li.data) == true) {
				sectionChat.setWidth(sectionWidth);
				sectionChat.fillData(li);
				trueHeight += sections[sections.push(sectionChat) - 1].getTrueHeight();
				if (sectionChat.parent == null)
					addChild(sectionChat);
			} else if (sectionChat.parent != null) {
				sectionChat.parent.removeChild(sectionChat);
			}
			if (sectionAccount.setData(li.data) == true) {
				sectionAccount.setWidth(sectionWidth);
				sectionAccount.fillData(li);
				trueHeight += sections[sections.push(sectionAccount) - 1].getTrueHeight();
				if (sectionAccount.parent == null)
					addChild(sectionAccount);
			} else if (sectionAccount.parent != null) {
				sectionAccount.parent.removeChild(sectionAccount);
			}
			if (sectionFromTo.setData(li.data) == true) {
				sectionFromTo.setWidth(sectionWidth);
				sectionFromTo.fillData(li);
				trueHeight += sections[sections.push(sectionFromTo) - 1].getTrueHeight();
				if (sectionFromTo.parent == null)
					addChild(sectionFromTo);
			} else if (sectionFromTo.parent != null) {
				sectionFromTo.parent.removeChild(sectionFromTo);
			}
			if (sectionText.setData(li.data) == true) {
				sectionText.setWidth(sectionWidth);
				sectionText.fillData(li);
				trueHeight += sections[sections.push(sectionText) - 1].getTrueHeight();
				if (sectionText.parent == null)
					addChild(sectionText);
			} else if (sectionText.parent != null) {
				sectionText.parent.removeChild(sectionText);
			}
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			setData(li, width);
			tfUser.y = ((li.num == 0) ? Config.MARGIN : 0);
			var sectionY:int = tfUser.y + tfUserHeight + Config.MARGIN;
			for (var i:int = 0; i < sections.length; i++) {
				if (i == 0)
					sections[i].setFirst(true);
				if (i == sections.length - 1) {
					sections[i].setLast(true);
					sections[i].setMine(li.data.mine);
				}
				sections[i].draw();
				sections[i].y = sectionY;
				sections[i].x = avatarSizeDouble + Config.DOUBLE_MARGIN;
				sectionY += sections[i].getTrueHeight();
			}
			if ("mine" in li.data == false || li.data.mine == false) {
				if (avatar.parent == null)
					addChild(avatar);
				avatar.graphics.clear();
				avatar.y = sectionY - avatarSizeDouble;
				if ("user" in li.data && li.data.user != null) {
					var uVO:UserVO = li.data.user;
					var avatarIBMD:ImageBitmapData = li.getLoadedImage("userAvatar");
					if (avatarIBMD != null) {
						ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarIBMD, ImageManager.SCALE_PORPORTIONAL);
					} else {
						ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, UI.getEmptyAvatarBitmapData(), ImageManager.SCALE_PORPORTIONAL);
					}
					tfUser.text = uVO.login;
					li.setHitZones( [ {
						type: HitZoneType.AVATAR,
						param: li.data.user.uid,
						x: avatar.x,
						y: avatar.y, 
						width: avatarSizeDouble,
						height: avatarSizeDouble
					} ] );
				} else if (li.data.bankBot == true) {
					ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarBankIBMD, ImageManager.SCALE_PORPORTIONAL);
					tfUser.text = "Bank Bot";
					li.setHitZones( [ {
						type: HitZoneType.AVATAR,
						param: "bankBot",
						x: avatar.x,
						y: avatar.y, 
						width: avatarSizeDouble,
						height: avatarSizeDouble
					} ] );
				} else {
					ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarNAIBMD, ImageManager.SCALE_PORPORTIONAL);
					tfUser.text = "N/A";
				}
			} else {
				if (avatar.parent != null)
					avatar.parent.removeChild(avatar);
				tfUser.text = Auth.myProfile.login;
			}
			if ("status" in li.data == true) {
				tfUser.text = tfUser.text + " [" + li.data.status + "]";
			}
			tfTime.text = getTimeString(li.data.time);
			tfTime.x = width - Config.MARGIN - tfTimeWidth;
			if (sections != null && sections.length != 0)
				tfTime.y = tfUserHeight + Config.MARGIN + sections[0].getTextLineY() - tfTime.getLineMetrics(0).ascent - 2;
			else
				tfTime.y = tfUserHeight + Config.MARGIN - tfTime.getLineMetrics(0).ascent - 2;
			var tfY:int = sectionY + Config.MARGIN;
			if ("amountEnd" in li.data == true && li.data.amountEnd != null) {
				var pre:String = "";
				if (("amountEndPreText" in li.data == true))
					pre = li.data.amountEndPreText;
				tfAmount.htmlText = pre + UI.renderCurrencyAdvanced(
					li.data.amountEnd,
					li.data.amountEndCurrency,
					FONT_SIZE_NORMAL,
					FONT_SIZE_SMALL
				);
				tfAmount.width = tfAmount.textWidth + 4;
				tfAmount.height = tfAmount.textHeight + 4;
				tfAmount.x = width - Config.MARGIN - tfTimeWidth - sectionAccount.getCornerEnd() + 2 - tfAmount.width;
				tfAmount.y = sectionY + Config.MARGIN;
				tfY = tfAmount.y + tfAmount.getLineMetrics(0).ascent + 2 - 2;
				tfAmount.visible = true;
			} else {
				tfAmount.visible = false;
			}
			graphics.clear();
			if (addCircle.parent != null)
				removeChild(addCircle);
			if (addTF.parent != null)
				removeChild(addTF);
			if (MobileGui.centerScreen.currentScreenClass == MyAccountScreen && li.data.type == "coinTrade") {
				if ("raw" in li.data == true) {
					if (li.data.raw.TYPE != "COIN_STAT_SELL" && li.data.raw.TYPE != "COIN_STAT_BUY") {
						graphics.lineStyle(int(Config.FINGER_SIZE * .05), 0xC6D5EE, 1, true);
						var pt:Point = new Point(int(sectionAccount.x + sectionAccount.BIRD_SIZE), int((sectionAccount.x + sectionAccount.BIRD_SIZE) * .5));
						if (li.data.first == true) {
							graphics.moveTo(pt.x, int(sectionAccount.y + sectionAccount.height * .5));
							graphics.curveTo(pt.y, int(sectionAccount.y + sectionAccount.height * .5), pt.y, int(sectionAccount.y + sectionAccount.height * .5) + pt.y);
							graphics.lineTo(pt.y, trueHeight + ((li.num == 0) ? Config.DOUBLE_MARGIN : Config.MARGIN));
						} else if (li.data.last == true) {
							graphics.moveTo(pt.x, int(sectionAccount.y + sectionAccount.height * .5));
							graphics.curveTo(pt.y, int(sectionAccount.y + sectionAccount.height * .5), pt.y, int(sectionAccount.y + sectionAccount.height * .5) - pt.y);
							graphics.lineTo(pt.y, 0);
						} else  if ("onlyOne" in li.data == false) {
							graphics.moveTo(pt.y, 0);
							graphics.lineTo(pt.y, trueHeight + ((li.num == 0) ? Config.DOUBLE_MARGIN : Config.MARGIN));
						}
						graphics.endFill();
						if ("showPrice" in li.data) {
							addChild(addCircle);
							var ct:ColorTransform = new ColorTransform();
							ct.color = 0x728FCF;
							addCircle.transform.colorTransform = ct;
							addCircle.width = addCircle.height = Config.FINGER_SIZE_DOT_75;
							addCircle.x = pt.y;
							addCircle.y = sectionText.y + sectionText.height * .5;
							addChild(addTF);
							addTF.text = li.data.showPrice;
							addTF.x = addCircle.x - addCircle.width * .5;
							addTF.y = addCircle.y + int((addCircle.height - addTF.height) * .5) - addCircle.height * .5;
							addTF.width = addCircle.width;
							li.setHitZones( [ {
								type: HitZoneType.CIRCLE,
								param: 0,
								x: addCircle.x - addCircle.width * .5,
								y: addCircle.y - addCircle.height * .5, 
								width: Config.FINGER_SIZE_DOT_75,
								height: Config.FINGER_SIZE_DOT_75
							} ] );
						}
					} else {
						addChild(addCircle);
						var ct1:ColorTransform = new ColorTransform();
						ct1.color = 0xA3B6E0;
						addCircle.transform.colorTransform = ct1;
						addCircle.width = addCircle.height = Config.FINGER_SIZE * .4;
						addCircle.x = int(sectionAccount.x + sectionAccount.BIRD_SIZE);
						addCircle.y = sectionText.y + sectionText.height * .5;
						addChild(addTF);
						addTF.text = li.data.raw.CUSTOM_DATA.total_trades;
						addTF.x = addCircle.x - addCircle.width * .5;
						addTF.y = addCircle.y + int((addCircle.height - addTF.height) * .5) - addCircle.height * .5;
						addTF.width = addCircle.width;
					}
				}
			}
			return this;
		}
		
		private function getTimeString(val:Number):String {
			var dateCurrent:Date = GlobalDate.dateCurrent;
			var dateCompared:Date = GlobalDate.comparedDate;
			dateCompared.setTime(val);
			
			var res:String;
			if (dateCurrent.getDate() == dateCompared.getDate() &&
				dateCurrent.getMonth() == dateCompared.getMonth() &&
				dateCurrent.getFullYear() == dateCompared.getFullYear()) {
					res = dateCompared.getHours() + "";
					if (res.length == 1)
						res = "0" + res;
					res += ":" + dateCompared.getMinutes();
					if (res.length == 4)
						res = res.substr(0, 3) + "0" + res.substr(3);
					return res;
			}
			res = dateCompared.getDate() + "";
			if (res.length == 1)
				res = "0" + res;
			res += "." + (dateCompared.getMonth() + 1);
			if (res.length == 4)
				res = res.substr(0, 3) + "0" + res.substr(3);
			return res;
		}
		
		private function renderCommentsText(count:int):String {
			return "<font color='" + COLOR_GRAY_LIGHT_STRING + "'>" + Lang.addComment + "</font>" + 
				   ((count == 0) ? "" : "<font color='" + COLOR_GRAY_DARK_STRING + "'> (" + count + ")</font>");
		}
		
		override public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData
		{
			var result:HitZoneData = new HitZoneData();
			
			
			var zones:Array = listItem.getHitZones();
			var data:Object = listItem.data;
			getView(listItem, getHeight(listItem, listItem.list.width), listItem.width, false);
			
			if (sections != null)
			{
				var itemsNum:int = sections.length;
				var item:Sprite;
				var widthResult:int = 0;
				var heightResult:int = 0;
				var minX:int = 1000;
				var minY:int = 1000;
				var paddingLeft:int = 0;
				
				for (var i:int = 0; i < itemsNum; i++) 
				{
					item = sections[i];
					if (item is BankAccountElementSectionBase)
					{
						paddingLeft = (item as BankAccountElementSectionBase).BIRD_SIZE;
						widthResult = (item as BankAccountElementSectionBase).getTrueWidth() - paddingLeft * 2;
						heightResult += (item as BankAccountElementSectionBase).getTrueHeight();
						if (minX > (item as BankAccountElementSectionBase).x)
						{
							minX = (item as BankAccountElementSectionBase).x;
						}
						if (minY > (item as BankAccountElementSectionBase).y)
						{
							minY = (item as BankAccountElementSectionBase).y;
						}
						
						result.radius = BankAccountElementSectionBase.CORNER_RADIUS;
					}
				}
				
				result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
				result.height = heightResult;
				result.width = widthResult;
				
				result.x = minX + paddingLeft;
				result.y = minY;
				
				return result;
			}
			
			return result;
		}
		
		public function dispose():void {
			
			if (avatarNAIBMD != null)
			{
				avatarNAIBMD.dispose();
				avatarNAIBMD = null;
			}
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
			if (tfUser != null)
			{
				UI.destroy(tfUser);
				tfUser = null;
			}
			if (tfUser != null)
			{
				UI.destroy(tfUser);
				tfUser = null;
			}
			if (tfTime != null)
			{
				UI.destroy(tfTime);
				tfTime = null;
			}
			if (tfComments != null)
			{
				UI.destroy(tfComments);
				tfComments = null;
			}
			if (tfAmount != null)
			{
				UI.destroy(tfAmount);
				tfAmount = null;
			}
			if (tfTimeEnd != null)
			{
				UI.destroy(tfTimeEnd);
				tfTimeEnd = null;
			}
			if (sectionAccount != null)
			{
				sectionAccount.dispose();
				sectionAccount = null;
			}
			if (sectionFromTo != null)
			{
				sectionFromTo.dispose();
				sectionFromTo = null;
			}
			if (sectionText != null)
			{
				sectionText.dispose();
				sectionText = null;
			}
			if (sectionChat != null)
			{
				sectionChat.dispose();
				sectionChat = null;
			}
		}
		
		public function get isTransparent():Boolean {
			return true;
		}
	}
}