package com.dukascopy.connect.screens {
	
	import assets.HeaderImage911;
	import assets.IconAttention2;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.megaText.TextCell;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsStatisticsManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.QuestionsStatVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Pavel Karpov. Telefision TEAM Kiev.
	 */
	
	public class UserQuestionsStatScreen extends BaseScreen {
		
		private const actions:Array = [ { id:"refreshBtn", img:Style.icon(Style.ICON_REFRESH), callback:onRefresh } ];
		private const avaSize:int = Config.FINGER_SIZE * 1.8;
		private const lineColor:uint = Style.color(Style.COLOR_LINE);
		private var topBar:TopBarScreen;
		private var scrollPanel:ScrollPanel;
		private var avatarBox:Sprite;
		private var LOADED_AVATAR_BMD:ImageBitmapData;
		private var EMPTY_AVATAR_BMD:ImageBitmapData;
		private var avatarBitmap:Bitmap;
	//	private var avaBgImage:HeaderImage911;
		private var avaBgBitmap:Bitmap;
		private var bannedLabel:Bitmap;
		private var bannedImage:Bitmap;
		private var FXNameBitmap:Bitmap;
		private var userNameBitmap:Bitmap;
		private var infoBox:Sprite;
		private var infoBoxBG:Shape;
		private var textCells:Object;
		private var preloader:Preloader;
		private var oldW:int;
		private var oldH:int;
		private var maxWidthTextCell:int;
		private var currentY:int;
		private var _hash:String = "";
		private var _waiting:Boolean;
		private var lastLoadedImageName:String;
		private var availableWidth:int; 
		private var halfWidth:int;
		private var tabCells:Array = ["answers", "questions", "accepted", "abuse", "spam", "block", "alarms"];
		private	var maxValueWidth:int = 0;
		
		private var currentUser:UserVO;
		
		private var needUpdate:Boolean = false;
		
		public function UserQuestionsStatScreen() {	}
		
		override protected function createView():void {
			super.createView();
			topBar = new TopBarScreen();
			avatarBox = new Sprite();
			scrollPanel = new ScrollPanel();
		//	avaBgImage = new HeaderImage911();
			avaBgBitmap = new Bitmap(null, "auto", true);
			avatarBitmap = new Bitmap(null, "auto", true);
			view.addChild(avaBgBitmap);
			avatarBox.addChild(avatarBitmap);
			
			infoBoxBG = new Shape();
			infoBoxBG.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			infoBoxBG.graphics.drawRect(0, 0, 10, 10);
			infoBox = new Sprite();
			
			textCells = { };
			scrollPanel.addObject(infoBoxBG);
			scrollPanel.addObject(infoBox);
			scrollPanel.addObject(avatarBox);
			scrollPanel.background = false;
			scrollPanel.view.y = topBar.trueHeight;
			avaBgBitmap.y = topBar.trueHeight;
			view.addChild(scrollPanel.view);
			_view.addChild(topBar);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			EMPTY_AVATAR_BMD ||= UI.drawAssetToRoundRect(new SWFEmptyAvatar(), avaSize);
			_params.doDisposeAfterClose = true;
			topBar.setData(Lang.text911statistic, true, actions);
			updateAvatarBMD();
			
			if (data != null && "userUID" in data && data.userUID != null && data.userUID != "")
				currentUser = UsersManager.getFullUserData(data.userUID);
			
			var path:String;
			var imageCache:ImageBitmapData;
			if (currentUser == null) {
				if (Auth.avatar != null) {
					path = Auth.getLargeAvatar(avaSize);
					imageCache = ImageManager.getImageFromCache(path);
					if (imageCache)
						onAvatarLoaded(path, imageCache);
				}
				if (Auth.hasFXName()) {
					FXNameBitmap = new Bitmap();
					FXNameBitmap.bitmapData = UI.renderText(Auth.getFXName(), 3000, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .36, false, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), true, "UserQuestionsStatScreen.FXNameBitmap");
					avatarBox.addChild(FXNameBitmap);
				}
				if (Auth.username != null) {
					userNameBitmap = new Bitmap();
					userNameBitmap.bitmapData = UI.renderText(Auth.login, 3000, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .24, false, Color.RED, Style.color(Style.COLOR_BACKGROUND), true, "UserQuestionsStatScreen.userNameBitmap");
					avatarBox.addChild(userNameBitmap);
				}
			} else {
				if (currentUser.getAvatarURL() != null) {
					path = currentUser.getAvatarURLProfile(avaSize * 2);
					imageCache = ImageManager.getImageFromCache(path);
					if (imageCache)
						onAvatarLoaded(path, imageCache);
				}
				if (currentUser.getDisplayName()) {
					FXNameBitmap = new Bitmap();
					FXNameBitmap.bitmapData = UI.renderText(currentUser.getDisplayName(), 3000, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .36, false, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), true, "UserQuestionsStatScreen.FXNameBitmap");
					avatarBox.addChild(FXNameBitmap);
				}
				if (currentUser.login != null) {
					userNameBitmap = new Bitmap();
					var loginStr:String;
					if (currentUser.fxID != 0)
						loginStr = currentUser.login;
					else
						loginStr = "user " + currentUser.md5sum;
					userNameBitmap.bitmapData = UI.renderText(loginStr, 3000, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .24, false, Color.RED, Style.color(Style.COLOR_BACKGROUND), true, "UserQuestionsStatScreen.userNameBitmap");
					avatarBox.addChild(userNameBitmap);
				}
			}
			createStatInfo();
			
			needUpdate = true;
		}
		
		override protected function drawView():void {
			var textWidth:int = _width - Config.DOUBLE_MARGIN * 2;
			if (oldW != _width || oldH != _height) {
				topBar.drawView(_width);
				availableWidth = _width - Config.FINGER_SIZE;
				halfWidth = _width * .5 - Config.FINGER_SIZE;
				currentY = Config.FINGER_SIZE * .44;
				/*if (oldW != _width) {
					var kf:Number = _width / avaBgImage.width;
					if (avaBgBitmap.bitmapData != null)
						avaBgBitmap.bitmapData.dispose();
					avaBgBitmap.bitmapData = new BitmapData(_width, Math.round(Config.FINGER_SIZE * 1.54), false, avaBgColor);
					avaBgBitmap.bitmapData.draw(avaBgImage, new Matrix(kf, 0, 0, kf, 0, Math.round(-30 * kf)), null, null, null, true);
				} */
				avatarBitmap.x = Math.round(_width - avaSize) * .5;
				avatarBitmap.y = currentY;
				currentY += avatarBitmap.height + Config.FINGER_SIZE * .18;
				if (FXNameBitmap != null) {
					FXNameBitmap.x = (_width - FXNameBitmap.width) * .5;
					FXNameBitmap.y = currentY;
					currentY += FXNameBitmap.height ;
				}
				if (userNameBitmap != null) {
					userNameBitmap.x = Math.round((_width - userNameBitmap.width) * .5);
					userNameBitmap.y = currentY;
					currentY += userNameBitmap.height;
				}
				scrollPanel.setWidthAndHeight(_width, _height - topBar.trueHeight);
				oldW = _width;
				oldH = _height;
				if (preloader != null) {
					preloader.x = Math.round(_width * .5);
					preloader.y = Math.round(_height * .5);
				}
				infoBox.y = currentY;
				scrollPanel.updateObjects();
				if (currentUser == null)
					drawStatInfo(QuestionsStatisticsManager.getMyStat(true));
				else
					drawStatInfo(QuestionsStatisticsManager.getUserStat(currentUser.uid, true));
				_view.graphics.clear();	
				_view.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				_view.graphics.drawRect(0, 0, _width, _height);
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			topBar.activate();
			scrollPanel.enable();
			if (currentUser == null) {
				QuestionsStatisticsManager.S_MY_STAT.add(onMyStat);
				if (QuestionsStatisticsManager.getMyStat(needUpdate == false).hash == null)
					drawStatInfo(QuestionsStatisticsManager.getMyStat());
			} else {
				QuestionsStatisticsManager.S_USER_STAT.add(onMyStat);
				if (QuestionsStatisticsManager.getUserStat(currentUser.uid, needUpdate == false).hash == null)
					drawStatInfo(QuestionsStatisticsManager.getUserStat(currentUser.uid));
			}
			
			var largeAvatar:String;
			if (currentUser != null)
				largeAvatar = currentUser.getAvatarURLProfile(avaSize * 2);
			else
				largeAvatar = Auth.avatar;
			if (!lastLoadedImageName && largeAvatar != null) {
				if (currentUser)
					ImageManager.loadImage(largeAvatar, onAvatarLoaded);
				else
					ImageManager.loadImage(Auth.getLargeAvatar(avaSize), onAvatarLoaded);
			}
			needUpdate = false;
			
			if (Config.ADMIN_UIDS.indexOf(Auth.uid) != -1)
				if (avatarBox != null && avatarBox.parent != null)
					PointerManager.addTap(avatarBox, copyToClipboard);
		}
		
		private function copyToClipboard(e:Event = null):void {
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, currentUser.uid + ";" + currentUser.md5sum);
			ToastMessage.display("copied");
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			QuestionsStatisticsManager.S_MY_STAT.remove(onMyStat);
			QuestionsStatisticsManager.S_USER_STAT.remove(onMyStat);
			topBar.deactivate();
			scrollPanel.disable();
			
			if (avatarBox != null && avatarBox.parent != null)
				PointerManager.removeTap(avatarBox, copyToClipboard);
		}
		
		override public function dispose():void {
			super.dispose();
			showPreloader(false);
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			UI.destroy(avatarBitmap);
			avatarBitmap = null;
			UI.destroy(avaBgBitmap);
			avaBgBitmap = null;
			UI.destroy(infoBoxBG);
			infoBoxBG = null;
			UI.destroy(FXNameBitmap);
			FXNameBitmap = null;
			UI.destroy(userNameBitmap);
			userNameBitmap = null;
			UI.destroy(bannedLabel);
			bannedLabel = null;
			UI.destroy(bannedImage);
			bannedImage = null;
			UI.disposeBMD(LOADED_AVATAR_BMD);
			LOADED_AVATAR_BMD = null;
			UI.disposeBMD(EMPTY_AVATAR_BMD);
			EMPTY_AVATAR_BMD = null;
		//	avaBgImage = null;
			for (var name:String in textCells)
				textCells[name].dispose();
			textCells = null;
			if (scrollPanel != null)
				scrollPanel.dispose();
			scrollPanel = null;
		}
		
		private function updateAvatarBMD():void {
			if (avatarBitmap == null)
				return;
			if (LOADED_AVATAR_BMD != null) {
				UI.disposeBMD(EMPTY_AVATAR_BMD);
				EMPTY_AVATAR_BMD = null;
				avatarBitmap.bitmapData = LOADED_AVATAR_BMD;
			} else {
				EMPTY_AVATAR_BMD ||= UI.drawAssetToRoundRect(new SWFEmptyAvatar(), avaSize);
				avatarBitmap.bitmapData = EMPTY_AVATAR_BMD;
			}
			scrollPanel.updateObjects();
		}
	
		private function onAvatarLoaded(url:String, bmd:ImageBitmapData):void {
			if (isDisposed)
				return;
			if (!bmd)
				return;
			LOADED_AVATAR_BMD ||= new ImageBitmapData("UserQuestionsStatScreen.LOADED_AVATAR_BMD", avaSize, avaSize);
			lastLoadedImageName = url;
			ImageManager.drawCircleImageToBitmap(LOADED_AVATAR_BMD, bmd, 0, 0, avaSize * .5);
			bmd = null;
			updateAvatarBMD();
		}
		
		private function onRefresh():void {
			if (_waiting)
				return;
			topBar.showAnimationOverButton("refreshBtn");
			showPreloader();
			if (currentUser == null)
				QuestionsStatisticsManager.getMyStat(false, true);
			else
				QuestionsStatisticsManager.getUserStat(currentUser.uid, false, true);
			_waiting = true;
		}
		
		private function onMyStat(...rest):void {
			_waiting = false;
			showPreloader(false);
			topBar.hideAnimation();
			if (currentUser == null)
				drawStatInfo(QuestionsStatisticsManager.getMyStat(true));
			else
				drawStatInfo(QuestionsStatisticsManager.getUserStat(currentUser.uid, true));
		}
		
		private function createStatInfo():void {
			/*if (currentUser == null) {
				createTextCell(Lang.rewardRightAnswer + ":", "rating");
				textCells["rating"].cellTuning( { complex:1 } );
				
				createTextCell(Lang.totalEarnings + ":", "received");
				textCells["received"].cellTuning( { complex:1 } );
				
				createTextCell(Lang.inPendingStatus + ":", "expected");
				textCells["expected"].cellTuning( { size:Math.round(Config.FINGER_SIZE * .27), color:0x78c046, complex:1 } );
			}*/
			
			createTextCell(Lang.textAnswers, "answers");
			createTextCell(Lang.textQuestions, "questions");
			
			createTextCell(Lang.rightAnswers, "accepted");
			textCells["accepted"].cellTuning( { color:Color.GREEN } );
			
			createTextCell(Lang.questionAuthorAbuseNum, "abuse");
			textCells["abuse"].cellTuning( { color:Color.RED } );
			
			createTextCell(Lang.textSpam, "spam");
			textCells["spam"].cellTuning( { color:Color.RED } );
			
			createTextCell(Lang.textBlocked, "block");
			textCells["block"].cellTuning( { color:Color.RED } );
			
			createTextCell(Lang.compliance, "alarms");
			textCells["alarms"].cellTuning( { color:Color.RED } );
		}
		
		private function createTextCell(text:String, name:String):void {
			var labelSettings:Object = { size:Math.round(Config.FINGER_SIZE * .23), color:Style.color(Style.COLOR_SUBTITLE) };
			var valueSettings:Object = { size:Math.round(Config.FINGER_SIZE * .47), color:Style.color(Style.COLOR_TEXT), complex:0 };
			var tc:TextCell = new TextCell(text, labelSettings, valueSettings);
			tc.name = name;
			textCells[name] = tc;
			infoBox.addChild(tc);
		}
		
		private function drawStatInfo(myStat:QuestionsStatVO):void {
			if (myStat.hash == _hash || _waiting)
				return;
			_hash = myStat.hash;
			var tc:TextCell;
			if (myStat.banned > 0) {
				if (textCells["banReason"] == null) {
					createTextCell(Lang.reasonForBan + ":", "banReason");
					textCells["banReason"].cellTuning( { size:Math.round(Config.FINGER_SIZE * .27) } );
				}
				if (bannedLabel == null)
					drawAllForBanned("Banned", new TextFormat("Tahoma", Math.round(Config.FINGER_SIZE * .3), 0xffffff));
			} else {
				if (textCells["banReason"] != null) {
					(textCells["banReason"] as TextCell).dispose();
					textCells["banReason"] = null;
					delete textCells["banReason"];
				}
				if (bannedLabel != null) {
					avatarBox.removeChild(bannedLabel);
					infoBox.removeChild(bannedImage);
				}
			}
			for (var name:String in textCells) {
				tc = TextCell(textCells[name]);
				if (myStat[tc.name] != null) {
					tc.cellTuning( { text:myStat[tc.name].toString() } );
				}
			}
			showStatInfo();
		}
			
		private function checkTabCellWidth(action:String = ""):Boolean {
			var tc:TextCell;
			var maxLabelWidth:int = 0;
			maxValueWidth = 0;
			var labelWidth:int = 0;
			var valueWidth:int = 0;
			var ll:int = tabCells.length;
			for (var i:int = 0; i < ll; i++) {
				tc = textCells[tabCells[i]];
				if (action == "setMultilineForLabel") {
					labelWidth = tc.setMultilineForLabel();
					valueWidth = tc.valueWidth;
				} else if (action == 'setSmallSizeForValue') {
					labelWidth = tc.labelWidth;
					valueWidth = tc.setSmallSizeForValue(Math.round(Config.FINGER_SIZE * .33));
				} else {
					labelWidth = tc.labelWidth;
					valueWidth = tc.valueWidth;
				}
				if (labelWidth > maxLabelWidth)
					maxLabelWidth = labelWidth ;
				if (valueWidth > maxValueWidth)
					maxValueWidth = valueWidth ;
			}
			var tt:int = maxLabelWidth + maxValueWidth;
			maxWidthTextCell = (tt > halfWidth) ? tt : 0;
			return (maxWidthTextCell > 0);
		}
		
		private function showStatInfo():void {
			var tc:TextCell;
			maxValueWidth = 0;
			if (checkTabCellWidth()) {
				if (checkTabCellWidth("setMultilineForLabel")) {
					checkTabCellWidth("setSmallSizeForValue");
				}
			}
			
			infoBox.graphics.clear();
			var grMatrix:Matrix = new Matrix();
            grMatrix.createGradientBox(_width, 40, 0, 0, 0);  
            infoBox.graphics.lineStyle(0, Style.color(Style.COLOR_LINE));
            infoBox.graphics.lineGradientStyle(GradientType.LINEAR, [lineColor, lineColor, lineColor], [0, 1, 0], [0, 128, 255], grMatrix);
            
			var marginLR:int = Config.FINGER_SIZE * .9;
			var marginC:int = Config.MARGIN;
			var dy:int = Config.FINGER_SIZE * .74;
			
			currentY = Config.FINGER_SIZE * .5;
			/*if (currentUser == null) {
				setPosition("rating", marginC, TextCell.ALIGN_BOTTOM, "CENTER");
				currentY += getDY("rating", .5);
				drawLine(Config.FINGER_SIZE, currentY, (_width - Config.FINGER_SIZE), currentY);
				currentY += Config.FINGER_SIZE * .4;
				
				setPosition("received", marginC, TextCell.ALIGN_BOTTOM, "CENTER");
				currentY += getDY("rating", .5);
				drawLine(Config.FINGER_SIZE, currentY, (_width - Config.FINGER_SIZE), currentY);
				currentY += getDY("rating", .4);
				
				setPosition("expected", marginC, TextCell.ALIGN_BOTTOM, "CENTER");
				currentY += getDY("expected", .5);
				infoBox.graphics.lineStyle(0, lineColor);
				drawLine(0, currentY , _width, currentY);
			}*/
			drawLine(0, currentY , _width, currentY);
			
			if (maxWidthTextCell == 0) {
				maxValueWidth += Config.FINGER_SIZE * .2;
				setPosition("answers", maxValueWidth, TextCell.TAB_LEFT, "TAB_LEFT", dy);
				setPosition("questions", maxValueWidth, TextCell.TAB_LEFT, "TAB_LEFT", dy);
				setPosition("accepted", maxValueWidth, TextCell.TAB_LEFT, "TAB_LEFT", dy);
				
				var linePos:int = currentY - dy * 3;
				
				
				currentY = textCells["answers"].y;
				setPosition("abuse", maxValueWidth, TextCell.TAB_LEFT, "TAB_RIGHT");
				setPosition("spam", maxValueWidth, TextCell.TAB_LEFT, "TAB_RIGHT", dy);
				setPosition("block", maxValueWidth, TextCell.TAB_LEFT, "TAB_RIGHT", dy);
				currentY = textCells["accepted"].y;
				setPosition("alarms", maxValueWidth, TextCell.TAB_LEFT, "TAB_RIGHT", dy);
				
				drawLine(_width * .5, linePos, _width * .5, Math.round(currentY + Config.FINGER_SIZE * .6));
			//	drawLine(_width * .5, currentY - dy * 3, _width * .5, Math.round(currentY += Config.FINGER_SIZE * .6));
			} else {
				maxValueWidth += Config.FINGER_SIZE * .1;
				setPosition("answers", maxValueWidth, TextCell.TAB_LEFT, "ONE_COLOMN", dy);
				setPosition("questions", maxValueWidth, TextCell.TAB_LEFT, "ONE_COLOMN", dy);
				setPosition("accepted", maxValueWidth, TextCell.TAB_LEFT, "ONE_COLOMN", dy);
				setPosition("abuse", maxValueWidth, TextCell.TAB_LEFT, "ONE_COLOMN", dy);
				setPosition("spam", maxValueWidth, TextCell.TAB_LEFT, "ONE_COLOMN", dy);
				setPosition("block", maxValueWidth, TextCell.TAB_LEFT, "ONE_COLOMN", dy);
				setPosition("alarms", maxValueWidth, TextCell.TAB_LEFT, "ONE_COLOMN", dy);
			}
			
			currentY += Config.FINGER_SIZE * .6;
			drawLine(0, currentY, _width, currentY);
			if (textCells["banReason"] != null) {
				setPosition("banReason", availableWidth, TextCell.COLOMN_LEFT, "LEFT", Math.round(Config.FINGER_SIZE * .5));
				avatarBox.addChild(bannedLabel);
				infoBox.addChild(bannedImage);
				bannedImage.x = _width - Config.FINGER_SIZE;
				bannedImage.y = currentY - Math.round(Config.FINGER_SIZE * .2);
				
				currentY += textCells["banReason"].height * .7;
				drawLine(0, currentY, _width, currentY);
			}
			infoBoxBG.y = avaBgBitmap.height;
			infoBoxBG.width = _width;
			infoBoxBG.height = infoBox.y + currentY + avatarBitmap.y - infoBoxBG.y;
			scrollPanel.updateObjects();
		}
		
		private function setPosition(name:String, space:int, align:String, align2:String, dy:int = 0):void {
			var tc:TextCell = textCells[name];
			if (tc == null)
				return;
			tc.setPositionLine(space, _width - Config.FINGER_SIZE, align);
			switch (align2) {
				case "CENTER": {
					tc.x = Math.round((_width - tc.width) * .5);
					break;
				}
				case "TAB_LEFT": {
					tc.x = Math.round(_width *.5 - Config.FINGER_SIZE * .4 - tc.width);
					break;
				}
				case "TAB_RIGHT": {
					tc.x = Math.round(_width - Config.FINGER_SIZE *.4 - tc.width);
					break;
				}
				case "ONE_COLOMN": {
					tc.x = Math.round((_width - maxWidthTextCell) * .5 + (maxWidthTextCell - tc.width));
					break;
				}
				case "LEFT": {
					tc.x = Math.round(Config.FINGER_SIZE * .5);
					break;
				}
			}
			currentY += dy;
			tc.y = currentY;
		}
		
		private function drawLine(x0:int, y0:int, x1:int, y1:int):void {
			infoBox.graphics.moveTo(x0, y0);
			infoBox.graphics.lineTo(x1, y1);
		}
		
		private function getDY(name:String, kf:Number):int {
			var tc:TextCell = textCells[name];
			return tc.isColomn ? tc.height + Config.MARGIN : Math.round(Config.FINGER_SIZE * kf);
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
			} else {
				if (preloader != null)
					preloader.hide();
			}
			infoBox.alpha = on ? .1 : 1;
		}
		
		private function drawAllForBanned(text:String, textFormat:TextFormat, angle:Number = -22, bgColor:uint = 0XCD3F43 ):void {
			const shadow:int = Config.FINGER_SIZE * .1;
			var ww:int = avaSize;
			var hh:int = Number(textFormat.size) * 1.5;
			var halfW:int = ww * .5;
			var halfH:int = hh * .5;

			var box:Sprite = new Sprite;
			var canvas:Sprite = new Sprite();
			var masK:Sprite = new Sprite();
			var tf:TextField = new TextField();
			
			canvas.graphics.beginFill(0x000000, .4);
			canvas.graphics.moveTo(0, hh);
			canvas.graphics.lineTo(ww, hh);
			canvas.graphics.lineTo(ww, hh + shadow);
			canvas.graphics.lineTo(0, hh);
			
			canvas.graphics.beginFill(bgColor, 1);
			canvas.graphics.drawRect(0, 0, ww , hh);
			
			masK.graphics.beginFill(0x00ff00);
			masK.graphics.drawCircle(halfW, halfH, halfW);
			
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = text;
			tf.setTextFormat(textFormat);
			tf.x = Math.round((ww - tf.textWidth) * .5); 
			canvas.addChild(tf);
			canvas.mask = masK;
			
			bannedLabel = new Bitmap(null, "auto", true);
			bannedLabel.bitmapData = new ImageBitmapData("banedLabel_1", ww, hh + shadow, true, 0x00000000);
			bannedLabel.bitmapData.draw(canvas);
			bannedLabel.smoothing = true;
			bannedLabel.rotation = angle;
			canvas.graphics.clear();
			
			var rr:Number = Math.sqrt(ww * ww + hh * hh) / 2;
			angle = Math.PI / 180 * angle + Math.atan2(hh, ww);
			bannedLabel.x = Math.round(avatarBitmap.x + halfW - rr * Math.cos(angle));
			bannedLabel.y = Math.round(avatarBitmap.y + halfW - rr * Math.sin(angle));
			
			bannedImage = new Bitmap(null, "auto", true);
			var img:IconAttention2 = new IconAttention2();
			hh = Config.FINGER_SIZE * .4;
			rr = hh/img.height;
			bannedImage.bitmapData = new ImageBitmapData("IconAttention2", hh, hh, false, 0xffffff);
			bannedImage.bitmapData.draw(img, new Matrix(rr, 0, 0, rr), null, null, null, true);
		}
	}
}