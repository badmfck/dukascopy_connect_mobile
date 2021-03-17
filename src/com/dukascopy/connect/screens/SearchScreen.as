package com.dukascopy.connect.screens {
import com.adobe.utils.StringUtil;
import com.dukascopy.connect.Config;
import com.dukascopy.connect.MobileGui;
import com.dukascopy.connect.gui.input.Input;
import com.dukascopy.connect.gui.lightbox.UI;
import com.dukascopy.connect.gui.list.List;
import com.dukascopy.connect.gui.list.renderers.ListContact;
import com.dukascopy.connect.gui.menuVideo.BitmapButton;
import com.dukascopy.connect.gui.preloader.Preloader;
import com.dukascopy.connect.screens.base.BaseScreen;
import com.dukascopy.connect.sys.assets.Assets;
import com.dukascopy.connect.sys.echo.echo;
import com.dukascopy.connect.sys.imageManager.ImageManager;
import com.dukascopy.connect.sys.php.PHP;
import com.dukascopy.connect.sys.php.PHPRespond;
import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
import com.dukascopy.connect.sys.swiper.Swiper;
import com.dukascopy.connect.type.ChatInitType;
import com.dukascopy.connect.vo.screen.ChatScreenData;
import com.dukascopy.connect.vo.users.adds.ContactVO;
import com.greensock.TweenMax;

import flash.desktop.NativeApplication;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.TimerEvent;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;

/**
	 * ...
	 * @author ...
	 */
	public class SearchScreen extends BaseScreen {
		
		//private var btnBack:Sprite;
		private var bg:Sprite;
		private var boxTop:Sprite;
		private var boxTopBG:Bitmap;
		//private var topTF:TextField;
		
		private var titleBitmap:Bitmap;
		
		private var input:Input;
		private var list:List;
		//private var searchTimer:Timer;
		private var topHeight:int;
		private var trueHeight:int;
		private var preloader:Preloader;
		private var swiper:Swiper;
		private var backButton:BitmapButton;
		private var BACK_BMD:BitmapData;
		
		private var lastSearchValue:String = "";
		
		public function SearchScreen() {}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			backButton.show(.3, .6);		
		}
		
		override protected function createView():void {
			super.createView();
			
			bg = new Sprite();
			bg.graphics.beginFill(0xF5F5F5);
			bg.graphics.drawRect(0, 0, 11, 11);
			_view.addChild(bg);
			
			topHeight = Config.FINGER_SIZE * 1.5;
			
			list = new List("SearchList");
			list.setStartVerticalSpace(topHeight + Config.FINGER_SIZE);
			_view.addChild(list.view);
			
			var topBarBtnSize:int = Config.FINGER_SIZE * .5;
			
			boxTop = new Sprite();
			_view.addChild(boxTop);
			
			boxTopBG = new Bitmap(Assets.getAsset(Assets.BG_SEARCH));
			boxTop.addChild(boxTopBG);
			
			
			var destX:int = Config.DOUBLE_MARGIN;
			var destY:int = Config.APPLE_TOP_OFFSET + Math.round((Config.FINGER_SIZE - topBarBtnSize) * .5);
			
			var tempBMD:BitmapData = Assets.getAsset(Assets.ICON_LEFT, 0xFFFFFF);
			var neededScale:Number = topBarBtnSize / tempBMD.width;			
			BACK_BMD = UI.scaleManual(tempBMD, neededScale);
			//BACK_BMD = Assets.getAsset(Assets.ICON_LEFT, 0xFFFFFF);
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setBitmapData(BACK_BMD,false);
			backButton.setOverflow(destY, destX, Config.FINGER_SIZE,topHeight-BACK_BMD.height - destY );		
			backButton.x =destX;
			backButton.y = destY;
			backButton.hide();
			backButton.tapCallback = onBack;
			boxTop.addChild(backButton);
			
			titleBitmap = new Bitmap();
			titleBitmap.bitmapData = UI.renderTextShadowed("Users search", 300, Config.FINGER_SIZE, false, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .38,false,0x84251b,0x000000,0xffffff,true,2, true);
			titleBitmap.y = Config.APPLE_TOP_OFFSET + int((Config.FINGER_SIZE - titleBitmap.height) * .5);
			boxTop.addChild(titleBitmap);
			
			input = new Input();
			input.setMode(Input.MODE_INPUT);
			input.setLabelText("Search...");
			input.setBorderVisibility(false);
			input.view.y =topHeight + int((Config.FINGER_SIZE - input.view.height) * .5);
			input.view.x = Config.DOUBLE_MARGIN;
			boxTop.addChild(input.view);
			
			list.S_STOP_UPPER_CONTENT.add(onListStopUpperContent);
			list.S_SHOW_UPPER_CONTENT.add(onListShowUpperContent);
			list.S_HIDE_UPPER_CONTENT.add(onListHideUpperContent);
					
			swiper = new Swiper("SearchScreen");
			swiper.S_ON_SWIPE.add(onSwipe);
		}
		
		private function onSwipe(direction:String):void {
			if (direction != Swiper.DIRECTION_RIGHT)
				return;
			MobileGui.centerScreen.show(MainScreen, null, 1);
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			swiper.activate();
			input.activate();
			backButton.activate();
			//PointerManager.addTap(btnBack, onBtnBack);
			input.S_CHANGED.add(onInputValueChanged);
			onInputValueChanged();
			list.activate();
			list.S_ITEM_TAP.add(onItemTap);
			
			input.getTextField().addEventListener(FocusEvent.FOCUS_IN, onListShowUpperContent);
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onListShowUpperContent);
		}
		
		private function onRespond(phpRespond:PHPRespond):void {
			hidePreloader();
			if (list == null) {	// Disposed
				phpRespond.dispose();
				return;
			}
			if (phpRespond.error == true) {
				echo("SearchScreen", "onRespond", "Error: " + phpRespond.errorMsg);
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data!=null && phpRespond.data.length == 0) {
				echo("SearchScreen", "onRespond", "Data is empty");
				if (list != null) {
					list.setData(null, ListContact);
				}
			} else {
				var dta:Array = [];
				for (var i:int = 0; i < phpRespond.data.length; i++)
					dta.push(new ContactVO(phpRespond.data[i]));
				list.setData(dta, ListContact, ["avatarURL"]);
				list.tapperInstance.setBounds([_width, _height - topHeight - Config.FINGER_SIZE, 0, topHeight + Config.FINGER_SIZE]);
				boxTop.y = 0;
				dta = null;
			}
			phpRespond.dispose();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			SoftKeyboard.closeKeyboard();
			super.deactivateScreen();
			swiper.deactivate();
			//PointerManager.removeTap(btnBack, onBtnBack);
			backButton.deactivate();
			input.deactivate();
			input.S_CHANGED.remove(onInputValueChanged);
			TweenMax.killDelayedCallsTo(doSearch);
			lastSearchValue = "";
			list.deactivate();
			list.S_ITEM_TAP.remove(onItemTap);
			
			input.getTextField().removeEventListener(FocusEvent.FOCUS_IN, onListShowUpperContent);
			NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE, onListShowUpperContent);
		}
		
		private function onItemTap(data:Object, n:int):void {
			var chatScreenData:ChatScreenData = new ChatScreenData();
				chatScreenData.usersUIDs = [data.uid];
				chatScreenData.type = ChatInitType.USERS_IDS;
				chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
				chatScreenData.backScreenData = data;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		private function onInputValueChanged():void {
			var searchValue:String = StringUtil.trim(input.value);
			var curLenght:int = searchValue.length;	
			if (curLenght > 2 && searchValue != "Search..." /*&& lastSearchValue != searchValue */) {					
				lastSearchValue = searchValue;
				showPreloader();
				TweenMax.killDelayedCallsTo(doSearch);
				TweenMax.delayedCall(1, doSearch);			
			} else {
				if (list != null) {
					list.setData(null, ListContact);
				}
				hidePreloader(); // not valid search value 
			}			
		}
		
		private function doSearch(e:TimerEvent = null):void {
			echo("SearchScreen", "doSearch");	
			var searchValue:String = StringUtil.trim(input.value);
			var curLenght:int = searchValue.length;	
			if (curLenght > 2 && searchValue != "Search...") {					
				lastSearchValue = searchValue;
				PHP.search_all(onRespond, lastSearchValue);						
			} else {	
				// current value is not valid for search 
				hidePreloader();
				TweenMax.killDelayedCallsTo(doSearch);
			}		
		}
		
		override public function onBack(e:Event = null):void {
			MobileGui.changeMainScreen(MainScreen, null, 1);
		}
		
		private function onListStopUpperContent(y:int):void {
			if (list.innerHeight - topHeight < trueHeight)
				return;
			TweenMax.killTweensOf(boxTop);
			boxTop.y = y;
			if (boxTop.y == -topHeight)
				list.tapperInstance.setBounds([_width, _height - Config.FINGER_SIZE, 0, Config.FINGER_SIZE]);
			else
				list.tapperInstance.setBounds([_width, _height - topHeight - Config.FINGER_SIZE, 0, topHeight + Config.FINGER_SIZE]);
		}
		
		private function onListHideUpperContent():void {
			if (list.innerHeight - topHeight < trueHeight)
				return;
			TweenMax.killTweensOf(boxTop);
			TweenMax.to(boxTop, 12, { y: -topHeight, useFrames:true});
			list.tapperInstance.setBounds([_width, _height - Config.FINGER_SIZE, 0, Config.FINGER_SIZE]);
			swiper.setBounds(_width,_height,list.view);
		}
		 
		private function onListShowUpperContent(e:Event = null):void {
			if (list.innerHeight - topHeight < trueHeight)
				return;
			TweenMax.killTweensOf(boxTop);
			TweenMax.to(boxTop, 12, { y:0, useFrames:true});
			list.tapperInstance.setBounds([_width, _height - topHeight - Config.FINGER_SIZE, 0, topHeight + Config.FINGER_SIZE]);
			swiper.setBounds(_width,_height- boxTop.height,list.view,0,boxTop.height);
		}
		
		override protected function drawView():void {
			trueHeight =  _height;
			bg.width = _width;
			bg.height = _height;
			
			ImageManager.resizeBitmap(boxTopBG, _width, topHeight, ImageManager.SCALE_PORPORTIONAL);
			boxTopBG.y = topHeight - boxTopBG.height;
			
			boxTop.graphics.clear();
			boxTop.graphics.beginFill(0xFF0000);
			boxTop.graphics.drawRect(0, 0, _width, topHeight);
			boxTop.graphics.beginFill(0xFFFFFF);
			boxTop.graphics.drawRect(0, topHeight, _width, Config.FINGER_SIZE - 1);
			boxTop.graphics.beginFill(0, .3);
			boxTop.graphics.drawRect(0, topHeight + Config.FINGER_SIZE - 1, _width, 1);
			boxTop.graphics.endFill();
			
			titleBitmap.x = (_width - titleBitmap.width) * .5;
			
			input.width = _width - Config.DOUBLE_MARGIN * 2;
			
			list.setWidthAndHeight(_width, _height);
			if (boxTop.y == -topHeight)
				list.tapperInstance.setBounds([_width, _height /*- Config.FINGER_SIZE*/, 0, Config.FINGER_SIZE]);
			else
				list.tapperInstance.setBounds([_width, _height - topHeight - Config.FINGER_SIZE, 0, topHeight + Config.FINGER_SIZE]);
			setPreloaderCoords();
			
			swiper.setBounds(_width, _height - boxTop.height, list.view, 0, boxTop.height);	
		}
		
		override public function dispose():void {
			super.dispose();
			
			//if (searchInput != null) {
				//searchInput.dispose();
				//searchInput = null;
			//}
			list.S_STOP_UPPER_CONTENT.remove(onListStopUpperContent);
			list.S_SHOW_UPPER_CONTENT.remove(onListShowUpperContent);
			list.S_HIDE_UPPER_CONTENT.remove(onListHideUpperContent);
			
			if (backButton != null)	{
				backButton.dispose();
				backButton = null;
			}
			
			if (titleBitmap != null){
				UI.destroy(titleBitmap);
				titleBitmap = null;
			}
			//if (btnBack != null)
				//btnBack.graphics.clear();
			//btnBack = null;
			if (bg != null)
				bg.graphics.clear();
			bg = null;
			if (boxTop != null)
				boxTop.graphics.clear();
			boxTop = null;
			//if (topTF != null)
				//topTF.text = "";
			//topTF = null;
			if (input != null)
				input.dispose();
			input = null;
			if (list != null)
				list.dispose();
			list = null;
			//if (searchTimer != null)
				//searchTimer.reset();
			//searchTimer = null;
			if (boxTopBG != null && boxTopBG.bitmapData != null) {
				boxTopBG.bitmapData.dispose();
				boxTopBG.bitmapData = null;
			}
			if (swiper != null)
				swiper.dispose();
			swiper = null;
			boxTopBG = null;
			hidePreloader();
		}
		
		private function showPreloader():void {
			if (preloader == null)
				preloader = new Preloader();
			_view.addChild(preloader);
			preloader.show(false);
			setPreloaderCoords();
		}
		
		private function hidePreloader():void {
			if (preloader != null)
				preloader.hide();
		}
		
		private function setPreloaderCoords():void {
			if (preloader != null) {
				preloader.x = _width * .5;
				preloader.y = (_height + list.getStartVerticalSpace()) * .5;
			}
		}
	}
}