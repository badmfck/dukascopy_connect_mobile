package com.dukascopy.connect.gui.list {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.OverlayData;
	import com.dukascopy.connect.gui.list.renderers.IListRenderer;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.utils.ImageCrypterOld;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.greensock.TweenMax;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class ListItem {
		
		private var _liView:ListItemView;
		private var _list:List;
		private var _data:Object;
		private var _renderer:IListRenderer;
		private var _height:int;
		private var _width:int;
		private var _hitZones:Array;
		private var _lastHitZone:String;
		private var _lastHitZoneObject:Object;
		private var _num:int;
		private var _y:int;
		
		private var fieldLinkNames:Array;
		public var wasLoading:Boolean;
		private var loadedImages:Array = [];
		private var unavaiablesImages:Array = [];
		private var cachedImagesCounter:int = 0;
		
		private var animatedZones:Array;
		private var alreadyAnimatedFields:Array;
		private var fildsToAnimate:Array;
		private var shouldAnimateImmediatelyImageName:String;
		
		private var listName:String;
		
		public var isDisposing:Boolean = false;
		public var drawTime:Boolean;
		
		//sizes on last draw call;
		public var drawnHeight:int = -1;
		public var drawnWidth:int = -1;
		public var elementYPosition:Number = 0;
		
		//---custom data from view to prevetn double calculations on getHeight & draw
		private var _customData:Object;
		private var needAnimation:Boolean;
		private var animationDelay:Number = 0;
		private var blinkRequest:Boolean;
		public function getCustomData():Object
		{
			if (_customData == null)
			{
				_customData = new Object();
			}
			return _customData;
		}
		//-----------------------------------------------------------------------------

		public function ListItem(listName:String, y:int, num:int, width:int, renderer:IListRenderer, data:Object, list:List, fieldLinkNames:Array = null, fildsToAnimate:Array = null) {
			_list = list;
			this.fildsToAnimate = fildsToAnimate;
			this.listName = listName;
			this.fieldLinkNames = fieldLinkNames;
			_data = data;
			_renderer = renderer;
			_num = num;
			_y = y;
			_width = width;
			_height = _renderer.getHeight(this, _width);
		}
		
		public function draw(w:int, scrollStopped:Boolean = true, highlight:Boolean = false):void {
			if (w == 0)
				return;
			if (renderer == null)
				return;
			if (isDisposing)
				return;
			cachedImagesCounter = 0;
			_width = w;
			if (_liView == null) {
				_liView = new ListItemView();
				_liView.y = _y;
			}
			_liView.draw(listName, num, _width, _height, renderer.isTransparent);
			
			if (blinkRequest)
			{
				blinkRequest = false;
				_liView.blink();
			}
			
			if (renderer == null)
				return;
			// TRY TO GET IMAGES FROM STOCK IF EXITS
			if (fieldLinkNames != null && data != null) {
				var l:int = fieldLinkNames.length;
				var n:int = 0;
				for (n; n < l; n++) {
					var url:String;
					if (data.hasOwnProperty(fieldLinkNames[n])) {
						url = data[fieldLinkNames[n]];
					}
					if (url == null)
						continue;
					var i:int=0;
					var j:int = loadedImages.length;
					var imgInStock:Boolean = false;
					for (i = 0; i < j; i++) {
						if (loadedImages[i][2] == url) {
							if (loadedImages[i][1] != null && loadedImages[i][1].isDisposed == false) {
								imgInStock = true;
								break;
							} else {
								loadedImages.splice(i, 1);
								break;
							}
						}
					}
					var imageLoadedFromCache:Boolean = false;
					if (imgInStock == false) {
						// IMAGE NOT IN STOCK, TRY TO SEARCH IN CACHE
						var ibd:ImageBitmapData = ImageManager.getImageFromCache(url);
						if (ibd != null && ibd.isDisposed == false) {
							if (loadedImages == null)
								loadedImages = [];
							addImageToStock(fieldLinkNames[n], url, ibd);
							imageLoadedFromCache = true;
						}
						i = 0;
						j = unavaiablesImages.length;
						for (i; i < j; i++) {
							if (unavaiablesImages[i][0] == url) {
								// This image already was called and
								// there is no local file for that url,
								// so we don`t need to try loading it one more time.
								imageLoadedFromCache = true;
							}
						}
						
						if (imageLoadedFromCache == false) {
							// TRY TO LOAD IMAGE FROM LOCALSTORE ONLY
							var imageAvaiable:Boolean = false;
							if (scrollStopped == true) {
								imageAvaiable = loadCachedImage(url, fieldLinkNames[n]);
							}
							if (imageAvaiable == false) {
								unavaiablesImages.push([url,fieldLinkNames[n]]);
							}
							else
								cachedImagesCounter++;
						}
					}
				}
			}
			
			var lml:int = (loadedImages) ? loadedImages.length : 0;
			var fnl:int = (fieldLinkNames) ? fieldLinkNames.length : 0;
			_liView.render(renderer.getView(this, _height, _width, highlight));
			
			if (shouldAnimateImmediatelyImageName) {
				var zone:Rectangle;
				if (animatedZones && (shouldAnimateImmediatelyImageName in animatedZones) && shouldAnimate(shouldAnimateImmediatelyImageName)) {
					if (_liView && _liView.image && _liView.image.bitmapData) {
						zone = new Rectangle(
							animatedZones[shouldAnimateImmediatelyImageName].x,
							animatedZones[shouldAnimateImmediatelyImageName].y,
							animatedZones[shouldAnimateImmediatelyImageName].width,
							animatedZones[shouldAnimateImmediatelyImageName].height
						);
						alreadyAnimatedFields ||= new Array();
						alreadyAnimatedFields[shouldAnimateImmediatelyImageName] = true;
						
						var dataId:String;
						if (data is ChatMessageVO)
						{
							dataId = (data as ChatMessageVO).chatUID + "_" + (data as ChatMessageVO).id;
						}
						
						_liView.addAnimation(zone, dataId);	
					}
				}
				shouldAnimateImmediatelyImageName = null;
			}
			if (needAnimation == true)
			{
				needAnimation = false;
				liView.alpha = 0;
				TweenMax.delayedCall(animationDelay + 0.1, animateShow);
			}
			if ( data != null && "getOverlay" in data)
			{
				var overlayData:OverlayData = data.getOverlay();
				if (overlayData != null)
				{
					liView.addOverlay(renderer.getOverlayPosition(), overlayData);
				}
				else
				{
					liView.removeOverlay();
				}
			}
			else
			{
				liView.removeOverlay();
			}
		}
		
		private function animateShow():void 
		{
			if (liView == null)
			{
				return;
			}
			var endPosition:Number = liView.x;
			if (animationDelay != 0)
			{
				liView.x = endPosition + Config.FINGER_SIZE * .4;
			}
			
			TweenMax.to(liView, 0.3, {alpha:1, x:endPosition});
		}
		
		private function loadCachedImage(url:String, imgName:String):Boolean {
			return ImageManager.loadImage(url, onCachedImageLoad, false, true);
		}
		
		private function onCachedImageLoad(loadedURL:String, loadedBmp:ImageBitmapData):void {
			if (loadedBmp == null)
				return;
			if (fieldLinkNames == null)
				return;
			var imgName:String;
			var l:int = fieldLinkNames.length;
			for (var i:int = 0; i < l; i++) {
				if (data[fieldLinkNames[i]] == loadedURL) {
					imgName = fieldLinkNames[i];
					break;
				}
			}
			if (imgName == null)
				return;
			addImageToStock(imgName, loadedURL, loadedBmp);
			cachedImagesCounter--;
			if (cachedImagesCounter <= 0) {
				cachedImagesCounter = 0;
				TweenMax.delayedCall(1, onImageLoaded, [imgName, true], true);
			}
		}
		
		private function onImageLoaded(imgName:String, animate:Boolean = true):void {
			var zone:Rectangle;
			if (animatedZones && (imgName in animatedZones)) {
				if (_liView && _liView.image && _liView.image.bitmapData)
					zone = new Rectangle(animatedZones[imgName].x, animatedZones[imgName].y, animatedZones[imgName].width, animatedZones[imgName].height);
			}
			draw(_width, false);
			if (zone && animate && shouldAnimate(imgName)) {
				alreadyAnimatedFields ||= [];
				alreadyAnimatedFields[imgName] = true;
				_liView.addAnimation(zone);
			}
		}
		
		public function setAnimatedZone(zoneName:String, rectangle:Rectangle):void {
			animatedZones ||= new Array();
			animatedZones[zoneName] = rectangle;
		}
		
		public function animateImage(zoneName:String, rectangle:Rectangle):void {
			setAnimatedZone(zoneName, rectangle);
			shouldAnimateImmediatelyImageName = zoneName;
		}
		
		private function shouldAnimate(imgName:String):Boolean {
			if (alreadyAnimatedFields && (imgName in alreadyAnimatedFields))
				return false;
			if (fildsToAnimate != null) {
				for (var i:int = 0; i < fildsToAnimate.length; i++) {
					if (fildsToAnimate[i] == imgName)
						return true;
				}
			}
			return false;
		}
		
		public function scrollStoppedShow():void {
			if (isDisposing == true)
				return;
			if (_liView == null || _liView.visible == false)
				return;
			if (wasLoading == true)
				return;
			
			var url:String;
			var l:int = unavaiablesImages.length;
			
			for (var n:int = 0; n < l; n++) {
				if (unavaiablesImages != null && unavaiablesImages[n] != null)
				{
					url = unavaiablesImages[n][0];
				}
				if (url == null || url.length == 0) {
					unavaiablesImages.splice(n, 1);
					n--;
					l--;
					continue;
				}
				wasLoading = true;
				loadImage(url);
			}
		}
		
		private function loadImage(url:String):void {
			ImageManager.loadImage(url, onLoadImage);
		}
		
		private function onLoadImage(loadedURL:String, bmd:ImageBitmapData):void {
			if (isDisposing)
				return;
			if (unavaiablesImages == null)
				return;
			var imgName:String;
			var l:int = unavaiablesImages.length;
			for (var i:int = 0; i < l; i++) {
				if (unavaiablesImages[i] != null && unavaiablesImages[i][0] == loadedURL) {
					imgName = unavaiablesImages[i][1];
					unavaiablesImages.splice(i, 1);
					break;
				}
			}
			if (imgName == null)
				return;
			addImageToStock(imgName, loadedURL, bmd);
			if (_liView != null && _liView.visible == true)
				onImageLoaded(imgName);
		}
		
		public function addImageFieldForLoading(name:String, ignore:Boolean = false):void {
			var i:int;
			var l:int;
			if (fieldLinkNames != null) {
				l = fieldLinkNames.length;
				for (i = 0; i < l; i++) 
					if (fieldLinkNames[i] == name && !ignore)
						return;
			}
			var wasInUnavaiable:Boolean = false;
			if (unavaiablesImages != null) {
				l = unavaiablesImages.length;
				for (i = 0; i < l; i++) {
					if (unavaiablesImages[i] != null && unavaiablesImages[i] is Array && (unavaiablesImages[i] as Array).length > 1 && unavaiablesImages[i][1] == name && !ignore) {
						wasInUnavaiable = true;
						return;
					}
				}
			}
			if (wasInUnavaiable == false) {
				var tmp:Array = name.split(".");
				var obj:Object = data;
				for (var j:int = 0; j < tmp.length - 1; j++)
				{
					if (tmp[j] in obj)
					{
						if (obj[tmp[j]] is Function)
							unavaiablesImages.push([obj[tmp[j]](), name]);
						else
							unavaiablesImages.push([obj[tmp[j]], name]);
					}
				}
			}
			fieldLinkNames ||= [];
			fieldLinkNames.push(name);
			wasLoading = false;
		}
		
		private function addImageToStock(name:String, url:String, bmp:ImageBitmapData):void {
			if (isDisposing) {
				if (bmp != null)
					bmp.dispose();
				return;
			}
			if (url == null || bmp == null)
				return;
			if (name == null)
				return;
			if (loadedImages == null)
				loadedImages=[];
			var n:int=0;
			var l:int = loadedImages.length;
			var add:Boolean = true;
			for (n = 0; n < l; n++){
				if(loadedImages[n][2] == url) {
					if (loadedImages[n][1] != null && loadedImages[n][1].isDisposed == false)
						return;
					else {
						loadedImages[n][1] = bmp;
						return;
					}
				}
			}
			var noDispose:Boolean = name.toLowerCase().indexOf('avatar') != -1;
			if (noDispose == false)	
				noDispose=name.toLowerCase().indexOf('sticker') != -1;
			loadedImages.push([name, bmp, url,noDispose]);
		}
		
		public function getLoadedImage(name:String):ImageBitmapData {
			if (loadedImages == null)
				return null;
			if (data == null)
			{
				return null;
			}
			if (name in data != true)
				return null;
			var url:String = data[name];
			// GET FROM LOADED BITMAPS
			var n:int=0;
			var l:int = loadedImages.length;
			for (n = 0; n < l; n++) {
				if(loadedImages[n][0] == name){
					if (loadedImages[n][1]!=null && loadedImages[n][1].isDisposed == false) {
						return loadedImages[n][1];
					}else {
						loadedImages[n] = null;
						loadedImages.splice(n, 1);
						break;
					}
				}
			}
			if (url) {
				var realUrl:String = url;
				if (realUrl.indexOf(ImageCrypterOld.imageKeyFlag) != -1)
					realUrl = realUrl.split(ImageCrypterOld.imageKeyFlag)[0];
				var image:ImageBitmapData = ImageManager.getImageFromCache(realUrl);
				if (image)
					return image;
			}
			return null;
		}
		
		public function scrollStoppedHide():void {
			clear();
		}
		
		public function dispose():void {
			blinkRequest = false;
			TweenMax.killDelayedCallsTo(animateShow);
			TweenMax.killTweensOf(_liView);
			//TODO - dispose loaded images
			if (loadedImages!=null) {
				var l:int = loadedImages.length;
				for (var n:int = 0; n <l; n++){
					if (loadedImages[n][1] != null) {
						// check for avatar
						if (loadedImages[n][3] == false)
							TweenMax.delayedCall(5, delayedImageDispose, [loadedImages[n][1]]);
					}
				}
			}
			
			needAnimation = false;
			loadedImages = null;
			
			_hitZones = null;
			_data = null;
			_num = 0;
			_height = 0;
			_y = 0;
			_width = 0;
			if (_liView != null)
			{
				TweenMax.killTweensOf(liView);
				_liView.dispose();
			}
			_liView = null;
			fieldLinkNames = null;
			
			animatedZones = null;
			alreadyAnimatedFields = null;
			fildsToAnimate = null;
		}
		
		private function delayedImageDispose(image:ImageBitmapData):void {
			image.dispose();
		}
		
		public function changeY(val:int, animate:Boolean = false):void {
			TweenMax.killTweensOf(_liView);
			_y = val;
			if (_liView != null)
			{
				if (animate == true && _liView.visible == true)
				{
					TweenMax.to(_liView, 0.25, {y:_y, delay:0.2});
				}
				else
				{
					_liView.y = _y;
				}
			}
		}
		
		public function clear():void {
			if (_liView != null)
				_liView.clear();
		}
		
		public function recalculateHeight(_w:int = -1):void {
			if (_w > 0)
				_width = _w;
			_height = _renderer.getHeight(this, _width);
		}
		
		public function setHitZones(hitZones:Array):void { _hitZones = hitZones; }
		public function getHitZones():Array {	return _hitZones;	}
		
		public function setLastHitZone(lastHitZoneObject:Object):void { 
			_lastHitZoneObject = lastHitZoneObject;
			if (_lastHitZoneObject != null)
				_lastHitZone = _lastHitZoneObject.type;
			else 
				_lastHitZone = null;
		}
		public function getLastHitZone(doClear:Boolean = true):String {
			var res:String = _lastHitZone;
			if (doClear){
				_lastHitZone = null;
				_lastHitZoneObject = null;
			}
			return res;
		}
		public function getLastHitZoneObject(doClear:Boolean = true):Object {
			var res:Object = _lastHitZoneObject;
			if (doClear){
				_lastHitZone = null;
				_lastHitZoneObject = null;
			}
			return res;
		}
		
		public function animate(delay:Number = 0):void 
		{
			animationDelay = delay;
			needAnimation = true;
		}
		
		public function hideWithDispose():void 
		{
			TweenMax.to(_liView, 0.5, {alpha:0, onComplete:dispose});
		}
		
		public function blink():void 
		{
			blinkRequest = true;
		}
		
		public function get renderer():IListRenderer { return _renderer; }
		public function get num():int { return _num; }
		public function get y():int { return _y; }
		public function get height():int { return _height; }
		public function get width():int { return _width; }
		public function get data():Object { return _data; }
		public function get list():List { return _list; }
		public function get liView():ListItemView { return _liView; }
		public function get lastHitZoneObject():Object 	{	return _lastHitZoneObject;	}
	}
}