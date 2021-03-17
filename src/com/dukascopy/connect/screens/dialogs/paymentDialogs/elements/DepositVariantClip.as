package com.dukascopy.connect.screens.dialogs.paymentDialogs.elements {
	
	import assets.New_selected;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapToggleSwitch;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class DepositVariantClip extends Sprite {
		
		static private var TOGGLER_BMD:ImageBitmapData;
		static private var TOGGLERBG_BMD:ImageBitmapData;
		
		private var storageTitle:Bitmap;
		private var durationTitle:Bitmap;
		private var duration:Bitmap;
		private var rewardTitle:Bitmap;
		private var icon:Bitmap;
		private var reward:Bitmap;
		public var data:Object;
		private var itemWidth:int;
		private var padding:int;
		private var bg:Sprite;
		private var itemTap:Function;
	//	private var selector:BitmapToggleSwitch;
		private var selectIcon:Sprite;
		private var selectedValue:Boolean;
		private var cropRectangle:Rectangle;
		
		public function DepositVariantClip(itemWidth:int, data:Object, itemTap:Function) {
			padding = Config.DIALOG_MARGIN;
			this.data = data;
			this.itemWidth = itemWidth;
			this.itemTap = itemTap;
			create();
		//	addToggler();
			draw();
		}
		
		private function addToggler():void {
			/*selector = new BitmapToggleSwitch();
			selector.setDownScale(1);
			selector.setDownColor(0x000000);
			selector.show(0);
			TOGGLERBG_BMD = UI.renderAsset(new SWFToggleBg(), Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_5);
			TOGGLER_BMD ||= UI.renderAsset(new SWFToggler(), Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2);
			selector.setDesignBitmapDatas(TOGGLERBG_BMD, TOGGLER_BMD, true);
			selector.setOverflow(8, 25,25, 8);
			selector.disposeBitmapOnDestroy = false;
			selector.mouseChildren = false;
			selector.mouseEnabled = false;
			addChild(selector);*/
		}
		
		public function select():void {
			selectedValue = true;
		//	selector.isSelected = true;
			
			selectIcon.visible = true;
		}
		
		public function deselect():void {
			selectedValue = false;
		//	selector.isSelected = false;
			
			selectIcon.visible = false;
		}
		
		public function get selected():Boolean {
		//	return selector.isSelected;
			return selectedValue;
		}
		
		public function activate():void
		{
			PointerManager.addTap(bg, onTapped);
		}
		
		public function deactivate():void
		{
			PointerManager.removeTap(bg, onTapped);
		}
	//	getinvesticonbyin
		private function onTapped(e:Event):void 
		{
			if (parent != null)
			{
				var hitZone:HitZoneData = new HitZoneData();
				var startPoint:Point = new Point(x, y);
				startPoint = this.parent.localToGlobal(startPoint);
				hitZone.width = itemWidth;
				hitZone.height = height;
				hitZone.type = HitZoneType.MENU_MIDDLE_ELEMENT;
				var positionPoint:Point = new Point();
				
				var touchPoint:Point = new Point(mouseX, mouseY);
				var globalTouchPoint:Point = localToGlobal(touchPoint);
				
				hitZone.touchPoint = globalTouchPoint;
				hitZone.visibilityRect = cropRectangle;
				hitZone.x = startPoint.x;
				hitZone.y = startPoint.y;
				Overlay.displayTouch(hitZone);
			}
			
			
			if (itemTap != null)
			{
				itemTap(data);
			}
		}
		
		public function setOverlaySize(cropRectangle:Rectangle):void
		{
			this.cropRectangle = cropRectangle;
		}
		
		private function draw():void 
		{
			drawStorageTitle();
			drawDurationTitle();
			drawDuration();
			drawRewardTitle();
			drawReward();
			drawIcon();
			
			updatePositions();
			
			var itemHeight:int = Math.max(reward.y + reward.height, duration.y + duration.height) + Config.DIALOG_MARGIN;
			
			selectIcon.y = int((itemHeight - selectIcon.height) * .5);
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, 0, itemWidth, itemHeight);
			bg.graphics.endFill();
			bg.graphics.lineStyle(2, Style.color(Style.CONTROL_INACTIVE));
			bg.graphics.moveTo(0, itemHeight - 2);
			bg.graphics.lineTo(itemWidth, itemHeight - 2);
		}
		
		private function drawIcon():void 
		{
			if (icon.bitmapData != null)
			{
				icon.bitmapData.dispose();
				icon.bitmapData = null;
			}
			var iconType:String;
			if (data.storage == "DUKASCOPY")
				iconType = "DCO";
			else if (data.storage == "BLOCKCHAIN")
				iconType = "BLOCKCHAIN"
			if (iconType != null)
			{
				var iconClip:Sprite = UI.getInvestIconByInstrument(iconType);
				if (iconClip != null)
				{
					var size:int = Config.FINGER_SIZE * .3;
					UI.scaleToFit(iconClip, size, size);
				}
				icon.bitmapData = UI.getSnapshot(iconClip);
			}
		}
		
		private function updatePositions():void {
			selectIcon.x = itemWidth - selectIcon.width - Config.DOUBLE_MARGIN;
			
			icon.x = padding;
			
			storageTitle.x = padding + Config.FINGER_SIZE * .4;
			storageTitle.y = int(Config.FINGER_SIZE * .3);
			icon.y = int(storageTitle.y + storageTitle.height * .5 - icon.height * .5);
			
			durationTitle.x = padding;
			durationTitle.y = int(storageTitle.y + storageTitle.height + Config.FINGER_SIZE * .4);
			
			duration.x = padding;
			duration.y = int(durationTitle.y + durationTitle.height + Config.FINGER_SIZE * .2);
			
			rewardTitle.x = int((selectIcon.x - padding * 3) * .5 + padding * 2);
			rewardTitle.y = durationTitle.y;
			
			reward.x = int((selectIcon.x - padding * 3) * .5 + padding * 2);
			reward.y = int(rewardTitle.y + rewardTitle.height + Config.FINGER_SIZE * .2);
		}
		
		private function drawStorageTitle():void 
		{
			storageTitle.bitmapData = TextUtils.createTextFieldData(
															data.storage, (itemWidth - padding*3)*.5, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .26, true, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), true);
		}
		
		private function drawDurationTitle():void 
		{
			durationTitle.bitmapData = TextUtils.createTextFieldData(
															Lang.depositDurationText + ":", (itemWidth - padding*3)*.5, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .26, true, Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), true);
		}
		
		private function drawDuration():void 
		{
			if (data.duration != null)
			{
				duration.bitmapData = TextUtils.createTextFieldData(
															data.duration, (itemWidth - padding*3)*.5, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .32, true, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), true);
			}
		}
		
		private function drawRewardTitle():void 
		{
			rewardTitle.bitmapData = TextUtils.createTextFieldData(
															Lang.depositRewardText + ":", (itemWidth - padding*3)*.5, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .26, true, Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), true);
		}
		
		private function drawReward():void 
		{
			if (data.reward != null && data.reward_currency != null)
			{
				var currency:String = data.reward_currency;
				if (Lang[currency] != null)
				{
					currency = Lang[currency];
				}
				
				reward.bitmapData = TextUtils.createTextFieldData(
															data.reward + " " + currency, (itemWidth - padding*3)*.5, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .32, true, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), true);
			}
		}
		
		private function create():void 
		{
			bg = new Sprite();
			addChild(bg);
			
			storageTitle = new Bitmap();
			addChild(storageTitle);
			
			durationTitle = new Bitmap();
			addChild(durationTitle);
			
			duration = new Bitmap();
			addChild(duration);
			
			rewardTitle = new Bitmap();
			addChild(rewardTitle);
			
			reward = new Bitmap();
			addChild(reward);
			
			icon = new Bitmap();
			addChild(icon);
			
			selectIcon = new New_selected();
			addChild(selectIcon);
			UI.colorize(selectIcon, Color.GREEN);
			var size:int = Config.FINGER_SIZE * .5;
			UI.scaleToFit(selectIcon, size, size);
			selectIcon.visible = false;
		}
		
		public function dispose():void
		{
			data = null;
			itemTap = null;
			
			if (storageTitle != null)
			{
				UI.destroy(storageTitle);
				storageTitle = null;
			}
			if (durationTitle != null)
			{
				UI.destroy(durationTitle);
				durationTitle = null;
			}
			if (selectIcon != null)
			{
				UI.destroy(selectIcon);
				selectIcon = null;
			}
			if (icon != null)
			{
				UI.destroy(icon);
				icon = null;
			}
			if (duration != null)
			{
				UI.destroy(duration);
				duration = null;
			}
			if (rewardTitle != null)
			{
				UI.destroy(rewardTitle);
				rewardTitle = null;
			}
			if (reward != null)
			{
				UI.destroy(reward);
				reward = null;
			}
			
			cropRectangle = null;
		}
	}
}