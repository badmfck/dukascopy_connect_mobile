package com.dukascopy.connect.gui.lightbox 
{
	import flash.display.Stage;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ZoomPanContainerExtended extends ZoomPanContainer
	{
		
		private var _allowHide:Boolean = true;
		
		public function ZoomPanContainerExtended(_stageRef:Stage, _maxSc:Number = 0, _minSc:Number = 0) 
		{
			super(_stageRef, _maxSc, _minSc);
		}
		
		override protected function allowThrowHide():Boolean {
		
			if (_allowHide)
			{
				return super.allowThrowHide()
			}
			return false;
		}
		
		public function setAllowHide(value:Boolean):void 
		{
			_allowHide = value;
		}
		
		public function getViewportRectForImage():Rectangle 
		{
			return new Rectangle((leftOffset-x)/scaleX, (topOffset-y)/scaleX, viewWidth/scaleX, viewHeight/scaleX);
		}
	}
}