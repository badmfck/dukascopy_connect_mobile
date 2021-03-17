package com.dukascopy.connect.gui.progress 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.shapes.Box;
	import com.dukascopy.connect.screens.call.IProgressIndicator;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quint;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Alexey
	 */
	public class ProgressNavigator extends Sprite implements IProgressIndicator
	{
		
		private var _currentStep:int = -1;
		
		private var  _stepsCount:int = 2;
		
		private var _viewWidth:int = 400;
		private var _viewHeight:int = 50;
		
		private var checkpointsArray:Array = [];
		private var  pool:Array = [];
		
	//	private var progressBar:Box = new Box(0x78C043, 100, 10, 1);
	//	private var progressBg:Box = new Box(0xc3c3c3, 100, 10, 1);
		private var progressBar:Box = new Box(0x171A23, 100, 10, 1);
		private var progressBg:Box = new Box(0x171A23, 100, 10, 1);
		
		private var _isDisposed:Boolean = false;
		
		public function ProgressNavigator() 
		{
			addChild(progressBg);
			addChild(progressBar);
			progressBg.radius = Config.MARGIN;
			progressBar.radius = Config.MARGIN;
			this.mouseChildren = false;
		}
		
		// Set Steps COUNT 
		public function setStepsCount(count:int):void {
			if (_isDisposed) return;
			if (count < 2) {
				//trace(this, " you cannot use progres with step count less than 2");
				return;
			}
			_stepsCount = count;			
			removeAllpoints();
			createPoints();
			positionPoints();
			updatePointsState(false);
		}
		
		// Select CURRENT Step 
		public function selectStep(step:Number, animate:Boolean):void
		{
			if (_isDisposed) return;
			
			if (_currentStep != step) {
				_currentStep = step;
				updateSelection(true);
				updatePointsState();
			}				
		}
		
		// Update Step Selection
		private function updateSelection(useAnimation:Boolean = true):void 
		{
			if (_isDisposed) return;
			var destWidth:int = 0;
			// no progress at all
			if (_currentStep <0) {
				
			}else if (_currentStep >= _stepsCount) {
				// all complete
				destWidth = _viewWidth;	
				
			}else {
				// select till step 
				destWidth = _currentStep * (_viewWidth /( _stepsCount - 1));
			}			
			
			TweenMax.killTweensOf(progressBar);
			if(useAnimation){
				TweenMax.to(progressBar, .3, { width:destWidth, ease:Quint.easeInOut } );
			}else {
				progressBar.width = destWidth;
			}
		}
		
		// TODO optimize all Loops 
		
		// Remove POINTS
		private function removeAllpoints():void
		{
			var item:CheckPoint;
			var l:int = checkpointsArray.length;
			for (var i:int = 0; i < l; i++) 
			{
				item = checkpointsArray[i];
				returnToPool(item);
			}			
			checkpointsArray.length = 0;
		}
		
		// Create POINTS
		private function createPoints():void {
			if (_isDisposed) return;
			var item:CheckPoint;
			for (var i:int = 0; i < _stepsCount; i++) {
				item = getFromPool();
				item.index = i;	
				item.renderIndex();
				checkpointsArray.push(item);
				addChild(item);
			}
			
		}
		
		// Position POINTS
		private function positionPoints():void
		{
			if (_isDisposed) return;
			var item:CheckPoint;
			var stepWidth:int = _viewWidth / (_stepsCount - 1);
			var l:int = checkpointsArray.length;
			for (var i:int = 0; i < l; i++) 
			{
				item = checkpointsArray[i];
				item.x = i * stepWidth;
				item.y = _viewHeight * .5;
			}			
		}
		
		// Select POINTS
		private function updatePointsState(useAnimation:Boolean = true):void
		{
			if (_isDisposed) return;
			var item:CheckPoint;
			var l:int = checkpointsArray.length;
			
			var isCurrent:Boolean = false;
			var isChecked:Boolean = false;
			var isUnchecked:Boolean = false;
			var state:int = -1;
			
			for (var i:int = 0; i < l; i++) {
				
				//state = i<_currentStep?CheckPoint.STATE_UNCHECKED:i>_currentStep?CheckPoint.STATE_CHECKED:CheckPoint.STATE_CURRENT;
				isCurrent = (i == _currentStep);
				isChecked = i > _currentStep;
				isUnchecked = i < currentStep;
				state = isCurrent?CheckPoint.STATE_CURRENT:isChecked?CheckPoint.STATE_CHECKED:CheckPoint.STATE_UNCHECKED;
				item = checkpointsArray[i];
				item.setState(state, useAnimation);			
				
			}			
			
		}
			
		// GET fom Points POOL 
		private function getFromPool():CheckPoint {
			if (pool.length > 0) {
				return pool.pop();
			}else {
				return new CheckPoint();	
			}
		}
		
		// Return Object to Points Pool
		private function returnToPool(item:CheckPoint):void	{
			item.reset();
			pool.push(item);			
		}
		
		// Dispose Pool of Points Objects
		private function disposePool():void
		{
			// TODO always remove all points before call this
			removeAllpoints();
			var item:CheckPoint;
			for (var i:int = 0; i < pool.length; i++) {
				item = pool[i];
				item.dispose();
				item = null;
			}
			pool = [];
		}
		
		// Dispose
		public function dispose():void
		{
			if (_isDisposed)
				return;
				
			// buttons pool with array
			disposePool();			
			
			// bg 
			UI.destroy(progressBg);
			progressBg = null;
			// bar line 
			TweenMax.killTweensOf(progressBar);
			UI.destroy(progressBar);
			progressBar = null;
			
			// base
			if (this.parent && this.parent != null) {
				this.parent.removeChild(this);	
			}
 			_isDisposed = true;
		}
		
		public function setSize(width:int, height:int):void
		{
			_viewWidth = width;
			_viewHeight = height;
			updateViewPort();
		}
		
		public function get selectedCircleRadius():int
		{
			return CheckPoint.SIZE*1.5;
		}
		
		private function updateViewPort():void 
		{
			if (_isDisposed) return;
			progressBg.width = _viewWidth;
			progressBg.height = 8;
			progressBg.y  = (_viewHeight - progressBg.height) * .5;
			
			progressBar.height = 8;
			progressBar.y  = (_viewHeight- progressBar.height)*.5;
			
			positionPoints();		
			updateSelection(false);
		}
		
		public function get currentStep():int 	{return _currentStep;}
	}
}