package com.dukascopy.connect.gui.chat 
{
	import assets.LinksIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.stickerManager.StickerManager;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class QuestionPanel extends Sprite
	{
		private var avatar:CircleAvatar;
		private var back:Sprite;
		private var scrollPanel:ScrollPanel;
		private var first:Shape;
		private var avatarSize:int;
		private var padding:int;
		private var maxTextHeight:Number;
		private var dateField:Bitmap;
		private var tips:Bitmap;
		private var fullPanelHeight:int;
		private var minPanelHeight:int;
		private var expanded:Boolean;
		private var itemWidth:int;
		private var inTransition:Boolean;
		private var secret:Boolean;
		private var data:QuestionVO;
		private var drawn:Boolean = false;
		private var tipsContainer:Sprite;
		private var links:Array;
		private var messageClips:Array;
		private var defaultText:String;
		private var user:UserVO;
		private var startTextHeight:Number;
		private var firstTime:Boolean;
		private var currentMaxHeight:int;
		private var userName:Bitmap;
		private var minTextExist:Boolean;
		
		public var S_HEIGHT_CHANGE:Signal = new Signal("QuestionPanel.S_HEIGHT_CHANGE");
		public var minHeight:int = Config.FINGER_SIZE * 1.17;
		
		public function QuestionPanel() 
		{
			firstTime = true;
			avatarSize = Config.FINGER_SIZE * .66;
			padding = Config.DOUBLE_MARGIN*.8;
			maxTextHeight = Config.FINGER_SIZE * 15;
			startTextHeight = Config.FINGER_SIZE * 4;
			
			back = new Sprite();
			var shadowHeight:int = Config.FINGER_SIZE * 0.02;
				back.graphics.beginFill(0xFFFFFF);
				back.graphics.drawRect(0, 0, 10, 10 - shadowHeight);
				back.graphics.endFill();
				
				back.graphics.beginFill(0, 0.1);
				back.graphics.drawRect(0, 10 - shadowHeight, 10, shadowHeight);
				back.graphics.endFill();
				back.scale9Grid = new Rectangle(1, 1, 7, 10 - shadowHeight - 1);
			addChild(back);
			
			avatar = new CircleAvatar();
			addChild(avatar);
			avatar.x = int(Config.FINGER_SIZE * .23);
			avatar.y = int(padding);
			
			scrollPanel = new ScrollPanel();
			
				first = new Shape();
				first.graphics.beginFill(0, 0);
				first.graphics.drawRect(0, 0, 1, 1);
				first.graphics.endFill();
			scrollPanel.addObject(first);
			addChild(scrollPanel.view);
			scrollPanel.view.x = avatarSize + padding * 2;
			
			dateField = new Bitmap();
			dateField.x = avatarSize + padding * 2;
			addChild(dateField);
			
			tipsContainer = new Sprite();
			addChild(tipsContainer);
			
			tips = new Bitmap();
			tipsContainer.addChild(tips);
		}
		
		public function dispose():void
		{
			TweenMax.killTweensOf(back);
			
			cleanMessages();
			messageClips = null;
			links = null;
			
			if (S_HEIGHT_CHANGE != null) {
				S_HEIGHT_CHANGE.dispose();
				S_HEIGHT_CHANGE = null;
			}
			if (avatar != null) {
				avatar.dispose();
				avatar = null;
			}
			if (scrollPanel != null) {
				scrollPanel.dispose();
				scrollPanel = null;
			}
			if (back != null) {
				UI.destroy(back);
				back = null;
			}
			if (first != null) {
				UI.destroy(first);
				first = null;
			}
			if (avatar != null) {
				UI.destroy(avatar);
				avatar = null;
			}
			if (dateField != null) {
				UI.destroy(dateField);
				dateField = null;
			}
			if (tips != null) {
				UI.destroy(tips);
				tips = null;
			}
			if (tipsContainer != null) {
				UI.destroy(tipsContainer);
				tipsContainer = null;
			}
		}
		
		public function deactivate():void
		{
			scrollPanel.disable();
			PointerManager.removeTap(this, onMainTap);
		}
		
		public function activate():void
		{
			if (expanded == true) {
				scrollPanel.enable();
			}
			
			PointerManager.addTap(this, onMainTap);
		}
		
		private function onMainTap(e:Event = null):void 
		{
			if (e == null || e.target != avatar)
			{
				if (e != null && e.target == tipsContainer)
				{
					DialogManager.alert(Lang.information, data.tipsAmount + " " + data.tipsCurrencyDisplay + Lang.textAdditionalTips);
					return;
				}
				
				if (expanded == true && links != null && links.length > 0 && e != null && e is MouseEvent){
					var l:int = links.length;
					var position:Point = new Point((e as MouseEvent).stageX, (e as MouseEvent).stageY);
					position = scrollPanel.containerBox.globalToLocal(position);
					for (var i:int = 0; i < l; i++) 
					{
						if (position.x > links[i].area.x && position.x < (links[i].area.x + links[i].area.width) &&
							position.y > links[i].area.y && position.y < (links[i].area.y + links[i].area.height)){
							
							if (data != null && ((Config.ADMIN_UIDS != null && Config.ADMIN_UIDS.indexOf(data.userUID) != -1) || (data.user != null && data.user.payRating > 4)))
							{
								var link:String = links[i].link;
								if (link.indexOf("http://") == -1 && link.indexOf("https://") == -1){
									link = "http://" + link;
								}
								navigateToURL(new URLRequest(link));
								return;
							}
						}
					}
				}
				
				if ((Math.abs(minPanelHeight - fullPanelHeight) > 3 && inTransition == false && fullPanelHeight > minPanelHeight) || minTextExist == true)
				{
					inTransition = true;
					
					if (expanded == true)
					{
						scrollPanel.disable();
						expanded = false;
						TweenMax.to(back, 0.3, { height:minPanelHeight, onUpdate:updateLayout, onComplete:onDeexpandComplete } );
					}
					else
					{
						expanded = true;
						TweenMax.to(back, 0.3, { height:fullPanelHeight, onUpdate:updateLayout, onStart:setFullText, onComplete:onExpandComplete } );
					}
				}
			}
			else if (e != null && e.target == avatar && user != null) {
				if (secret == false && user.uid != Auth.uid) {
					MobileGui.changeMainScreen(UserProfileScreen, {
							backScreen: MobileGui.centerScreen.currentScreenClass, 
							backScreenData: MobileGui.centerScreen.currentScreen.data, 
							data: user
					} );
				}
			}
		}
		
		private function onDeexpandComplete():void 
		{
			inTransition = false;
			updateLayout();
			S_HEIGHT_CHANGE.invoke();
			
			setSmallText();
		}
		
		private function setSmallText():void 
		{
			cleanMessages();
			
			var multiline:Boolean = false;
			var textHeight:int = 10;
			
			var messageText:String = getMessage();
			
			
			if (data == null)
			{
				multiline = true;
				textHeight = Config.FINGER_SIZE * 0.75;
				
				minTextExist = true;
				if (messageText.indexOf("<min/>") != -1)
				{
					messageText = messageText.slice(0, messageText.indexOf("<min/>"));
					textHeight = 10;
				}
			}
			
			var messageBitmapData:ImageBitmapData = TextUtils.createTextFieldData(
															messageText, 
															itemWidth - avatarSize - padding * 3, 
															textHeight, 
															multiline, 
															TextFormatAlign.LEFT, 
															TextFieldAutoSize.NONE, 
															Config.FINGER_SIZE * .30, 
															multiline, 
															0x000000, 
															0xFFFFFF, 
															true, true, true);
			var message:Bitmap = new Bitmap(messageBitmapData);
			
			if (minTextExist == true)
			{
				minHeight = int(message.height + scrollPanel.view.y + Config.FINGER_SIZE * .3);
			}
			
			scrollPanel.addObject(message);
			messageClips.push(message);
			if (data != null)
			{
				message.y = Config.MARGIN * 1.6;
			}
		//	message.x = 1;
		}
		
		private function onExpandComplete():void 
		{
			scrollPanel.enable();
			inTransition = false;
			updateLayout();
			S_HEIGHT_CHANGE.invoke();
		}
		
		private function updateLayout():void {
			scrollPanel.containerBox.y = 0;
			var contentHeight:int;
			if (expanded){
				contentHeight = back.height - padding * 1.8 - tips.height + 1;
				if (data == null)
				{
					contentHeight -= scrollPanel.view.y;
				}
			}
			else{
				contentHeight = back.height - padding * 1.8 - tips.height + 1 + Config.FINGER_SIZE * .17;
				
				if (data == null)
				{
					contentHeight -= scrollPanel.view.y;
				}
			}
			
			scrollPanel.setWidthAndHeight(itemWidth - avatarSize - padding * 2, contentHeight);
			tipsContainer.y = int(back.height - tips.height - padding*.9);
			dateField.y = int(tipsContainer.y + tipsContainer.height * .5 - dateField.height * .5);
		}
		
		public function draw(data:QuestionVO, itemWidth:int, defaultText:String = null, defaultUser:UserVO = null, defaultIncognito:Boolean = false, maxHeight:int = -1, updateOnly:Boolean = false):void
		{
			if (defaultText != null)
			{
				this.defaultText = defaultText;
			}
			
			if (data != null) {
				user = data.user;
				
				if(data.incognito == true) {
					secret = true;
				}
			}
			else if (defaultUser != null){
				user = defaultUser;
				secret = defaultIncognito;
			}
			
			this.data = data;
			
			this.itemWidth = itemWidth;
			
			avatar.setData(user, avatarSize * .5, secret);
			
			if (updateOnly == false)
			{
				if (data == null)
				{
					// simple channel with description panel
					
					var namePadding:int = Config.FINGER_SIZE * .44;
					
					if (userName == null)
					{
						var userText:String;
						if (user != null)
						{
							userText = user.getDisplayName();
						}
						
						userName = new Bitmap();
						addChild(userName);
					//	userName.x = avatar.x;
						userName.y = padding;
						userName.x = scrollPanel.view.x;
						userName.bitmapData = TextUtils.createTextFieldData(
																		userText, 
																		itemWidth - padding * 2, 
																		10, 
																		true, 
																		TextFormatAlign.LEFT, 
																		TextFieldAutoSize.LEFT, 
																		Config.FINGER_SIZE * .28, 
																		true, 
																		0x525771, 
																		0xFFFFFF, 
																		true);
						
						minHeight += namePadding;
						
						avatar.y = padding;
						scrollPanel.view.y = padding + namePadding;
					}
					
					
					
					setFullText();
					currentMaxHeight = maxHeight;
					repositionElements(maxHeight, false);
					setSmallText();
					minPanelHeight = minHeight;
				//	repositionElements(maxHeight, false);
					expanded = false;
				//	scrollPanel.enable();
					
					back.width = itemWidth;
					back.height = minPanelHeight;
					
					updateLayout();
					
				//	setSmallText();
				}
				else
				{
					setFullText();
					
					currentMaxHeight = maxHeight;
					repositionElements(maxHeight, false);
					var currentHeight:int = repositionElements(maxHeight, true);
					
					expanded = true;
					scrollPanel.enable();
					
					back.width = itemWidth;
					back.height = currentHeight;
				}
			}
			
		//	updateLayout();
			if (drawn == false)
			{
				alpha = 0;
				TweenMax.to(this, 0.2, { alpha:1 } );
			}
			
			drawn = true;
		}
		
		private function repositionElements(maxHeight:int = -1, calculateStartHeight:Boolean = true):int 
		{
			var maxTextHeightLocal:int = maxTextHeight;
			if (firstTime &&  calculateStartHeight)
			{
				firstTime = false;
				maxTextHeightLocal = startTextHeight;
			}
			
			var textHeight:int = Math.min(maxTextHeightLocal, scrollPanel.itemsHeight);
			
			/*if (data == null && expanded == false)
			{
				textHeight -= scrollPanel.view.y;
			}*/
			
			scrollPanel.setWidthAndHeight(itemWidth - avatarSize - padding * 2, textHeight);
			scrollPanel.update();
			updateTips();
			
			if (data != null) {
				var created:Date = new Date(data.createdTime * 1000);
				dateField.visible = true;
				if (dateField.bitmapData != null)
				{
					dateField.bitmapData.dispose();
					dateField.bitmapData = null;
				}
				
				dateField.bitmapData = TextUtils.createTextFieldData(
																		Lang.asked + " " + DateUtils.getComfortDateRepresentationWithMinutes(created), 
																		itemWidth - tips.width - padding * 4 - avatarSize, 
																		10, 
																		true, 
																		TextFormatAlign.LEFT, 
																		TextFieldAutoSize.LEFT, 
																		Config.FINGER_SIZE * .18, 
																		true, 
																		0x8791AA, 
																		0xFFFFFF, 
																		true);
			}
			else {
				dateField.visible = false;
				tips.visible = false;
			}
			tipsContainer.y = int(scrollPanel.view.y + scrollPanel.height + padding*.9);
			dateField.y = int(tipsContainer.y + tipsContainer.height * .5 - dateField.height * .5);
			tipsContainer.x = int(dateField.x + dateField.width + padding);
			
			minPanelHeight = minHeight;
			
			if (calculateStartHeight == false)
			{
				fullPanelHeight = getHeight();
				
				if (maxHeight != -1 && fullPanelHeight > maxHeight)
				{
					fullPanelHeight = maxHeight;
				}
				return fullPanelHeight;
			}
			else{
				return getHeight();
			}
		}
		
		private function setFullText():void 
		{
			cleanMessages();
			
			var message:String = getMessage(true);
			var linksPattern:RegExp = /\b((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/ig;
			var stickersPattern:RegExp = /(<s>.*?<s>)/g;
			
			var messageItems:Array = message.split(linksPattern);
			
			if (messageItems != null && messageItems.length > 0 && messageItems[messageItems.length - 1] == "\n") {
				messageItems.removeAt(messageItems.length - 1);
			}
			
			var l:int = messageItems.length;
			
			var allMesages:Array = new Array();
			for (var j:int = 0; j < l; j++) 
			{
				if (messageItems[j] != null && messageItems[j] != undefined) {
					allMesages = allMesages.concat(messageItems[j].split(stickersPattern));
				}
			}
			
			l = allMesages.length;
			messageClips = new Array();
			var questionItem:Bitmap;
			var position:int = Config.MARGIN * 1.6;
			if (data == null && userName != null)
			{
				position = 0;
			}
			
			links = new Array();
			var linksBack:Sprite = new Sprite();
			var linkIcon:LinksIcon = new LinksIcon();
			var linkPadding:int = Config.FINGER_SIZE * .16;
			UI.scaleToFit(linkIcon, Config.FINGER_SIZE * .8, Config.FINGER_SIZE * .25);
			linksBack.addChild(linkIcon);
			linkIcon.x = linkPadding;
			linkIcon.y = linkPadding * 1.1;
			var linkBitmapData:ImageBitmapData;
			var serviceString:String;
			var maxItemWidth:int = itemWidth - avatarSize - padding * 3;
			var sticker:Sprite;
			
			for (var i:int = 0; i < l; i++) 
			{
				if (allMesages[i] != null && allMesages[i] != undefined && allMesages[i] != ""){
					questionItem = new Bitmap();
					messageClips.push(questionItem);
					if (linksPattern.test(allMesages[i])){
						linksPattern.lastIndex = 0;
						linkBitmapData = TextUtils.createTextFieldData(
																	allMesages[i], 
																	maxItemWidth - linkPadding * 3 - linkIcon.width - Config.FINGER_SIZE*.1, 
																	10, 
																	true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .28, 
																	true, 
																	0x3498DB, 
																	0xE7F0FF, 
																	true);
						
						linksBack.graphics.clear();
						linksBack.graphics.beginFill(0xE7F0FF);
						linksBack.graphics.drawRoundRect(0, 0, linkBitmapData.width + linkPadding * 3 + linkIcon.width, linkBitmapData.height + linkPadding * 2, Config.FINGER_SIZE * .2);
						linksBack.graphics.endFill();
						questionItem.bitmapData = UI.getSnapshot(linksBack, StageQuality.HIGH, "QuestionPanel.message");
						questionItem.bitmapData.copyPixels(linkBitmapData, linkBitmapData.rect, new Point(linkPadding * 2 + linkIcon.width, linkPadding), null, null, true);
						
						links.push({area:new Rectangle(0, position, itemWidth, questionItem.height), link:allMesages[i]});
						
						linkBitmapData.dispose();
						linkBitmapData = null;
					}
					else if (stickersPattern.test(allMesages[i])) {
						stickersPattern.lastIndex = 0;
						serviceString = allMesages[i].slice(3, allMesages[i].length - 3);
						serviceString = serviceString.split(",")[0];
						
						sticker = StickerManager.getLocalStickerVector(int(serviceString), 1, Config.FINGER_SIZE, Config.FINGER_SIZE);
						if (sticker != null) {
							UI.scaleToFit(sticker, Config.FINGER_SIZE * 1.5, Config.FINGER_SIZE * 1.5);
							questionItem.bitmapData = UI.getSnapshot(sticker, StageQuality.HIGH, "QuestionPanel.sticker");
						}
						
					}
					else{
						questionItem.bitmapData = TextUtils.createTextFieldData(
																	allMesages[i], 
																	maxItemWidth, 
																	10, 
																	true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .30, 
																	true, 
																	0x000000, 
																	0xFFFFFF, 
																	true, true);
					}
					if (questionItem.bitmapData != null){
						scrollPanel.addObject(questionItem);
						questionItem.y = position;
						position += questionItem.height + Config.MARGIN;
					}
					
				}
			}
			var endClip:Sprite = new Sprite();
			endClip.graphics.beginFill(0xFFFFFF);
			endClip.graphics.drawRect(0, 0, 1, 1);
			endClip.graphics.endFill();
		//	scrollPanel.addObject(endClip);
			endClip.y = position + Config.MARGIN * .7;
			
			UI.destroy(linkIcon);
			linkIcon = null;
			
			UI.destroy(linksBack);
			linksBack = null;
			scrollPanel.addObject(first);
			scrollPanel.update();
		}
		
		private function cleanMessages():void 
		{
			if (messageClips != null){
				var l:int = messageClips.length;
				for (var i:int = 0; i < l; i++) 
				{
					UI.destroy(messageClips[i]);
				}
				if (scrollPanel != null){
					scrollPanel.removeAllObjects();
				}
			}
		}
		
		private function getMessage(withSystemMessages:Boolean = false):String {
			if (data == null)
			{
				if (defaultText != null){
					return defaultText;
				}
				return Lang.questionNoMoreExist;
			}
			var messageText:String = "";
			var jsonData:Object;
			if (data.messages != null) {
				var l:int = data.messages.length;
				for (var i:int = 0; i < l; i++)	{
					if (data.messages[i].text != null) {
						if (data.messages[i].text.indexOf(Config.BOUNDS) != -1){
							if (withSystemMessages == true ){
								try{
									jsonData = JSON.parse((data.messages[i].text as String).slice(Config.BOUNDS.length));
									if ("type" in jsonData && 
										jsonData.type == ChatSystemMsgVO.TYPE_STICKER && 
										"additionalData" in jsonData && 
										jsonData.additionalData != null)
									{
										messageText += "<s>" + jsonData.additionalData + "<s>";
									}
								}
								catch (e:Error){}
							}
						}
						else{
							messageText += data.messages[i].text;
							if (i != l-1){
								messageText += "\n";
							}
						}
					}
				}
			}
			
			return messageText;
		}
		
		private function updateTips():void {
			if (data == null) {
				tips.visible = false;
				return;
			}
			tips.visible = true;
			var colorText:Number;
			var colorBack:Number;
			var text:String = Lang.textReward + ":" + data.tipsAmount + " " + data.tipsCurrencyDisplay.toUpperCase();
			if (data.isPaid) {
				text += " " + Lang.textPaid;
				colorBack = 0xD9FADE;
				colorText = 0x50B11C;
			} else {
				colorBack = 0xFAE7E7;
				colorText = 0xD92626;
			}
			
			var tipsText:TextFieldSettings = new TextFieldSettings(
													text,
													colorText, Config.FINGER_SIZE * .18);
			if (tips.bitmapData != null)
			{
				tips.bitmapData.dispose();
				tips.bitmapData = null;
			}
			tips.bitmapData = TextUtils.createbutton(tipsText, colorBack, 1, Config.MARGIN * .85, NaN, -1, Config.MARGIN * .25);
		}
		
		public function getHeight():int 
		{
			return Math.max(tipsContainer.y + tips.height + padding * .9, avatar.y + avatarSize + padding, dateField.y + dateField.height + padding * .6);
		}
		
		public function collapse():void 
		{
			if (expanded == true) {
				onMainTap();
			}
		}
		
		public function update():void {
			draw(ChatManager.getCurrentChat().getQuestion(), itemWidth, null, null, false, currentMaxHeight, true);
		}
	}
}