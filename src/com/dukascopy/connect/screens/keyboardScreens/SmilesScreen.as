package com.dukascopy.connect.screens.keyboardScreens {
	
	import assets.IconSmileGroup1;
	import assets.IconSmileGroup2;
	import assets.IconSmileGroup3;
	import assets.IconSmileGroup4;
	import assets.IconSmileGroup5;
	import assets.IconSmileGroup6;
	import assets.IconSmileGroup7;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.tabs.NewTabs;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.screens.keyboardScreens.InnerSmileScreen1;
	import com.dukascopy.connect.screens.keyboardScreens.InnerSmileScreen2;
	import com.dukascopy.connect.sys.richTextField.RichTextSmilesCodes;
	import com.dukascopy.connect.sys.swiper.Swiper;
	import com.dukascopy.connect.type.MainColors;
	import flash.display.Shape;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class SmilesScreen extends BaseScreen {
		
		private var bg:Shape;
		private var smilesGroupsBG:Shape;
		private var smilesGroups:NewTabs;
		private var smilesSM:ScreenManager;
		private var activated:Boolean;
		
		private var screenClass:Class = InnerSmileScreen1;
		private var id:String = "";
		
		private var swiper:Swiper;
		private var recentShowing:Boolean = false;
		
		public function SmilesScreen() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			
			
			bg = new Shape();
				bg.graphics.beginFill(MainColors.WHITE);
				bg.graphics.drawRect(0, 0, 1, 1);
				bg.graphics.endFill();
			_view.addChild(bg);
			smilesSM = new ScreenManager("Smiles");
				smilesSM.setBackground(false);
			_view.addChild(smilesSM.view);
			smilesGroupsBG = new Shape();
				smilesGroupsBG.graphics.beginFill(0xECEEEF);
				smilesGroupsBG.graphics.drawRect(0, 0, 1, 1);
				smilesGroupsBG.graphics.endFill();
			_view.addChild(smilesGroupsBG);
			
			smilesGroups = new NewTabs();
			smilesGroups.view.y = 2;
			
			if (RichTextSmilesCodes.recentSmiles.length == 0) {
				smilesGroups.add(null, 0 + "", false, new IconSmileGroup1());
				smilesGroups.add(null, 1 + "", true, new IconSmileGroup2());
				id = "1";
				smilesSM.show(screenClass, RichTextSmilesCodes.emojiCategories["0"]);
			} else {
				smilesGroups.add(null, 0 + "", true, new IconSmileGroup1());
				smilesGroups.add(null, 1 + "", false, new IconSmileGroup2());
				id = "0";
				smilesSM.show(screenClass, RichTextSmilesCodes.recentSmiles);
			}
			smilesGroups.add(null, 2 + "", false, new IconSmileGroup3());
			smilesGroups.add(null, 3 + "", false, new IconSmileGroup4());
			smilesGroups.add(null, 4 + "", false, new IconSmileGroup5());
			smilesGroups.add(null, 5 + "", false, new IconSmileGroup6());
			smilesGroups.add(null, 6 + "", false, new IconSmileGroup7());
			
			_view.addChild(smilesGroups.view);
			
			swiper = new Swiper("SmilesScreen");
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			_params.doDisposeAfterClose = false;
			
			bg.width = _width;
			bg.height = _height;
			
			smilesGroupsBG.width = _width;
			smilesGroupsBG.height = smilesGroups.height + 2;
		}
		
		override protected function drawView():void {
			smilesGroups.setWidthAndHeight(_width, Config.FINGER_SIZE * .85);
			
			bg.width = _width;
			bg.height = _height;
			
			smilesGroupsBG.width = _width;
			smilesGroupsBG.height = smilesGroups.height + 2;
			
			smilesSM.view.y = smilesGroupsBG.height;
			smilesSM.setSize(_width, _height - smilesGroupsBG.height);
		}
		
		override public function updateBounds():void {
			if (smilesGroups != null)
				smilesGroups.tapper.setBounds([_width, smilesGroups.height, 0, smilesGroups.view.localToGlobal(new Point()).y]);
			if (swiper != null)
				swiper.setBounds(_width, smilesSM.view.height, MobileGui.stage, 0, smilesSM.view.localToGlobal(new Point()).y);
			if (smilesSM != null && smilesSM.currentScreen != null)
				smilesSM.currentScreen.updateBounds();
		}
		
		private function onSmilesGroupSelected(id:String):void {
			if (id == this.id)
				return;
			if (screenClass == InnerSmileScreen1)
				screenClass = InnerSmileScreen2;
			else
				screenClass = InnerSmileScreen1;
			if (id == "0") {
				smilesSM.show(screenClass, RichTextSmilesCodes.recentSmiles, 1, recentShowing ? 0 : .3);
				recentShowing = false;
			} else {
				smilesSM.show(screenClass, RichTextSmilesCodes.emojiCategories[int(id) -1], (id > this.id) ? 0 : 1);
			}
			this.id = id;
			smilesGroups.busy = true;
		}
		
		override public function activateScreen():void {
			activated = true;
			
			if (smilesGroups != null) {
				smilesGroups.activate();
				if (smilesGroups.S_ITEM_SELECTED != null)
					smilesGroups.S_ITEM_SELECTED.add(onSmilesGroupSelected);
				smilesGroups.tapper.setBounds([_width, smilesGroups.height, 0, smilesGroups.view.localToGlobal(new Point()).y]);
			}
			
			if (swiper != null) {
				swiper.S_ON_SWIPE.add(onSwipe);
				swiper.activate();
				swiper.setBounds(_width, smilesSM.view.height, MobileGui.stage, 0, smilesSM.view.localToGlobal(new Point()).y);
			}
			
			if (smilesSM != null) {
				smilesSM.activate();
				smilesSM.S_COMPLETE_SHOW.add(setBusy);
			}
			setBusy(null);
		}
		
		private function setBusy(cls:Class):void {
			smilesGroups.busy = false;
		}
		
		override public function deactivateScreen():void {
			activated = false;
			
			if (smilesGroups != null) {
				smilesGroups.deactivate();
				if (smilesGroups.S_ITEM_SELECTED != null)
					smilesGroups.S_ITEM_SELECTED.remove(onSmilesGroupSelected);
			}
			
			if (smilesSM != null) {
				smilesSM.deactivate();
				smilesSM.S_COMPLETE_SHOW.remove(setBusy);
			}
			
			if (swiper != null) {
				swiper.deactivate();
				swiper.S_ON_SWIPE.remove(onSwipe);
			}
		}
		
		private function onSwipe(direction:String):void {
			if (smilesGroups.busy == true)
				return;
			var tabIndex:int = int(id);
			if (direction == Swiper.DIRECTION_RIGHT) {
				if (tabIndex == 0)
					return;
				tabIndex--;
			} else if (direction == Swiper.DIRECTION_LEFT) {
				if (tabIndex == 6)
					return;
				tabIndex++;
			} else
				return;
			smilesGroups.updateSelected(tabIndex);
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (smilesGroups != null)
				smilesGroups.dispose();
			smilesGroups = null;
			
			if (smilesSM != null)
				smilesSM.dispose();
			smilesSM = null;
			
			if (swiper != null)
				swiper.dispose();
			swiper = null;
			
			RichTextSmilesCodes.saveRecentToStore();
		}
		
		
		public function showRecent():void {
			if (id == "0")
				return;
			if (smilesGroups != null && RichTextSmilesCodes.recentSmiles != null && RichTextSmilesCodes.recentSmiles.length > 0) {
				recentShowing = true;
				smilesGroups.updateSelected(0);
				if (activated == false)
					onSmilesGroupSelected("0");
			}
		}
	}
}