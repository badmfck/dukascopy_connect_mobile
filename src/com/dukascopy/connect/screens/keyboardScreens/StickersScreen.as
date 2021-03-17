package com.dukascopy.connect.screens.keyboardScreens {

	import assets.IconSmileGroup1;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.style.Style;
	import com.telefision.sys.signals.Signal;

	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.tabs.NewTabs;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.keyboardScreens.InnerStickerScreen1;
	import com.dukascopy.connect.screens.keyboardScreens.InnerStickerScreen2;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.stickerManager.StickerManager;
	import com.dukascopy.connect.sys.swiper.Swiper;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.type.StickersGroupName;
	import com.greensock.TweenMax;

	import flash.display.Shape;
	import flash.geom.Point;

	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class StickersScreen extends BaseScreen {
		
		public static var S_STICKER_PRESSED:Signal = new Signal("StickersScreen.S_STICKER_PRESSED");
		
		private var images:Array;
		private var imagesLoadingCount:uint;
		private var preloader:Preloader;
		private var cantSend:Boolean;
		
		private var bg:Shape;
		private var stickersGroupsBG:Shape;
		private var stickersGroups:NewTabs;
		private var stickersSM:ScreenManager;
		private var activated:Boolean;
		
		private var screenClass:Class = InnerStickerScreen1;
		private var id:String = "";
		
		private var swiper:Swiper;
		private var recentShowing:Boolean = false;
		
		public function StickersScreen() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, 0, 1, 1);
				bg.graphics.endFill();
			_view.addChild(bg);
			stickersSM = new ScreenManager("Stickers");
				stickersSM.setBackground(false);
			_view.addChild(stickersSM.view);
			stickersGroupsBG = new Shape();
				stickersGroupsBG.graphics.beginFill(Style.color(Style.COLOR_STICKERS_MENU_BACKGROUND));
				stickersGroupsBG.graphics.drawRect(0, 0, 1, 1);
				stickersGroupsBG.graphics.endFill();
			_view.addChild(stickersGroupsBG);
			
			swiper = new Swiper("StickersScreen");
		}
		
		private function dellayedStickersGet():void {
			echo("StickersScreen", "dellayedStickersGet");
			StickerManager.S_STICKERS.add(drawStickers);
			StickerManager.getStickers();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			if (images == null){
				TweenMax.killDelayedCallsTo(dellayedStickersGet);
				TweenMax.delayedCall(30, dellayedStickersGet, [], true);
			}
			
			if (data != null && data.showRecent == true && stickersGroups != null && StickerManager.recentStickers != null && StickerManager.recentStickers.length > 0)
				onStickerGroupSelected("0");
			
			_params.doDisposeAfterClose = false;
			
			bg.width = _width;
			bg.height = _height;
			stickersGroupsBG.width = _width;
			stickersGroupsBG.height = int(Config.FINGER_SIZE * .85 + 2);
			stickersSM.view.y = stickersGroupsBG.height;
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			bg.width = _width;
			bg.height = _height;
			stickersGroupsBG.width = _width;
			stickersSM.setSize(_width, _height - stickersGroupsBG.height);
			if (stickersGroups != null)
				stickersGroups.setWidthAndHeight(_width, Config.FINGER_SIZE * .85);
			setPreloaderCoords();
		}
		
		override public function updateBounds():void {
			if (stickersGroups != null)
				stickersGroups.tapper.setBounds([_width, stickersGroups.height, 0, stickersGroups.view.localToGlobal(new Point()).y]);
			if (swiper != null)
				swiper.setBounds(_width, stickersSM.view.height, MobileGui.stage, 0, stickersSM.view.localToGlobal(new Point()).y);
			if (stickersSM != null && stickersSM.currentScreen != null)
				stickersSM.currentScreen.updateBounds();
		}
		
		private function onStickerGroupSelected(id:String):void {
			ImageManager.disposeCurrentStickers();
			if (id == this.id)
				return;
			if (id == "0") {
				stickersSM.show(screenClass, StickerManager.recentStickers, 1, recentShowing ? 0 : .3);
				recentShowing = false;
			} else {
				var stickers:Array = null;
				var groups:Array = StickerManager.getAllStickers();
				for (var i:int = 0; i < groups.length; i++) {
					if (groups[i].name == images[int(id) - 1][2]) {
						stickers = groups[i].stickers;
						break;
					}
				}
				
				stickers = sortStickers((images[int(id) - 1][2]), stickers);
				
				if (screenClass == InnerStickerScreen1)
					screenClass = InnerStickerScreen2;
				else
					screenClass = InnerStickerScreen1;
				stickersSM.show(screenClass, stickers, (id > this.id) ? 0 : 1);
			}
			this.id = id;
			stickersGroups.busy = true;
		}
		
		private function sortStickers(groupName:String, stickers:Array):Array {
			if (!stickers)
				return null;
			if (groupName == StickersGroupName.REGULAR || 
				groupName == StickersGroupName.DOG || 
				groupName == StickersGroupName.BOY || 
				groupName == StickersGroupName.GIRL || 
				groupName == StickersGroupName.CAT ||
				groupName == StickersGroupName.COW || 
				groupName == StickersGroupName.GESTURES ||
				groupName == StickersGroupName.ADULT)
				return stickers.sortOn("sort", Array.NUMERIC);
			return stickers;
		}
		
		override public function activateScreen():void {
			activated = true;
			if (stickersGroups != null) {
				stickersGroups.activate();
				stickersGroups.tapper.setBounds([_width, stickersGroups.height, 0, stickersGroups.view.localToGlobal(new Point()).y]);
				if (stickersGroups.S_ITEM_SELECTED != null)
					stickersGroups.S_ITEM_SELECTED.add(onStickerGroupSelected);
			}
			if (stickersSM != null) {
				stickersSM.S_COMPLETE_SHOW.add(setBusy);
				stickersSM.activate();
			}
			if (swiper != null) {
				swiper.S_ON_SWIPE.add(onSwipe);
				swiper.activate();
				swiper.setBounds(_width, stickersSM.view.height, MobileGui.stage, 0, stickersSM.view.localToGlobal(new Point()).y);
			}
			setBusy(null);
		}
		
		override public function deactivateScreen():void {
			activated = false;
			StickerManager.S_STICKERS.remove(drawStickers);
			if (stickersGroups != null) {
				stickersGroups.deactivate();
				if (stickersGroups.S_ITEM_SELECTED != null)
					stickersGroups.S_ITEM_SELECTED.remove(onStickerGroupSelected);
			}
			if (stickersSM != null) {
				stickersSM.S_COMPLETE_SHOW.remove(setBusy);
				stickersSM.deactivate();
			}
			if (swiper != null) {
				swiper.deactivate();
				swiper.S_ON_SWIPE.remove(onSwipe);
			}
		}
		
		private function onSwipe(direction:String):void {
			if (stickersGroups == null || stickersGroups.busy == true)
				return;
			var tabIndex:int = int(id);
			if (direction == Swiper.DIRECTION_RIGHT) {
				if (tabIndex == 0)
					return;
				tabIndex--;
			} else if (direction == Swiper.DIRECTION_LEFT) {
				if (tabIndex == stickersGroups.getLastIndex())
					return;
				tabIndex++;
			} else
				return;
			stickersGroups.updateSelected(tabIndex);
		}
		
		private function setBusy(cls:Class):void {
			if (stickersGroups == null)
				return;
			stickersGroups.busy = false;
		}
		
		private function drawStickers():void {
			showPreloader();
			clear();
			var groups:Array = StickerManager.getAllStickers();
			imagesLoadingCount = groups.length;
			for (var i:int = 0; i < imagesLoadingCount; i++) {
				images ||= [];
				//!TODO:remove when real "adult" stickers will be avaliable from server; discreasing loadCounter - image
				//if (groups[i].name == StikerGroupType.STIKER_GROUP_ADULT)
				//imagesLoadingCount--;
				
				images.push([StickerManager.getGroupIcon(i, onImageLoaded), null, groups[i].name]);
			}
		}
		
		private function onImageLoaded(link:String, image:ImageBitmapData):void {
			if (_isDisposed)
				return;
			var i:int;
			for (i = 0; i < images.length; i++) {
				//!TODO: better to use group id as key?;
				if (images[i][0] == link) {
					images[i][1] = image;
					imagesLoadingCount--;
				}
			}
			if (imagesLoadingCount == 0) {
				hidePreloader();
				stickersGroups = new NewTabs();
				stickersGroups.view.y = 2;
				_view.addChild(stickersGroups.view);
				var bool:Boolean = (stickersGroups != null && StickerManager.recentStickers != null && StickerManager.recentStickers.length > 0);
				stickersGroups.add(null, 0 + "", bool, new IconSmileGroup1());
				for (i = 0; i < images.length; i++)
					stickersGroups.add(null, (i + 1) + "", (i == 0) ? !bool : false, null, images[i][1]);
				stickersGroups.setWidthAndHeight(_width, Config.FINGER_SIZE * .85);
				stickersGroupsBG.width = _width;
				stickersGroupsBG.height = stickersGroups.height + 2;
				stickersSM.view.y = stickersGroupsBG.height;
				var trueH:int = _height - stickersGroupsBG.height;
				stickersSM.setSize(_width, trueH);
				swiper.setBounds(_width, trueH, MobileGui.stage, 0, stickersSM.view.localToGlobal(new Point()).y);
				if (activated) {
					stickersGroups.activate();
					stickersGroups.S_ITEM_SELECTED.add(onStickerGroupSelected);
					stickersGroups.tapper.setBounds([_width, stickersGroups.height, 0, stickersGroups.view.localToGlobal(new Point()).y]);
				}
				if (bool)
					onStickerGroupSelected("0");
				else
					onStickerGroupSelected("1");
			}
		}
		
		private function clear():void {
			
			ImageManager.disposeCurrentStickers();
			
			if (stickersGroups != null)
				stickersGroups.dispose();
			stickersGroups = null;
			if (images != null) {
				while (images.length > 0) {
					if (images[0] == null) {
						images.splice(0, 1);
						continue;
					}
					if (images[0][0] != "")
						ImageManager.unloadImage(images[0][0]);
					images[0][0] = "";
					if (images[0][1] != null)
						images[0][1].dispose();
					images[0][1] = null;
					images[0][2] = "";
					images[0] = null;
					images.splice(0, 1);
				}
				images = null;
			}
		}
		
		override public function dispose():void {
			
			clear();
			
			super.dispose();
			TweenMax.killDelayedCallsTo(dellayedStickersGet);
			StickerManager.S_STICKERS.remove(drawStickers);
			if (stickersGroups != null) {
				stickersGroups.S_ITEM_SELECTED.remove(onStickerGroupSelected);
				stickersGroups.dispose();
			}
			stickersGroups = null;
			if (stickersSM != null)
				stickersSM.dispose();
			stickersSM = null;
			
			if (preloader != null) {
				hidePreloader();
				preloader.dispose();
			}
			preloader = null;
			
			if (swiper != null)
				swiper.dispose();
			swiper = null;
			
			StickerManager.saveRecentToStore();
		}
		
		private function showPreloader():void {
			if (preloader == null)
				preloader = new Preloader();
			_view.addChild(preloader);
			preloader.show();
			setPreloaderCoords();
		}
		
		private function hidePreloader():void {
			if (preloader != null)
				preloader.hide();
		}
		
		private function setPreloaderCoords():void {
			if (preloader != null) {
				preloader.x = _width * .5;
				preloader.y = _height * .5;
			}
		}
		
		public function showRecent():void {
			if (id == "0")
				return;
			if (stickersGroups != null && StickerManager.recentStickers != null && StickerManager.recentStickers.length > 0) {
				recentShowing = true;
				stickersGroups.updateSelected(0);
				if (activated == false)
					onStickerGroupSelected("0");
			}
		}
	}
}