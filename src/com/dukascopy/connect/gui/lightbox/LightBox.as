package com.dukascopy.connect.gui.lightbox {
		import assets.CircleLoaderShape;
		import assets.NextIcon;
		import assets.PrewIcon;
		import asssets.EmptyImage;
		import com.dukascopy.connect.Config;
		import com.dukascopy.connect.MobileGui;
		import com.dukascopy.connect.data.ImageContextMenuTexts;
		import com.dukascopy.connect.data.TextFieldSettings;
		import com.dukascopy.connect.data.screenAction.IScreenAction;
		import com.dukascopy.connect.data.screenAction.customActions.OpenFxProfileAction;
		import com.dukascopy.connect.data.screenAction.customActions.SaveOpenImageAction;
		import com.dukascopy.connect.gui.components.CirclePreloader;
		import com.dukascopy.connect.gui.list.renderers.ListLinkWithIcon;
		import com.dukascopy.connect.gui.menuVideo.BitmapButton;
		import com.dukascopy.connect.gui.preloader.Preloader;
		import com.dukascopy.connect.gui.shapes.Box;
		import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
		import com.dukascopy.connect.sys.chatManager.ChatManager;
		import com.dukascopy.connect.sys.connectionManager.NetworkManager;
		import com.dukascopy.connect.sys.contentProvider.IContentProvider;
		import com.dukascopy.connect.sys.crypter.Crypter;
		import com.dukascopy.connect.sys.dialogManager.DialogManager;
		import com.dukascopy.connect.sys.echo.echo;
		import com.dukascopy.connect.sys.imageManager.IImageData;
		import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
		import com.dukascopy.connect.sys.imageManager.ImageManager;
		import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
		import com.dukascopy.connect.sys.pointerManager.PointerManager;
		import com.dukascopy.connect.utils.FilesSaveUtility;
		import com.dukascopy.connect.utils.ImageCrypterOld;
		import com.dukascopy.connect.utils.TextUtils;
		import com.dukascopy.langs.Lang;
		import com.greensock.TweenLite;
		import com.greensock.TweenMax;
		import com.greensock.easing.Expo;
		import com.telefision.sys.signals.Signal;
		import flash.display.Bitmap;
		import flash.display.BitmapData;
		import flash.display.DisplayObjectContainer;
		import flash.display.Sprite;
		import flash.display.Stage;
		import flash.display.StageOrientation;
		import flash.display.StageQuality;
		import flash.events.Event;
		import flash.filters.BitmapFilterQuality;
		import flash.filters.BlurFilter;
		import flash.geom.Matrix;
		import flash.geom.Point;
		import flash.geom.Rectangle;
		import flash.net.URLRequest;
		import flash.net.navigateToURL;
		import flash.text.TextFieldAutoSize;
		import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Alexey
	 */
	
	public class LightBox {
		
		public static var S_LIGHTBOX_CLOSED:Signal = new Signal("LightBox.S_LIGHTBOX_CLOSED");
		public static var S_LIGHTBOX_OPENED:Signal = new Signal("LightBox.S_LIGHTBOX_OPENED");
		public static var S_REQUEST_PREW_CONTENT:Signal = new Signal("LightBox.S_REQUEST_PREW_CONTENT");
		
		//pool
		private static var freeVOStock:Vector.<LightBoxItemVO> = new Vector.<LightBoxItemVO>;
		private static var addedVOStock:Vector.<LightBoxItemVO> = new Vector.<LightBoxItemVO>;
		private static var currentLightBoxVO:LightBoxItemVO;
		private static var hash:Object = { };
		
		//flags 
		private static var isCreated:Boolean = false;
		private static var _isShowing:Boolean = false;
		private static var stageReady:Boolean = false;
		
		private static var _stageRef:Stage;
		private static var viewWidth:int = 0;
		private static var viewHeight:int = 0;
		
		private static var _imageLoaded:Boolean = false;
		
		// ui 
		private static var _view:DisplayObjectContainer;		
		private static var animationLayer:Sprite = new Sprite();	
		private static var viewHolder:Sprite = new Sprite();
		private static var background:Box;
		private static var preloader:CirclePreloader;
		private static var lightBoxMenu:LightboxMenu;		
		private static var zoomPanCont:ZoomPanContainer;
		
		//pagination
		private static var _currentIndex:int = -1;
		private static var _currentShowDirection:int = -1;
		
		// calculation rectangles 
		private static var tempRect:Rectangle = new Rectangle();
		private static var croprect:Rectangle = new Rectangle();
		
		private static var saveShedule:TweenLite;
		
		/** INTERSECTION OF VIEW PORT AND IMAGE IN LIGHTBOX **/
		private static var viewPortRect:Rectangle= new Rectangle();
		private static var imageRect:Rectangle = new Rectangle();
		static private var appleHeaderSprite:Sprite;
		static private var loadingDescription:Bitmap;
		static private var previewImageDisplayed:Boolean;
		static private var header:LightboxHeader;
		static private var lastPreview:Bitmap;
	//	static private var circleLoader:CircleProgress;
		static private var headerMask:Sprite;
		static private var currentActions:Vector.<IScreenAction>;
		static private var openFxProfileButton:BitmapButton;
		static private var opeLinkButton:BitmapButton;
		static private var listenForScreenRotation:Boolean;
		static private var currentContentProvider:IContentProvider;
		static private var imagesCounter:Bitmap;
		static private var imagesLoader:Preloader;
		static private var nextPhotoButton:BitmapButton;
		static private var prewPhotoButton:BitmapButton;
		static private var inTransition:Boolean;
		static private var currentLink:String;
		static private var currentUserFxName:String;
		static private var currentRetryIndex:int = 0;
		static private var mainImageLoadError:Boolean = false;
		static private var loadImageInProgress:Boolean = false;
		
		public function LightBox() {}
		
		public static function setStage(stageRef:Stage,view:DisplayObjectContainer):void {
			if (stageRef != null) {
				_stageRef  = stageRef;
				_stageRef.addEventListener(Event.RESIZE, onResize);
				_view = view;
				stageReady = true;
			} else {
				//trace("LightBox -> cannot assign stage reference because it cannot be null  ");
			}
		}
		
		private static function createView():void {
			
			echo("Lightbox", "createView", "START");
			
			if (!stageReady || isCreated)
				return;
			isCreated = true;
			
			viewWidth = _stageRef.stageWidth;
			viewHeight = _stageRef.stageHeight;
			
			zoomPanCont = new ZoomPanContainer(_stageRef, 0, 0);
			zoomPanCont.topOffset = 0;
			zoomPanCont.setViewportSize(viewWidth,viewHeight );
			zoomPanCont.closeCallback = onClose;
			zoomPanCont.tapCallback = onTap;
			zoomPanCont.longPressCallback = onLongPress;
			zoomPanCont.dragOpacityCallback = onDragOpacity;
			zoomPanCont.showNextFunction = displayNext;
			zoomPanCont.showPrevFunction = displayPrev;
			zoomPanCont.usePagination = true;
			
			background = new Box(0x000000, viewWidth, viewHeight, 1);
			viewHolder.addChild(background);
			viewHolder.addChild(zoomPanCont);
			viewHolder.addChild(animationLayer);
			
			lightBoxMenu = new LightboxMenu();
			lightBoxMenu.stageRef = _stageRef;
			lightBoxMenu.setSize(viewWidth, viewHeight);
			viewHolder.addChild(lightBoxMenu);
			
			if (Config.PLATFORM_APPLE)
			{
				appleHeaderSprite = new Sprite();
				appleHeaderSprite.graphics.beginFill(0, 0.8);
				appleHeaderSprite.graphics.drawRect(0, 0, viewWidth, Config.APPLE_TOP_OFFSET);
				appleHeaderSprite.graphics.endFill();
			}
			header = new LightboxHeader(viewWidth, Config.FINGER_SIZE * .85);
			header.S_ON_BACK.add(onBackButtonClick);
			header.settingsCallback = openSettings;
			viewHolder.addChild(header);
			
			var headerTopGap:int = 0;
			if (MobileGui.currentOrientation == StageOrientation.UPSIDE_DOWN || MobileGui.currentOrientation == StageOrientation.DEFAULT)
				headerTopGap = Config.APPLE_TOP_OFFSET;
			
			header.y = headerTopGap;
			
			headerMask = new Sprite();
			headerMask.graphics.beginFill(0);
			headerMask.graphics.drawRect(0, 0, viewWidth, header.getHeight());
			headerMask.graphics.endFill();
			headerMask.y = header.y;
			viewHolder.addChild(headerMask);
			header.mask = headerMask;
			
			/*circleLoader = new CircleProgress();
			viewHolder.addChild(circleLoader);
			circleLoader.x = int(viewWidth * .5);
			circleLoader.y = int(viewHeight * .5);*/
			
			loadingDescription = new Bitmap();
			viewHolder.addChild(loadingDescription);
			
			openFxProfileButton = new BitmapButton();
			openFxProfileButton.setStandartButtonParams();
			openFxProfileButton.setDownScale(1);
			openFxProfileButton.setDownColor(0xFFFFFF);
			openFxProfileButton.tapCallback = openFxProfile;
			openFxProfileButton.disposeBitmapOnDestroy = true;
			openFxProfileButton.hide();
			openFxProfileButton.deactivate();
			viewHolder.addChild(openFxProfileButton);
			
			openFxProfileButton.setBitmapData(TextUtils.createbutton(new TextFieldSettings(Lang.openProfile, 0xFFFFFF, Config.FINGER_SIZE * .28), 0xFFFFFF, 0.15), true);
			
			openFxProfileButton.x = int(viewWidth - openFxProfileButton.width - Config.MARGIN);
			openFxProfileButton.y = int(viewHeight - openFxProfileButton.height - Config.MARGIN -Config.APPLE_BOTTOM_OFFSET);
			
			
			opeLinkButton = new BitmapButton();
			opeLinkButton.setStandartButtonParams();
			opeLinkButton.setDownScale(1);
			opeLinkButton.setDownColor(0xFFFFFF);
			opeLinkButton.tapCallback = openLink;
			opeLinkButton.disposeBitmapOnDestroy = true;
			opeLinkButton.hide();
			opeLinkButton.deactivate();
			viewHolder.addChild(opeLinkButton);
			
			
			imagesCounter = new Bitmap();
			viewHolder.addChild(imagesCounter);
			
			nextPhotoButton = new BitmapButton();
			nextPhotoButton.setStandartButtonParams();
			nextPhotoButton.setDownScale(1);
			nextPhotoButton.setDownColor(0xFFFFFF);
			nextPhotoButton.tapCallback = displayNext;
			nextPhotoButton.disposeBitmapOnDestroy = true;
			nextPhotoButton.hide();
			
			var iconNext:NextIcon = new NextIcon();
			UI.scaleToFit(iconNext, Config.FINGER_SIZE*.7, Config.FINGER_SIZE*.7);
			nextPhotoButton.setBitmapData(UI.getSnapshot(iconNext, StageQuality.HIGH, "LightBox.nextIcon"), true);
			nextPhotoButton.setOverflow(Config.FINGER_SIZE * 2, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE * 2);
			iconNext = null;
			viewHolder.addChild(nextPhotoButton);
			
			
			prewPhotoButton = new BitmapButton();
			prewPhotoButton.setStandartButtonParams();
			prewPhotoButton.setDownScale(1);
			prewPhotoButton.setDownColor(0xFFFFFF);
			prewPhotoButton.tapCallback = displayPrev;
			prewPhotoButton.disposeBitmapOnDestroy = true;
			prewPhotoButton.hide();
			
			var iconPrew:PrewIcon = new PrewIcon();
			UI.scaleToFit(iconPrew, Config.FINGER_SIZE*.7, Config.FINGER_SIZE*.7);
			prewPhotoButton.setBitmapData(UI.getSnapshot(iconPrew, StageQuality.HIGH, "LightBox.nextIcon"), true);
			prewPhotoButton.setOverflow(Config.FINGER_SIZE * 2, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE * 2);
			iconPrew = null;
			viewHolder.addChild(prewPhotoButton);
			
			var loaderSize:int = Config.FINGER_SIZE * .5;
			if (loaderSize%2 == 1)
				loaderSize ++;
			imagesLoader = new Preloader(loaderSize, CircleLoaderShape);
			viewHolder.addChild(imagesLoader);
			imagesLoader.hide();
			
			updateImageLoaderPosition();
		}
		
		static private function openFxProfile():void {
			var action:OpenFxProfileAction = new OpenFxProfileAction(currentUserFxName);
			action.execute();
		}
		
		static private function openLink():void {
			if (currentLink != null) {
				navigateToURL(new URLRequest(currentLink));
			}
		}
		
		static private function onBackButtonClick():void {
			echo("Lightbox", "onBackButtonClick", "");
			if (currentLightBoxVO && currentLightBoxVO.cancelCallback != null) {
				currentLightBoxVO.cancelCallback();
			}
			callClose();
		}
		
		static private function openGallery():void {
			echo("Lightbox", "openGallery", "");
			
			if (currentLightBoxVO != null && FilesSaveUtility.getIsFileExists(currentLightBoxVO.URL)) {
				FilesSaveUtility.openGalleryIfFileExists(currentLightBoxVO.URL);
			}
			onTap();
		}
		
		static private function openSettings():void {
			echo("Lightbox", "openSettings", "START");
			var menuItems:Array = new Array();
			
			currentActions = getCurrentImageActions();
			
			if (currentActions.length > 0) {
				for (var i:int = 0; i < currentActions.length; i++) {
					menuItems.push( {
									icon:currentActions[i].getIconClass(),
									fullLink:ImageContextMenuTexts.getText(int(currentActions[i].getData())), 
									id:i
					});
				}
				
				DialogManager.showDialog(ScreenLinksDialog, { callback:
					function(data:Object):void {
						if (data.id == -1) {
							return;
						}
						//!TODO:проверить на наличие;
						if (("id" in data) && currentActions[data.id] != null) {
							currentActions[data.id].execute();
						}
					}
				, data:menuItems, itemClass:ListLinkWithIcon, title:Lang.imageOptions, listenScreenRotation:true} );
			}
			echo("Lightbox", "openSettings", "END");
		}
		
		static private function getCurrentImageActions():Vector.<IScreenAction> {
			var actions:Vector.<IScreenAction> = new Vector.<IScreenAction>();
			
			//пока берём экшены из первого объекта;
			var vo:LightBoxItemVO;
			if (addedVOStock != null && addedVOStock.length > 0 && addedVOStock[0] != null && (addedVOStock[0] as LightBoxItemVO).imageActions != null)	{
				actions = actions.concat((addedVOStock[0] as LightBoxItemVO).imageActions);
			}
			else if (currentLightBoxVO != null && currentLightBoxVO.imageActions != null) {
				actions = actions.concat(currentLightBoxVO.imageActions);
			}
			
			if (currentLightBoxVO != null) {
				var openSaveImageAction:SaveOpenImageAction = new SaveOpenImageAction(currentLightBoxVO.URL, zoomPanCont);
				actions.push(openSaveImageAction);
			}
			
			/*if (currentLightBoxVO != null && FilesSaveUtility.getIsFileExists(currentLightBoxVO.URL)) {
				var openImageAction:OpenImageAction = new OpenImageAction(currentLightBoxVO.URL);
				openImageAction.setData(ImageContextMenuType.OPEN);
				actions.push(openImageAction);
			}
			else
			{
				if (currentLightBoxVO != null) {
					var saveImageAction:SaveImageAction = new SaveImageAction(zoomPanCont, currentLightBoxVO.URL);
					saveImageAction.setData(ImageContextMenuType.SAVE);
					actions.push(saveImageAction);
				}
			}*/
			return actions;
		}
		
		static private function onTap():void
		{
			echo("Lightbox", "onTap", "START");
			TweenMax.killTweensOf(header);
			TweenMax.killTweensOf(openFxProfileButton);
			TweenMax.killTweensOf(imagesCounter);
			
			var headerTopGap:int = 0;
			if (MobileGui.currentOrientation == StageOrientation.UPSIDE_DOWN || MobileGui.currentOrientation == StageOrientation.DEFAULT)
				headerTopGap = Config.APPLE_TOP_OFFSET;
			
			if (header != null && openFxProfileButton != null)
			{
				if (header.shown)
				{
					header.shown = false;
					TweenMax.to(header, 0.5, {y:(headerTopGap - header.getHeight())});
						TweenMax.to(openFxProfileButton, 0.5, { y:(viewHeight + Config.MARGIN) } );
						if (opeLinkButton != null){
							TweenMax.to(opeLinkButton, 0.5, { y:(viewHeight + Config.MARGIN) } );
						}
						
						if (imagesCounter != null)
						{
							TweenMax.to(imagesCounter, 0.5, { y:(viewHeight + Config.MARGIN) } );
				}
					}
				else
				{
					header.shown = true;
					TweenMax.to(header, 0.5, {y:headerTopGap});
						TweenMax.to(openFxProfileButton, 0.5, { y:viewHeight - openFxProfileButton.height - Config.MARGIN } );
						if (opeLinkButton != null){
							TweenMax.to(openFxProfileButton, 0.5, { y:viewHeight - openFxProfileButton.height - Config.MARGIN } );
						}
						if (imagesCounter != null)
						{
							TweenMax.to(imagesCounter, 0.5, { y:viewHeight - openFxProfileButton.height - Config.MARGIN } );
				}
			}
			}
		
			echo("Lightbox", "onTap", "END");
		}
		
		private static function addView():void {
			echo("Lightbox", "addView", "");
			if (_view != null)
			{
			_view.addChild(viewHolder);
			S_LIGHTBOX_OPENED.invoke();
		}
		}
		
		private static function saveImage():void{
			echo("Lightbox", "saveImage", "START");	
			if (zoomPanCont != null && currentLightBoxVO != null && currentLightBoxVO.URL != null) {
				var bmd:BitmapData = zoomPanCont.getBitmapData();
				FilesSaveUtility.saveFileToForGallery(bmd, currentLightBoxVO.URL);
			}
			echo("Lightbox", "saveImage", "END");
		}
		
		private static function removeView():void {
			echo("Lightbox", "removeView", "");	
			if (viewHolder != null && viewHolder.parent != null) {
				viewHolder.parent.removeChild(viewHolder);
			}
			S_LIGHTBOX_CLOSED.invoke();
		}
		
		// EVENT HANDLERS -------------------------------------------------------------------------------------------------------------------------
		//============================================================================
		
		/** ON RESIZE **/
		static private function onResize(e:Event = null):void  {
			echo("Lightbox", "onResize", "START");
			var orientation:String = MobileGui.currentOrientation;
			
			if (_stageRef == null)
			{
				return;
			}
			
			var w:int;
			var h:int;
			var currentRotation:Number = viewHolder.rotation;
			if (orientation == StageOrientation.UPSIDE_DOWN || orientation == StageOrientation.DEFAULT || listenForScreenRotation == false)
			{
				if (appleHeaderSprite != null)
					appleHeaderSprite.visible = true;
				if (viewHolder != null)
				{
				viewHolder.rotation = 0;
				viewHolder.x = 0;
				viewHolder.y = 0;
				}
				
				if (openFxProfileButton != null)
				{
					openFxProfileButton.rotationAdded = 0;
				}
				if (opeLinkButton != null)
				{
					opeLinkButton.rotationAdded = 0;
				}
				if (nextPhotoButton != null)
				{
					nextPhotoButton.rotationAdded = 0;
				}
				if (prewPhotoButton != null)
				{
					prewPhotoButton.rotationAdded = 0;
				}
				
				w = _stageRef.stageWidth;
				h = _stageRef.stageHeight;
				
				if (openFxProfileButton != null)
				{
					openFxProfileButton.rotationAdded = 0;
				}
				if (opeLinkButton != null)
				{
					opeLinkButton.rotationAdded = 0;
				}
			}
			else if (orientation == StageOrientation.ROTATED_LEFT)
			{
				if (appleHeaderSprite != null)
				appleHeaderSprite.visible = false;
				if (viewHolder != null)
				{
				viewHolder.rotation = 90;
				viewHolder.x = _stageRef.fullScreenWidth;
				viewHolder.y = 0;
				}
				
				h = _stageRef.stageWidth;
				w = _stageRef.stageHeight;
				
				hidePopups();
				
				if (openFxProfileButton != null)
				{
					openFxProfileButton.rotationAdded = 90;
				}
				if (opeLinkButton != null)
				{
					opeLinkButton.rotationAdded = 90;
				}
				if (nextPhotoButton != null)
				{
					nextPhotoButton.rotationAdded = 90;
			}
				if (prewPhotoButton != null)
				{
					prewPhotoButton.rotationAdded = 90;
				}
			}
			else if (orientation == StageOrientation.ROTATED_RIGHT)
			{
				if (appleHeaderSprite != null)
				appleHeaderSprite.visible = false;
				if (viewHolder != null)
				{
				viewHolder.rotation = -90;
				viewHolder.y = _stageRef.fullScreenHeight;
				viewHolder.x = 0;
				}
				
				h = _stageRef.stageWidth;
				w = _stageRef.stageHeight;
				
				hidePopups();
				
				if (openFxProfileButton != null)
				{
					openFxProfileButton.rotationAdded = -90;
				}
				if (opeLinkButton != null)
				{
					opeLinkButton.rotationAdded = -90;
				}
				if (nextPhotoButton != null)
				{
					nextPhotoButton.rotationAdded = -90;
			}
				if (prewPhotoButton != null)
			{
					prewPhotoButton.rotationAdded = -90;
			}
			}
			
			if (openFxProfileButton != null)
			{
				openFxProfileButton.x = int(w - openFxProfileButton.width - Config.MARGIN);
			}
			
			if (zoomPanCont != null)
			{
			if (currentRotation != viewHolder.rotation)
			{
				zoomPanCont.animateImageRotation(w, h, currentRotation, viewHolder.rotation);
			}
			else
			{
				zoomPanCont.setViewportSize(w, h);
			}
			}
			
			setSize(w, h, false);
			echo("Lightbox", "onResize", "END");	
		}
		
		static private function hidePopups():void 
		{
			echo("Lightbox", "hidePopups", "");
			DialogManager.closeDialog();
		}
		
		/*** ON  CLOSE ***/	
		private static function onClose():void
		{
			prewButtonAllowed = false;
			prewCallPanding = false;
			
			cancelCurrentLoading();
			echo("Lightbox", "onClose", "START");
			disposeVOs();
			currentLightBoxVO = null;
			isShowing = false;
			hideMenu();
			if (zoomPanCont != null) {
				zoomPanCont.setBitmapData(null, false);
				zoomPanCont.deactivate();
				zoomPanCont.setBitmapData(null, true);
				zoomPanCont.resetTouchPoints();
			}
			if (lightBoxMenu != null) {
				lightBoxMenu.callCancel();
			}
			if (openFxProfileButton)
			{
				openFxProfileButton.deactivate();
				openFxProfileButton.hide();
			}
			if (opeLinkButton)
			{
				opeLinkButton.deactivate();
				opeLinkButton.hide();
			}
			clearContentProvider();
			listenForScreenRotation = false;
			setImagesCounter();
		//	totalLength = 0;
			imagesLoader.hide();
		}
		
		/*** ON LONG PRESS  ***/		
		private static  function onLongPress():void {
			//trace("LONG PRESS ON LIGHTBOX ");
		}
		
		/*** ON DRAG OPACITY CHANGE  ***/
		private static function onDragOpacity(pct:Number):void {
			//trace("BG ALPHA " + pct) ;
			if (isCreated) {
				background.alpha = pct;
				var butH:int = MobileGui.stage.stageHeight * .1;
				lightBoxMenu.hideOffset = butH - (pct * butH);
				
				if (header.shown) {
					var headerTopGap:int = 0;
					if (MobileGui.currentOrientation == StageOrientation.UPSIDE_DOWN || MobileGui.currentOrientation == StageOrientation.DEFAULT)
						headerTopGap = Config.APPLE_TOP_OFFSET;
					
					header.y = headerTopGap + int( -(1 - (pct - 0.1) * 1.111) * header.getHeight());
					openFxProfileButton.y = (viewHeight + Config.MARGIN) - (Config.MARGIN * 2 + openFxProfileButton.height) * ((pct - 0.1) * 1.111) -Config.APPLE_BOTTOM_OFFSET;
					if (opeLinkButton){
						opeLinkButton.y = (viewHeight + Config.MARGIN) - (Config.MARGIN * 2 + opeLinkButton.height) * ((pct - 0.1) * 1.111)-Config.APPLE_BOTTOM_OFFSET;
					}
				}
				
				if (nextPhotoButton != null && nextPhotoButton.getIsShown() == true)
				{
					nextPhotoButton.alpha = pct;
				}
				
				if (prewPhotoButton != null && prewPhotoButton.getIsShown() == true)
				{
					prewPhotoButton.alpha = pct;
				}	
				
				if (imagesCounter != null && imagesCounter.bitmapData != null)
				{
					imagesCounter.y = (viewHeight + Config.MARGIN) - (Config.MARGIN * 2 + openFxProfileButton.height) * ((pct - 0.1) * 1.111)-Config.APPLE_BOTTOM_OFFSET;
				}
			}
		}	
		
		/*** NEXT PAGE **/
		private static  function displayNext():void {
			prewCallPanding = false;
			if (hasNextImage()) {
				//trace("NEXT PAGE");
				zoomPanCont.resetTouchPoints();
				zoomPanCont.forceCheckBounds();
				
				_currentShowDirection = 1;
				hideWithAnimationLeft();
				currentIndex++;
			}else {
				zoomPanCont.forceCheckBounds();
			}			
		}
		
		/** PREV PAGE **/
		private static function displayPrev():void {
			if (hasPrevImage()) {
				zoomPanCont.resetTouchPoints();
				zoomPanCont.forceCheckBounds();
				_currentShowDirection = -1;
				hideWithAnimationRight();
				currentIndex--;
			}else {
				if (allowPrewButton && !prewCallPanding)
				{
					prewCallPanding = true;
					attachPreloader();
					S_REQUEST_PREW_CONTENT.invoke();
				}
				else
				{
					zoomPanCont.forceCheckBounds();
				}
			}
			echo("Lightbox", "displayPrev", "END");
		}
		
		static private function canPrew():Boolean 
		{
			if (prewButtonAllowed)
			{
				return true;
			}
			return hasPrevImage();
		}
		
		/** HIDE TO RIGHT SIDE **/
		private static function hideWithAnimationLeft():void
		{					
			echo("Lightbox", "hideWithAnimationLeft", "START");
			var m:Matrix;						
			tempRect.x = 0;
			tempRect.y = 0;
			tempRect.width = 0;
			tempRect.height = 0;
			var cropRect:Rectangle = getIntersectionRect(tempRect);
			if (cropRect.width < 1 && cropRect.height < 1) {			
				return;
			}
			// draw segment to hide
			//var poolItem:ObjectsPoolItem = ObjectsPool.getBitmap(0, 0);			
			var bitmapToHide:Bitmap = new Bitmap();// poolItem.item;
			var bmd:ImageBitmapData = new ImageBitmapData("LightBox.hideWithAnimationLeft", cropRect.width, cropRect.height, true, 0x000000);
				m = zoomPanCont.transform.matrix;
				m.ty = 0;
				m.tx =  zoomPanCont.x < 0?zoomPanCont.x:0;
			
			croprect.y = 0;
			croprect.width = cropRect.width;
			croprect.height = cropRect.height;
			croprect.x = cropRect.x;
				
			bmd.drawWithQuality(zoomPanCont, m, null, null, croprect, false, StageQuality.LOW);
			bitmapToHide.bitmapData = bmd;
			zoomPanCont.deactivate();
			
			bitmapToHide.x = cropRect.x;
			bitmapToHide.y = cropRect.y;			
			animationLayer.addChild(bitmapToHide);
			TweenMax.to(bitmapToHide, 20, {useFrames:true, x: -cropRect.width, ease:Expo.easeOut, onComplete:onSegmentHide, onCompleteParams:[bitmapToHide] } );
			zoomPanCont.setBitmapData(null, true);			
			//	showPreloader();
			echo("Lightbox", "hideWithAnimationLeft", "END");
		}
		
		
		/** HIDE TO RIGHT SIDE **/
		private static function hideWithAnimationRight():void
		{					
			echo("Lightbox", "hideWithAnimationRight", "START");
			var m:Matrix;						
			tempRect.x = 0;
			tempRect.y = 0;
			tempRect.width = 0;
			tempRect.height = 0;
			var cropRect:Rectangle = getIntersectionRect(tempRect);
			if (cropRect.width < 1 && cropRect.height < 1) {			
				return;
			}
			// draw segment to hide
			//var poolItem:ObjectsPoolItem = ObjectsPool.getBitmap(0, 0);			
			var bitmapToHide:Bitmap = new Bitmap();// poolItem.item;
			var bmd:ImageBitmapData = new ImageBitmapData("LightBox.hideWithAnimationRight", cropRect.width, cropRect.height, true, 0x000000);
				m = zoomPanCont.transform.matrix;
				m.ty = 0;
				m.tx =  zoomPanCont.x < 0?zoomPanCont.x:0;
			
			croprect.y = 0;
			croprect.width = cropRect.width;
			croprect.height = cropRect.height;
			croprect.x = cropRect.x;
				
			bmd.drawWithQuality(zoomPanCont, m, null, null, croprect, false, StageQuality.LOW);
			bitmapToHide.bitmapData = bmd;
			zoomPanCont.deactivate();
					
			bitmapToHide.x = cropRect.x;
			bitmapToHide.y = cropRect.y;			
			animationLayer.addChild(bitmapToHide);
			TweenMax.to(bitmapToHide, 20, { useFrames:true, x:zoomPanCont.viewWidth, ease:Expo.easeOut , onComplete:onSegmentHide, onCompleteParams:[bitmapToHide] } );
			zoomPanCont.setBitmapData(null, true);			
			echo("Lightbox", "hideWithAnimationRight", "END");
		}
		
		private static  function onSegmentHide(pooledBitmap:Bitmap):void {
			echo("Lightbox", "onSegmentHide", "");
			var bmp:Bitmap = pooledBitmap;
			if (bmp.bitmapData) {
				bmp.bitmapData.dispose();
				bmp.bitmapData = null;
			}
			bmp = null;
		}
		
		private static function initPreloaderIfRequired():void {
			
		}
		
		private static function addPreloader():void {
			imageLoaded = false;
			TweenMax.killDelayedCallsTo(showPreloader);
			TweenMax.delayedCall(2, showPreloader);	
		}
		
		private static function showPreloader():void {
			attachPreloader();
			showLoadDescription(Lang.loading);
		}
		
		static private function attachPreloader():void 
		{
			if (preloader == null)
			{
				preloader = new CirclePreloader();
				preloader.x = int(viewWidth  * .5);
				preloader.y = int(viewHeight * .5);
				viewHolder.addChild(preloader);
			}
		}
		
		private static function removePreloader():void {
			echo("Lightbox", "removePreloader", "");
			TweenMax.killDelayedCallsTo(showPreloader);
			hideLoadDescription();
			if (preloader != null)
			{
				if (viewHolder != null && viewHolder.contains(preloader))
				{
					viewHolder.removeChild(preloader);
				}
				preloader.dispose();
				preloader = null;
			}
			imageLoaded = true;
		}
		
		static private function hideLoadDescription():void 
		{
			loadingDescription.visible = false;
		}
			
		// LIGHTBOX  API   ---------------------------------------------------------------------------------------------------------------------------
		//============================================================================
		
		/**
		 * Adds to stock LightBoxItemVO for later use by calling method show(url);
		 * @param	url 
		 * @param	crypt
		 * @param	name
		 * @param	okCallback
		 * @param	cancelCallback
		 */
		public static function add(url:String, crypt:Boolean = false, name:String = "", 
									okCallback:Function = null, 
									cancelCallback:Function = null, 
									smallPreview:String = null, 
									imageActions:Vector.<IScreenAction> = null):void {
			createView();
			var cryptKey:String;
			if (url.indexOf(ImageCrypterOld.imageKeyFlag) != -1)
			{
				var pathElements:Array = url.split(ImageCrypterOld.imageKeyFlag);
			//	url = pathElements[0];
				cryptKey = (pathElements[1] as String);
			}
			else
			{
				
			}
			
			if (exists(url)) {
				//trace("Image :" + url +" alrady added to stock");
				return;
			}
			var newVO:LightBoxItemVO = getVO();
			newVO.URL =  url;
			newVO.cryptKey = cryptKey;
			newVO.previewURL = smallPreview;
			newVO.imageActions = imageActions;
			newVO.crypt = crypt;
			newVO.name = name;
			newVO.okCallback = okCallback;
			newVO.cancelCallback = cancelCallback;
			hash[url] = newVO;
			addedVOStock[addedVOStock.length] = newVO;
		}
		
		public static function unshift(url:String, crypt:Boolean = false, name:String = "", 
									okCallback:Function = null, 
									cancelCallback:Function = null, 
									smallPreview:String = null, 
									imageActions:Vector.<IScreenAction> = null):void {
			createView();
			var cryptKey:String;
			if (url.indexOf(ImageCrypterOld.imageKeyFlag) != -1)
			{
				var pathElements:Array = url.split(ImageCrypterOld.imageKeyFlag);
			//	url = pathElements[0];
				cryptKey = (pathElements[1] as String);
			}
			else
			{
				
			}
			
			if (exists(url)) {
				//trace("Image :" + url +" alrady added to stock");
				return;
			}
			var newVO:LightBoxItemVO = getVO();
			newVO.URL =  url;
			newVO.cryptKey = cryptKey;
			newVO.previewURL = smallPreview;
			newVO.imageActions = imageActions;
			newVO.crypt = crypt;
			newVO.name = name;
			newVO.okCallback = okCallback;
			newVO.cancelCallback = cancelCallback;
			hash[url] = newVO;
			addedVOStock.unshift(newVO);
		}
		
		public static function showCommunityLink(userFxName:String):void
		{
			createView();
			
			if (userFxName != null)
			{
				currentUserFxName = userFxName;
				openFxProfileButton.y = int(viewHeight - openFxProfileButton.height - Config.MARGIN -Config.APPLE_BOTTOM_OFFSET);
				openFxProfileButton.x = int(viewWidth - openFxProfileButton.width - Config.MARGIN);
				openFxProfileButton.show();
				openFxProfileButton.activate();
			}
		}
		
		public static function showLink(link:String, text:String):void
		{
			createView();
			
			opeLinkButton.setBitmapData(TextUtils.createbutton(new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .28), 0xFFFFFF, 0.15), true);
			currentLink = link;
			opeLinkButton.y = int(viewHeight - opeLinkButton.height - Config.MARGIN)-Config.APPLE_BOTTOM_OFFSET;
			opeLinkButton.x = int(viewWidth - opeLinkButton.width - Config.MARGIN);
			opeLinkButton.show();
			opeLinkButton.activate();
		}
		
		static private function loadContent():void 
		{
			if (currentContentProvider != null)
			{
				showContentLoader();
				
				currentContentProvider.S_COMPLETE.add(onContentReady);
				currentContentProvider.S_ERROR.add(onContentError);
				currentContentProvider.execute();
			}
		}
		
		static private function onContentError():void 
		{
			hideContentLoader();
			clearContentProvider();
		}
		
		static private function clearContentProvider():void 
		{
			if (currentContentProvider != null)
			{
				currentContentProvider.S_COMPLETE.remove(onContentReady);
				currentContentProvider.S_ERROR.remove(onContentError);
				
				currentContentProvider.dispose();
				currentContentProvider = null;
			}
		}
		
		static private function onContentReady():void 
		{
			hideContentLoader();
			
			var images:Array = currentContentProvider.getResult();
			if (images != null && images.length > 0)
			{
				var l:int = images.length;
				var newVO:LightBoxItemVO
				for (var i:int = 0; i < l; i++) 
				{
					newVO = getVO();
					newVO.URL = (images[i] as IImageData).getURL();
				//	newVO.imageActions = imageActions;
					newVO.name = i.toString();
				//	newVO.okCallback = okCallback;
				//	newVO.cancelCallback = cancelCallback;
					hash[newVO.URL] = newVO;
					addedVOStock[addedVOStock.length] = newVO;
				}
				
				checkNavigationButtons();
			}
			
			if (addedVOStock != null && addedVOStock.length > 0 && currentIndex == -1)
			{
				currentIndex = 0;
			}
			
			setImagesCounter();
			clearContentProvider();
		}
		
		static private function setImagesCounter():void 
		{
			if (imagesCounter.bitmapData != null)
			{
				imagesCounter.bitmapData.dispose();
				imagesCounter.bitmapData = null;
			}
			if (totalLength > 1)
			{
				imagesCounter.bitmapData = TextUtils.createbutton(new TextFieldSettings((currentIndex + 1).toString() + "/" + totalLength.toString(), 
																	0xFFFFFF, Config.FINGER_SIZE * .28), 0xFFFFFF, 0.15, Config.MARGIN * 1.5);
			}
			updateImageLoaderPosition();
		}
		
		static private function showContentLoader():void 
		{
			imagesLoader.show();
		}
		
		static private function hideContentLoader():void 
		{
			imagesLoader.hide();
		}
		
		/**
		 * Removes from stock LightBoxItemVO  and hides lightbox if removed image is current 
		 * @param	url
		 */
		public static function remove(url:String):void {
			echo("Lightbox", "remove", "START");
			if (!exists(url)) {
				return;
			}
			createView();
			var vo:LightBoxItemVO = hash[url];
			hash[url] = null;
			var ind:int = addedVOStock.indexOf(vo);
			if (ind != -1) {
				addedVOStock.splice(ind, 1);
			}
			
			unloadImage(vo);
			
			if (vo.URL == currentLightBoxVO.URL) {
				disposeVOs();
			} else {
				returnVO(vo);  //return to pool
			}
			
			if (currentLightBoxVO != null && vo != null && currentLightBoxVO.URL == vo.URL) {
				callClose();
			}
		}
		
		/**
		 * 
		 * @param	bmd
		 * @param	okCallback
		 * @param	cancelCallback
		 */
		public static function previewBitmap(bmd:ImageBitmapData, okCallback:Function = null, cancelCallback:Function = null):void {
			echo("Lightbox", "previewBitmap", "START");
			createView();
			disposeVOs();
			_currentShowDirection = 0;
			TweenMax.killDelayedCallsTo(showPreloader);
			if (!isShowing)
			{
				animateShow();
			}
			
			var newVO:LightBoxItemVO = getVO();
			newVO.URL =  "preview_bmd";
			newVO.crypt = false;
			newVO.name = "";
			newVO.okCallback = okCallback;
			newVO.cancelCallback = cancelCallback;
			newVO.bitmapData = bmd;
			hash["preview_bmd"] = newVO;
			addedVOStock[addedVOStock.length] = newVO;
			isShowing = true;
			currentIndex = 0;
			echo("Lightbox", "previewBitmap", "END");
		}	
		
		/**
		 * Disposes all images stock and hides lightbox if it is opened 
		 */
		public static function disposeVOs():void {
			echo("Lightbox", "disposeVOs", "START");
			if (!isCreated) return;
			var l:int = addedVOStock.length;
			var vo:LightBoxItemVO;
			for (var i:int = 0; i < l; i++) {
				vo = addedVOStock[i];
				if (i > 0)
				{
					unloadImage(vo);
				}
			//	
				hash[vo.URL] = null;
				returnVO(vo);
			}
			addedVOStock.length = 0;
			_currentIndex = -1;
		}
		
		static private function unloadImage(vo:LightBoxItemVO):void {
			if (vo != null && vo.URL != null) {
				ImageManager.unloadImage(vo.URL);
				vo.disposed = true;
			}
		}
		
		/**
		 * Shows image by added to stock url
		 * @param	url
		 */
		public static function show(url:String, 
									title:String = null, 
									listenScreenRotation:Boolean = false,
									contentProvider:IContentProvider = null):void {
			echo("Lightbox", "show", "START");
			
			if (!exists(url) && currentContentProvider != null)
				return; // no such url 
			listenForScreenRotation = listenScreenRotation;
			clearOrientation();
			updateOrientation();
			createView();
			startListenConnectionChanged();
			TweenMax.killDelayedCallsTo(showPreloader);
			
			if (imagesCounter != null)
			{
				imagesCounter.alpha = 1;
			}
			if (nextPhotoButton != null)
			{
				nextPhotoButton.alpha = 1;
				nextPhotoButton.hide();
			}
			if (prewPhotoButton != null)
			{
				prewPhotoButton.alpha = 1;
				prewPhotoButton.hide();
			}
			
			var headerTopGap:int = 0;
			if (MobileGui.currentOrientation == StageOrientation.UPSIDE_DOWN || MobileGui.currentOrientation == StageOrientation.DEFAULT)
				headerTopGap = Config.APPLE_TOP_OFFSET;
			
			header.y = headerTopGap;
			header.shown = true;
			
			removePreviewImage();
			var destIndex:int  = getIndexByURL(url);
			
			if (!isShowing)
			{
				animateShow();
			}
			
			isShowing = true;
			imageLoaded = false;
			_currentShowDirection = 0;
			currentIndex = destIndex;
			zoomPanCont.distanceOpacity  = 1;
			
			if (title)
				header.setData(title, getCurrentImageActions());
			
			if (contentProvider != null)
			{
				currentContentProvider = contentProvider;
				loadContent();
			}
				
			NativeExtensionController.S_ORIENTATION_CHANGE.add(setOrientation);
			echo("Lightbox", "show", "END");
		}
		
		static private function startListenConnectionChanged():void 
		{
			NetworkManager.S_CONNECTION_CHANGED.add(onConnectionChanged);
		}
		
		static private function onConnectionChanged():void 
		{
			if (NetworkManager.isConnected) {
				if (mainImageLoadError == true && loadImageInProgress == false) {
					currentRetryIndex = 0;
					TweenMax.killDelayedCallsTo(loadMainImage);
					loadMainImage();
				}
			}
		}
		
		static private function clearOrientation():void {
			echo("Lightbox", "clearOrientation", "START");
			var orientation:String = MobileGui.currentOrientation;
			if (orientation == StageOrientation.UPSIDE_DOWN || orientation == StageOrientation.DEFAULT || listenForScreenRotation == false)
				viewHolder.rotation = 0;
			else if (orientation == StageOrientation.ROTATED_LEFT)
				viewHolder.rotation = 90;
			else if (orientation == StageOrientation.ROTATED_RIGHT)
				viewHolder.rotation = -90;
			echo("Lightbox", "clearOrientation", "END");
		}
		
		static private function animateShow():void 
		{
			viewHolder.alpha = 0;
			TweenMax.killTweensOf(viewHolder);
			TweenMax.to(viewHolder, 0.5, {alpha:1} );
		}
		
		private static function clean():void
		{
			if (zoomPanCont != null)
			{
				zoomPanCont.setBitmapData(null, false);
			}
			removeView();
		}
		
		public static function close():void
		{
			isShowing = false;
		}
		
		private static function doClose():void
		{
			echo("Lightbox", "doClose", "START");
			ImageManager.S_DECRYPT_START.remove(onImageDecryptStart);
			
			TweenMax.killTweensOf(header);
			TweenMax.killTweensOf(viewHolder);
			TweenMax.killTweensOf(openFxProfileButton);
			TweenMax.killTweensOf(opeLinkButton);
			removePreviewImage();
			if (!_isShowing)
			{
				return;
			}
			
			imageLoaded = true; // flag to remove stage tap close
			
			if (currentLightBoxVO != null)
			{
				unloadImage(currentLightBoxVO);
			}
			
			disposeVOs();
			
			currentLightBoxVO = null;
			
			hideMenu();
			
			if (zoomPanCont != null)
			{
				zoomPanCont.stopTrackActivity();
				zoomPanCont.deactivate();
				zoomPanCont.resetTouchPoints();
			}
			
			if (openFxProfileButton)
			{
				openFxProfileButton.deactivate();
				openFxProfileButton.hide();
			}
			
			if (opeLinkButton)
			{
				opeLinkButton.deactivate();
				opeLinkButton.hide();
			}
			
			TweenMax.to(viewHolder, 0.3, {alpha:0, onComplete:clean} );
			echo("Lightbox", "doClose", "END");
		}
		
		private static function getIndexByURL(url:String):int {
			var vo:LightBoxItemVO  = hash[url];
			return addedVOStock.indexOf(vo);
		}
		
		public static function addBitmap(bmd:ImageBitmapData, animate:Boolean = true):void {
			echo("Lightbox", "addBitmap", "START");
			var shouldDispose:Boolean = false;
			if (previewImageDisplayed)
			{
				lastPreview = new Bitmap();
				var previewBD:ImageBitmapData = new ImageBitmapData("Lightbox.lastPreviewBD", viewWidth, viewHeight);
				previewBD.draw(zoomPanCont, zoomPanCont.transform.matrix);
			//	lastPreview.bitmapData = previewBD;
				viewHolder.addChild(lastPreview);
				TweenMax.to(lastPreview, 0.6, {alpha:0, onComplete:removePreviewImage});
				
				viewHolder.setChildIndex(lastPreview, viewHolder.getChildIndex(zoomPanCont) + 1);
				shouldDispose = true;
			}
			
			if (bmd == null)
			{
				var image:EmptyImage = new EmptyImage();
				UI.scaleToFit(image, Math.min(viewWidth, viewHeight), Math.min(viewWidth, viewHeight));
				bmd = UI.getSnapshot(image, StageQuality.HIGH, "LightBox.emptyImage");
				image = null;
			}
			
			if (_currentShowDirection == 0) {
				zoomPanCont.show(listenForScreenRotation);
				zoomPanCont.setBitmapData(bmd, shouldDispose);
				imageLoaded = true;
			} else {
				imageLoaded = true;
				zoomPanCont.show(listenForScreenRotation);
				zoomPanCont.setBitmapDataWithTransition(bmd, _currentShowDirection, animate);
			}
			inTransition = false;
			zoomPanCont.activate();
			
			previewImageDisplayed = false;
			echo("Lightbox", "addBitmap", "END");
		}
		
		static private function removePreviewImage():void 
		{
			echo("Lightbox", "removePreviewImage", "START");
			if (lastPreview)
			{
				TweenMax.killTweensOf(lastPreview);
				if (lastPreview.bitmapData)
				{
					lastPreview.bitmapData.dispose();
					lastPreview.bitmapData = null;
				}
				if (viewHolder.contains(lastPreview))
				{
					viewHolder.removeChild(lastPreview);
				}
				lastPreview = null;
			}
			echo("Lightbox", "removePreviewImage", "END");
		}
		
		private static function onCurrentIndexChange():void {
			
			cancelCurrentLoading();
			echo("Lightbox", "onCurrentIndexChange", "START");
			inTransition = true;
			currentLightBoxVO = addedVOStock[_currentIndex];
			currentLightBoxVO.previewShown = false;
			setImagesCounter();
			header.hideSettingsButton();
			
			/*if (currentLightBoxVO && currentLightBoxVO.imageActions && currentLightBoxVO.imageActions.length > 0)
			{
				header.showSettingsButton();
			}
			else
			{
				header.hideSettingsButton();
			}*/
			
			if (currentLightBoxVO.cancelCallback != null || currentLightBoxVO.okCallback != null) {
				lightBoxMenu.setCallbacks(currentLightBoxVO.cancelCallback, currentLightBoxVO.okCallback);
				showMenu();
			} else {
				lightBoxMenu.setCallbacks(null, null);
				hideMenu();
			}
			if (currentLightBoxVO.bitmapData != null) {
				onImageLoadComplete(currentLightBoxVO.URL, currentLightBoxVO.bitmapData);
			} else{
				
				
			//	hideSaveButton();
				ImageManager.S_DECRYPT_START.remove(onImageDecryptStart);
				ImageManager.S_DECRYPT_START.add(onImageDecryptStart);
				
				var existingImage:ImageBitmapData = ImageManager.getImageFromCache(currentLightBoxVO.URL);
				if (existingImage)
				{
					existingImage.incUseCount("getImageFromCache");
					onImageLoadComplete(currentLightBoxVO.URL, existingImage);
				}
				else
				{
					showPreview(currentLightBoxVO.previewURL);
					addPreloader();
					loadMainImage();
				}
			}
			echo("Lightbox", "onCurrentIndexChange", "END");
		}
		
		static private function loadMainImage():void {
			if (currentLightBoxVO != null && isConnectionAvaliable()) {
				ImageManager.S_LOAD_PROGRESS.add(onImageLoadProgress);
				loadImageInProgress = true;
				ImageManager.loadImage(currentLightBoxVO.URL, onImageLoadComplete, true);
			}
		}
		
		static private function isConnectionAvaliable():Boolean 
		{
			return NetworkManager.isConnected;
		}
		
		static private function cancelCurrentLoading():void {
			if (currentLightBoxVO != null) {
				ImageManager.cancelLoad(currentLightBoxVO.URL, onImageLoadComplete);
			}
			currentRetryIndex = 0;
			loadImageInProgress = false;
			mainImageLoadError = false;
			removePreloader();
			NetworkManager.S_CONNECTION_CHANGED.remove(onConnectionChanged);
			TweenMax.killDelayedCallsTo(loadMainImage);
		}
		
		static private function onImageLoadProgress(url:String, percent:int):void 
		{
			// a proveritj na null? 
			
			//if (currentLightBoxVO.URL != url)
			//{
			//	return;
			//}
		//	circleLoader.setValue(percent);
		}
		
		static private function showPreview(previewURL:String):void 
		{
			echo("Lightbox", "showPreview", "START");
			if (previewURL)
			{
				var realUrl:String = previewURL;
				if (realUrl.indexOf(ImageCrypterOld.imageKeyFlag) != -1)
				{
					realUrl = realUrl.split(ImageCrypterOld.imageKeyFlag)[0];
				}
				
				var previewImage:ImageBitmapData = ImageManager.getImageFromCache(realUrl);
				if (previewImage)
				{
					currentLightBoxVO.previewShown = true;
					var result:ImageBitmapData = new ImageBitmapData("LightBox.showPreview", previewImage.width, previewImage.height);
					result.copyPixels(previewImage, new Rectangle(0,0,previewImage.width,previewImage.height), new Point(0,0));
					var blur:BlurFilter = new BlurFilter();
					blur.blurX = Config.FINGER_SIZE*.3; 
					blur.blurY = Config.FINGER_SIZE*.3; 
					blur.quality = BitmapFilterQuality.LOW;
				//	result.applyFilter(result, new Rectangle(0,0,previewImage.width,previewImage.height), new Point(0,0), blur);
					
				//	result.colorTransform(new Rectangle(0, 0, previewImage.width, previewImage.height), new ColorTransform(0.7, 0.7, 0.7, 1));
					
					addBitmap(result);
					
					previewImageDisplayed = true;
				}
				else {
				//	addPreloader();
				}
			}
			else {
			//	addPreloader();
			}
			echo("Lightbox", "showPreview", "END");
		}
		
		static private function onImageDecryptStart(url:String):void 
		{
			if (!exists(url)) return;
			ImageManager.S_DECRYPT_START.remove(onImageDecryptStart);
			addPreloader();
			if (preloader != null && preloader.visible == true)
				showLoadDescription(Lang.decrypting);
		}
		
		static private function showLoadDescription(text:String):void 
		{
			echo("Lightbox", "showLoadDescription", "START");
			loadingDescription.visible = true;
			if (loadingDescription.bitmapData)
			{
				loadingDescription.bitmapData.dispose();
				loadingDescription.bitmapData = null;
			}
			loadingDescription.bitmapData = TextUtils.createTextFieldData(text, viewWidth - Config.DOUBLE_MARGIN * 2, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .35, false, 0xFFFFFF, 0x000000, true);
			
			if (preloader != null)
			{
				loadingDescription.x = preloader.x - loadingDescription.width * .5;
				loadingDescription.y = preloader.y + preloader.height*2 + Config.DIALOG_MARGIN;
			}
			else
			{
				loadingDescription.x = viewWidth * .5 - loadingDescription.width * .5;
				loadingDescription.y = viewHeight * .75;
			}
			
			echo("Lightbox", "showLoadDescription", "END");
		}
		
		// TODO fake image change to real load 
		private static function onImageLoadComplete(url:String, bmd:ImageBitmapData):void {
			echo("Lightbox", "onImageLoadComplete", "START");
			loadImageInProgress = false;
			TweenMax.killDelayedCallsTo(loadMainImage);
			ImageManager.S_LOAD_PROGRESS.remove(onImageLoadProgress);
			
			ImageManager.S_DECRYPT_START.remove(onImageDecryptStart);
			if (!exists(url)) return; // image does not exists in stock 
			if (currentLightBoxVO.URL == url) { // check if loadded image is exactly same as currently awaiting image 
				
				checkButtons();
				header.showSettingsButton();
				
				
				if (currentLightBoxVO.crypt)
				{
					if (bmd == null) {
						mainImageLoadError = true;
						displayError();
					//	retryLoadImage();
					}
					else {
						removePreloader();
						mainImageLoadError = false;
						if (!bmd.decrypted) {
							if (ChatManager.getCurrentChat() != null) {
								var key:Array = ChatManager.getCurrentChat().imageKey;
								if (key.length > 100)
									addBitmap(Crypter.decryptImage(bmd, key), !currentLightBoxVO.previewShown);
							}
						}
						else {
							addBitmap(bmd, !currentLightBoxVO.previewShown);
						}
					}
				}
				else {
					removePreloader();
					addBitmap(bmd);
				}
			}
			else {
				ImageManager.unloadImage(url);
				//trace("LightBox loaded URL is different from Current ");
			}
			echo("Lightbox", "onImageLoadComplete", "END");
		}
		
		static private function displayError():void 
		{
			TweenMax.killDelayedCallsTo(showPreloader);
			showLoadDescription(Lang.imageCorrupted);
		}
		
		static private function retryLoadImage():void {
			TweenMax.killDelayedCallsTo(loadMainImage);
			
			if (currentRetryIndex > 2)
				return;
			
			var timeout:int;
			if (currentRetryIndex == 0)
				timeout = 3;
			else if(currentRetryIndex == 1)
				timeout = 10;
			else if(currentRetryIndex == 2)
				timeout = 20;
			
			currentRetryIndex ++;
			TweenMax.delayedCall(timeout, loadMainImage);
		}
		
		static private function checkButtons():void 
		{
			echo("Lightbox", "checkButtons", "START");
			
			checkNavigationButtons();
		}
		
		static private function checkNavigationButtons():void 
		{
			if (nextPhotoButton != null)
			{
				if (hasNextImage())
				{
					nextPhotoButton.activate();
					nextPhotoButton.show();
				}
				else
				{
					nextPhotoButton.deactivate();
					nextPhotoButton.hide();
				}
			}
			
			if (prewPhotoButton != null)
			{
				if (canPrew())
				{
					prewPhotoButton.activate();
					prewPhotoButton.show();
				}
				else
				{
					prewPhotoButton.deactivate();
					prewPhotoButton.hide();
				}
			}
		}
		
		private static var isDefaultButtonsEnabled:Boolean = true;
		static private var prewButtonAllowed:Boolean;
		static private var prewCallPanding:Boolean;
		
		private static function showDefaultButtons():void
		{
			isDefaultButtonsEnabled = true;
			/*if (closeBtn.parent == null)
			{
				viewHolder.addChild(closeBtn);
			}*/
			//if (saveBtn.parent == null)
			//{
				//viewHolder.addChild(saveBtn);
			//}
			if (appleHeaderSprite && appleHeaderSprite.parent == null)
			{
				viewHolder.addChild(appleHeaderSprite);
			}
		}
		
		private static function hideDefaultButtons():void
		{
			isDefaultButtonsEnabled = false;
			/*if (closeBtn.parent != null)
			{
				closeBtn.parent.removeChild(closeBtn);
			}*/
			//if (saveBtn.parent != null)
			//{
				//saveBtn.parent.removeChild(saveBtn);
			//}
			if (appleHeaderSprite && appleHeaderSprite.parent != null)
			{
				viewHolder.removeChild(appleHeaderSprite);
			}
		}
		
		private static function exists(url:String):Boolean { return hash[url] != null; }
		private static function showMenu():void {
			if (lightBoxMenu == null)
				return;
			lightBoxMenu.show();
			hideDefaultButtons();
		}
		private static function hideMenu():void {
			if (lightBoxMenu == null)
				return;
			lightBoxMenu.hide();
			showDefaultButtons();
		}
		
		// UTILS---------------------------------------------------------------------------------------------------------------------------------
		//======================================================================
		private static function getVO(): LightBoxItemVO {
			if (freeVOStock.length == 0) {
				return new LightBoxItemVO();
			} else {
				return freeVOStock.pop();
			}
		}
		
		private static function returnVO(vo:LightBoxItemVO):void {
			if (vo == null)
				return;
			vo.reset();
			freeVOStock[freeVOStock.length] = vo;
			// TODO check for max pool size and dispose unnecessary items 
		}
		
		public static function getIntersectionRect(returnRect:Rectangle):Rectangle {
			echo("Lightbox", "getIntersectionRect", "");
			viewPortRect.x = 0;
			viewPortRect.y = zoomPanCont.topOffset;
			viewPortRect.width = int(zoomPanCont.viewWidth);
			viewPortRect.height = int(zoomPanCont.viewHeight);
			
			imageRect.x = int(zoomPanCont.x);
			imageRect.y = int(zoomPanCont.y);
			imageRect.width = int(zoomPanCont.width);
			imageRect.height = int(zoomPanCont.height);
			returnRect = viewPortRect.intersection(imageRect);
			return returnRect;
		}
		
		private static function get totalLength():int { return addedVOStock.length; }
		private static function hasNextImage():Boolean { return totalLength>1&& _currentIndex != totalLength - 1; }
		private static function hasPrevImage():Boolean {
			return totalLength > 1 && _currentIndex != 0; 
		}
		public static  function get currentIndex():int { return _currentIndex; }
		public static function set currentIndex(value:int):void {
			if (value < 0)
				return;
			if (value > totalLength - 1)
				return; // we pass index out of range
			if (value == _currentIndex)
				return;
			_currentIndex = value;
			onCurrentIndexChange();
		}
		
		// is image currenty displaying or lightbox is closed 
		static public function get isShowing():Boolean { return _isShowing; }
		static public function set isShowing(value:Boolean):void {
			if (value == _isShowing)
				return;
			
			if (value) {
				addView();
			} else {
				doClose();
			}
			_isShowing = value;
		}
		
		public static function get imageLoaded():Boolean { return _imageLoaded;	}
		public static function set imageLoaded(value:Boolean):void {
			_imageLoaded = value;
			if (!_imageLoaded) {
				PointerManager.addTap(_stageRef, onNotLoadedLightboxClick);
			} else {
				PointerManager.removeTap(_stageRef, onNotLoadedLightboxClick);
			}
		}
		
		private static function onNotLoadedLightboxClick(e:Event = null):void {
			if (e != null && e.target != null && e.target is BitmapButton) {
				return;
			}
			if (inTransition == false) {
				callClose();
			}
		}
		
		static private function callClose():void {
			isShowing = false;
			TweenMax.killDelayedCallsTo(showPreloader);
			onClose();
		}
		
		public static function setSize(width:int, height:int, resizeImage:Boolean = true):void {
			echo("Lightbox", "setSize", "START");
			viewWidth = width;
			viewHeight = height;
			if (isCreated) {
				if (resizeImage && zoomPanCont!= null)
					zoomPanCont.setViewportSize(viewWidth, viewHeight);
				if (background != null)
				{
				background.width = viewWidth;
				background.height = viewHeight;
				}
				if (preloader) {
					preloader.x = viewWidth  * .5;
					preloader.y = viewHeight * .5;
				}
				if (lightBoxMenu != null)
				{
				lightBoxMenu.setSize(viewWidth, viewHeight);
				}
				if (nextPhotoButton != null)
				{
					nextPhotoButton.x = int(viewWidth - nextPhotoButton.width - Config.FINGER_SIZE * .3);
					nextPhotoButton.y = int(viewHeight * .5 - nextPhotoButton.height * .5);
				}
				
				if (prewPhotoButton != null)
				{
					prewPhotoButton.x = int(Config.FINGER_SIZE * .3);
					prewPhotoButton.y = int(viewHeight * .5 - nextPhotoButton.height * .5);
				}
				
				updateElements();
			}
			echo("Lightbox", "setSize", "END");
		}
		
		static private function updateElements():void {
			echo("Lightbox", "updateElements", "START");
			if (openFxProfileButton != null) {
				TweenMax.killTweensOf(openFxProfileButton);
				openFxProfileButton.y = int(viewHeight - openFxProfileButton.height - Config.MARGIN  -Config.APPLE_BOTTOM_OFFSET);
			}
			if (opeLinkButton != null) {
				TweenMax.killTweensOf(opeLinkButton);
				opeLinkButton.y = int(viewHeight - opeLinkButton.height - Config.MARGIN)-Config.APPLE_BOTTOM_OFFSET;
			}
			if (header != null) {
				TweenMax.killTweensOf(header);
				header.setSize(viewWidth, Config.FINGER_SIZE * .85);
				
				if (headerMask != null) {
					headerMask.graphics.clear();
					headerMask.graphics.beginFill(0);
					headerMask.graphics.drawRect(0, 0, viewWidth, header.getHeight());
					headerMask.graphics.endFill();
					var headerTopGap:int = 0;
					if (MobileGui.currentOrientation == StageOrientation.UPSIDE_DOWN || MobileGui.currentOrientation == StageOrientation.DEFAULT)
						headerTopGap = Config.APPLE_TOP_OFFSET;
					if (header.shown)
						header.y = headerTopGap;
					else
						header.y = headerTopGap - header.getHeight();
					headerMask.y = headerTopGap;
				}
			}
			
			updateImageLoaderPosition();
		}
		
		static private function updateImageLoaderPosition():void 
		{
			if (imagesLoader != null)
			{
				imagesLoader.x = int(Config.MARGIN + Config.FINGER_SIZE*.5);
				imagesLoader.y = int(viewHeight - Config.FINGER_SIZE*.5 - Config.MARGIN);
			}
			
			if (imagesCounter != null)
			{
				var sideMargin:int = 0;
				if (MobileGui.currentOrientation == StageOrientation.ROTATED_LEFT)
				{
					sideMargin = Config.APPLE_TOP_OFFSET;
				}
				imagesCounter.x = Config.MARGIN + sideMargin;
				imagesCounter.y = int(viewHeight - imagesCounter.height - Config.MARGIN)-Config.APPLE_BOTTOM_OFFSET;
			}
		}
		
		static public function updateViewPort():void {
			if (isCreated) {
				setSize(_stageRef.stageWidth, _stageRef.stageHeight);
			}
		}
		
		static public function deactivate():void 
		{
			if (zoomPanCont)
			{
				zoomPanCont.deactivate();
				zoomPanCont.resetTouchPoints();
			}
			if (openFxProfileButton)
			{
				openFxProfileButton.deactivate();
			}
			if (opeLinkButton)
			{
				opeLinkButton.deactivate();
			}
			if (header)
			{
				header.deactivate();
			}
			if (nextPhotoButton != null)
			{
				nextPhotoButton.deactivate();
		}
		}
		
		static public function activate():void 
		{
			if (zoomPanCont)
			{
				zoomPanCont.activate();
			}
			if (openFxProfileButton)
			{
				openFxProfileButton.activate();
			}
			if (opeLinkButton)
			{
				opeLinkButton.activate();
			}
			if (header)
			{
				header.activate();
			}
			if (nextPhotoButton != null)
			{
				nextPhotoButton.activate();
			}
		}
		
		static public function allowPrewButton():void 
		{
			prewButtonAllowed = true;
		}
		
		static public function checkPendingCalls():void 
		{
			removePreloader();
			if (currentLightBoxVO != null)
			{
				_currentIndex = getIndexByURL(currentLightBoxVO.URL);
			}
			
			setImagesCounter();
			if (prewCallPanding)
			{
				prewCallPanding = false;
				displayPrev();
			}
		}
		
		static public function disablePrewButton():void 
		{
			prewButtonAllowed = false;
			prewCallPanding = false;
			removePreloader();
			
			if (prewPhotoButton != null)
			{
				if (hasPrevImage() == false)
				{
					prewPhotoButton.deactivate();
					prewPhotoButton.hide();
				}
			}
		}
		
		static public function clearPending():void 
		{
			removePreloader();
			prewCallPanding = false;
			disablePrewButton();
		}
		
		static private function setOrientation():void {
			if (isShowing)
				updateOrientation();
		}
		
		static private function updateOrientation():void {
			echo("Lightbox", "updateOrientation", "START");
			if (listenForScreenRotation) {
				zoomPanCont.setOrientation(MobileGui.currentOrientation);
				onResize();
			}
			echo("Lightbox", "updateOrientation", "END");
		}
	}
}