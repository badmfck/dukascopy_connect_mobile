package com.dukascopy.connect.gui.lightbox
{
	import assets.StopButtonIcon;
	import asssets.EmptyImage;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.shapes.Box;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.type.ScaleMode;
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import fl.motion.MatrixTransformer;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageOrientation;
	import flash.display.StageQuality;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	public class ZoomPanContainer extends Sprite implements IBitmapProvider
	{
		
		private var stageRef:Stage;
		
		private var _viewWidth:Number = 300;
		private var _viewHeight:Number = 500;
		
		private var originalWidth:Number;
		private var originalHeight:Number;
		
		private var TWEEN_TIME:Number = .4;
		private var canvasBitmap:Bitmap = new Bitmap();
		public var topOffset:int = 0;
		public var leftOffset:int = 0;
		
		//Settings
		public var _maxScale:Number;
		public var _minScale:Number; //0 - ne u4itivatj
		public var _miScale:Number; //0 - ne u4itivatj
		public var _maScale:Number; //0 - ne u4itivatj
		
		//Private
		private var pointsPool:Vector.<Point> = new Vector.<Point>;
		private var downPointsIDs:Vector.<int> = new Vector.<int>;
		private var _touchPoints:Vector.<Point> = new Vector.<Point>(4, true);
		private var _downTouches:uint = 0;
		private var _upTimer:uint;
		private var _clickThreshold:uint = 9; //Max allowed move distance on a "tap/click" event
		private var touchesDictionary:Dictionary = new Dictionary(true);
		
		private var _downP:Point = new Point();
		private var realDownPoint:Point = new Point();
		
		private var _initDistanceTwoPoints:Number;
		private var _highestDelta:Number = 0;
		
		//callbacks
		public var touchEndCallback:Function;
		public var dragOpacityCallback:Function;
		private var _distanceOpacity:Number = 1;
		
		private const TAP_ACCEPT_TIME:Number = .5;
		private const LONG_PRESS_TIME:Number = .8;
		private const DOUBLE_TAP_TIME:Number = .5;
		private const MIN_OPACITY:Number = .1;
		
		// TAPPING 
		
		private var _acceptTap:Boolean = false;
		private var numTaps:Number = 0;
		
		// ZOOMING 
		private var isZooming:Boolean = false;
		private var isZoomed:Boolean = false;
		private var minified:Boolean = false;
		
		private const hideTreshold:Number = Config.FINGER_SIZE * 2;
		private const paginationTrashold:Number = Config.FINGER_SIZE;
		
		// callbacks 
		public var longPressCallback:Function;
		public var closeCallback:Function;
		public var showStatusBarCallback:Function;
		public var hideStatusBarCallback:Function;
		
		// ACTIVITY 
		private var _activityTimer:uint;
		private var onActivityCallback:Function;
		
		// HIDE ON SWIPE PARAMS 
		private var hideOnUp:Boolean = false;
		private var allowHideOnThrowUP:Boolean = false;
		private var allowHideOnThrowDOWN:Boolean = false;
		
		// PAGINATION ON SWIPE  <--O     O--> 
		private var _usePagination:Boolean = false;
		private var paginateOnUp:Boolean = false;
		private var allowThrowRight:Boolean = false;
		private var allowThrowLeft:Boolean = false;
		public var showPrevFunction:Function;
		public var showNextFunction:Function;
		public var tapCallback:Function;
		
		// is 
		private var isHidden:Boolean = true;
		private var enabled:Boolean = true;
		
		// using these matrix for calculations
		private var tempMatrix1:Matrix = new Matrix();
		private var tempMatrix2:Matrix = new Matrix();
		private var tempMatrix3:Matrix = new Matrix();
		private var tempMatrix4:Matrix = new Matrix();
		private var _downMatrix:Matrix;
		
		// DIRECTIONAL LOCK 
		private const DIRECTION_DETECT_OFFSET:int = 15;
		private var needDetectDirection:Boolean = false;
		private var isDirectionDetected:Boolean = false;
		private var HOR_LOCK:Boolean = false; // Y axis locked 
		private var VER_LOCK:Boolean = false;	// X axis locked 	
		private var lockXCoordinate:int = 0;
		private var lockYCoordinate:int = 0;
		
		private var _scaleMode:int = ScaleMode.FIT;
		private var orientation:String;
		private var listenForScreenRotation:Boolean;
		private var rotationData:Object;
		private var pendingAnimationData:Object;
		private var rotatioinAnimationPlaying:Boolean;
		private var inAnimation:Boolean;
		public var touchStartCallback:Function;
		
		public var allowHideOnSwipe:Boolean = true;
		
		/** @CONSTRUCTOR */
		public function ZoomPanContainer(_stageRef:Stage, _maxSc:Number = 0, _minSc:Number = 0)
		{
			stageRef = _stageRef;
			_maxScale = _maxSc;
			_minScale = _minSc;
			addChild(canvasBitmap);
			this.mouseChildren = this.mouseEnabled = false;
		}
		
		// EVENT HANDLERS =============================================================
		//=============================================================================
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ESCAPE)
			{
				hide();
			}
		}
		
		/*** 1 ON TOUCH START **/
		private function onTouchBegin(e:TouchEvent):void
		{
			if ((e.target is Box) == false)
			{
			//	return;
			}
			if ((e.target is BitmapButton))
			{
				return;
			}
			
			if (!enabled) return;
			if (canvasBitmap.bitmapData == null) return;// neher skeilitj		
			startActivityTimer();
			
			if (isHidden) return;
			if (_scaleMode == ScaleMode.FIT)
			{
				if (isZooming || e.stageY <= topOffset || e.stageX <= leftOffset) return;
			}
			else if (_scaleMode == ScaleMode.FILL)
			{
				if (isZooming || e.stageY <= 0 || e.stageX <= 0) return;
			}
			
			if (downPointsIDs.indexOf(e.touchPointID) >= 0) return;
			if (_downTouches >= 2) return;
			
			// ESLI ZOOMIMSJA TO OSTANAVLIVAEM PROCESS ZOOMA  
			if (!isZooming)
			{
				isZooming = false;
				TweenMax.killTweensOf(this)
				if (rotationData != null)
				{
					TweenMax.killTweensOf(rotationData);
				}
			}
			
			_downTouches++;
			var newPoint:Point;
			var indexToPushPoint:int;
			
			// 1 ) FIRST TOUCH =============================================================
			if (_downTouches == 1)
			{
				
				if (orientation == null || orientation == StageOrientation.UPSIDE_DOWN || orientation == StageOrientation.DEFAULT || listenForScreenRotation == false)
				{
					newPoint = getFreePoint(e.stageX, e.stageY);
				}
				else if (orientation == StageOrientation.ROTATED_LEFT)
				{
					newPoint = getFreePoint(e.stageY, stage.fullScreenWidth - e.stageX);
				}
				else if (orientation == StageOrientation.ROTATED_RIGHT)
				{
					newPoint = getFreePoint(stage.fullScreenHeight - e.stageY, e.stageX);
				}
				
				/// creating new point  ----------------------------------------
				
				touchesDictionary[e.touchPointID] = newPoint;
				indexToPushPoint = downPointsIDs.length;
				downPointsIDs[indexToPushPoint] = (e.touchPointID);
				///----------------------------------------------------------------
				
				/// remember start position on first touch ------------------
				_downP.x = x;
				_downP.y = y;
				realDownPoint.x = x;
				realDownPoint.y = y;
				///------------------------------------------------------------------
				
				/// reset long press timer --------------------------------------
				TweenMax.killDelayedCallsTo(onLongPress);
				TweenMax.delayedCall(LONG_PRESS_TIME, onLongPress);
				///------------------------------------------------------------------
				/// reset tap timer -----------------------------------------------
				TweenMax.killDelayedCallsTo(stopTapAccept);
				TweenMax.delayedCall(DOUBLE_TAP_TIME, stopTapAccept);
				_acceptTap = true;
				///------------------------------------------------------------------
				
				/// check if we need directional lock ------------------------
				isDirectionDetected = false;
				HOR_LOCK = false;
				VER_LOCK = false;
				needDetectDirection = allowDirectionDetect();
				
				///-----------------------------------------------------------------
				
				/// check if we can close lightbox on throw  vertically image ---
				hideOnUp = allowThrowHide();
				///------------------------------------------------------------------------
				
				/// check if we can paginate on horizontal swipe ----------------
				paginateOnUp = allowThrowPagination();
				///------------------------------------------------------------------------
				
				addTouchEvents();
				
				/// resyng touch points for zoom -----------------------------------
				resync();
					///------------------------------------------------------------------------
				
					// end first touch ===============================================================
				
					// 2) SECOND TOUCH - READY TO ZOOM ===========================================
			}
			else if (_downTouches == 2)
			{
				
				/// reset long press --------------------------------------------------
				TweenMax.killDelayedCallsTo(onLongPress);
				///-----------------------------------------------------------------------
				
				//if (!isDirectionDetected) {
				needDetectDirection = false;
				HOR_LOCK = false;
				VER_LOCK = false;
				//	}
				
				/// IGNORE ZOOMING IF DIRECTIONAL LOCK WAS DETECTED  --
				if (needDetectDirection && isDirectionDetected)
				{
					
					// X locked 
					if (HOR_LOCK)
					{
						//paginateOnUp = false;
						hideOnUp = true;
					}
					
					// Y locked 
					if (VER_LOCK)
					{
						paginateOnUp = true;
						hideOnUp = false;
					}
					
					_downTouches--;
					
				}
				else
				{
					
					/// creating new point  ----------------------------------------
					
					if (orientation == null || orientation == StageOrientation.UPSIDE_DOWN || orientation == StageOrientation.DEFAULT || listenForScreenRotation == false)
					{
						newPoint = getFreePoint(e.stageX, e.stageY);
					}
					else if (orientation == StageOrientation.ROTATED_LEFT)
					{
						newPoint = getFreePoint(e.stageY, stage.fullScreenWidth - e.stageX);
					}
					else if (orientation == StageOrientation.ROTATED_RIGHT)
					{
						newPoint = getFreePoint(stage.fullScreenHeight - e.stageY, e.stageX);
					}
					
					touchesDictionary[e.touchPointID] = newPoint;
					indexToPushPoint = downPointsIDs.length;
					downPointsIDs[indexToPushPoint] = (e.touchPointID);
					///----------------------------------------------------------------
					
					/// destroy hide and pagination on swipe image ----------------
					hideOnUp = false;
					paginateOnUp = false;
					///-----------------------------------------------------------------------
					
					/// Calculate initial distance between points --------------------
					const p1:Point = touchesDictionary[downPointsIDs[0]];
					const p2:Point = touchesDictionary[downPointsIDs[1]];
					const dist:Number = Point.distance(p1, p2);
					_initDistanceTwoPoints = dist / scaleX;
					///------------------------------------------------------------------------
					
					/// resyng touch points for zoom -----------------------------------
					resync();
						///------------------------------------------------------------------------
					
				}
			}
			
			if (touchStartCallback != null)
			{
				touchStartCallback();
			}
			
			//=======  end 2 second touch ========================================================
		}
		
		/*** RESYNC POINTS  */
		
		private final function resync():void
		{
			_downMatrix = transform.matrix;
			var id:int = downPointsIDs[0];
			var p:Point = touchesDictionary[id];
			_touchPoints[0] = p.clone();
			_touchPoints[1] = p1 ? p1.clone() : null;
		}
		
		/*** 2 ON TOUCH MOVE **/
		private function onTouchMove(e:TouchEvent):void
		{
			if (!enabled) return;
			
			/// esli koli4estvo touchej bol6e odnogo to ignorim perelistivanie i close na swipe 
			if (_downTouches >= 2)
			{
				hideOnUp = false;
				paginateOnUp = false;
			}
			///---------------------------------------------------------------------------------------------
			
			/// pustoj lightbox --------------------------------------------------------------------------
			if (canvasBitmap.bitmapData == null) return;// neher skeilitj		
			///---------------------------------------------------------------------------------------------
			
			/// pokazivaem wapku lightboxa ---------------------------------------------------------
			startActivityTimer();
			///---------------------------------------------------------------------------------------------
			
			if (isHidden) return;//kostiljok
			
			if (isZooming) return;
			
			/// touch point nebil zaregestrirovan  na TouchBegin ------------
			if (downPointsIDs.indexOf(e.touchPointID) == -1) return;
			///--------------------------------------------------------------------------
			
			const firstTouchID:int = downPointsIDs[0];
			var firstTouchPoint:Point = touchesDictionary[firstTouchID];
			
			/// kill long press timer -------------------------------------------------					
			TweenMax.killDelayedCallsTo(onLongPress);
			///--------------------------------------------------------------------------
			
			/// TOUCH POINTS ZOOM bTRANSFORM CALCULATIONS -----
			var touchPoint:Point = touchesDictionary[e.touchPointID];
			if (touchPoint != null)
			{
				
				if (orientation == null || orientation == StageOrientation.UPSIDE_DOWN || orientation == StageOrientation.DEFAULT || listenForScreenRotation == false)
				{
					touchPoint.x = HOR_LOCK ? lockXCoordinate : e.stageX;
					touchPoint.y = VER_LOCK ? lockYCoordinate : e.stageY;
				}
				else if (orientation == StageOrientation.ROTATED_LEFT)
				{
					touchPoint.x = HOR_LOCK ? lockXCoordinate : e.stageY;
					touchPoint.y = VER_LOCK ? lockYCoordinate : stage.fullScreenWidth - e.stageX;
				}
				else if (orientation == StageOrientation.ROTATED_RIGHT)
				{
					touchPoint.x = HOR_LOCK ? lockXCoordinate : stage.fullScreenHeight - e.stageY;
					touchPoint.y = VER_LOCK ? lockYCoordinate : e.stageX;
				}
			}
			
			//const firstTouchID:int = downPointsIDs[0];
			//var firstTouchPoint:Point = touchesDictionary[firstTouchID];
			
			if (_touchPoints[2] != null)
			{
				var secondTouchPoint:Point = _touchPoints[2];
				secondTouchPoint.x = firstTouchPoint.x;
				secondTouchPoint.y = firstTouchPoint.y;
			}
			else
			{
				_touchPoints[2] = touchesDictionary[firstTouchID].clone();
			}
			_touchPoints[3] = p1 ? p1.clone() : null;
			
			tempMatrix1 = _downMatrix.clone();
			var deltaMatrix:Matrix = deltaMatrixArray();
			if (deltaMatrix != null)
			{
				tempMatrix2 = deltaMatrix;
			}
			else
			{
				return;
			}
			
			tempMatrix1.concat(tempMatrix2);
			
			///  GET TOUCH OFFSETS -------------------------------------------
			//	const dY:Number = y - _downP.y;			
			//	const dX:Number = x - _downP.x;						
			const dY:Number = tempMatrix1.ty - _downP.y;
			const dX:Number = tempMatrix1.tx - _downP.x;
			const absX:Number = Math.abs(dX);
			const absY:Number = Math.abs(dY);
			///----------------------------------------------------------------------------
			
			// SKEILIM I DVIGAEM KONTAINER ===========			
			if (needDetectDirection)
			{
				if (isDirectionDetected)
				{
					transform.matrix = tempMatrix1;
				}
			}
			else
			{
				transform.matrix = tempMatrix1;
			}
			
			//======================================
			
			/// resetim vremennie matrici -----------------------------------------
			tempMatrix1.identity();
			tempMatrix2.identity();
			///--------------------------------------------------------------------------
			
			///  Nado opredelitj v kakom napravleniji scroll budet proishoditj =====
			if (needDetectDirection && !isDirectionDetected)
			{
				
				/// find scroll direction by offset  ---------------------------------------
				if (absX > DIRECTION_DETECT_OFFSET || absY > DIRECTION_DETECT_OFFSET)
				{
					
					VER_LOCK = absX > DIRECTION_DETECT_OFFSET;
					HOR_LOCK = !VER_LOCK;
					
					if (orientation == null || orientation == StageOrientation.UPSIDE_DOWN || orientation == StageOrientation.DEFAULT || listenForScreenRotation == false)
					{
						firstTouchPoint.x = e.stageX;
						firstTouchPoint.y = e.stageY;
					}
					else if (orientation == StageOrientation.ROTATED_LEFT)
					{
						firstTouchPoint.x = e.stageY;
						firstTouchPoint.y = stage.fullScreenWidth - e.stageX;
					}
					else if (orientation == StageOrientation.ROTATED_RIGHT)
					{
						firstTouchPoint.x = stage.fullScreenHeight - e.stageY;
						firstTouchPoint.y = e.stageX;
					}
					
					lockYCoordinate = firstTouchPoint.y;// add offset for detection to compensate move done
					lockXCoordinate = firstTouchPoint.x;
					
					_downP.x = firstTouchPoint.x;
					_downP.y = firstTouchPoint.y;
					
					resync();
					
					isDirectionDetected = true;
						//alpha = 0.4;
					
				}
				else
				{
					HOR_LOCK = false;
					VER_LOCK = false;
						//	alpha = 1;
				}
				
			}
			
			//====================================================
			///Menjaem prozra4nostj backgrounda na drag------------------------
			if (HOR_LOCK)
			{
				var touchPosition:Number;
				if (orientation == null || orientation == StageOrientation.UPSIDE_DOWN || orientation == StageOrientation.DEFAULT || listenForScreenRotation == false)
				{
					touchPosition = e.stageY;
				}
				else if (orientation == StageOrientation.ROTATED_LEFT)
				{
					touchPosition = stage.fullScreenWidth - e.stageX;
				}
				else if (orientation == StageOrientation.ROTATED_RIGHT)
				{
					touchPosition = e.stageX;
				}
				const deltaY:Number = Math.abs(_downP.y - touchPosition);
				if (deltaY > 100)
				{//hideTreshold) { 					
					//	var pct:Number = 1 - ((deltaY-hideTreshold) / (hideTreshold*.5));
					var pct:Number = 1 - ((deltaY - 100) / 200);
					if (pct < MIN_OPACITY) pct = MIN_OPACITY;
					if (pct > 1) pct = 1;
					distanceOpacity = pct;
					return;
				}
				else
				{
					distanceOpacity = 1;
				}
			}
			///-----------------------------------------------------------------------------
		}
		
		/*** 3  ON TOUCH END **/
		private function onTouchEnd(e:TouchEvent):void
		{
			if (!enabled) return;
			if (canvasBitmap == null || canvasBitmap.bitmapData == null) return;// neher skeilitj		
			if (isHidden) return;//kostiljok
			
			/// reset activity timer ---------------------------------------------------
			startActivityTimer();
			///---------------------------------------------------------------------------
			
			/// was this point initialized on touch begin ---------------------------
			var index:int = downPointsIDs.indexOf(e.touchPointID);
			if (index < 0) return;
			///----------------------------------------------------------------------------
			
			/// proverka na TAP  -----------------------------------------------------
			var tapped:Boolean = false;
			//Check if this should be considered a "click/tap"
			if (_downTouches == 1 && _acceptTap && realDownPoint != null)
			{
				if (Math.abs(x - realDownPoint.x) < _clickThreshold && Math.abs(y - realDownPoint.y) < _clickThreshold)
				{
					numTaps++;
					// TAP IS DISPATCHED 
					if (numTaps >= 2)
					{
						tapped = true;
						numTaps = 0;
						
						if (isZoomed)
						{
							isZoomed = false;
							zoomOut();
						}
						else
						{
							isZoomed = true;
							zoomIn();
						}
					}
					else
					{
						if (tapCallback && e.target is Box)
						{
							tapCallback();
						}
						TweenMax.killDelayedCallsTo(resetDoubleTap);
						TweenMax.delayedCall(DOUBLE_TAP_TIME, resetDoubleTap);
					}
				}
				else
				{
					//Tried tap, but was moved 					
				}
			}
			///-----------------------------------------------------------------------------
			
			/// Udaljaem iz stoka touch pointov --------------------------------------
			if (downPointsIDs != null)
			{
				downPointsIDs.splice(index, 1)[0];
			}
			
			_downTouches--;
			///-------------------------------------------------------------------------------
			
			/// ne poslednij touch point UP --------------------------------------------
			if (_downTouches > 0)
			{
				resync();
				
					/// Poslednij touch point UP  ----------------------------------------------		
			}
			else
			{
				
				if (touchEndCallback != null) touchEndCallback();
				TweenMax.killDelayedCallsTo(onLongPress);
			}
			///------------------------------------------------------------------------------
			
			// PROVERJAEM OFFSET I NUZNBO LI HIDE ILI NEXT-PREV IMAGE 
			if (_downTouches == 0 && !tapped && realDownPoint != null)
			{
				
				const dY:Number = y - realDownPoint.y;
				const dX:Number = x - realDownPoint.x;
				const absX:Number = Math.abs(dX)
				const absY:Number = Math.abs(dY)
				const isHorizontalMovement:Boolean = absX > absY;
				
				/// pagination on swipe ----------------------------------------	
				if (isHorizontalMovement && absX > paginationTrashold && paginateOnUp)
				{
					var paginationDirection:int = dX;
					if (dX < 0)
					{
						if (allowThrowRight)
						{
							nextPage();
						}
						else
						{
							checkBounds(); // TODO check
						}
					}
					else
					{
						if (allowThrowLeft)
						{
							previousPage();
						}
						else
						{
							checkBounds(); // TODO check
						}
					}
					return;
				}
				///--------------------------------------------------------------
				
				/// hide on swipe  -------------------------------------------
				if (absY > hideTreshold && hideOnUp)
				{
					//var hideDirection:int = dY;						
					//hide up 
					if (dY < 0)
					{
						if (allowHideOnThrowUP)
						{
							hide(false);
							return;
						}
					}
					// hide down 
					if (dY > 0)
					{
						if (allowHideOnThrowDOWN)
						{
							hide(true);
							return;
						}
					}
				}
				///-----------------------------------------------------------
				
				checkBounds();
				
			}
		}
		
		/*** ON LONG PRESS ***/
		private final function onLongPress():void
		{
			resetTouchPoints();
			if (longPressCallback != null) longPressCallback();
		}
		
		// PRIVATE METHODS ============================================================		
		
		//=============================================================================
		
		/*** REMOVE TOUCH EVENTS */
		private final function removeTouchEvents():void
		{
			stageRef.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			stageRef.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			stageRef.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			stageRef.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stageRef.removeEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
		}
		
		/** ADD TOUCH EVENTS **/
		private final function addTouchEvents():void
		{
			//		stageRef.addEventListener(MouseEvent.MOUSE_DOWN, onDown);			
			stageRef.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			stageRef.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			stageRef.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			stageRef.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stageRef.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
		}
		
		/** ACTIVATE */
		public final function activate():void
		{
			addTouchEvents();
		}
		
		/**  DEACTIVATE  **/
		public final function deactivate():void
		{
			removeTouchEvents();
		}
		
		/*** ALLOW DIRECTION DETECT ***/
		private final function allowDirectionDetect():Boolean
		{
			var h:Number = originalHeight * scaleY;
			if (h <= _viewHeight)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		// PAGINATION  METHODS ============================================================
		//=============================================================================
		
		/** ON WHEEL **/
		private final function onWheel(e:MouseEvent):void
		{
			if (e.delta < 0)
			{
				previousPage();
			}
			else
			{
				nextPage();
			}
		}
		
		/** NEXT **/
		public final function nextPage():void
		{
			paginateOnUp = false;
			if (showNextFunction != null) showNextFunction();
		}
		
		/** PREV  **/
		public final function previousPage():void
		{
			paginateOnUp = false;
			if (showPrevFunction != null) showPrevFunction();
		
		}
		
		/*** ALLOW PAGINATION  ***/
		private final function allowThrowPagination():Boolean
		{

			if (!_usePagination) return false;
			
			allowThrowRight = false;
			allowThrowLeft = false;
			const w:Number = originalWidth * scaleX;
			
			// esli kartinka vnutri viewporta 
			
			if (w <= _viewWidth + 5)
			{
				allowThrowRight = true;
				allowThrowLeft = true;
				return true;
			}
			
			if (this.x >= 0)
			{
				allowThrowLeft = true;
				return true;
			}
			
			if (this.x <= _viewWidth - w)
			{
				allowThrowRight = true;
				return true;
			}
			return false;
		
		}
		
		// SHOW <--> HIDE METHODS ======================================================
		//=============================================================================
		
		/*** SHOW  **/
		public final function show(listenForScreenRotation:Boolean = false):void
		{

			this.listenForScreenRotation = listenForScreenRotation;
			//if (!isHidden) return;			
			TweenMax.killTweensOf(this);
			if (rotationData != null)
			{
				TweenMax.killTweensOf(rotationData);
			}
			
			transform.matrix = new Matrix();
			
			isZooming = false;
			isHidden = false;
			canvasBitmap.visible = true;
			if (dragOpacityCallback != null)
				dragOpacityCallback(1);
			startActivityTimer();

		}
		
		/** ALLOW HIDE **/
		protected function allowThrowHide():Boolean
		{

			
			if (allowHideOnSwipe == false)
				return false;
			
			allowHideOnThrowDOWN = false;
			allowHideOnThrowUP = false;
			const imgH:Number = originalHeight * scaleY;
			
			//ESLI KATRINKA < VIEWPORTA 
			if (imgH <= _viewHeight)
			{
				allowHideOnThrowDOWN = allowHideOnThrowUP = true; // allow throw both directions
				return true;
				
					// KARTINKA > VIEWPORTA 	
			}
			else
			{
				if (this.y >= topOffset)
				{
					allowHideOnThrowDOWN = true;
					return true; // allow throw down 
				}
				
				if (this.y <= -(imgH - _viewHeight - topOffset - 1))
				{ // -1 for accuracy
					allowHideOnThrowUP = true;
					return true; // allow throw up
				}
				return false;
			}
		
		}
		
		/*** DEFINE SCROLL POLICES */
		private final function detectScrollPolices():void
		{
		
		}
		
		/*** HIDE**/
		public final function hide(hideDown:Boolean = false):void
		{

			if (isHidden) return;
			
			clearRotateAnimation();
			
			deactivate();
			isZooming = false;
			isHidden = true;
			hideOnUp = false;
			
			TweenMax.killTweensOf(this);
			if (rotationData != null)
			{
				TweenMax.killTweensOf(rotationData);
			}
			var dy:Number = hideDown ? _viewHeight + topOffset + 30 : -originalHeight * scaleY - topOffset;
			TweenMax.to(this, .3, {y: dy, ease: Expo.easeOut, onComplete: function():void
			{
				onHideComplete();
			}});

		}
		
		/*** ON HIDE COMPLETE ***/
		private final function onHideComplete():void
		{
			if (closeCallback != null) closeCallback();
			canvasBitmap.visible = false;
			if (canvasBitmap.bitmapData)
			{
				canvasBitmap.bitmapData.dispose();// TODO ?hz
				canvasBitmap.bitmapData = null;
			}
		}
		
		// ZOOM  METHODS ==============================================================
		//=============================================================================
		
		/** TOGGLE ZOOM **/
		private final function toggleZoom():void
		{
			if (isZoomed)
			{
				isZoomed = false;
				zoomOut();
			}
			else
			{
				isZoomed = true;
				zoomIn();
			}
		}
		
		/** ZOOM OUT **/
		private final function zoomOut():void
		{
			minified = true;
			hideOnUp = true;
			paginateOnUp = true;
			isZooming = true;
			var dx:Number = (_viewWidth - originalWidth * _miScale) * .5 + leftOffset;
			var dy:Number = (_viewHeight - originalHeight * _miScale) * .5 + topOffset;
			TweenMax.killTweensOf(this);
			if (rotationData != null)
			{
				TweenMax.killTweensOf(rotationData);
			}
			TweenMax.to(this, .3, {x: dx, y: dy, scaleX: _miScale, scaleY: _miScale, onUpdate: checkBoundsOnScale, onComplete: onZoomOutComplete});
		}
		
		/*** ZOOM IN **/
		private final function zoomIn():void
		{
			//`paginateOnUp = true;
			minified = false;
			isZooming = true;
			var dx:Number = (_viewWidth - originalWidth) * .5 + leftOffset;
			var dy:Number = (_viewHeight - originalHeight) * .5 + topOffset;
			TweenMax.killTweensOf(this);
			if (rotationData != null)
			{
				TweenMax.killTweensOf(rotationData);
			}
			TweenMax.to(this, .3, {x: dx, y: dy, scaleX: 1, scaleY: 1, onUpdate: checkBoundsOnScale, onComplete: onZoomOutComplete});
		}
		
		/*** onZoomComplete ***/
		private final function onZoomOutComplete():void
		{
			isZooming = false;
			minified = true;
			checkBoundsOnScale();
		}
		
		/*** onZoomComplete ***/
		private final function onZoomInComplete():void
		{
			isZooming = false;
			minified = false;
			checkBoundsOnScale();
		}
		
		// ACTIVITY TRACKING  METHODS =================================================
		//=============================================================================
		public final function startTrackActivity(onActivityCallback:Function):void
		{
			this.onActivityCallback = onActivityCallback;
			TweenMax.killDelayedCallsTo(setActivityStopped);
			TweenMax.delayedCall(1, setActivityStopped);
		}
		
		public final function stopTrackActivity():void
		{
			this.onActivityCallback = null
			TweenMax.killDelayedCallsTo(setActivityStopped);
		}
		
		private final function setActivityStopped():void
		{
			if (_downTouches > 0 || canvasBitmap.bitmapData == null || !enabled)
			{ // ne prjatatj esli bitmapdata null i ne zagruzilasj
				TweenMax.killDelayedCallsTo(setActivityStopped);
				TweenMax.delayedCall(1, setActivityStopped);
				if (onActivityCallback != null) onActivityCallback(true);
			}
			else
			{
				if (onActivityCallback != null) onActivityCallback(false);
			}
		
		}
		
		private final function startActivityTimer():void
		{
			TweenMax.killDelayedCallsTo(setActivityStopped);
			TweenMax.delayedCall(1, setActivityStopped);
			if (onActivityCallback != null) onActivityCallback(true);
		}
		
		public final function forceCheckBounds():void
		{
			checkBounds(1);
		}
		
		public final function resetTouchPoints():void
		{
			_downTouches = 0;
			if (downPointsIDs != null){
				downPointsIDs.length = 0;
			}
		}
		
		// PRIVATE METHODS ============================================================
		//=============================================================================
		
		/*** resetDoubleTap ***/
		private final function resetDoubleTap():void
		{
			numTaps = 0;
		}
		
		/** STOP ACCEPT TAP **/
		private final function stopTapAccept():void
		{
			_acceptTap = false;
		}
		
		/****  FIRST  */
		private final function get p1():Point
		{
			if (_downTouches < 2) return null;
			return touchesDictionary[downPointsIDs[1]];
		}
		
		/** DISTANCE OPACITY  **/
		public function get distanceOpacity():Number  { return _distanceOpacity; }
		
		public function set distanceOpacity(value:Number):void
		{
			if (value == _distanceOpacity) return;
			_distanceOpacity = value;
			if (dragOpacityCallback != null) dragOpacityCallback(_distanceOpacity);
		}
		
		/*** USE PAGINATION **/
		public function get usePagination():Boolean  { return _usePagination; }
		
		public function set usePagination(value:Boolean):void
		{
			_usePagination = value;
		}
		
		/*** VIEW WIDTH **/
		public function get viewWidth():Number  { return _viewWidth; }
		
		/** VIEW HEIGHT **/
		public function get viewHeight():Number  { return _viewHeight; }
		
		/*** checkBoundsOnScale ***/
		[Inline]
		private final function checkBoundsOnScale():void
		{
			var scX:Number = transform.matrix.a;
			var destX:Number = this.x;
			var destY:Number = this.y;
			const curW:Number = scX * originalWidth;
			const curH:Number = scX * originalHeight;
			
			// HORIZONTAL ALIGN
			if (curW > _viewWidth)
			{
				if (x > leftOffset)
				{
					destX = leftOffset;
					this.x = destX;
				}
				if (x + curW < _viewWidth + leftOffset)
				{
					destX = _viewWidth - width + leftOffset;
					this.x = destX;
				}
			}
			else
			{
				//centrate
				if (_scaleMode == ScaleMode.FIT)
				{
					destX = (_viewWidth - curW) * .5 + leftOffset;
					this.x = destX;
				}
				minified = true;
			}
			
			// VERTICAL ALIGN 
			if (curH > _viewHeight)
			{
				if (y > topOffset)
				{
					destY = topOffset;
					this.y = destY;
				}
				if (y + curH < _viewHeight + topOffset)
				{
					destY = _viewHeight - curH + topOffset;
					this.y = destY;
				}
			}
			else
			{
				//centrate
				if (_scaleMode == ScaleMode.FIT)
				{
					destY = (_viewHeight - curH) * .5 + topOffset;
					this.y = destY;
				}
				minified = true;
			}
		}
		
		/** RETURN MINIMAL SCALE BASED ON VIEWPORT AND IMAGE SIZES **/
		[Inline]
		public final function getMinScale(imageWidth:int, imageHeight:int, fitWidth:Number, fitHeight:Number):Number
		{
			const sX:Number = fitWidth / imageWidth;
			const sY:Number = fitHeight / imageHeight;
			const rD:Number = imageWidth / imageHeight;
			const rR:Number = fitWidth / fitHeight;
			return rD >= rR ? sX : sY;
		}
		
		[Inline]
		public final function getMaxScale(imageWidth:int, imageHeight:int, fitWidth:Number, fitHeight:Number):Number
		{
			const sX:Number = fitWidth / imageWidth;
			const sY:Number = fitHeight / imageHeight;
			const rD:Number = imageWidth / imageHeight;
			const rR:Number = fitWidth / fitHeight;
			return rD < rR ? sX : sY;
		}
		
		/** CHECK BOUNDS **/
		private final function checkBounds(time:Number = -1, manualResize:Boolean = true):void
		{
			echo("ZoomPanContainer", "checkBounds", "START");
			time = time == -1 ? TWEEN_TIME : time;
			if (_scaleMode == ScaleMode.FIT)
			{
				_miScale = getMinScale(originalWidth, originalHeight, _viewWidth, _viewHeight);
			}
			else if (_scaleMode == ScaleMode.FILL)
			{
				_miScale = getMaxScale(originalWidth, originalHeight, _viewWidth, _viewHeight);
			}
			
			var destX:Number = this.x;
			var destY:Number = this.y;
			
			//Proverka na in scale 
			var destScale:Number = scaleX;
			if (scaleX <= _miScale)
			{
				///CENTRUEM PO GORIZONTALI I VERTIKALI
				destScale = _miScale;
				isZoomed = false;
				if (_scaleMode == ScaleMode.FIT)
				{
					destX = (_viewWidth - originalWidth * _miScale) * .5 + leftOffset;
					destY = (_viewHeight - originalHeight * _miScale) * .5 + topOffset;
				}
				else if (_scaleMode == ScaleMode.FILL)
				{
					if (x > leftOffset)
					{
						destX = leftOffset;
					}
					if (x + originalWidth * _miScale < _viewWidth + leftOffset)
					{
						destX = _viewWidth - originalWidth * _miScale + leftOffset;
					}
					if (y > topOffset)
					{
						destY = topOffset;
					}
					if (y + originalHeight * _miScale < _viewHeight + topOffset)
					{
						destY = _viewHeight - originalHeight * _miScale + topOffset;
					}
				}
				TweenMax.killTweensOf(this);
				if (rotationData != null)
				{
					TweenMax.killTweensOf(rotationData);
				}
				inAnimation = true;
				TweenMax.to(this, time, {scaleX: destScale, scaleY: destScale, x: destX, y: destY, alpha: 1, distanceOpacity: 1, ease: Expo.easeOut, onComplete:boundsCheckComplete});
				return;
			}
			else
			{
				// HORIZONTAL ALIGN
				if (width >= _viewWidth)
				{
					
					if (x > leftOffset)
					{
						
						if (manualResize)
						{
							destX = leftOffset;
						}
						else
						{
							destX = _viewWidth * .5 - width * .5;
						}
					}
					if (x + width < _viewWidth + leftOffset)
					{
						destX = _viewWidth - width + leftOffset;
					}
				}
				else
				{
					//centrate
					if (_scaleMode == ScaleMode.FIT)
					{
						destX = (_viewWidth - width) * .5 + leftOffset;
					}
				}
				
				// VERTICAL ALIGN 
				if (height >= _viewHeight)
				{
					if (y > topOffset)
					{
						
						if (manualResize)
						{
							destY = topOffset;
						}
						else
						{
							destY = _viewHeight * .5 - height * .5;
						}
					}
					if (y + height < _viewHeight + topOffset)
					{
						destY = _viewHeight - height + topOffset;
					}
				}
				else
				{
					//centrate
					if (_scaleMode == ScaleMode.FIT)
					{
						destY = (_viewHeight - height) * .5 + topOffset;
					}
				}
				TweenMax.to(this, time, {x: destX, y: destY, distanceOpacity: 1, ease: Expo.easeOut, onComplete:boundsCheckComplete});
			}
		}
		
		/*** UPDATE VIEWPORT ***/
		private function updateViewPort(manualResize:Boolean = false):void
		{
			checkBounds(-1, manualResize);
		}
		
		// ACCESSOR INTERFACE ============================================================
		//=============================================================================
		/*** getBitmapData ***/
		public function getBitmapData():BitmapData  { return canvasBitmap.bitmapData; }
		
		/*** SET BITMAP DATA **/
		public function setBitmapData(bmd:ImageBitmapData, disposePrevBitmapData:Boolean = false, fitInBox:Boolean = true):void {
			if (isHidden) {
				if (rotationData != null) {
					TweenMax.killTweensOf(rotationData);
				}
				TweenMax.killTweensOf(this);
			}

			var oldBmd:ImageBitmapData = canvasBitmap.bitmapData as ImageBitmapData;
			canvasBitmap.bitmapData = bmd;
			canvasBitmap.smoothing = true;

			if (disposePrevBitmapData && oldBmd != null) {
				if (oldBmd.name == "LightBox.emptyImage" || oldBmd.name == "LightBox.showPreview") {
					oldBmd.dispose();
				} else {
					ImageManager.unloadImage(oldBmd.name);
				}
			}

			if (bmd != null) {
				canvasBitmap.scaleX = canvasBitmap.scaleY = 1;
				originalWidth = canvasBitmap.width;
				originalHeight = canvasBitmap.height;
				const p:Number = (originalHeight * originalWidth);
				const b:Number = 16000000 / p;
				_maScale = Math.sqrt(b);
				_maxScale = Math.sqrt(b);	// auto max scale detect 
				if (fitInBox) {
					scaleX = scaleY = 0.0000001;
				}
			} else {
				_maxScale = 0;
				scaleX = scaleY = 1;
			}
			if (bmd) {
				checkBounds(0);
			}
		}
		
		/** ADD BITMAP WITH ANIMATION **/
		public function setBitmapDataWithTransition(bmd:BitmapData, showDirection:int = -1, animate:Boolean = false):void
		{

			if (isHidden)
			{
				if (rotationData != null)
				{
					TweenMax.killTweensOf(rotationData);
				}
				TweenMax.killTweensOf(this);
			}
			
			var oldBmd:ImageBitmapData = canvasBitmap.bitmapData as ImageBitmapData;
			canvasBitmap.bitmapData = bmd;
			canvasBitmap.smoothing = true;
			if (oldBmd != null)
			{
				oldBmd.dispose();
			}
			
			if (bmd != null)
			{
				originalWidth = canvasBitmap.width;
				originalHeight = canvasBitmap.height;
				
				const initScale:Number = getMinScale(originalWidth, originalHeight, _viewWidth, _viewHeight);
				this.scaleX = this.scaleY = initScale;
				this.y = (_viewHeight - originalHeight * initScale) * .5 + topOffset;
				
				const p:Number = (originalHeight * originalWidth);
				const b:Number = 16000000 / p;
				_maScale = Math.sqrt(b);
				_maxScale = Math.sqrt(b);	// auto max scale detect 
				
				var animationTime:Number = 0.4;
				if (animate == true)
				{
					if (showDirection == -1)
					{
						// from left
						this.x = -originalWidth * initScale + leftOffset;
					}
					else
					{
						// from left
						this.x = _viewWidth + leftOffset;
					}
				}
				else
				{
					animationTime = 0;
				}

				checkBounds(animationTime);
			}
		}
		
		/*** SET SIZE **/
		public function setViewportSize(_w:Number, _h:Number):void
		{

			_viewWidth = _w;
			_viewHeight = _h;
			updateViewPort(false);
		}
		
		/*** DISPOSE **/
		public function destroy():void
		{

			TweenMax.killDelayedCallsTo(setActivityStopped);
			removeTouchEvents();
			//clearEvents();
			stageRef.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			
			if (canvasBitmap.bitmapData != null)
			{
				canvasBitmap.bitmapData.dispose();
				removeChild(canvasBitmap);
				canvasBitmap = null;
			}
			touchesDictionary = null;
			_downMatrix = null;
			downPointsIDs = null;
			touchStartCallback = null;
			touchEndCallback = null;

		}
		
		// UTILS METHODS ===============================================================
		//=============================================================================
		
		/** FIT INTO RECTANGLE **/
		public function fitIntoRect(_matrix:Matrix, objWidth:Number, objHeight:Number, fitWidth:Number, fitHeight:Number, fillRect:Boolean = false):Matrix
		{

			const matrix:Matrix = _matrix;
			var sX:Number = fitWidth / objWidth;
			var sY:Number = fitHeight / objHeight;
			var rD:Number = objWidth / objHeight;
			var rR:Number = fitWidth / fitHeight;
			var sH:Number = fillRect ? sY : sX;
			var sV:Number = fillRect ? sX : sY;
			var s:Number = rD >= rR ? sH : sV;
			var w:Number = objWidth * s;
			var h:Number = objHeight * s;
			
			var tX:Number = 0.0;
			var tY:Number = 0.0;
			//CENTRATE		
			tX = 0.5 * (w - fitWidth);
			tY = 0.5 * (h - fitHeight);
			matrix.scale(s, s);
			matrix.translate(-tX, -tY);
			return matrix;
		}
		
		//Matrix helper to calculate position and scale
		public function deltaMatrixArray():Matrix
		{

			if (_touchPoints[1] && _touchPoints[3])
			{
				return deltaMatrix();
			}
			else
			{
				const pp:Point = _touchPoints[2];
				const d:Point = pp.subtract(_touchPoints[0]);
				return new Matrix(1, 0, 0, 1, d.x, d.y);
			}
		}
		
		private function deltaMatrix():Matrix
		{

			const m1:Matrix = matrixFromBaseLineAdvanced(tempMatrix3, _touchPoints[0], _touchPoints[1]);
			const m2:Matrix = matrixFromBaseLineAdvanced(tempMatrix4, _touchPoints[2], _touchPoints[3]);
			if ((!m1) || (!m2)) return null;
			m1.invert();
			m1.concat(m2);
			if (_maxScale > 0 && _highestDelta > _initDistanceTwoPoints * _maxScale) return null;
			else if (_minScale < 1 && _highestDelta < _initDistanceTwoPoints * _minScale) return null;
			return m1;
		}
		
		private function matrixFromBaseLineAdvanced(m:Matrix, p1:Point, p2:Point, scale:Number = 0):Matrix
		{
			const delta:Point = p2.subtract(p1);
			const _absX:Number = Math.abs(delta.x);
			const _absY:Number = Math.abs(delta.y);
			_highestDelta = (_absX > _absY) ? _absX : _absY;
			m.a = _highestDelta;
			m.b = 0;
			m.c = 0;
			m.d = _highestDelta;
			m.tx = p1.x;
			m.ty = p1.y;
			return m;
		}
		
		/*** enable ***/
		public final function enable():void
		{
			enabled = true;
		}
		
		/*** disable ***/
		public final function disable():void
		{
			enabled = false;
		}
		
		/*** fitToViewPort ***/
		public final function fitToViewPort():void
		{
			scaleX = scaleY = 0.0000001;
			checkBounds(0);
		}
		
		/** POINTS FACTORY **/
		private function getFreePoint(__x:Number = 0, __y:Number = 0):Point
		{

			if (pointsPool.length > 0)
			{
				var p:Point = pointsPool.pop();
				p.x = __x;
				p.y = __y;
				return p;
			}
			else
			{
				return new Point(__x, __y);
			}
		}
		
		public function setScaleMode(value:int):void
		{
			_scaleMode = value;
		}
		
		public function clear():void
		{
			if (canvasBitmap && canvasBitmap.bitmapData)
			{
				canvasBitmap.bitmapData.dispose();
				canvasBitmap.bitmapData = null;
			}
		}
		
		public function setOrientation(orientation:String):void
		{
			this.orientation = orientation;
		}
		
		public function animateImageRotation(w:int, h:int, currentRotation:Number, newRotation:Number):void 
		{

			if (rotatioinAnimationPlaying)
			{
				pendingAnimationData = new Object();
				pendingAnimationData.width = w;
				pendingAnimationData.height = h;
				pendingAnimationData.currentRotation = currentRotation;
				pendingAnimationData.newRotation = newRotation;
				
				return;
			}
			
			rotatioinAnimationPlaying = true;
			removeTouchEvents();
			
			_viewWidth = w;
			_viewHeight = h;
			
			var initCenter:Point;
			var endPoint:Point;
			
			var stageWidth:int = MobileGui.stage.fullScreenWidth;
			var stageHeight:int = MobileGui.stage.fullScreenHeight;
			
			if (Math.abs(Math.abs(currentRotation) - Math.abs(newRotation)) == 90 || Math.abs(Math.abs(currentRotation) - Math.abs(newRotation)) == -90)
			{
				if (newRotation == 0)
				{
					initCenter = new Point( -x + stageHeight * .5, -y + stageWidth * .5);
					endPoint = new Point(stageWidth*.5 - initCenter.x, stageHeight*.5 - initCenter.y);
				}
				else
				{
					initCenter = new Point( -x + stageWidth * .5, -y + stageHeight * .5);
					endPoint = new Point(stageHeight*.5 - initCenter.x, stageWidth*.5 - initCenter.y);
				}
				
			}
			else if (Math.abs(Math.abs(currentRotation) - Math.abs(newRotation)) == 180 || Math.abs(Math.abs(currentRotation) - Math.abs(newRotation)) == 0)
			{
				endPoint = new Point(x, y);
			}
			
			var centerPoint:Point;
			if (currentRotation == 90 || currentRotation == -90)
			{
				centerPoint = new Point(stageHeight * .5, stageWidth * .5);
			}
			else
			{
				centerPoint = new Point(stageWidth * .5, stageHeight * .5);
			}
			centerPoint = new Point(stageWidth * .5, stageHeight * .5);
			
			var endRotation:Number = 0;
			rotation = endRotation;
			x = endPoint.x;
			y = endPoint.y;
			
			var mat:Matrix = transform.matrix.clone();
			var matOriginal:Matrix = transform.matrix.clone();
			centerPoint = globalToLocal(centerPoint);
			MatrixTransformer.rotateAroundInternalPoint(mat, centerPoint.x, centerPoint.y, currentRotation - newRotation);
			transform.matrix = mat;
			
			rotationData = new Object();
			rotationData.rotation = this.rotation;
			rotationData.matrix = matOriginal;
			rotationData.rotationPoint = centerPoint.clone();
			
			TweenMax.to(rotationData, 0.3, {rotation:endRotation, onUpdate:updateItemRotation, onComplete:rotateAnimationComplete} );

		}
		
		private function updateItemRotation():void 
		{

			var matrix:Matrix = rotationData.matrix.clone();
			MatrixTransformer.rotateAroundInternalPoint(matrix, rotationData.rotationPoint.x, rotationData.rotationPoint.y, rotationData.rotation);
			transform.matrix = matrix;
			matrix = null;

		}
		
		private function rotateAnimationComplete():void 
		{

			addTouchEvents();
			
			rotationData.matrix = null;
			rotationData = null;
			rotatioinAnimationPlaying = false;
			
			checkBounds();

		}
		
		private function boundsCheckComplete():void
		{
			inAnimation = false;
			if (pendingAnimationData != null)
			{
				animateImageRotation(
										pendingAnimationData.width,
										pendingAnimationData.height,
										pendingAnimationData.currentRotation,
										pendingAnimationData.newRotation);
				
				pendingAnimationData = null;
			}

		}
		
		private function clearRotateAnimation():void 
		{

			TweenMax.killTweensOf(this);
			
			pendingAnimationData = null;
			
			if (rotationData != null)
			{
				TweenMax.killTweensOf(rotationData);
				rotationData.matrix = null;
				rotationData = null;
			}
			
			rotatioinAnimationPlaying = false;

		}
	}
}