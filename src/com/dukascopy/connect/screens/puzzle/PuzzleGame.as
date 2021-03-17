package com.dukascopy.connect.screens.puzzle
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.LightBox;
	import com.dukascopy.connect.gui.lightbox.LightboxHeader;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Quint;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageOrientation;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Alexey Skuryat
	
	 */
	public class PuzzleGame extends Sprite
	{
		
		private var _viewWidth:int = 300;
		private var _viewHeight:int = 400;
		
		private var _isActivated:Boolean = false;
		
		private var _originalBMD:ImageBitmapData;
		private var _imageBitmapData:BitmapData;
		
		private var _maxCellsToShow:int = 0;
		private var _isDisposed:Boolean = false;
		
		private var _totalCellsCount:int = 0;
		private var _openedCellsCount:int = 0;
		
		private var _numRow:int = 0;
		private var _numCol:int = 0;
		private var _cellSizeSquare:Rectangle;
		private var imageScale:Number = 1;
		
		private var _imageContainer:Sprite;
		private var _imageBitmap:Bitmap;
		
		private var openedCellsMap:Array = [];
		private var _openedIndexes:Array = [];
		private var imageSquares:Array = [];
		private var imageSquaresShuffeled:Array = [];
		private static var tempPoint:Point = new Point();
		
		private var puzzleData:Object = {};
		private var shuffledIndexes:Array = [];
		private var IMAGE_ID:String = "";
		
		private var effectLayer:Bitmap = new Bitmap();
		private var appleHeaderBitmap:Bitmap;
		
		
		private var puzzleDataLoaded:Boolean = false;
		// Background
		private var backgroundOverlay:Bitmap = new Bitmap(new BitmapData(1, 1, false, 0x000000));
		
		// Buy Button
		private static var buyButtonBitmapData:BitmapData;
		private var buyButton:BitmapButton;
		
		// Store puzzle datas by ID 
		private static var cachedPuzzleDatas:Object = {};
		private var header:LightboxHeader;
		public var backButtonCallback:Function;
		public var buyButtonCallback:Function;
		
		private var _isPreview:Boolean = false;
		private var _isShown:Boolean = false;
		private var preloader:Preloader;
		public var dialogCallback:Function;
		
		private var clickToPlaySprite:Bitmap;
		
		
		/** @CONSTRUCTOR **/
		public function PuzzleGame()
		{
			
			_cellSizeSquare = new Rectangle();
			_imageContainer = new Sprite();
			_imageBitmap = new Bitmap();
			_imageContainer.addChild(_imageBitmap);
			addChild(backgroundOverlay);
			addChild(_imageContainer);
			effectLayer = new Bitmap(new BitmapData(1, 1, false, 0xffffff));
			addChild(effectLayer);
			effectLayer.visible = false;
			backgroundOverlay.alpha = .9;
			
			// EUROPE
			buyButton = new BitmapButton();
			buyButton.setStandartButtonParams();
			buyButton.usePreventOnDown = false;
			buyButton.cancelOnVerticalMovement = true;
			buyButton.setOverflow(0,0,0,0);
			//buyButton.setBitmapData(
			var asset:SWFBuyImageIcon = new SWFBuyImageIcon();
			UI.scaleToFit(asset, Config.FINGER_SIZE, Config.FINGER_SIZE);				
			buyButton.setBitmapData(UI.getSnapshot(asset, StageQuality.HIGH, "PuzzleGame.buyButton"),true);	
			buyButton.hide();
			addChild(buyButton);
			buyButton.tapCallback = onBuyButtonTap;
			asset = null;
			
			
			// top line
			if (Config.PLATFORM_APPLE)
			{
				appleHeaderBitmap = new Bitmap(new BitmapData(1,1,false,0x000000));
				appleHeaderBitmap.alpha  = 0.7;
				appleHeaderBitmap.width  = _viewWidth;
				appleHeaderBitmap.height  = Config.APPLE_TOP_OFFSET;
				addChild(appleHeaderBitmap);
				
			}
			// header 
			header = new LightboxHeader(_viewWidth, Config.FINGER_SIZE * .85);
			header.S_ON_BACK.add(onBackButtonClick);
			header.hideSettingsButton();
			addChild(header);
			
			var headerTopGap:int = 0;
			if (MobileGui.currentOrientation == StageOrientation.UPSIDE_DOWN || MobileGui.currentOrientation == StageOrientation.DEFAULT)
				headerTopGap = Config.APPLE_TOP_OFFSET;
			
			header.y = headerTopGap;
		}
		
		public function onBackButtonClick():void
		{
			if (backButtonCallback != null)
			{
				backButtonCallback();
			}
			//echo("Lightbox", "onBackButtonClick", "");	
		
		}
		
		private function showClickToStart():void
		{
			if (clickToPlaySprite == null){
				clickToPlaySprite = new Bitmap();
			}
			TweenMax.killTweensOf(clickToPlaySprite);
			UI.disposeBMD(clickToPlaySprite.bitmapData);
			clickToPlaySprite.bitmapData = UI.renderTextPlane(Lang.clickToPlay, 
																_viewWidth,
																_viewHeight * .3,
																true,
																TextFormatAlign.CENTER, 
																TextFieldAutoSize.LEFT, 
																Config.FINGER_SIZE *.4, 
																true,
																AppTheme.WHITE,
																AppTheme.SCREEN_BACKGROUND_COLOR, 
																0xffffff, 10, 5, 5, 10,null,false,false,0,true);
			
			addChild(clickToPlaySprite);			
			var destX:int =  _viewWidth * .5 - clickToPlaySprite.width * .5
			var destY:int =  _viewHeight * .5 - clickToPlaySprite.height * .5;
			clickToPlaySprite.x = destX+_viewWidth*.1;
			clickToPlaySprite.y = destY;
			clickToPlaySprite.scaleX = 3;
			clickToPlaySprite.alpha = 0;			
			TweenMax.to(clickToPlaySprite, .53,{x:destX, alpha:1, scaleX:1, ease:Expo.easeOut, delay:.3});
		}
		
		private function hideClickToStart():void{
			if(clickToPlaySprite!=null){
				var destX:int = - clickToPlaySprite.width *3;				
				TweenMax.killTweensOf(clickToPlaySprite);
				TweenMax.to(clickToPlaySprite, .53,{x:destX, alpha:0, scaleX:3, ease:Expo.easeIn, onComplete:destroyClickToStart});
			}
		}
				
		private function destroyClickToStart():void{
			if (clickToPlaySprite != null){
				TweenMax.killTweensOf(clickToPlaySprite);
				UI.destroy(clickToPlaySprite);
				clickToPlaySprite = null;
			}
		}
		
		public function setTitle(title:String):void {
			if (header != null){				
				header.setData(title, null);
			}			
		}
		
		private function showUI():void	{
			if (backgroundOverlay != null)
			{
				backgroundOverlay.visible = true;
			}
			
			if (header != null)
			{
				header.hideSettingsButton();
				header.visible = true;
			}
			
			if (_imageBitmap != null)
			{
				_imageBitmap.visible = true;
			}
			
			if (effectLayer != null)
			{
				effectLayer.visible = true;
			}
			
			if (buyButton != null)
			{
				//buyButtonBitmapData = UI.renderButtonWithIcon("Pay to unlock image", _viewWidth - Config.DOUBLE_MARGIN * 2, Config.FINGER_SIZE, 0xffffff, 0x00a551, 0x008c45, /*AppTheme.BUTTON_CORNER_RADIUS*/ Config.FINGER_SIZE, AppTheme.BUTTON_CORNER_RADIUS);
				//buyButton.setBitmapData(buyButtonBitmapData, true);
				buyButton.x = _viewWidth- buyButton.width - Config.DOUBLE_MARGIN;
				buyButton.y = _viewHeight - buyButton.height - Config.DOUBLE_MARGIN;
				buyButton.show(.3, .5);
			}
		
			if (appleHeaderBitmap != null){
				appleHeaderBitmap.visible = true;
			}
			showPreloader();
		}
		
		private function hideUI():void
		{
			if (backgroundOverlay != null)
			{
				backgroundOverlay.visible = false;
			}
			
			if (header != null)
			{
				header.visible = false;
			}
			
			if (_imageBitmap != null)
			{
				_imageBitmap.visible = false;
			}
			
			if (effectLayer != null)
			{
				effectLayer.visible = false;
			}
			
			if (buyButton != null)
			{
				buyButton.hide();
			}
			if (appleHeaderBitmap != null){
				appleHeaderBitmap.visible = false;
			}
			hidePrelaoder();
		}
		
		//===========================================================================================================
		// PRELOADER SHOW / HIDE
		//===========================================================================================================	
		
		public function showPreloader():void
		{
			if (preloader == null)
			{
				preloader = new Preloader();
			}
			preloader.x = MobileGui.stage.stageWidth * .5;
			preloader.y = MobileGui.stage.stageHeight * .5;
			addChild(preloader);
			preloader.show();
		}
		
		public function hidePrelaoder():void
		{
			if (preloader != null)
			{
				preloader.hide();
				if (preloader.parent)
				{
					preloader.parent.removeChild(preloader);
				}
			}
		}
		
		
		
		/** ON BUTTON TAP **/
		private function onBuyButtonTap():void
		{
			//trace("Buy Now ");
			if (buyButtonCallback != null){
				buyButtonCallback();
			}
		}
		
		private function showButton():void
		{
			buyButton.show(.3);
		}
		
		private function hideButton():void
		{
			buyButton.hide();
		}
		
		// HIDE
		public function hide():void
		{
			hideUI();
			destroyClickToStart();
			deactivate();
			_isShown = false;
		}
		
		// SHOW 
		public function show():void
		{
			
			if (_isDisposed) return;
			showUI();
			_isShown = true;
		
		}
		
		public function clearGame():void
		{
			UI.disposeBMD(_originalBMD);
			_originalBMD = null;
			
			UI.disposeBMD(_imageBitmapData);
			_imageBitmapData = null;
			
			_numCol = 0;
			_numRow = 0;
			_totalCellsCount = 0;
			_maxCellsToShow = 0;
			_cellSizeSquare.width = 0;
			_cellSizeSquare.height = 0;
			_cellSizeSquare.x = 0;
			_cellSizeSquare.y = 0;
			imageScale = 1;
			
			//clear arrays
			shuffledIndexes.length = 0;
			openedCellsMap.length = 0;
			_openedCellsCount = 0;
			_openedIndexes.length = 0;
		
		}
		
		public function setupGame(img_id:String, bmd:ImageBitmapData, col:int, row:int, max_cells_to_open:int = 2, isPreview:Boolean = false ):void
		{
			if (bmd == null)
			{
				return;
			}
			if (_isDisposed) return;
			
			if (bmd.width < col || bmd.height < row) return;
			
			clearGame();
			
			_isPreview = isPreview;
			_originalBMD = bmd;
			_numCol = col;
			_numRow = row;
			_totalCellsCount = _numCol * _numRow;
			_maxCellsToShow = max_cells_to_open;
			_imageBitmapData = new BitmapData(_originalBMD.width, _originalBMD.height, false, 0x000000);
		
			_imageBitmap.bitmapData = isPreview?_originalBMD:_imageBitmapData;
			
			_imageBitmap.smoothing = true;
			_cellSizeSquare.width = int(_originalBMD.width / _numCol);
			_cellSizeSquare.height = int(_originalBMD.height / _numRow);
			
			
			if(!isPreview){
				_imageBitmapData.lock();
				var rect:Rectangle = new Rectangle(0, 0, 4, _originalBMD.height);
				for (var i:int = 0; i < _numCol + 1; i++)
				{
					var addedX:int = i == _numCol? 0: -2;
					rect.x = _cellSizeSquare.width * i + addedX;
					_imageBitmapData.fillRect(rect, 0x2a2a2a);
				}
				
				rect.x = 0;
				rect.width = _originalBMD.width;
				rect.height = 4;
				for (var j:int = 0; j < _numRow + 1; j++)
				{
					var addedY:int = -2;// j == _numRow? -2: -2;
					rect.y = _cellSizeSquare.height * j + addedY;
					_imageBitmapData.fillRect(rect, 0x2a2a2a);
				}
				
				
				_imageBitmapData.unlock();
			}
				
			
			imageScale = UI.getMinScale(_originalBMD.width, _originalBMD.height, _viewWidth, _viewHeight);
			// position image bitmap
			_imageBitmap.scaleX = _imageBitmap.scaleY = imageScale;
			if (_imageBitmap.height <= _viewHeight)
			{
				_imageBitmap.y = (_viewHeight - _imageBitmap.height) * .5;
				_imageBitmap.x = (_viewWidth - _imageBitmap.width) * .5;
			}
				
				
			
			if (isPreview) {
				puzzleDataLoaded = true;
				hidePrelaoder();
				return;		
			}
						
			// Load From Store 
			_openedIndexes.length = 0;
			puzzleDataLoaded = false;
			IMAGE_ID = img_id + "_pzl";			
			//var cachedData:Object = cachedPuzzleDatas[IMAGE_ID];
			//if(cachedData != null){
			//onPuzzleDataLoaded(cachedData, false);
			//}else{
				Store.load(IMAGE_ID, onPuzzleDataLoaded);
			//}				
			//Need somehow cleanup puzzle datas 
		}
		
		// Loaded Game Data 
		private function onPuzzleDataLoaded(data:Object, err:Boolean):void
		{
			hidePrelaoder();
			var needGenerateShuffle:Boolean = true;
			var loadedPuzzleData:Object = null;
			if (err == true || data == null) {
				//trace(">>  Cannot load puzzle data from storage-> generate dinamically " + IMAGE_ID);
				//return;
			}
			else
			{
				needGenerateShuffle = false;
				loadedPuzzleData = data;
			}
			
			createCells(needGenerateShuffle);
			
			// set shuffled indexes 
			if (loadedPuzzleData != null)
			{
				shuffledIndexes = loadedPuzzleData.shuffledIndexes != null ? loadedPuzzleData.shuffledIndexes : shuffledIndexes;
				openedCellsMap = loadedPuzzleData.openedCellsMap != null ? loadedPuzzleData.openedCellsMap : openedCellsMap;
				
				_openedCellsCount = loadedPuzzleData.openedCellsCount != null ? loadedPuzzleData.openedCellsCount : _openedCellsCount;
				var _openedIndexesData:Array = loadedPuzzleData.openedIndexes != null ? loadedPuzzleData.openedIndexes : _openedIndexes;
				
				setShuffledIndexes(shuffledIndexes);
				setOpenedCells(_openedIndexesData);
			}
			else
			{
				
			}
			
			if (_openedCellsCount <= 0){
				showClickToStart();
			}else{
				hideClickToStart();
			}
			
			//saveGameData();
			puzzleDataLoaded = true;
			
			if (_isActivated)
			{
				activate();
			}
		
		}
		
		// Save Game Data 
		public function saveGameData():void { 			
			puzzleData.shuffledIndexes = shuffledIndexes;
			puzzleData.openedCellsMap = openedCellsMap;
			puzzleData.openedCellsCount = _openedCellsCount;
			puzzleData.openedIndexes = _openedIndexes;
			
			if (IMAGE_ID != null && puzzleData != null)	{
				cachedPuzzleDatas[IMAGE_ID] = puzzleData;
				Store.save(IMAGE_ID, puzzleData); // Maybe should optimize this data somehow?
			}
		}
		
		public function removeGameDataFromStore():void {
			if (IMAGE_ID != null){
				Store.remove(IMAGE_ID);
			}
		}
		
		/**
		 * TODO maybe should generate cell when it's needed dynamicaly, not all at once
		 */
		private function createCells(generateShuffle:Boolean = true):void
		{
			var xPos:int = 0;
			var yPos:int = 0;
			var segmentBMD:BitmapData;
			openedCellsMap.length = 0;
			disposeCells();
			
			
			shuffledIndexes.length = 0;
			
			for (var i:int = 0; i < _totalCellsCount; i++)
			{
				shuffledIndexes[i] = i;		// Normalize First		
				
				openedCellsMap[i] = 0; // THIS RESETS All empty cells	
				
				var colItem:int = i % _numCol;
				var rowItem:int = i / _numCol;
				_cellSizeSquare.x = int(colItem * _cellSizeSquare.width);
				_cellSizeSquare.y = int(rowItem * _cellSizeSquare.height);
				var destX:int = int(colItem * _cellSizeSquare.width);
				var destY:int = int(rowItem * _cellSizeSquare.height);
				segmentBMD = new BitmapData(_cellSizeSquare.width, _cellSizeSquare.height, false, 0x000000);
				//segmentBMD.draw(_originalBMD ,null,null,null, _cellSizeSquare ,false);
				segmentBMD.copyPixels(_originalBMD, _cellSizeSquare, getPoint(0, 0), null, null, false);
				imageSquares[i] = segmentBMD;
				imageSquaresShuffeled[i] = segmentBMD;
				
					//var b:Bitmap = new Bitmap();
					//b.bitmapData = segmentBMD;
					//b.alpha = .8;
					//b.scaleX = b.scaleY = imageScale;
					//addChild(b);
					//b.x = destX*imageScale;
					//b.y = destY*imageScale;		
			}
			
			// If need generate shuffled array 
			if (generateShuffle)
			{
				shuffledIndexes = arrayShuffle(shuffledIndexes); // save indexes?
			}
			//trace("Shuffeled Indexes String" + shuffledIndexes.toString());
		}
		
		// uses shuffled indexes value 
		public function setOpenedCells(indexes:Array):void
		{
			for (var i:int = 0; i < indexes.length; i++)
			{
				openCellByIndex(indexes[i], true /* use shuffle? */, true /*force redraw*/);
			}
		}
		
		// Always set this first before setOpenedCels, otherwize items will be shown wrong 
		public function setShuffledIndexes(array:Array):void
		{
			shuffledIndexes = array;
		}
		
		public function arrayShuffle(array:Array):Array
		{
			var m:int = array.length;
			var i:int;
			var temp:int;
			var tempInt:int;
			while (m)
			{
				i = int(Math.random() * m--);
				temp = array[m];
				array[m] = array[i];
				array[i] = temp;
			}
			
			//trace("Shuffled Array " + array.toString());
			return array;
		}
		
		//
		//public function arrayShuffle(array:Vector.<BitmapData>):Vector.<BitmapData>{
		//var m:int = array.length;
		//var i:int;
		//var temp:BitmapData;
		//var tempInt:int;
		//while (m)	{						
		//i = int(Math.random() * m--);					
		////i = Math.floor(Math.random() /3);
		//temp = array[m];			
		//array[m] = array[i];
		//array[i] = temp;
		//// 
		//tempInt = shuffledIndexes[m];
		//shuffledIndexes[m] = shuffledIndexes[i];
		//shuffledIndexes[i] = tempInt;
		////shuffledIndexes[i] = normalIndexes[m];
		//
		//}		 
		//
		//
		//
		//trace("Shuffled String " + 	shuffledIndexes.toString());
		//return array;
		//}
		
		private function disposeCells():void
		{
			imageSquaresShuffeled.length = 0;
			for (var i:int = 0; i < imageSquares.length; i++)
			{
				var item:BitmapData = imageSquares[i] as BitmapData;
				if (item != null)
				{
					item.dispose();
					item = null;
				}
			}
			imageSquares.length = 0;
		
		}
		
		public function setSize(w:int, h:int):void
		{
			if (_viewWidth != w || _viewHeight != h)
			{
				_viewWidth = w;
				_viewHeight = h;
				updateViewPort();
			}
		}
		
		public function updateViewPort():void
		{
			if (_isDisposed) return;
			
			// resize image
			if (_originalBMD != null)
			{
				imageScale = UI.getMinScale(_originalBMD.width, _originalBMD.height, _viewWidth, _viewHeight);
				_imageBitmap.scaleX = _imageBitmap.scaleY = imageScale;
				if (_imageBitmap.height < _viewHeight)
				{
					_imageBitmap.y = (_viewHeight - _imageBitmap.height) * .5;
				}
				
			}
			// Buy button
			if (buyButton != null)
			{
				//buyButtonBitmapData = UI.renderButtonWithIcon("Pay to unlock image", _viewWidth - Config.DOUBLE_MARGIN * 2, Config.FINGER_SIZE, 0xffffff, 0x00a551, 0x008c45, /*AppTheme.BUTTON_CORNER_RADIUS*/ Config.FINGER_SIZE, AppTheme.BUTTON_CORNER_RADIUS);
				//buyButton.setBitmapData(buyButtonBitmapData, true);
				buyButton.x = _viewWidth- buyButton.width - Config.DOUBLE_MARGIN;
				buyButton.y = _viewHeight - buyButton.height - Config.DOUBLE_MARGIN;
			}
			
			// bg
			backgroundOverlay.width = _viewWidth;
			backgroundOverlay.height = _viewHeight;
			
			//header on ios
			if (appleHeaderBitmap != null){
				appleHeaderBitmap.width  = _viewWidth;
				appleHeaderBitmap.height  = Config.APPLE_TOP_OFFSET;
			}
			
			//header
			header.setSize(_viewWidth, Config.FINGER_SIZE * .85);
		}
		
		
		public function activate():void
		
		{
			if (_isDisposed) return;
			_isActivated = true;
			if (puzzleDataLoaded)
			{
				PointerManager.addTap(_imageContainer, onImageTap);
			}
			showButton();
			buyButton.activate();
			header.activate();
		}
		
		public function deactivate():void
		{
			if (_isDisposed) return;
			_isActivated = false;
			PointerManager.removeTap(_imageContainer, onImageTap);
			buyButton.deactivate();
			header.deactivate();
		}
		
		private function onImageTap(e:Event):void
		{
			if (_isPreview) return;
			if (e == null) return;
			if (!hasFreeCells())
			{				
			
				
				if (InvoiceManager.isPreProcessing == false) {					
					if (dialogCallback != null){
						dialogCallback();
					}				
				}
				return;
			}
			var tapX:int = e["localX"] - _imageBitmap.x;
			var tapY:int = e["localY"] - _imageBitmap.y;
			var clickedCol:int = (tapX / (_cellSizeSquare.width * imageScale));
			var clickedRow:int = (tapY / (_cellSizeSquare.height * imageScale));
			var index:int = clickedRow * _numCol + clickedCol;
			openCellByIndex(index, true, false, true);
		}
		
		private function doEffect(x:int, y:int, width:int, height:int):void
		{
			var posX:int = x * imageScale + _imageBitmap.x;
			var posY:int = y * imageScale + _imageBitmap.y;
			var outBound:int = 20;
			var destWidth:int = _cellSizeSquare.width * imageScale;
			var destHeight:int = _cellSizeSquare.height * imageScale;
			TweenMax.killTweensOf(effectLayer);
			effectLayer.alpha = 1;
			effectLayer.x = posX;
			effectLayer.y = posY;
			effectLayer.width = _cellSizeSquare.width * imageScale;
			effectLayer.height = _cellSizeSquare.height * imageScale;
			TweenMax.to(effectLayer, .7, {autoAlpha: 0, x: posX - 20, y: posY - 20, width: destWidth + 40, height: destHeight + 40, ease: Quint.easeOut});
		}
		
		
		public function openCellByIndex(index:int, useShuffleValue:Boolean = false, forceRedraw:Boolean = false, useFX:Boolean = false):void
		{
			//trace("Open Segment " + index);
			if (index < 0 || index >= _totalCellsCount)
			{
				return;
			}
			if (isIndexOpened(index) && !forceRedraw)
			{
				return;
			}
			
			// Check index range 
			if (index >= 0 || index < _totalCellsCount)
			{
				openedCellsMap[index] = 1;
				_openedCellsCount++;
				if (_openedIndexes.indexOf(index != -1))
				{
					_openedIndexes.push(index);
				}
				
				if (_openedCellsCount > 0){
					hideClickToStart();
				}
				//var segmentBMD:BitmapData = imageSquares[index];	
				var imageByIndex:int = useShuffleValue ? shuffledIndexes[index] : index;
				var segmentBMD:BitmapData = imageSquaresShuffeled[imageByIndex];
				var clickedCol:int = index % _numCol;
				var clickedRow:int = int(index / _numCol);
				var segmentX:int = (clickedCol * _cellSizeSquare.width + .5);
				var segmentY:int = (clickedRow * _cellSizeSquare.height + .5);
				_cellSizeSquare.x = segmentX;
				_cellSizeSquare.y = segmentY;
				//_imageBitmapData.fillRect(_cellSizeSquare, 0x000000);
				_imageBitmapData.copyPixels(segmentBMD, segmentBMD.rect, getPoint(segmentX, segmentY));
				//trace("CCOL "+ clickedCol);
				//trace("CROW "+ clickedRow);
				
				if (useFX)
				{
					saveGameData();
					doEffect(segmentX, segmentY, segmentBMD.rect.height, segmentBMD.rect.width);
				}
			}
		
		}
		
		static private function onOK():void
		{
			LightBox.close();
		}
		
		static private function onCancel():void{
			LightBox.close();
		}
		
		public function dispose():void
		{
			if (_isDisposed) return;
			_isDisposed = true;
			
			if (buyButton != null)
			{
				buyButton.dispose();
				buyButton = null;
			}
			
			hidePrelaoder();
			TweenMax.killTweensOf(effectLayer);
			disposeCells();
			deactivate();
			UI.destroy(_imageBitmap);
			_imageBitmap = null;
			UI.disposeBMD(_originalBMD);
			_originalBMD = null;
			UI.disposeBMD(_imageBitmapData);
			_imageBitmapData = null;
			UI.destroy(_imageContainer);
			_imageContainer = null;
			UI.destroy(backgroundOverlay);
			backgroundOverlay = null;	
			UI.destroy(appleHeaderBitmap);
			appleHeaderBitmap = null;
			
			if (header != null)
			{
				header.dispose();
				header = null;
			}
		}
		
		public function hasFreeCells():Boolean  { return _openedIndexes.length < _maxCellsToShow; }
		
		public function isIndexOpened(i:int):Boolean  { return openedCellsMap[i] == 1; }
		
		private static function getPoint(x:int = 0, y:int = 0):Point  { tempPoint.x = x; tempPoint.y = y; return tempPoint; }
	
	}

}