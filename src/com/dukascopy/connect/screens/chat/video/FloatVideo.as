package com.dukascopy.connect.screens.chat.video 
{
	import assets.ExpandIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.CirclePreloader;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.viManager.data.VIAction;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power2;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.PermissionEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.CameraPosition;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.net.NetStream;
	import flash.permissions.PermissionStatus;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class FloatVideo extends Sprite
	{
		static public const MRZ:String = "mrz";
		static public const SELFIE:String = "selfie";
		static public const GOLOGRAM:String = "gologram";
		
		private var video:Video;
		public var size:Rectangle;
		private var camera:Camera;
		private var maskClip:Sprite;
		private var background:Sprite;
		private var moving:Boolean;
		private var startTouchPoint:Point;
		private var restrictedArea:Rectangle;
		private var padding:int;
		private var expandCallback:Function;
		private var expandButton:BitmapButton;
		private var startPosition:int;
		private var needAnimate:Boolean;
		private var lockedMove:Boolean;
		private var titleClip:Sprite;
		private var backButton:BitmapButton;
		private var nextButton:BitmapButton;
		private var currentPhotoCallback:Function;
		private var lastX:Number;
		private var lastY:Number;
		private var currentTitle:String;
		private var videoContainer:Sprite;
		private var imagePreview:Bitmap;
		private var currentBitmap:ImageBitmapData;
		private var lastSelectedSize:Rectangle;
		private var selectedCamera:String;
		private var titleText:Bitmap;
		public var hided:Boolean;
		private var loader:CirclePreloader;
		private var maximized:Boolean;
		private var overlay:String;
		
		public function FloatVideo(restrictedArea:Rectangle, expandCallback:Function) 
		{
			selectedCamera = CameraPosition.FRONT;
			
			this.expandCallback = expandCallback;
			padding = Config.MARGIN;
			this.restrictedArea = restrictedArea;
			
			create();
		}
		
		public function getCamera(index:int = 0):Camera
		{
			return camera;
			
			//!TODO:;
			
			/*try{
				camera = Camera.getCamera(index+"");
			}catch (e:Error){
				echo("CallManager", "createCamera","Can`t get camera");
			}
			
			if (camera == null)
				camera = Camera.getCamera();*/
				
		}
		
		private function create():void 
		{
			background = new Sprite();
			addChild(background);
			
			videoContainer = new Sprite()
			addChild(videoContainer);
			
			video = new Video();
			videoContainer.addChild(video);
			
			maskClip = new Sprite();
			addChild(maskClip);
			maskClip.visible = false;
			
			if (restrictedArea != null)
			{
				videoContainer.mask = maskClip;
				
				expandButton = new BitmapButton();
				expandButton.setStandartButtonParams();
				expandButton.usePreventOnDown = false;
				expandButton.tapCallback = expand;
				expandButton.cancelOnVerticalMovement = true;
				var icon:ExpandIcon = new ExpandIcon();
				UI.scaleToFit(icon, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
				expandButton.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "FloatVideo.button"));
				addChild(expandButton);
				expandButton.visible = false;
			}
		}
		
		private function expand():void 
		{
			if (expandCallback != null)
			{
				expandCallback.call();
			}
		}
		
		public function setStream(ns:NetStream, size:Rectangle):void 
		{
			this.size = size;
			attachStream(ns);
		}
		
		private function attachStream(ns:NetStream):void 
		{
			if (ns == null)
			{
				getCameraPermission();
			}
			else
			{
				
			}
		}
		
		private function getCameraPermission():void {
			if (Camera.isSupported) {
				if (Camera.permissionStatus != PermissionStatus.GRANTED && (Camera as Object).permissionStatus  !== undefined) {
					var cam:Camera = Camera.getCamera();
					cam.addEventListener(PermissionEvent.PERMISSION_STATUS, function(e:PermissionEvent):void {
						if (e.status == PermissionStatus.GRANTED || e.status == PermissionStatus.ONLY_WHEN_IN_USE)
						{
							getMicrophonePermission();
							return;
						}
						else
						{
							//!TODO:;
						}
					});
					try {
						cam.requestPermission();
					} catch(err:Error) {
						echo("CallManager", "getCameraPermission", err.message, true);
					}
				} else
					getMicrophonePermission();
			} else
				getMicrophonePermission();
		}
		
		private function getMicrophonePermission():void {
			if (Microphone.isSupported) {
				if (Microphone.permissionStatus != PermissionStatus.GRANTED && (Microphone as Object).permissionStatus  !== undefined) {
					var mic:Microphone = Microphone.getMicrophone();
					mic.addEventListener(PermissionEvent.PERMISSION_STATUS, function(e:PermissionEvent):void {
						lastSelectedSize = size;
						attachCamera(lastSelectedSize);
						return;
					});
					try {
						mic.requestPermission();
					} catch(err:Error) {
						echo("CallManager", "getMicrophonePermission", err.message, true);
					}
				} else
				{
					lastSelectedSize = size;
					attachCamera(lastSelectedSize);
				}
			} else
			{
				lastSelectedSize = size;
				attachCamera(lastSelectedSize);
			}
		}
		
		public function activate():void
		{
			if (restrictedArea != null)
			{
				PointerManager.addDown(this, onTouchStart);
			}
			
			if (expandButton != null)
			{
				expandButton.activate();
			}
			
			if (nextButton != null)
			{
				nextButton.activate();
			}
			
			if (backButton != null)
			{
				backButton.activate();
			}
		}
		
		private function onTouchStart(e:Event = null):void 
		{
			if (lockedMove) 
			{
				return;
			}
			
			e.stopImmediatePropagation();
			e.stopPropagation();
			if (moving == false)
			{
				if (e is MouseEvent)
				{
					startTouchPoint = new Point((e as MouseEvent).stageX - x, (e as MouseEvent).stageY - y);
				}
				else
				{
					//!TODO;
				}
				
				moving = true;
				PointerManager.addMove(this, onTouchMove);
				PointerManager.addUp(MobileGui.stage, onTouchEnd);
			}
		}
		
		private function onTouchEnd(e:Event):void 
		{
			if (restrictedArea != null)
			{
				PointerManager.removeMove(this, onTouchMove);
				PointerManager.removeUp(MobileGui.stage, onTouchEnd);
				
				if (needAnimate)
				{
					needAnimate = false;
					
					var newX:int = x;
					var newY:int = y;
					
					if (newX < restrictedArea.x + padding)
					{
						newX = restrictedArea.x + padding;
					}
					else if (newX + size.width > restrictedArea.x + restrictedArea.width - padding)
					{
						newX = restrictedArea.x + restrictedArea.width - padding - size.width;
					}
					
					if (newY < restrictedArea.y + padding)
					{
						newY = restrictedArea.y + padding;
					}
					else if (newY + size.height > restrictedArea.y + restrictedArea.height - padding)
					{
						newY = restrictedArea.y + restrictedArea.height - padding - size.height;
					}
					
					TweenMax.to(this, 0.3, {x:newX, y:newY});
				}
			}
			
			moving = false;
		}
		
		private function onTouchMove(e:Event):void 
		{
			e.stopImmediatePropagation();
			e.stopPropagation();
			var newX:int;
			var newY:int;
			
			if (e is MouseEvent)
			{
				newX = (e as MouseEvent).stageX - startTouchPoint.x;
				newY = (e as MouseEvent).stageY - startTouchPoint.y;
			}
			else
			{
				//!TODO;
			}
			
			if (newX < restrictedArea.x + padding)
			{
				newX = restrictedArea.x + padding + (newX - restrictedArea.x - padding) * .5;
				needAnimate = true;
			}
			else if (newX + size.width > restrictedArea.x + restrictedArea.width - padding)
			{
				newX = restrictedArea.x + restrictedArea.width - padding - size.width + (newX - (restrictedArea.x + restrictedArea.width - padding - size.width)) * .5;
				needAnimate = true;
			}
			
			if (newY < restrictedArea.y + padding)
			{
				newY = restrictedArea.y + padding + (newY - restrictedArea.y - padding) * .5;
				needAnimate = true;
			}
			else if (newY + size.height > restrictedArea.y + restrictedArea.height - padding)
			{
				newY = restrictedArea.y + restrictedArea.height - padding - size.height + (newY - (restrictedArea.y + restrictedArea.height - padding - size.height)) * .5;
				needAnimate = true;
			}
			
			x = newX;
			y = newY;
		}
		
		public function deactivate():void
		{
			if (restrictedArea != null)
			{
				PointerManager.removeDown(this, onTouchStart);
				PointerManager.removeMove(this, onTouchMove);
				PointerManager.removeUp(MobileGui.stage, onTouchEnd);
			}
			
			if (expandButton != null)
			{
				expandButton.deactivate();
			}
			
			if (nextButton != null)
			{
				nextButton.deactivate();
			}
			
			if (backButton != null)
			{
				backButton.deactivate();
			}
			
			moving = false;
		}
		
		private function createCamera(position:String):Camera
		{
			for (var i:uint = 0; i < Camera.names.length; ++i)
			{
				var cam:Camera = Camera.getCamera(String(i));
				if (cam.position == position) return cam;
			}
			return Camera.getCamera();
		}
		
		private function attachCamera(selectedSize:Rectangle):void 
		{
			if (Camera.isSupported){
				
				camera = createCamera(selectedCamera);
				
				/*var resultArea:Rectangle = new Rectangle();
				var k:Number = Math.max(size.width / camera.width, size.height / camera.height);
				resultArea.x = size.x;
				resultArea.y = size.y;
				resultArea.height = int(camera.height * k);
				resultArea.width = int(camera.width * k);*/
				
				
				if (Config.PLATFORM_APPLE)
				{
					camera.setMode(selectedSize.height, selectedSize.width, 15);
					
					video.rotation = 0;
					
					video.width = selectedSize.height;
					video.height = selectedSize.width;
					
					video.rotation = 90;
					video.x = selectedSize.width;
				}
				else
				{
					camera.setMode(selectedSize.height, selectedSize.width, 15);
				//	video.x = size.width - 10;
				//	video.y = 10;
				
					video.rotation = 0;
					
					video.width = selectedSize.height;
					video.height = selectedSize.width;
					
					if (maximized == true)
					{
						if (selectedCamera == CameraPosition.FRONT)
						{
							video.rotation = -90;
							video.x = 0;
							video.y = selectedSize.height;
						}
						else
						{
							video.rotation = 90;
							video.x = selectedSize.width;
							video.y = 0;
						}
					}
					else
					{
						if (selectedCamera == CameraPosition.FRONT)
						{
							video.rotation = -90;
							video.y = selectedSize.height;
							video.x = 0;
						}
						else
						{
							video.rotation = 90;
							video.y = 0;
							video.x = selectedSize.width;
						}
					}
				}
				
				video.attachCamera(camera);
			}
			if (restrictedArea != null)
			{
				maskClip.graphics.clear();
				maskClip.graphics.beginFill(0);
				maskClip.graphics.drawRoundRect(0, 0, selectedSize.width, selectedSize.height, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
				maskClip.graphics.endFill();
				
				var padding:int = Config.FINGER_SIZE * .06;
				
				background.graphics.clear();
				background.graphics.beginFill(0xFFFFFF, 1);
				background.graphics.drawRoundRect( -padding, -padding, selectedSize.width + padding * 2, selectedSize.height + padding * 2, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
				background.graphics.endFill();
				
			//	expandButton.x = int(Config.FINGER_SIZE * .1);
			//	expandButton.y = int(selectedSize.height - expandButton.height - Config.FINGER_SIZE * .1);
			}
			else
			{
				background.graphics.clear();
				background.graphics.beginFill(0xc4def1, 1);
				background.graphics.drawRoundRect( 0, 0, selectedSize.width, selectedSize.height, 0, 0);
				background.graphics.endFill();
			}
		}
		
		public function dispose():void
		{
			video.attachCamera(null);
			video = null;
			size = null;
			camera = null;
			restrictedArea = null;
			startTouchPoint = null;
			
			UI.destroy(maskClip);
			maskClip = null;
			
			UI.destroy(background);
			background = null;
			
			if (expandButton != null)
			{
				expandButton.dispose();
				expandButton = null;
			}
			
			TweenMax.killTweensOf(this);
			
			expandCallback = null;
			
			PointerManager.removeDown(this, onTouchStart);
			PointerManager.removeMove(this, onTouchMove);
			PointerManager.removeUp(MobileGui.stage, onTouchEnd);
		}
		
		public function show(duration:Number):void 
		{
			y = startPosition - Config.FINGER_SIZE;
			alpha = 0;
			TweenMax.to(this, duration, {alpha:1, y:startPosition});
			visible = true;
		}
		
		private function makeInvisible():void 
		{
			visible = false;
		}
		
		public function hide():void 
		{
			TweenMax.to(this, 0.3, {alpha:0, y:startPosition - Config.FINGER_SIZE, onComplete:makeInvisible});
			hided = true;
		}
		
		public function setPosition(position:int):void 
		{
			y = position;
			startPosition = position;
		}
		
		public function onShown():void 
		{
			hided = false;
		}
		
		public function takePhoto(onPhotoResult:Function, title:String, overlay:String):void 
		{
			this.overlay = overlay;
			
			if (maximized == false)
			{
				maximize(title);
			}
			
			currentPhotoCallback = onPhotoResult;
		}
		
		public function onSuccess():void 
		{
			selectedCamera = CameraPosition.FRONT;
			minimize();
		}
		
		public function showLoadingState():void 
		{
			if (loader == null)
			{
				loader = new CirclePreloader();
				addChild(loader);
				loader.x = lastSelectedSize.width * .5;
				loader.y = lastSelectedSize.height * .5;
			}
		}
		
		public function hideLoadingState():void 
		{
			if (loader != null)
			{
				loader.dispose();
				if (loader.parent != null)
				{
					loader.parent.removeChild(loader);
				}
				loader = null;
			}
		}
		
		public function switchCamera(camera:String):void 
		{
			if (camera == VIAction.CAMERA_FRONT)
			{
				selectedCamera = CameraPosition.FRONT;
			}
			else if (camera == VIAction.CAMERA_REAR)
			{
				selectedCamera = CameraPosition.BACK;
			}
			attachCamera(lastSelectedSize);
		}
		
		public function toStartState():void 
		{
			backClick();
		}
		
		private function maximize(title:String):void 
		{
			maximized = true;
			currentTitle = title;
			
			lastX = x;
			lastY = y;
			
			animateMaximaze();
			
			lockedMove = true;
			
			PointerManager.removeDown(this, onTouchStart);
		}
		
		private function animateMaximaze():void 
		{
			var maxSize:Rectangle = new Rectangle();
			maxSize.x = Config.MARGIN;
			maxSize.y = Config.MARGIN + Config.APPLE_TOP_OFFSET;
			maxSize.width = MobileGui.stage.fullScreenWidth - Config.MARGIN * 2;
			
			if (Config.PLATFORM_ANDROID == true)
			{
				maxSize.height = MobileGui.stage.stageHeight - Config.MARGIN * 2 - Config.APPLE_TOP_OFFSET - Config.APPLE_BOTTOM_OFFSET;
			}
			else
			{
				maxSize.height = MobileGui.stage.fullScreenHeight - Config.MARGIN * 2 - Config.APPLE_TOP_OFFSET - Config.APPLE_BOTTOM_OFFSET;
			}
			
			var time:Number = 0.3;
			
			var animateObject:Object = new Object();
			animateObject.startWidth = video.width;
			animateObject.startHeight = video.height;
			
			animateObject.endWidth = maxSize.width;
			animateObject.endHeight = maxSize.height;
			
			TweenMax.to(animateObject, time, {startWidth:animateObject.endWidth, startHeight:animateObject.endHeight, onUpdateParams:[animateObject], onUpdate:updateMaximize, onComplete:onMaximizeComplete});
			
			TweenMax.to(this, time, {x:maxSize.x, y:maxSize.y});
		}
		
		private function onMaximizeComplete():void 
		{
			var maxSize:Rectangle = new Rectangle();
			maxSize.x = Config.MARGIN;
			maxSize.y = Config.MARGIN + Config.APPLE_TOP_OFFSET;
			maxSize.width = MobileGui.stage.fullScreenWidth - Config.MARGIN * 2;
			if (Config.PLATFORM_ANDROID == true)
			{
				maxSize.height = MobileGui.stage.stageHeight - Config.MARGIN * 2 - Config.APPLE_TOP_OFFSET - Config.APPLE_BOTTOM_OFFSET;
			}
			else
			{
				maxSize.height = MobileGui.stage.fullScreenHeight - Config.MARGIN * 2 - Config.APPLE_TOP_OFFSET - Config.APPLE_BOTTOM_OFFSET;
			}
			
			lastSelectedSize = maxSize;
			attachCamera(lastSelectedSize);
			
			x = maxSize.x;
			y = maxSize.y;
			
			addTitle(currentTitle, maxSize);
			
			if (overlay != null)
			{
				
			}
		}
		
		private function updateMaximize(animateObject:Object):void 
		{
			var padding:int = Config.FINGER_SIZE * .06;
			
			if (Config.PLATFORM_APPLE)
			{
				video.rotation = 0;
				video.width = animateObject.startHeight;
				video.height = animateObject.startWidth;
				video.rotation = 90;
				video.x = animateObject.startWidth;
				
				maskClip.graphics.clear();
				maskClip.graphics.beginFill(0);
				maskClip.graphics.drawRoundRect(0, 0, video.width, video.height, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
				maskClip.graphics.endFill();
				
				background.graphics.clear();
				background.graphics.beginFill(0xFFFFFF, 1);
				background.graphics.drawRoundRect( -padding, -padding, video.width + padding * 2, video.height + padding * 2, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
				background.graphics.endFill();
			}
			else
			{
				video.rotation = 0;
				video.width = animateObject.startHeight;
				video.height = animateObject.startWidth;
				
				if (selectedCamera == CameraPosition.FRONT)
				{
					video.rotation = -90;
					video.x = 0;
					video.y = animateObject.startHeight;
				}
				else
				{
					video.rotation = 90;
					video.x = animateObject.startWidth;
					video.y = 0;
				}
				
				maskClip.graphics.clear();
				maskClip.graphics.beginFill(0);
				maskClip.graphics.drawRoundRect(0, 0, video.width, video.height, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
				maskClip.graphics.endFill();
				
				background.graphics.clear();
				background.graphics.beginFill(0xFFFFFF, 1);
				background.graphics.drawRoundRect( -padding, -padding, video.width + padding * 2, video.height + padding * 2, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
				background.graphics.endFill();
			}
		}
		
		private function addTitle(title:String, maxSize:Rectangle):void 
		{
			if (titleClip == null)
			{
				titleClip = new Sprite();
				videoContainer.addChild(titleClip);
				
				if (titleText == null)
				{
					titleText = new Bitmap();
					titleClip.addChild(titleText);
				}
				
				drawTitleText(title, maxSize);
			}
			
			if (backButton == null)
			{
				backButton = new BitmapButton();
				backButton.setStandartButtonParams();
				backButton.setDownScale(1);
				backButton.setDownColor(0);
				backButton.tapCallback = backClick;
				backButton.disposeBitmapOnDestroy = true;
				backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
				addChild(backButton);
				
				drawBackButton();
			}
			
			if (nextButton == null)
			{
				nextButton = new BitmapButton();
				nextButton.setStandartButtonParams();
				nextButton.setDownScale(1);
				nextButton.setDownColor(0);
				nextButton.tapCallback = nextClick;
				nextButton.disposeBitmapOnDestroy = true;
				nextButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
				addChild(nextButton);
			}
			
			drawNextButton(Lang.makePhoto);
			
			backButton.x = maxSize.width * .5 - backButton.width - Config.MARGIN;
			nextButton.x = maxSize.width * .5 + Config.MARGIN;
			backButton.y = nextButton.y = int(maxSize.height - backButton.height - Config.MARGIN);
			
			backButton.activate();
			nextButton.activate();
		}
		
		private function drawTitleText(title:String, maxSize:Rectangle):void 
		{
			if (titleText != null)
			{
				if (titleText.bitmapData != null)
				{
					titleText.bitmapData.dispose();
					titleText.bitmapData = null;
				}
				titleText.bitmapData = TextUtils.createTextFieldData(title, maxSize.width - Config.DIALOG_MARGIN*2, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .34, true, 0x5B6770, 
															0xFFFFFF, false, true);
				titleText.x = Config.DIALOG_MARGIN;
				titleText.y = int(Config.FINGER_SIZE * .3);
				titleClip.graphics.clear();
				titleClip.graphics.beginFill(0xFFFFFF);
				titleClip.graphics.drawRect(0, 0, maxSize.width, int(titleText.height + Config.FINGER_SIZE * .6));
				titleClip.graphics.endFill();
			}
		}
		
		private function drawNextButton(text:String):void
		{
			var componentsWidth:int = MobileGui.stage.fullScreenWidth - Config.DIALOG_MARGIN * 2;
			
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawBackButton():void
		{
			var componentsWidth:int = MobileGui.stage.fullScreenWidth - Config.DIALOG_MARGIN * 2;
			
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0x657280, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0xFFFFFF, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			backButton.setBitmapData(buttonBitmap, true);
		}
		
		private function nextClick():void 
		{
			if (imagePreview == null)
			{
				makePhoto();
			}
			else
			{
				if (currentPhotoCallback != null)
				{
					var bd:ImageBitmapData = currentBitmap;
					currentBitmap = null;
					currentPhotoCallback(true, bd);
				}
				
			//	currentPhotoCallback = null;
			}
		}
		
		private function makePhoto():void 
		{
		//	nextButton.visible = false;
		//	backButton.visible = false;
			
			if (currentBitmap != null)
			{
				currentBitmap.dispose();
				currentBitmap = null;
			}
			
			var bd:ImageBitmapData = new ImageBitmapData("FloatVideo.screen", video.width, video.height, false, 0xFFFFFF);
			videoContainer.mask = null;
			bd.draw(video, video.transform.matrix);
			videoContainer.mask = maskClip;
			currentBitmap = bd;
			
			if (imagePreview == null)
			{
				imagePreview = new Bitmap(bd.clone());
				videoContainer.addChild(imagePreview);
				imagePreview.width = video.width + Config.FINGER_SIZE * 2;
				imagePreview.height = video.height + Config.FINGER_SIZE * 2;
				imagePreview.x = -Config.FINGER_SIZE;
				imagePreview.y = -Config.FINGER_SIZE;
				video.visible = false;
				
				
				var m:Array = new Array();
				m = m.concat([1, 0, 0, 0, 255]);  // red
				m = m.concat([0, 1, 0, 0, 255]);  // green
				m = m.concat([0, 0, 1, 0, 255]);  // blue
				m = m.concat([0, 0, 0, 1, 0]);
				var filter:ColorMatrixFilter = new ColorMatrixFilter(m);
				
			//	imagePreview.filters = [filter]; 
				
			//	TweenMax.to(imagePreview, 0.6, {colorMatrixFilter:{brightness:1}});
				
				TweenMax.to(imagePreview, 0.6, {width:video.width, height:video.height, x:0, y:0, onComplete:onScreenshotReady, ease:Power2.easeOut});
			}
		}
		
		private function onScreenshotReady():void 
		{
		//	nextButton.visible = true;
		//	backButton.visible = true;
			
		//	drawNextButton(Lang.textSend);
			
			var bd:ImageBitmapData = currentBitmap;
			currentBitmap = null;
			currentPhotoCallback(true, bd);
		}
		
		private function backClick():void 
		{
			if (currentBitmap != null)
			{
				currentBitmap.dispose();
				currentBitmap = null;
			}
			
			if (imagePreview != null)
			{
				backToVideo();
			}
			else
			{
				if (currentPhotoCallback != null)
				{
					currentPhotoCallback(false, null);
				}
				
			//	currentPhotoCallback = null;
				
				minimize();
			}
		}
		
		private function backToVideo():void 
		{
			drawNextButton(Lang.makePhoto);
			video.visible = true;
			if (imagePreview != null)
			{
				videoContainer.removeChild(imagePreview);
				UI.destroy(imagePreview);
				imagePreview = null;
			}
		}
		
		private function minimize():void 
		{
			maximized = false;
			
			Overlay.removeCurrent();
			
			if (imagePreview != null)
			{
				backToVideo();
			}
			
			var time:Number = 0.3;
			
			
			var animateObject:Object = new Object();
			animateObject.startWidth = video.width;
			animateObject.startHeight = video.height;
			
			animateObject.endWidth = size.width;
			animateObject.endHeight = size.height;
			
			TweenMax.to(animateObject, time, {startWidth:animateObject.endWidth, startHeight:animateObject.endHeight, onUpdateParams:[animateObject], onUpdate:updateMinimize, onComplete:onMinimizeComplete});
			
			
		//	TweenMax.to(video, time, {width:size.width, height:size.height, onUpdate:updateMinimize, onComplete:onMinimizeComplete, ease:Power2.easeOut});
			TweenMax.to(this, time, {x:lastX, y:lastY});
			
			removeTitle();
			removeButtons();
		}
		
		private function onMinimizeComplete():void 
		{
			lastSelectedSize = size;
			attachCamera(lastSelectedSize);
			
			x = lastX;
			y = lastY;
			
			PointerManager.addDown(this, onTouchStart);
			
			lockedMove = false;
		}
		
		private function updateMinimize(animateObject:Object):void 
		{
			if (Config.PLATFORM_APPLE)
			{
				video.rotation = 0;
				video.width = animateObject.startHeight;
				video.height = animateObject.startWidth;
				video.rotation = 90;
				video.x = animateObject.startWidth;
				
				maskClip.graphics.clear();
				maskClip.graphics.beginFill(0);
				maskClip.graphics.drawRoundRect(0, 0, video.width, video.height, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
				maskClip.graphics.endFill();
				
				background.graphics.clear();
				background.graphics.beginFill(0xFFFFFF, 1);
				background.graphics.drawRoundRect( -padding, -padding, video.width + padding * 2, video.height + padding * 2, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
				background.graphics.endFill();
			}
			else
			{
				video.rotation = 0;
				video.width = animateObject.startHeight;
				video.height = animateObject.startWidth;
				video.rotation = -90;
				video.y = animateObject.startHeight;
				video.x = 0;
				
				maskClip.graphics.clear();
				maskClip.graphics.beginFill(0);
				maskClip.graphics.drawRoundRect(0, 0, video.width, video.height, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
				maskClip.graphics.endFill();
				
				background.graphics.clear();
				background.graphics.beginFill(0xFFFFFF, 1);
				background.graphics.drawRoundRect( -padding, -padding, video.width + padding * 2, video.height + padding * 2, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
				background.graphics.endFill();
			}
			
			maskClip.graphics.clear();
			maskClip.graphics.beginFill(0);
			maskClip.graphics.drawRoundRect(0, 0, video.width, video.height, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			maskClip.graphics.endFill();
			
			var padding:int = Config.FINGER_SIZE * .06;
			
			background.graphics.clear();
			background.graphics.beginFill(0xFFFFFF, 1);
			background.graphics.drawRoundRect( -padding, -padding, video.width + padding * 2, video.height + padding * 2, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
			background.graphics.endFill();
		}
		
		private function removeTitle():void 
		{
			if (titleClip != null)
			{
				titleClip.graphics.clear();
				if (titleClip.parent != null)
				{
					titleClip.parent.removeChild(titleClip);
				}
				titleClip = null;
			}
			if (titleText != null)
			{
				if (titleText.bitmapData != null)
				{
					titleText.bitmapData.dispose();
					titleText.bitmapData = null;
				}
				if (titleText.parent != null)
				{
					titleText.parent.removeChild(titleText);
				}
				titleText = null;
			}
		}
		
		private function removeButtons():void 
		{
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
			//	removeChild(backButton);
			}
			
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			//	removeChild(nextButton);
			}
		}
	}
}