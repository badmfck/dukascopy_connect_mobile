package com.dukascopy.connect.gui.list {
	
	import com.dukascopy.connect.data.OverlayData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class ListItemView extends Sprite {
		
		private var animations:Array;
		private var animationObject:Object;
		private var overlay:Sprite;
		private var overlays:Object;
		private var blinkClip:Sprite;
		private var _width:int;
		private var _height:int;
		public var image:Bitmap;
		
		public function ListItemView() {
			mouseChildren = false;
			animations = new Array();
			blendMode = BlendMode.LAYER;
		}
		
		public function draw(listName:String, num:int, _width:int, _height:int, isRendererTransparent:Boolean):void {
			this._width = _width;
			this._height = _height;
			
			var created:Boolean = false;
			if (image == null) {
				image = new Bitmap()
				addChild(image);
			}
			if (image.bitmapData == null) {
				image.bitmapData = new ImageBitmapData(listName + ".item:" + num, _width, _height);
				created = true;
			} else {
				if (_width != image.width || _height != image.height) {
					if (image.bitmapData != null)
						image.bitmapData.dispose();
					image.bitmapData = new ImageBitmapData(listName + ".item:" + num, _width, _height);
					created = true;
				}
			}
			if (created == false && isRendererTransparent == true)
				image.bitmapData.fillRect(image.bitmapData.rect, 0);
			if (animationObject)
				update(animationObject);
		}
		
		public function render(view:IBitmapDrawable):void {
			var time:Number = getTimer();
			
			image.bitmapData.drawWithQuality(view, (view as Sprite).transform.matrix, (view as Sprite).transform.colorTransform, null, null, true, StageQuality.HIGH);
			if (animationObject)
				update(animationObject);
		}
		
		public function dispose():void {
			if (parent != null)
				parent.removeChild(this);
			if (image != null) {
				if (image.bitmapData != null) {
					image.bitmapData.dispose();
					image.bitmapData = null;
				}
			}
			if (overlay != null)
			{
				UI.destroy(overlay);
				overlay = null;
			}
			if (blinkClip != null)
			{
				TweenMax.killTweensOf(blinkClip);
				UI.destroy(blinkClip);
				blinkClip = null;
			}
			removeAnimations();
			animations = null;
		}
		
		private function removeAnimations():void {
			/*if (dataId in animationObject && animationObject.dataId != null)
			{
				unregisterAnimation(animationObject.dataId);
			}*/
			
			TweenMax.killTweensOf(animationObject);
			if (animationObject && animationObject.source) {
				animationObject.source.dispose();
				animationObject.source = null;
			}
			animationObject = null;
		}
		
		public function clear():void {
			if (image != null && image.bitmapData != null) {
				image.bitmapData.dispose();
				image.bitmapData = null;
			}
			removeAnimations();
		}
		
		public function addAnimation(zone:Rectangle, dataId:String = null):void {
			var rect:Rectangle = new Rectangle(0, 0, zone.width, zone.height);
			
			var sourceBD:ImageBitmapData = new ImageBitmapData("ListItemView.animation", zone.width, zone.height);
			var destinationPoint:Point = new Point(zone.x, zone.y);
			sourceBD.copyPixels(image.bitmapData, zone, new Point(0, 0));
			
			animationObject = { };
			animationObject.point = destinationPoint;
			animationObject.rect = rect;
			animationObject.alpha = 0;
			animationObject.source = sourceBD;
			
			var my_filter:ColorMatrixFilter = new ColorMatrixFilter(new Array(1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, animationObject.alpha, 0));
			
			animationObject.filter = my_filter;
			
			if (image.bitmapData)
				image.bitmapData.applyFilter(sourceBD, rect, destinationPoint, my_filter);
			if (dataId != null) {
				animationObject.dataId = dataId;
				registerAnimation(dataId);
			}
			TweenMax.to(animationObject, 0.6, { alpha:1, onUpdate:update, onUpdateParams:[animationObject], onComplete:animationComplete} );
		}
		
		public function removeOverlay():void 
		{
			if (overlay != null)
			{
				overlay.visible = false;
			}
		}
		
		public function addOverlay(overlayPosition:Rectangle, overlayData:OverlayData):void 
		{
			if (overlayData.crown == true && overlayPosition != null)
			{
				showOverlay(OverlayData.CROWN, overlayPosition);
			}
			else
			{
				hideOverlay(OverlayData.CROWN);
			}
			
			if (overlayData.toad == true && overlayPosition != null)
			{
				showOverlay(OverlayData.TOAD, overlayPosition);
			}
			else
			{
				hideOverlay(OverlayData.TOAD);
			}
			
			if (overlayData.jail == true && overlayPosition != null)
			{
				showOverlay(OverlayData.JAIL, overlayPosition);
			}
			else
			{
				hideOverlay(OverlayData.JAIL);
			}
			
			if (overlayData.flower_1 == true && overlayPosition != null)
			{
				showOverlay(OverlayData.FLOWER_1, overlayPosition);
			}
			else
			{
				hideOverlay(OverlayData.FLOWER_1);
			}
			if (overlayData.flower_2 == true && overlayPosition != null)
			{
				showOverlay(OverlayData.FLOWER_2, overlayPosition);
			}
			else
			{
				hideOverlay(OverlayData.FLOWER_2);
			}
			if (overlayData.flower_3 == true && overlayPosition != null)
			{
				showOverlay(OverlayData.FLOWER_3, overlayPosition);
			}
			else
			{
				hideOverlay(OverlayData.FLOWER_3);
			}
			if (overlayData.flower_4 == true && overlayPosition != null)
			{
				showOverlay(OverlayData.FLOWER_4, overlayPosition);
			}
			else
			{
				hideOverlay(OverlayData.FLOWER_4);
			}
		}
		
		public function blink():void 
		{
			removeblinkClip();
			if (blinkClip == null)
			{
				blinkClip = new Sprite();
				blinkClip.graphics.beginFill(0, 0.35);
				blinkClip.graphics.drawRect(0, 0, _width, _height);
				blinkClip.graphics.endFill();
				addChildAt(blinkClip, 0);
				TweenMax.to(blinkClip, 1, {alpha:0, onComplete:removeblinkClip});
			}
		}
		
		private function removeblinkClip():void 
		{
			if (blinkClip != null)
			{
				TweenMax.killTweensOf(blinkClip);
				UI.destroy(blinkClip);
				blinkClip = null;
			}
		}
		
		private function hideOverlay(type:String):void 
		{
			if (overlay == null)
			{
				return;
			}
			if (overlays == null || overlays[type] == null)
			{
				return;
			}
			overlays[type].visible = false;
		}
		
		private function showOverlay(type:String, overlayPosition:Rectangle):void 
		{
			if (overlay == null)
			{
				overlay = new Sprite();
				addChild(overlay);
			}
			if (overlays == null)
			{
				overlays = new Object();
			}
			if (overlays[type] == null)
			{
				var icon:Sprite = new (OverlayData.getIcon(type));
				overlays[type] = icon;
				overlay.addChild(icon);
			}
			else
			{
				overlays[type].visible = true;
			}
			if (type == OverlayData.FLOWER_1 || type == OverlayData.FLOWER_2 || type == OverlayData.FLOWER_3 || type == OverlayData.FLOWER_4)
			{
				UI.scaleToFit(overlays[type], overlayPosition.width * 1.5 * 10, overlayPosition.width * 1.5);
				overlays[type].x = overlayPosition.x + overlayPosition.width - overlays[type].width * .5;
				overlays[type].y = overlayPosition.y + overlayPosition.width * 2 - overlays[type].height * .65;
			}
			else
			{
				overlays[type].scaleX = overlays[type].scaleY = overlayPosition.width * 2 / 100;
				overlays[type].x = overlayPosition.x + overlayPosition.width;
				overlays[type].y = overlayPosition.y + overlayPosition.width;
			}
		}
		
		private function registerAnimation(dataId:String):void 
		{
			
		}
		
		private function unregisterAnimation(dataId:String):void {
			
		}
		
		private function update(animationData:Object):void {
			if (image.bitmapData && animationObject) {
				animationObject.filter.matrix = new Array(1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, animationObject.alpha, 0);
				image.bitmapData.applyFilter(animationObject.source, animationObject.rect, animationObject.point, animationObject.filter);
			} else
				removeAnimations();
		}
		
		private function animationComplete():void {
			removeAnimations();
		}
	}
}