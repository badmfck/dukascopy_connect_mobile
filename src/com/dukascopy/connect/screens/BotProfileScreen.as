package com.dukascopy.connect.screens {
	
	import assets.BlockUserIcon;
	import assets.ButtonChatContent;
	import assets.ButtonPayContent;
	import assets.SettingsIcon_banForever;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.UserListRenderer;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.topBar.TopBarProfile;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.Gifts;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.bot.BotManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.GiftType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.type.UserBlockStatusType;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.adds.BotVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Pavel Karpov. Telefision TEAM Kiev.
	 */
	
	public class BotProfileScreen extends BaseScreen {
		
		private var buttonPaddingLeft:int = Config.MARGIN * 3;
		private var circleButtonsSize:int = Config.FINGER_SIZE * 1.3;
		private var iconSize:int = Config.FINGER_SIZE * 0.36;
		private var iconArrowSize:int = Config.FINGER_SIZE * 0.30;
		private var optionLineHeight:int = Config.FINGER_SIZE * .8;
		private var fitWidth:int;
		
		private const actions:Array = [ { id: "refreshBtn", img: SWFPaymentsRefreshIcon, callback: onRefresh } ];
		
		private var avatarExists:Boolean = false;
		private var avatarSize:int;
		private var avatarBMD:ImageBitmapData;
		
		private var titleFormat:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .25);
		private var descFormat:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .23, MainColors.GREY);
		
		private var preloader:Preloader;
		private var topBar:TopBarProfile;
		private var scrollPanel:ScrollPanel;
			private var first:Shape;
			private var avatar:Sprite;
				private var crown:Sprite;
				private var avatarShape:Shape; 
				private var avatarPreloader:Preloader;
				private var ownerTF:TextField;
				private var contactListItem:ListItem;
				private var contactItem:UserListRenderer;
				private var descriptionTitleTF:TextField;
				private var descriptionTF:TextField;
			private var mainActions:Sprite;
		//  MAIN ACTIONS  //
		private var actionChat:Object = { icon:ButtonChatContent, callback:onChatButtonTap };
		private var actionPay:Object = { icon:ButtonPayContent, callback:onPayButtonTap };
		//  OTHER ACTIONS  //
		private var actionBlockUser:Object = { iconL:BlockUserIcon, title:"", callback:onBlockButtonTap };
		//  ACTIONS ONLY FOR ADMIN  //
		private var actionBanUser:Object = { iconL:SWFSettingsIcon_ban, title:Lang.textBanUser, callback:onBanButtonTap, red:true };
		private var actionBanForeverUser:Object = { iconL:SettingsIcon_banForever, title:Lang.textBanForeverUser, callback:onBanForeverButtonTap, red:true };
		
		private var botVO:BotVO;
		
		private var mainButtons:Array/*BitmapButton*/;
		private var otherButtons:Array/*BitmapButton*/;
		
		private var avatarsToDispose:Array/*ImageBitmapData*/;
		
		private var waiting:Boolean;
		private var firstTime:Boolean = true;
		private var controlsPosition:int;
		private var cliHeight:int;
		
		public function BotProfileScreen() { }
		
		override protected function createView():void {
			super.createView();
			topBar = new TopBarProfile();
			_view.addChild(topBar);
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = MainColors.WHITE;
			first = new Shape();
				first.graphics.beginFill(0, 0);
				first.graphics.drawRect(0, 0, 1, 1);
				first.graphics.endFill();
			scrollPanel.addObject(first);
				avatar = new Sprite();
			scrollPanel.addObject(avatar);
			avatarShape = new Shape();
			avatar.addChild(avatarShape);
			
			_view.addChildAt(scrollPanel.view, 0);
		}
		
		override protected function drawView():void {
			scrollPanel.setWidthAndHeight(_width, _height - scrollPanel.view.y);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.title = "Bot profile screen";
			_params.doDisposeAfterClose = true;
			
			BotManager.S_BOT_ADDITIONAL_DATA.add(onAdditionalDataLoaded);
			
			if (data.data is BotVO)
				botVO = data.data;
			
			if (botVO.disposed == true) {
				MobileGui.S_BACK_PRESSED.invoke();
				return;
			}
			
			if (Auth.blocked != null && Auth.blocked.indexOf(botVO.uid) != -1)
				actionBlockUser.title = Lang.unblockUser;
			else
				actionBlockUser.title = Lang.blockUser;
			
			fitWidth = _width - buttonPaddingLeft * 2;
			
			scrollPanel.view.y = topBar.trueHeight;
			scrollPanel.setWidthAndHeight(_width, _height - scrollPanel.view.y);
			avatarSize = ((_width - Config.FINGER_SIZE * 3) * .5);
			avatar.x = int(_width * .5);
			avatar.y = avatarSize + Config.FINGER_SIZE;
			
			topBar.setStatusUserUID(botVO.uid);
			topBar.setData(botVO.getDisplayName(), true, actions);
			topBar.drawView(_width);
			
			var componentY:int = avatar.y + avatarSize + Config.DOUBLE_MARGIN * 2;
			createMainActions(componentY);
			if (mainActions != null)
				componentY += mainActions.height + Config.DOUBLE_MARGIN * 2;
			scrollPanel.updateObjects();
			
			onAvatarLoaded(null, ImageManager.getImageFromCache(botVO.bigAvatarURL), true);
			if (avatarExists == false)
				onAvatarLoaded(null, getEmptyAvatar(), true);
			
			ownerTF = new TextField();
			ownerTF.selectable = false;
			ownerTF.defaultTextFormat = titleFormat;
			ownerTF.multiline = false;
			ownerTF.wordWrap = false;
			ownerTF.text = "Owner:";
			ownerTF.width = ownerTF.textWidth + 4;
			ownerTF.height = ownerTF.textHeight + 4;
			ownerTF.y = componentY;
			ownerTF.x = Config.DOUBLE_MARGIN - 2;
			scrollPanel.addObject(ownerTF);
			
			componentY += ownerTF.height;
			
			contactItem = new UserListRenderer();
			contactListItem = new ListItem("", 0, 0, _width, contactItem, botVO.owner, null);
			cliHeight = contactItem.getHeight(contactListItem, _width);
			contactItem.getView(contactListItem, cliHeight, _width);
			contactItem.y = componentY;
			PointerManager.addTap(contactItem, openOwnerProfile);
			componentY += cliHeight + Config.DOUBLE_MARGIN;
			scrollPanel.addObject(contactItem);
			
			componentY = addBotDescription(componentY);
			
			createOtherActions(componentY);
		}
		
		private function addBotDescription(componentY:int):int {
			if (botVO.description != null) {
				if (descriptionTitleTF == null) {
					descriptionTitleTF = new TextField();
					descriptionTitleTF.selectable = false;
					descriptionTitleTF.defaultTextFormat = titleFormat;
					descriptionTitleTF.multiline = false;
					descriptionTitleTF.wordWrap = false;
					descriptionTitleTF.x = Config.DOUBLE_MARGIN - 2;
					scrollPanel.addObject(descriptionTitleTF);
				}
				descriptionTitleTF.text = "Description:";
				descriptionTitleTF.width = descriptionTitleTF.textWidth + 4;
				descriptionTitleTF.height = descriptionTitleTF.textHeight + 4;
				descriptionTitleTF.y = componentY;
				
				componentY += descriptionTitleTF.height + Config.MARGIN;
				
				if (descriptionTF == null) {
					descriptionTF ||= new TextField();
					descriptionTF.selectable = false;
					descriptionTF.defaultTextFormat = descFormat;
					descriptionTF.multiline = true;
					descriptionTF.wordWrap = true;
					descriptionTF.x = Config.DOUBLE_MARGIN - 2;
					scrollPanel.addObject(descriptionTF);
				}
				descriptionTF.text = botVO.description;
				descriptionTF.width = _width - Config.DOUBLE_MARGIN * 2 - 4;
				descriptionTF.height = descriptionTF.textHeight + 4;
				descriptionTF.y = componentY;
				
				componentY += descriptionTF.height + Config.MARGIN;
			}
			return componentY;
		}
		
		private function onAdditionalDataLoaded(bot:BotVO):void {
			if (botVO.uid != bot.uid)
				return;
			showPreloader(false);
			onAvatarLoaded(null, ImageManager.getImageFromCache(botVO.bigAvatarURL), true);
			topBar.updateTitle(botVO.getDisplayName());
			topBar.hideAnimation();
			scrollPanel.updateObjects();
			
			var componentY:int = addBotDescription(contactItem.y + cliHeight + Config.DOUBLE_MARGIN);
			
			if (otherButtons != null && otherButtons.length != 0) {
				for (var i:int = 0; i < otherButtons.length; i++) {
					otherButtons[i].y = componentY;
					componentY += otherButtons[i].height + Config.MARGIN;
				}
			}
		}
		
		private function createOtherActions(yPos:int):void {
			if (botVO.uid == null || botVO.uid.length == 0)
				return;
			var actions:Array = [];
			actions.push(actionBlockUser);
			if (Config.ADMIN_UIDS.indexOf(Auth.uid) != -1) {
				actions.push(actionBanUser);
				actions.push(actionBanForeverUser);
			}
			createOtherActionsButtons(actions, yPos);
		}
		
		private function createOtherActionsButtons(actions:Array, yPos:int):void {
			if (actions == null || actions.length == 0)
				return;
			otherButtons ||= [];
			var obj:Object;
			var iconL:DisplayObject;
			var iconR:DisplayObject;
			var btn:BitmapButton;
			var l:int = actions.length;
			for (var i:int = 0; i < l; i++) {
				obj = actions[i];
				if (obj.iconL != undefined && obj.iconL != null) {
					iconL = new obj.iconL();
					if (obj.red == true)
						UI.colorize(iconL, MainColors.RED);
					else
						UI.colorize(iconL, 0x96A4B0);
					UI.scaleToFit(iconL, iconSize, iconSize);
				}
				if (obj.iconR != undefined && obj.iconR != null) {
					iconR = new obj.iconR();
					if (obj.red == true)
						UI.colorize(iconR, MainColors.RED);
					else
						UI.colorize(iconL, 0x96A4B0);
					UI.scaleToFit(iconR, iconArrowSize, iconArrowSize);
				}
				btn = new BitmapButton();
				btn.usePreventOnDown = false;
				btn.setDownScale(1);
				btn.setDownColor(0x000000);
				var ibmd:ImageBitmapData = UI.renderSettingsTextAdvanced(
					obj.title,
					_width,
					optionLineHeight,
					false,
					TextFormatAlign.LEFT,
					TextFieldAutoSize.NONE,
					Config.FINGER_SIZE * 0.34,
					false,
					(obj.red == true) ? MainColors.RED : AppTheme.GREY_DARK,
					0,
					0,
					iconL,
					iconR
				);
				UI.destroy(iconL);
				UI.destroy(iconR);
				iconL = null;
				iconR = null;
				btn.setBitmapData(ibmd);
				btn.tapCallback = obj.callback;
				btn.x = 0;
				btn.y = yPos;
				btn.hide();
				scrollPanel.addObject(btn);
				obj.button = btn;
				otherButtons.push(btn);
				yPos += btn.height + Config.MARGIN;
			}
		}
		
		private function createMainActions(yPos:int):void {
			var actions:Array = [
				actionChat,
				actionPay
			];
			createMainActionsButtons(actions, yPos);
		}
		
		private function createMainActionsButtons(actions:Array, yPos:int):void {
			if (actions == null || actions.length == 0)
				return;
			if (mainActions == null) {
				mainButtons = [];
				mainActions = new Sprite();
				mainActions.y = yPos;
				scrollPanel.addObject(mainActions);
			}
			var btnX:int = 0;
			var btn:BitmapButton;
			var cnt:Sprite;
			var l:int = actions.length;
			for (var i:int = 0; i < l; i++) {
				cnt = new actions[i].icon();
				cnt.height = circleButtonsSize;
				cnt.width = cnt.width * cnt.scaleY;
				btn = new BitmapButton();
				btn.setDownScale(1);
				btn.setDownColor(0x000000);
				btn.setBitmapData(UI.getSnapshot(cnt, StageQuality.HIGH, "UserProfileScreen.circleButton"), true);
				btn.tapCallback = actions[i].callback;
				btn.hide();
				btn.x = btnX;
				btnX += btn.width + Config.DOUBLE_MARGIN;
				mainActions.addChild(btn);
				mainButtons.push(btn);
			}
			mainActions.x = int((_width - mainActions.width) * .5);
		}
		
		private function getEmptyAvatar():ImageBitmapData {
			return UI.getEmptyAvatarBitmapData(avatarSize * 2, avatarSize * 2);
		}
		
		private function onAvatarLoaded(url:String, bmd:ImageBitmapData, success:Boolean):void {
			if (_isDisposed == true)
				return;
			if (success == false)
				return;
			if (avatarExists == true && avatarBMD == null)
				return;
			if (url != null) {
				var needToPush:Boolean = false;
				avatarsToDispose ||= [];
				var l:int = avatarsToDispose.length;
				for (var i:int = 0; i < l; i++)
					if (avatarsToDispose[i] == bmd)
						break;
				if (needToPush == true)
					avatarsToDispose.push(bmd);
			}
			if (avatarBMD == bmd)
				return;
			avatarBMD = bmd;
			if (avatarBMD == null)
				return;
			avatarShape.graphics.clear();
			ImageManager.drawGraphicCircleImage(avatarShape.graphics, 0 , 0, avatarSize, avatarBMD, ImageManager.SCALE_INNER_PROP);
			avatarShape.x = -avatarSize;
			avatarShape.y = -avatarSize;
			
			avatarExists = true;
			hideAvatarPreloader();
		}
		
		public function showAvatarPreloader():void {
			if (avatarPreloader == null)
				avatarPreloader = new Preloader();
			if (avatarPreloader.parent == null)
				avatar.addChild(avatarPreloader);
			avatarPreloader.show();
		}
		
		private function hideAvatarPreloader():void {
			if (avatarPreloader == null)
				return;
			if (avatarPreloader.parent == null)
				return;
			avatarPreloader.hide(true);
			avatarPreloader = null;
		}
		
		override public function activateScreen():void {
			if (_isActivated == true)
				return;
			super.activateScreen();
			if (_isDisposed == true)
				return;
			topBar.activate();
			scrollPanel.enable();
			if (firstTime == true) {
				showPreloader();
				BotManager.getBotAdditionalData(botVO.uid);
			}
			
			var l:int;
			var count:int;
			if (mainButtons != null) {
				count = 3;
				l = mainButtons.length;
				for (var i:int = 0; i < l; i++) {
					if (firstTime == true)
						mainButtons[i].show(.3, count * .15, true, .9, 0);
					mainButtons[i].activate();
					count++;
				}
			}
			
			if (otherButtons != null) {
				l = otherButtons.length;
				for (i = 0; i < l; i++) {
					if (firstTime == true)
						otherButtons[i].show(.3, count * .15, true, .9, 0);
					otherButtons[i].activate();
					count++;
				}
			}
			
			firstTime = false;
		}
		
		override public function deactivateScreen():void {
			if (_isActivated == false)
				return;
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			topBar.deactivate();
			scrollPanel.disable();
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			super.dispose();
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			botVO = null;
			topBar.dispose();
			topBar = null;
			scrollPanel.dispose();
			scrollPanel = null;
			
			BotManager.S_BOT_ADDITIONAL_DATA.remove(onAdditionalDataLoaded);
		}
		
		private function onRefresh():void {
			if (waiting == true)
				return;
			showPreloader();
			topBar.showAnimationOverButton("refreshBtn", false);
			TweenMax.delayedCall(2, function():void {
				if (_isDisposing == true || _isDisposed == true)
					return;
				BotManager.getBotAdditionalData(botVO.uid);
			});
		}
		
		private function showPreloader(on:Boolean = true):void {
			if (on == true) {
				if (preloader == null) {
					preloader = new Preloader();
					preloader.x = Math.round(_width * .5);
					preloader.y = Math.round(_height * .5);
					_view.addChild(preloader);
				}
				preloader.show(false);
			} else if (preloader != null) {
				preloader.hide();
			}
			waiting = on;
			scrollPanel.view.alpha = on ? .1 : 1;
		}
		
		private function onChatButtonTap():void {
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.usersUIDs = [botVO.uid];
			chatScreenData.type = ChatInitType.USERS_IDS;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = data;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		private function onPayButtonTap():void {
			var giftData:GiftData = new GiftData();
			giftData.user = botVO.owner;
			giftData.type = GiftType.MONEY_TRANSFER;
			Gifts.startSendMoney(giftData);
		}
		
		private function onBlockButtonTap():void {
			var btn:BitmapButton;
			if (actionBlockUser.button != undefined)
				btn = actionBlockUser.button;
			if (btn != null)
				btn.deactivate();
			UsersManager.USER_BLOCK_CHANGED.add(onUserBlockStatusChanged);
			UsersManager.changeUserBlock(botVO.uid, (Auth.blocked != null && Auth.blocked.indexOf(botVO.uid) != -1) ? UserBlockStatusType.UNBLOCK : UserBlockStatusType.BLOCK);
		}
		
		private function onUserBlockStatusChanged(data:Object):void {
			UsersManager.USER_BLOCK_CHANGED.remove(onUserBlockStatusChanged);
			if (_isDisposed == true)
				return;
			var btn:BitmapButton;
			if (actionBlockUser.button != undefined)
				btn = actionBlockUser.button;
			if (btn == null)
				return;
			if (_isActivated == true)
				btn.activate();
			actionBlockUser.title = (data.status == UserBlockStatusType.BLOCK) ? Lang.unblockUser : actionBlockUser.title = Lang.blockUser;
			
			var iconL:DisplayObject;
			var iconR:DisplayObject;
			if (actionBlockUser.iconL != undefined && actionBlockUser.iconL != null) {
				iconL = new actionBlockUser.iconL();
				UI.scaleToFit(iconL, iconSize, iconSize);
			}
			if (actionBlockUser.iconR != undefined && actionBlockUser.iconR != null) {
				iconR = new actionBlockUser.iconR();
				UI.scaleToFit(iconR, iconArrowSize, iconArrowSize);
			}
			var ibmd:ImageBitmapData = UI.renderSettingsTextAdvanced(
				actionBlockUser.title,
				fitWidth,
				optionLineHeight,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.NONE,
				Config.FINGER_SIZE * 0.34,
				false,
				AppTheme.GREY_DARK,
				0,
				0,
				iconL,
				iconR
			);
			UI.destroy(iconL);
			UI.destroy(iconR);
			iconL = null;
			iconR = null;
			btn.setBitmapData(ibmd, true);
		}
		
		private function onBanButtonTap():void {
			PHP.admin911_ban(onBanResponse, botVO.uid, "");
		}
		
		private function onBanResponse(phpRespod:PHPRespond):void {
			if (phpRespod.error == true) {
				ToastMessage.display("User not banned");
				phpRespod.dispose();
			}
			ToastMessage.display("User banned");
			phpRespod.dispose();
		}
		
		private function onBanForeverButtonTap():void {
			PHP.admin911_banForever(onBanResponse, botVO.uid, "");
		}
		
		private function onBanForeverResponse(phpRespod:PHPRespond):void {
			if (phpRespod.error == true) {
				ToastMessage.display("User not banned");
				phpRespod.dispose();
			}
			ToastMessage.display("User banned forever");
			phpRespod.dispose();
		}
		
		private function openOwnerProfile(...rest):void {
			MobileGui.changeMainScreen(
				UserProfileScreen,
				{
					data:botVO.owner,
					backScreen:MobileGui.centerScreen.currentScreenClass,
					backScreenData:this.data
				}
			);
		}
	}
}