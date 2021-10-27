package com.dukascopy.connect.screens.context 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.type.HitZoneType;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */

	public class ContextMenuScreen extends BaseScreen
	{
		private var background:Bitmap;
		private var backgroundBloor:Bitmap;
		private var targetClip:Sprite;
		private var targetClipBack:Sprite;
		private var targetClipBackContainer:Sprite;
		private var actionButtons:Vector.<ContextMenuButton>;
		private var buttonsContainer:Sprite;
		private var screenLocked:Boolean;
		private var currentSelectedIndex:int = -1;
		private var buttons:Sprite;
		private var itemBD:ImageBitmapData;
		private var itemBackBD:ImageBitmapData;
		private var wasDown:Boolean;
		
		public function ContextMenuScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			_params.doDisposeAfterClose = true;
			
			var dataZone:HitZoneData = data.data.hitzone;
			
			var backBD:ImageBitmapData = new ImageBitmapData("ContextMenuScreen.background", MobileGui.stage.fullScreenWidth, MobileGui.stage.fullScreenHeight, false, 0xFFFFFF);
			backBD.draw(MobileGui.centerScreen.currentScreen.view);
			
			var matrix:Matrix;
			var padding:Number = Config.MARGIN * .6;
			
			if (dataZone.type == HitZoneType.AVATAR) {
				itemBD = new ImageBitmapData("ContextMenuScreen.item", dataZone.width, dataZone.height, false, 0xFFFFFF);
				matrix = new Matrix();
				matrix.translate(-(dataZone.x + 1), -(dataZone.y + 1));
				itemBD.draw(MobileGui.centerScreen.currentScreen.view, matrix);
				ImageManager.drawGraphicCircleImage(targetClip.graphics, 0, 0, dataZone.width, itemBD, ImageManager.SCALE_PORPORTIONAL);
				
				targetClip.x = dataZone.x + 1;
				targetClip.y = dataZone.y + 1;
				
				itemBackBD = new ImageBitmapData("ContextMenuScreen.itemBack", dataZone.width * 2 + padding*2, dataZone.height * 2 + padding*2, true, 0x80FFFFFF);
				ImageManager.drawGraphicCircleImage(targetClipBack.graphics, 0, 0, dataZone.width + padding, itemBackBD, ImageManager.SCALE_PORPORTIONAL);
				
				targetClipBackContainer.x = dataZone.x + dataZone.width + 1;
				targetClipBackContainer.y = dataZone.y + dataZone.height + 1;
				
				targetClipBack.x = - (dataZone.width + padding);
				targetClipBack.y = - (dataZone.height + padding);
				
				targetClipBackContainer.scaleX = targetClipBackContainer.scaleY = 0.6;
				TweenMax.to(targetClipBackContainer, 0.55, {scaleX:1.5, scaleY:1.5});
				TweenMax.to(targetClipBackContainer, 0.55, {scaleX:1, scaleY:1, delay:0.55});
			}
			else if (dataZone.type == HitZoneType.MESSAGE_TEXT || dataZone.type == HitZoneType.MESSAGE_IMAGE) {
				itemBD = new ImageBitmapData("ContextMenuScreen.item", dataZone.width - 1, dataZone.height - 1, false, 0xFFFFFF);
				matrix = new Matrix();
				matrix.translate(-(dataZone.x + 1), -(dataZone.y + 1));
				itemBD.drawWithQuality(MobileGui.centerScreen.currentScreen.view, matrix, null, null, null, false, StageQuality.HIGH);
				ImageManager.drawGraphicRectangleImage(
														targetClip.graphics, 0, 0, dataZone.width - 1, dataZone.height - 1, 
														Math.ceil(Config.FINGER_SIZE * .3), itemBD);
				
				targetClip.x = dataZone.x + 1;
				targetClip.y = dataZone.y + 1;
				
				itemBackBD = new ImageBitmapData("ContextMenuScreen.itemBack", dataZone.width + padding * 2, dataZone.height + padding * 2, true, 0x80FFFFFF);
				ImageManager.drawGraphicRectangleImage(
														targetClipBack.graphics, 0, 0, dataZone.width + padding*2, dataZone.height + padding*2, 
														Math.ceil(Config.FINGER_SIZE * .3), itemBackBD);
				
				targetClipBackContainer.x = dataZone.x + dataZone.width/2;
				targetClipBackContainer.y = dataZone.y + dataZone.height/2;
				
				targetClipBack.x = - (dataZone.width/2 + padding);
				targetClipBack.y = - (dataZone.height/2 + padding);
				
				var endWidth:int = targetClipBackContainer.width;
				var endHeight:int = targetClipBackContainer.height;
				
				targetClipBackContainer.width = targetClipBackContainer.width * .9;
				targetClipBackContainer.height = targetClipBackContainer.height * .9;
			//	targetClipBackContainer.scaleX = targetClipBackContainer.scaleY = 0.6;
				TweenMax.to(targetClipBackContainer, 0.55, {width:endWidth * 1.1, height:endHeight * 1.1});
				TweenMax.to(targetClipBackContainer, 0.55, {width:endWidth, height:endHeight, delay:0.55});
			}
			
			var blur:BlurFilter = new BlurFilter();
			blur.blurX = Config.FINGER_SIZE * .3;
			blur.blurY = Config.FINGER_SIZE * .3; 
			blur.quality = BitmapFilterQuality.MEDIUM;
			var bloorBD:ImageBitmapData = new ImageBitmapData("ContextMenuScreen.backBloor", MobileGui.stage.fullScreenWidth, MobileGui.stage.fullScreenHeight);
			bloorBD.applyFilter(backBD, new Rectangle(0, 0, backBD.width, backBD.height), new Point(0, 0), blur);
			var brightness:Number = -30;
			bloorBD.applyFilter(bloorBD, bloorBD.rect, new Point(), new ColorMatrixFilter(
																					[
																						1, 0, 0, 0, brightness,
																						0, 1, 0, 0, brightness, 
																						0, 0, 1, 0, brightness, 
																						0, 0, 0, 1, 0]));
			
			backgroundBloor.alpha = 0;
			backgroundBloor.bitmapData = bloorBD;
			TweenMax.to(backgroundBloor, 0.65, {alpha:1, onComplete:onBackgroundShowComplete});
			
			background.bitmapData = backBD;
			
			createButtons(data.data.actions);
		}
		
		private function createButtons(actions:Vector.<IScreenAction>):void 
		{
			actionButtons = new Vector.<ContextMenuButton>();
			
			buttons = new Sprite();
			view.addChild(buttons);
			buttonsContainer = new Sprite();
			buttons.addChild(buttonsContainer);
			
			var padding:int = Config.DOUBLE_MARGIN;
			
			var button:ContextMenuButton;
			var currentY:int = 0;
			var maxWidth:int = 0;
			
			if (actions != null) {
				var l:int = actions.length;
				for (var i:int = 0; i < l; i++) {
					button = new ContextMenuButton();
					button.createText(actions[i], background.width - padding * 2);
					if (maxWidth < button.getWidth()) {
						maxWidth = button.getWidth();
					}
					actionButtons.push(button);
					buttonsContainer.addChild(button);
				}
				
				for (var i2:int = 0; i2 < l; i2++) {
					actionButtons[i2].createBack(i2 == 0, i2 == l - 1, maxWidth);
					actionButtons[i2].y = currentY;
					currentY += actionButtons[i2].getHeight();
				}
			}
			
			buttons.x = targetClip.x;
			
			var overlap:Boolean = false;
			var makeDark:int = 0;
			
			if (targetClip.y - buttonsContainer.height - padding > padding) {
				buttons.y = targetClip.y - padding;
				buttonsContainer.y = -buttonsContainer.height;
			}
			else{
				buttons.y = targetClip.y + targetClip.height + padding;
				buttonsContainer.y = 0;
				if (buttons.y + buttonsContainer.height + padding > MobileGui.stage.fullScreenWidth)
				{
					makeDark++;
					buttons.y = targetClip.y + padding;
					overlap = true;
				}
			}
			
			if (targetClip.x + buttonsContainer.width + padding > MobileGui.stage.fullScreenWidth) {
				buttons.x = targetClip.x;
				buttonsContainer.x = - targetClip.x + (MobileGui.stage.fullScreenWidth - padding - buttonsContainer.width);
				if (overlap)
				{
					if (targetClip.x - padding - buttonsContainer.width > padding)
					{
					//	buttonsContainer.x = - targetClip.x + (MobileGui.stage.fullScreenWidth - padding - buttonsContainer.width);
					}
				}
			}
			else{
				makeDark++;
				buttons.x = targetClip.x;
				buttonsContainer.x = 0;
			}
			
			if (makeDark == 2)
			{
				for (var i3:int = 0; i3 < l; i3++) {
					actionButtons[i3].toDark();
				}
			}
			
			buttons.alpha = 0;
			buttons.scaleX = buttons.scaleY = 0.6;
			TweenMax.to(buttons, 0.35, {alpha:1, scaleX:1, scaleY:1, delay:0.35, ease:Back.easeOut});
		}
		
		private function onBackgroundShowComplete():void {
			screenLocked = false;
		}
		
		override protected function createView():void {
			super.createView();
			
			background = new Bitmap();
			view.addChild(background);
			
			backgroundBloor = new Bitmap();
			view.addChild(backgroundBloor);
			
			targetClipBackContainer = new Sprite();
			view.addChild(targetClipBackContainer);
			
			targetClipBack = new Sprite();
			targetClipBackContainer.addChild(targetClipBack);
			
			targetClip = new Sprite();
			view.addChild(targetClip);
		}
		
		override protected function drawView():void {
			super.drawView();
			view.graphics.clear();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (background != null)	{
				UI.destroy(background);
				background = null;
			}
			if (backgroundBloor != null) {
				TweenMax.killTweensOf(backgroundBloor);
				UI.destroy(backgroundBloor);
				backgroundBloor = null;
			}
			if (targetClip != null)	{
				TweenMax.killTweensOf(targetClip);
				UI.destroy(targetClip);
				targetClip = null;
			}
			if (targetClipBack != null)	{
				TweenMax.killTweensOf(targetClipBack);
				UI.destroy(targetClipBack);
				targetClipBack = null;
			}
			if (buttonsContainer != null) {
				UI.destroy(buttonsContainer);
				buttonsContainer = null;
			}
			if (targetClipBackContainer != null) {
				TweenMax.killTweensOf(targetClipBackContainer);
				UI.destroy(targetClipBackContainer);
				targetClipBackContainer = null;
			}
			if (buttons != null) {
				TweenMax.killTweensOf(buttons);
				UI.destroy(buttons);
				buttons = null;
			}
			if (actionButtons != null){
				var l:int = actionButtons.length;
				for (var i:int = 0; i < l; i++) {
					TweenMax.killTweensOf(actionButtons[i]);
					actionButtons[i].dispose();
				}
				actionButtons = null;
			}
			if (itemBD != null) {
				itemBD.dispose();
				itemBD = null;
			}
			if (itemBackBD != null) {
				itemBackBD.dispose();
				itemBackBD = null;
			}
			
			TweenMax.killDelayedCallsTo(close);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed || screenLocked)
				return;
			
			PointerManager.addTap(view, onTap);
			PointerManager.addDown(view, onDown);
			PointerManager.addUp(view, onUp);
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			
			PointerManager.removeTap(view, onTap);
			PointerManager.removeDown(view, onDown);
			PointerManager.removeUp(view, onUp);
			PointerManager.removeMove(view, onMove);
		}
		
		private function onDown(e:Event = null):void {
			wasDown = true;
			if (actionButtons != null && buttonsContainer.getBounds(view).contains(view.mouseX, view.mouseY)) {
				var l:int = actionButtons.length;
				for (var i:int = 0; i < l; i++) {
					if (actionButtons[i].getBounds(buttonsContainer).contains(buttonsContainer.mouseX, buttonsContainer.mouseY)) {
						actionButtons[i].select();
						currentSelectedIndex = i;
						break;
					}
				}
			}
			PointerManager.addMove(view, onMove);
		}
		
		private function onMove(e:Event = null):void {
			if (actionButtons != null && buttonsContainer.getBounds(view).contains(view.mouseX, view.mouseY)) {
				var l:int = actionButtons.length;
				for (var i:int = 0; i < l; i++) {
					if (actionButtons[i].getBounds(buttonsContainer).contains(buttonsContainer.mouseX, buttonsContainer.mouseY)) {
						
						if (currentSelectedIndex != i) {
							if (currentSelectedIndex != -1 && actionButtons.length > i - 1) {
								actionButtons[currentSelectedIndex].unselect();
							}
							
							actionButtons[i].select();
							currentSelectedIndex = i;
						}
						
						return;
					}
				}
			}
			if (currentSelectedIndex != -1 && actionButtons.length > currentSelectedIndex - 1) {
				actionButtons[currentSelectedIndex].unselect();
			}
			currentSelectedIndex = -1;
		}
		
		private function onUp(e:Event = null):void {
			if (wasDown == false)
				return;
			
			if (actionButtons != null && buttonsContainer.getBounds(view).contains(view.mouseX, view.mouseY)) {
				var l:int = actionButtons.length;
				for (var i:int = 0; i < l; i++) {
					if (buttonsContainer != null && actionButtons[i].getBounds(buttonsContainer).contains(buttonsContainer.mouseX, buttonsContainer.mouseY)) {
						onItemTap(i);
					//	break;
					}
				}
			}
			if (actionButtons != null && currentSelectedIndex != -1 && actionButtons.length > currentSelectedIndex - 1) {
				actionButtons[currentSelectedIndex].unselect();
			}
			currentSelectedIndex = -1;
			PointerManager.removeMove(view, onMove);
		}
		
		private function onTap(e:Event = null):void {
			if (actionButtons != null && buttonsContainer.getBounds(view).contains(view.mouseX, view.mouseY)) {
				var l:int = actionButtons.length;
				for (var i:int = 0; i < l; i++) {
					if (actionButtons[i].getBounds(buttonsContainer).contains(buttonsContainer.mouseX, buttonsContainer.mouseY)) {
						onItemTap(i);
						break;
					}
				}
			}
			else {
				preClose();
			}
		}
		
		private function onItemTap(index:int):void {	
			preClose(true, index);
			
			if (actionButtons != null && actionButtons.length >= index + 1 && actionButtons[index].getAction() != null) {
				actionButtons[index].select();
				actionButtons[index].getAction().execute();
			}
		}
		
		private function preClose(holdMenu:Boolean = false, selectedIndex:int = -1):void {
			screenLocked = true;
			deactivateScreen();
			TweenMax.delayedCall(0.4, close);
			background.visible = false;
			TweenMax.to(targetClip, 0.2, {alpha:0});
			TweenMax.to(targetClipBack, 0.2, {alpha:0});
			TweenMax.to(backgroundBloor, 0.2, {alpha:0});
			
			var l:int = actionButtons.length;
			for (var i:int = 0; i < l; i++) {
				if (holdMenu && i == selectedIndex) {
					TweenMax.to(actionButtons[i], 0.2, {alpha:0, delay:0.2});
				}
				else {
					TweenMax.to(actionButtons[i], 0.2 , {alpha:0});
				}	
			}
		}
		
		private function close():void {
			ServiceScreenManager.closeView();
		}
	}
}